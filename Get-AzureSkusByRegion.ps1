<#
.SYNOPSIS
    Refresh the per-region SKU snapshot consumed by Score-AzureRegionFit.ps1.

.DESCRIPTION
    Emits a canonical JSON snapshot mapping every SKU of a curated set of
    Azure resource providers to every region it is available in, plus a
    human-readable Markdown breakdown per geography group.

    The catalogue (Tier 1, 11 providers) was validated empirically because
    ARM does not expose a uniform SKU-by-region API. Three endpoint shapes
    are dispatched by the script:

      Shape A    /providers/{ns}/skus?api-version=X
                 One call per provider, returns the full SKU x region matrix.
                 Providers: ApiManagement, Compute, Storage, Cache,
                            CognitiveServices, Kusto, Synapse,
                            MachineLearningServices.

      Shape B    /providers/Microsoft.Web/geoRegions?api-version=X&sku=SKU
                 One call per SKU in the App Service basket; returns the
                 regions where that SKU is supported.
                 Providers: Web (App Service + Functions + Logic Apps).

      Shape C    /providers/{ns}/locations/{loc}/capabilities?api-version=X
                 One call per region; extracts the top-level supported
                 editions / SKU tiers.
                 Providers: Sql, DBforPostgreSQL.

    Output files:

      data/skus-by-region.json          Canonical snapshot consumed by
                                        Score-AzureRegionFit.ps1.
      outputs/skus-by-region/<geo>/
        skus-by-<geo>.md                Per-region SKU tables, one section
                                        per provider (mirrors the shape of
                                        the Learn 'API Management region
                                        availability' page).
        skus-by-<geo>.csv               Long-form CSV: one row per
                                        (provider, sku, region).

    Providers explicitly out of scope in this cut, deferred to a backlog
    issue for per-provider endpoint research: DBforMySQL, EventHub,
    ServiceBus, SignalRService, App (Container Apps), KeyVault, Search,
    Batch, DataFactory, DocumentDB.

.PARAMETER GeographyGroup
    Azure geography group to render as human-readable output (default
    'Europe'). Case-insensitive. The canonical JSON always covers all
    regions the SKUs endpoints return; -GeographyGroup only affects the
    Markdown/CSV outputs under outputs/skus-by-region/<geo>/.

.PARAMETER Provider
    Optional filter: one or more provider namespaces to include. Defaults
    to the full Tier 1 catalogue (11 providers).

.PARAMETER SubscriptionId
    Subscription to use. If omitted, uses the currently-selected 'az'
    subscription. SKU endpoints are subscription-agnostic in payload but
    the URL scope is /subscriptions/{sub}/...

.PARAMETER OutputDirectory
    Root directory for outputs. Default: current directory. The script
    writes to <OutputDirectory>/data/skus-by-region.json and
    <OutputDirectory>/outputs/skus-by-region/<geo>/.

.PARAMETER SkipMarkdown
    Skip the human-readable outputs and only write data/skus-by-region.json.

.PARAMETER List
    List the Tier 1 catalogue (providers, endpoint shape, api-version) and
    exit. No calls made.

.EXAMPLE
    ./Get-AzureSkusByRegion.ps1
    # Refreshes data/skus-by-region.json and emits Europe Markdown/CSV.

.EXAMPLE
    ./Get-AzureSkusByRegion.ps1 -GeographyGroup 'UK'
    # Same as above but Markdown/CSV covers UK regions.

.EXAMPLE
    ./Get-AzureSkusByRegion.ps1 -Provider Microsoft.ApiManagement
    # Refresh only APIM's block in data/skus-by-region.json (merged with
    # any existing snapshot; other providers are preserved).

.EXAMPLE
    ./Get-AzureSkusByRegion.ps1 -List
    # Print the catalogue and exit.

.NOTES
    Requires: Azure CLI (`az`) on PATH, and PowerShell 5.1+ (or PowerShell
    7+ on any OS). You must be logged in ('az login').

    Version: 1.0.0
    License: MIT
#>
[CmdletBinding()]
param(
    [string]$GeographyGroup = 'Europe',
    [string[]]$Provider,
    [string]$SubscriptionId,
    [string]$OutputDirectory = (Get-Location).Path,
    [switch]$SkipMarkdown,
    [switch]$List
)

$ErrorActionPreference = 'Stop'

try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding            = [System.Text.Encoding]::UTF8
} catch { }

# ------------------------------------------------------------------ helpers --

function Test-Prereq {
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        throw "Azure CLI ('az') is not on PATH. Install from https://learn.microsoft.com/cli/azure/install-azure-cli"
    }
    $acct = az account show 2>$null | ConvertFrom-Json
    if (-not $acct) { throw "Not signed in. Run 'az login' first." }
    return $acct
}

function Set-ActiveSubscription([string]$SubId) {
    if ($SubId) {
        Write-Host "Setting subscription to $SubId ..." -ForegroundColor Cyan
        az account set --subscription $SubId | Out-Null
    }
    return (az account show | ConvertFrom-Json)
}

function ConvertTo-Slug([string]$s) {
    ($s.ToLowerInvariant() -replace '\s+','-' -replace '[^a-z0-9\-]','' -replace '-+','-').Trim('-')
}

function Get-NormalizedLocation([string]$s) {
    if ($null -eq $s) { return '' }
    ($s -replace '\s','').ToLowerInvariant()
}

function Invoke-AzRestWithRetry {
    param(
        [Parameter(Mandatory)][string]$Uri,
        [int]$MaxAttempts = 4
    )
    $attempt = 0
    while ($true) {
        $attempt++
        $errFile = [System.IO.Path]::GetTempFileName()
        try {
            # Send stderr to file so warnings ("az rest sometimes writes to
            # stderr with a valid JSON body on stdout") don't corrupt the
            # JSON parse.
            $raw = az rest --method get --uri $Uri 2>$errFile
        } finally {
            $errText = if (Test-Path $errFile) { Get-Content $errFile -Raw } else { '' }
            Remove-Item $errFile -ErrorAction SilentlyContinue
        }
        $text = ($raw -join "`n")

        $json = $null
        try { $json = $text | ConvertFrom-Json -ErrorAction Stop } catch { }
        if ($json) { return $json }

        $combined = "$errText`n$text"
        $shouldRetry = ($attempt -lt $MaxAttempts) -and (
            $combined -match 'TooManyRequests|429' -or
            $combined -match 'InternalServerError|500|502|503|504' -or
            $combined -match 'timed out|timeout'
        )
        if (-not $shouldRetry) {
            $short = ($combined -split "`n" | Select-Object -First 1)
            throw "az rest failed after $attempt attempt(s): $Uri -- $short"
        }
        $sleep = [Math]::Min(30, [Math]::Pow(2, $attempt))
        Write-Host ("    Transient failure (attempt {0}/{1}), sleeping {2}s ..." -f $attempt, $MaxAttempts, $sleep) -ForegroundColor DarkYellow
        Start-Sleep -Seconds $sleep
    }
}

# --------------------------------------------------------- the catalogue --

# 11-provider Tier 1 catalogue. Each entry records:
#   Shape      A | B | C
#   ApiVersion Verified 2026-07-13
#   Category   Broad classification for the Markdown grouping
#   Basket     (Shape B only) SKU names to iterate
#
# See docs/PROVIDERS-SKU-CATALOG.md for endpoint quirks per provider.
function Get-SkuCatalogue {
    return [ordered]@{
        'Microsoft.ApiManagement'          = @{ Shape='A'; ApiVersion='2024-05-01';         Category='Integration' }
        'Microsoft.Compute'                = @{ Shape='A'; ApiVersion='2024-07-01';         Category='Compute' }
        'Microsoft.Storage'                = @{ Shape='A'; ApiVersion='2023-05-01';         Category='Storage' }
        'Microsoft.Cache'                  = @{ Shape='A'; ApiVersion='2024-11-01';         Category='Databases' }
        'Microsoft.CognitiveServices'      = @{ Shape='A'; ApiVersion='2024-10-01';         Category='AI + ML' }
        'Microsoft.Kusto'                  = @{ Shape='A'; ApiVersion='2024-04-13';         Category='Analytics' }
        'Microsoft.Synapse'                = @{ Shape='A'; ApiVersion='2021-06-01';         Category='Analytics' }
        'Microsoft.MachineLearningServices'= @{ Shape='A'; ApiVersion='2024-10-01';         Category='AI + ML' }
        'Microsoft.Web'                    = @{ Shape='B'; ApiVersion='2023-12-01';         Category='Web'
            Basket = @('FREE','SHARED','BASIC','STANDARD','PREMIUM','PREMIUMV2','PREMIUMV3','PREMIUMMV3',
                       'ISOLATED','ISOLATEDV2','DYNAMIC','ELASTICPREMIUM','FLEXCONSUMPTION','WORKFLOWSTANDARD') }
        'Microsoft.Sql'                    = @{ Shape='C'; ApiVersion='2023-08-01-preview'; Category='Databases' }
        'Microsoft.DBforPostgreSQL'        = @{ Shape='C'; ApiVersion='2024-08-01';         Category='Databases' }
    }
}

# ------------------------------------------------- endpoint-shape dispatch --

# Shape A: single call returns the full SKU x region matrix.
# Response: { "value": [ { "name": "...", "tier": "...", "locations": ["uksouth",...] }, ... ] }
function Get-SkusShapeA {
    param([Parameter(Mandatory)][string]$Namespace, [Parameter(Mandatory)][string]$ApiVersion, [Parameter(Mandatory)][string]$SubId)
    $uri = "https://management.azure.com/subscriptions/$SubId/providers/$Namespace/skus?api-version=$ApiVersion"
    Write-Host ("  Shape A: {0} ..." -f $Namespace) -ForegroundColor DarkCyan
    $resp = Invoke-AzRestWithRetry -Uri $uri
    $skus = @{}
    foreach ($item in @($resp.value)) {
        $name = $item.name
        if (-not $name) { continue }
        if (-not $skus.ContainsKey($name)) {
            $skus[$name] = [ordered]@{
                name      = $name
                tier      = $item.tier
                locations = New-Object System.Collections.Generic.HashSet[string]
            }
        }
        foreach ($loc in @($item.locations)) {
            if ($loc) { [void]$skus[$name].locations.Add((Get-NormalizedLocation $loc)) }
        }
    }
    # Normalise sets to sorted arrays.
    $out = foreach ($k in $skus.Keys) {
        [pscustomobject]@{
            name      = $skus[$k].name
            tier      = $skus[$k].tier
            locations = @($skus[$k].locations | Sort-Object)
        }
    }
    return @($out | Sort-Object name)
}

# Shape B: one call per SKU basket entry; response lists regions supporting that SKU.
# Response: { "value": [ { "name": "UK South", ... }, ... ] }
function Get-SkusShapeB-Web {
    param([Parameter(Mandatory)][string]$ApiVersion, [Parameter(Mandatory)][string]$SubId, [Parameter(Mandatory)][string[]]$Basket)
    Write-Host ("  Shape B: Microsoft.Web ({0} SKUs) ..." -f $Basket.Count) -ForegroundColor DarkCyan
    $out = foreach ($sku in $Basket) {
        $uri = "https://management.azure.com/subscriptions/$SubId/providers/Microsoft.Web/geoRegions?api-version=$ApiVersion&sku=$sku"
        try {
            $resp = Invoke-AzRestWithRetry -Uri $uri
            $locs = @($resp.value | ForEach-Object { Get-NormalizedLocation $_.name } | Where-Object { $_ } | Sort-Object -Unique)
            Write-Host ("    {0,-16} -> {1} region(s)" -f $sku, $locs.Count) -ForegroundColor DarkGray
            [pscustomobject]@{ name = $sku; tier = $null; locations = $locs }
        } catch {
            Write-Host ("    {0,-16} -> ERROR: {1}" -f $sku, $_.Exception.Message) -ForegroundColor DarkYellow
        }
    }
    return @($out | Where-Object { $_ } | Sort-Object name)
}

# Shape C: one call per region; extract top-level supported editions / tiers.
# For Microsoft.Sql: response.supportedManagedInstanceVersions[].supportedEditions[].name
#                    response.supportedServerVersions[].supportedEditions[].name
# For Microsoft.DBforPostgreSQL: response.value[].supportedFlexibleServerEditions[].name
function Get-SkusShapeC {
    param(
        [Parameter(Mandatory)][string]$Namespace,
        [Parameter(Mandatory)][string]$ApiVersion,
        [Parameter(Mandatory)][string]$SubId,
        [Parameter(Mandatory)][object[]]$Regions
    )
    Write-Host ("  Shape C: {0} ({1} regions) ..." -f $Namespace, $Regions.Count) -ForegroundColor DarkCyan
    # skuName -> HashSet<normalized region>
    $skuMap = @{}
    $ok = 0; $skip = 0
    foreach ($r in $Regions) {
        $loc = $r.name
        $uri = "https://management.azure.com/subscriptions/$SubId/providers/$Namespace/locations/$loc/capabilities?api-version=$ApiVersion"
        try {
            $resp = Invoke-AzRestWithRetry -Uri $uri
        } catch {
            Write-Host ("    {0,-22} -> skipped ({1})" -f $loc, ($_.Exception.Message -split "`n" | Select-Object -First 1)) -ForegroundColor DarkGray
            $skip++
            continue
        }
        $editions = New-Object System.Collections.Generic.HashSet[string]
        switch ($Namespace) {
            'Microsoft.Sql' {
                foreach ($v in @($resp.supportedManagedInstanceVersions)) {
                    foreach ($ed in @($v.supportedEditions)) { if ($ed.name) { [void]$editions.Add("MI:$($ed.name)") } }
                }
                foreach ($v in @($resp.supportedServerVersions)) {
                    foreach ($ed in @($v.supportedEditions)) { if ($ed.name) { [void]$editions.Add("DB:$($ed.name)") } }
                }
            }
            'Microsoft.DBforPostgreSQL' {
                foreach ($v in @($resp.value)) {
                    foreach ($ed in @($v.supportedServerEditions)) { if ($ed.name) { [void]$editions.Add($ed.name) } }
                }
            }
            default { }
        }
        $normLoc = Get-NormalizedLocation $loc
        foreach ($ed in $editions) {
            if (-not $skuMap.ContainsKey($ed)) { $skuMap[$ed] = New-Object System.Collections.Generic.HashSet[string] }
            [void]$skuMap[$ed].Add($normLoc)
        }
        $ok++
    }
    Write-Host ("    {0} regions probed OK, {1} skipped" -f $ok, $skip) -ForegroundColor DarkGray
    $out = foreach ($sku in $skuMap.Keys) {
        [pscustomobject]@{
            name      = $sku
            tier      = $null
            locations = @($skuMap[$sku] | Sort-Object)
        }
    }
    return @($out | Sort-Object name)
}

# --------------------------------------------------------------- main flow --

$catalogue = Get-SkuCatalogue

if ($List) {
    Write-Host "`nTier 1 SKU catalogue:" -ForegroundColor Yellow
    $catalogue.Keys | ForEach-Object {
        $e = $catalogue[$_]
        [pscustomobject]@{
            Provider   = $_
            Shape      = $e.Shape
            ApiVersion = $e.ApiVersion
            Category   = $e.Category
        }
    } | Format-Table -AutoSize
    Write-Host "See docs/PROVIDERS-SKU-CATALOG.md for endpoint quirks per provider."
    return
}

$acct = Test-Prereq
$acct = Set-ActiveSubscription -SubId $SubscriptionId
$SubId = $acct.id
Write-Host ("Subscription: {0} ({1})" -f $acct.name, $acct.id) -ForegroundColor Green
Write-Host ("Tenant:       {0}" -f $acct.tenantId) -ForegroundColor Green

# Filter catalogue by -Provider if supplied.
$targets = if ($Provider) {
    $unknown = $Provider | Where-Object { -not $catalogue.Contains($_) }
    if ($unknown) { throw "Unknown provider(s): $($unknown -join ', '). Run -List to see the catalogue." }
    $Provider
} else {
    @($catalogue.Keys)
}
Write-Host ("Targeting {0} provider(s)." -f $targets.Count) -ForegroundColor Green

# Fetch regions for Shape C iteration (all non-Stage regions across all geographies).
Write-Host "Fetching regions ..." -ForegroundColor Cyan
$allLocations = az account list-locations -o json | ConvertFrom-Json
$regionsAll = $allLocations | Where-Object { $_.metadata -and $_.metadata.regionType -eq 'Physical' }

# Prepare output paths.
if (-not (Test-Path $OutputDirectory)) { New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null }
$OutputDirectory = (Resolve-Path $OutputDirectory).Path
$dataDir = Join-Path $OutputDirectory 'data'
$geoSlug = ConvertTo-Slug $GeographyGroup
$mdDir   = Join-Path $OutputDirectory (Join-Path 'outputs' (Join-Path 'skus-by-region' $geoSlug))
New-Item -ItemType Directory -Force -Path $dataDir | Out-Null
if (-not $SkipMarkdown) { New-Item -ItemType Directory -Force -Path $mdDir | Out-Null }

# Load existing snapshot (if any) so a partial refresh only touches the
# requested providers.
$snapshotPath = Join-Path $dataDir 'skus-by-region.json'
$snapshot = if (Test-Path $snapshotPath) {
    try { Get-Content $snapshotPath -Raw | ConvertFrom-Json -Depth 12 } catch { $null }
} else { $null }

if (-not $snapshot) {
    $snapshot = [pscustomobject]@{
        snapshot_date    = ''
        geography_group  = $GeographyGroup
        endpoint_shapes  = [pscustomobject]@{}
        api_versions     = [pscustomobject]@{}
        providers        = [pscustomobject]@{}
    }
}

# Ensure the snapshot has all the expected top-level fields (upgrades from older snapshots).
foreach ($f in 'snapshot_date','geography_group','endpoint_shapes','api_versions','providers') {
    if (-not ($snapshot.PSObject.Properties.Name -contains $f)) {
        $default = switch ($f) {
            'snapshot_date'   { '' }
            'geography_group' { $GeographyGroup }
            default           { [pscustomobject]@{} }
        }
        $snapshot | Add-Member -NotePropertyName $f -NotePropertyValue $default
    }
}
# Strip sub_id if a legacy snapshot has it (subscription-agnostic metadata; don't leak customer sub).
if ($snapshot.PSObject.Properties['sub_id']) { $snapshot.PSObject.Properties.Remove('sub_id') }

# Helper: set a property on a PSCustomObject (add-or-update).
function Set-Prop {
    param($Obj, [string]$Name, $Value)
    if ($Obj.PSObject.Properties[$Name]) { $Obj.$Name = $Value }
    else { $Obj | Add-Member -NotePropertyName $Name -NotePropertyValue $Value }
}

Write-Host "`nProbing SKU endpoints ..." -ForegroundColor Cyan
$stats = @()
foreach ($ns in $targets) {
    $entry = $catalogue[$ns]
    $skus  = $null
    try {
        switch ($entry.Shape) {
            'A' { $skus = Get-SkusShapeA -Namespace $ns -ApiVersion $entry.ApiVersion -SubId $SubId }
            'B' { $skus = Get-SkusShapeB-Web -ApiVersion $entry.ApiVersion -SubId $SubId -Basket $entry.Basket }
            'C' { $skus = Get-SkusShapeC -Namespace $ns -ApiVersion $entry.ApiVersion -SubId $SubId -Regions $regionsAll }
            default { throw "Unknown shape '$($entry.Shape)' for $ns" }
        }
    } catch {
        Write-Host ("  {0} FAILED: {1}" -f $ns, $_.Exception.Message) -ForegroundColor Red
        continue
    }

    # Record in the snapshot.
    Set-Prop $snapshot.endpoint_shapes $ns $entry.Shape
    Set-Prop $snapshot.api_versions    $ns $entry.ApiVersion
    Set-Prop $snapshot.providers $ns ([pscustomobject]@{
        endpoint_shape = $entry.Shape
        category       = $entry.Category
        skus           = @($skus)
        sku_count      = @($skus).Count
        region_count   = ((@($skus).locations | ForEach-Object { $_ }) | Sort-Object -Unique).Count
    })

    $stats += [pscustomobject]@{
        Provider = $ns
        Shape    = $entry.Shape
        SKUs     = @($skus).Count
        Regions  = $snapshot.providers.$ns.region_count
    }
}

$snapshot.snapshot_date   = (Get-Date -Format 'yyyy-MM-dd')
$snapshot.geography_group = $GeographyGroup

# Write canonical JSON.
$snapshot | ConvertTo-Json -Depth 12 | Set-Content -Path $snapshotPath -Encoding UTF8
Write-Host ("`nWrote {0}" -f $snapshotPath) -ForegroundColor Green
$stats | Format-Table -AutoSize | Out-String | Write-Host

if ($SkipMarkdown) { return }

# ---------- human-readable outputs for the selected geography ----------

$regionsGeo = $allLocations |
    Where-Object { $_.metadata -and $_.metadata.geographyGroup -and $_.metadata.geographyGroup.ToLower() -eq $GeographyGroup.ToLower() } |
    Sort-Object displayName

if (-not $regionsGeo) {
    Write-Host ("No regions match geography group '{0}' - skipping Markdown output." -f $GeographyGroup) -ForegroundColor Yellow
    return
}

Write-Host ("Generating {0} SKU tables for '{1}' ({2} regions) ..." -f $targets.Count, $GeographyGroup, $regionsGeo.Count) -ForegroundColor Cyan

$regionNorms = $regionsGeo | ForEach-Object { [pscustomobject]@{ Name=$_.name; Display=$_.displayName; Norm=(Get-NormalizedLocation $_.name) } }

# Long-form CSV: one row per (provider, sku, region-in-geography, available).
$csvRows = foreach ($ns in $targets) {
    if (-not $snapshot.providers.$ns) { continue }
    foreach ($s in $snapshot.providers.$ns.skus) {
        $normSet = @{}
        foreach ($l in $s.locations) { $normSet[$l] = $true }
        foreach ($rc in $regionNorms) {
            [pscustomobject]@{
                Provider  = $ns
                Category  = $snapshot.providers.$ns.category
                Sku       = $s.name
                Tier      = $s.tier
                Region    = $rc.Name
                RegionDisplay = $rc.Display
                Available = if ($normSet.ContainsKey($rc.Norm)) { 'yes' } else { 'no' }
            }
        }
    }
}
$csvPath = Join-Path $mdDir ("skus-by-{0}.csv" -f $geoSlug)
$csvRows | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
Write-Host "  Wrote $csvPath"

# Markdown: per-provider table with regions as columns.
$md = @()
$md += "# Azure SKUs by $GeographyGroup region"
$md += ""
$md += ("Generated: {0} | Providers: {1} | Source: Azure ARM (subscription-agnostic metadata)" -f $snapshot.snapshot_date, $targets.Count)
$md += ""
$md += "Source: ARM SKU endpoints (see docs/PROVIDERS-SKU-CATALOG.md for endpoint shapes per provider)."
$md += ""
$md += "## At a glance"
$md += ""
$md += "| Provider | Category | Endpoint | SKUs (total) | Regions in $GeographyGroup |"
$md += "|---|---|:---:|---:|---:|"
foreach ($ns in $targets) {
    if (-not $snapshot.providers.$ns) { continue }
    $inGeo = 0
    foreach ($s in $snapshot.providers.$ns.skus) {
        $intersect = $s.locations | Where-Object { $regionNorms.Norm -contains $_ }
        if (@($intersect).Count -gt 0) { $inGeo++ }
    }
    $md += ("| {0} | {1} | {2} | {3} | {4}/{5} |" -f $ns, $snapshot.providers.$ns.category, $snapshot.providers.$ns.endpoint_shape, $snapshot.providers.$ns.sku_count, $inGeo, $snapshot.providers.$ns.sku_count)
}
$md += ""

foreach ($ns in $targets) {
    if (-not $snapshot.providers.$ns) { continue }
    $md += "## $ns"
    $md += ""
    $md += ('Endpoint shape: **{0}**  |  Category: **{1}**  |  API version: `{2}`' -f $snapshot.providers.$ns.endpoint_shape, $snapshot.providers.$ns.category, $snapshot.api_versions.$ns)
    $md += ""
    $header = "| SKU | Tier | " + (($regionNorms.Display | ForEach-Object { $_ }) -join ' | ') + " |"
    $sep    = "|-----|------|" + (($regionNorms | ForEach-Object { ':---:' }) -join '|') + "|"
    $md += $header
    $md += $sep
    foreach ($s in ($snapshot.providers.$ns.skus | Sort-Object name)) {
        $normSet = @{}
        foreach ($l in $s.locations) { $normSet[$l] = $true }
        $cells = foreach ($rc in $regionNorms) { if ($normSet.ContainsKey($rc.Norm)) { 'yes' } else { '-' } }
        $md += ("| {0} | {1} | " -f $s.name, ($s.tier ?? '')) + ($cells -join ' | ') + " |"
    }
    $md += ""
}
$mdPath = Join-Path $mdDir ("skus-by-{0}.md" -f $geoSlug)
$md -join "`n" | Set-Content -Path $mdPath -Encoding UTF8
Write-Host "  Wrote $mdPath"

Write-Host "`nDone." -ForegroundColor Green
