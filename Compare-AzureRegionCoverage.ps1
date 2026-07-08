<#
.SYNOPSIS
    Compare the Azure resource types you have deployed in a source region
    against other regions to find viable multi-region targets.

.DESCRIPTION
    Answers two questions:
      1. "Are all the services I use in <SourceRegion> also available in
         <TargetRegion>?"  --> use -TargetRegion (validate mode).
      2. "Which region in <GeographyGroup> is the best match for what I have
         deployed in <SourceRegion>?"  --> omit -TargetRegion (score mode).

    How it works:
      - Uses Azure Resource Graph to inventory the resource TYPES you have
        deployed in the source region across the subscriptions you can see
        (or restrict via -SubscriptionId / -ManagementGroupId).
      - Uses ARM provider metadata (az provider list) to look up each
        resource type's list of supported regions.
      - Cross-references and produces a coverage report for each candidate
        region.

    Output files (in -OutputDirectory):
      - region-coverage-<src>.csv     Per-region coverage summary.
      - region-coverage-<src>.md      Human-readable report with gap analysis.
      - deployed-types-<src>.csv      Full inventory of RTs found in the source region.

.PARAMETER SourceRegion
    Region name (e.g. 'northeurope') whose deployments you want to reproduce.
    Case-insensitive. Required.

.PARAMETER InventoryFile
    Path to a CSV with columns 'ResourceType' and 'Instances' (matching the
    'deployed-types-<src>.csv' output shape). When set, Azure Resource Graph
    is NOT queried and this file is used as the inventory. Useful for offline
    what-if analysis or working from a pre-computed inventory.
    Overrides -Scope, -SubscriptionId, -ManagementGroupId, -TenantId.

.PARAMETER TargetRegion
    (Validate mode) Single region to check against. When set, other regions
    are ignored and the report focuses on this target.

.PARAMETER GeographyGroup
    (Score mode) Rank all regions in this geography group. Default: 'Europe'.
    Ignored when -TargetRegion is provided.

.PARAMETER Scope
    Which set of subscriptions to inventory:
      - Subscription      : one or more specific subs (default = current context).
      - Tenant            : every subscription in the target tenant your identity can see.
      - ManagementGroup   : every subscription under -ManagementGroupId.
    Default: 'Subscription'.

.PARAMETER TenantId
    (Scope=Tenant) Restrict tenant scope to this tenant ID. Defaults to the
    tenant of the currently-selected 'az' subscription. Useful when your
    identity is signed into multiple tenants.

.PARAMETER SubscriptionId
    (Scope=Subscription) One or more subscription IDs to scan.
    If Scope is Subscription and this is omitted, the currently-selected 'az' subscription is used.

.PARAMETER ManagementGroupId
    (Scope=ManagementGroup) The management group ID to scan.

.PARAMETER OutputDirectory
    Where to write outputs. Default: current directory.

.PARAMETER MinResourceCount
    Only consider resource types with at least this many instances in the
    source region. Default: 1. Useful for ignoring stragglers.

.PARAMETER IncludeStageRegions
    Include Stage/EUAP/internal regions in candidate lists. Default: excluded.

.EXAMPLE
    ./Compare-AzureRegionCoverage.ps1 -SourceRegion northeurope
    # Score every European region against your current subscription's North Europe deployments.

.EXAMPLE
    ./Compare-AzureRegionCoverage.ps1 -SourceRegion northeurope -Scope Tenant
    # Same, but inventory every subscription your identity can see in the tenant.

.EXAMPLE
    ./Compare-AzureRegionCoverage.ps1 -SourceRegion northeurope -TargetRegion swedencentral
    # Validate whether Sweden Central supports everything the current subscription runs in North Europe.

.EXAMPLE
    ./Compare-AzureRegionCoverage.ps1 -SourceRegion northeurope `
        -Scope Subscription -SubscriptionId <guid1>,<guid2>
    # Restrict inventory to specific subscriptions.

.EXAMPLE
    ./Compare-AzureRegionCoverage.ps1 -SourceRegion eastus -GeographyGroup 'US' `
        -Scope ManagementGroup -ManagementGroupId prod-mg -OutputDirectory ./out

.EXAMPLE
    ./Compare-AzureRegionCoverage.ps1 -SourceRegion northeurope `
        -InventoryFile ./example-inventory.csv -OutputDirectory ./out
    # Offline / synthetic: uses the CSV as-is, does not query Resource Graph.

.NOTES
    Requires: Azure CLI ('az') with 'resource-graph' extension, PowerShell 5.1+.
    Read-only: only queries Resource Graph and ARM metadata.

    Version: 1.0.0
    License: MIT
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$SourceRegion,

    [string]$TargetRegion,

    [string]$GeographyGroup = 'Europe',

    [ValidateSet('Subscription','Tenant','ManagementGroup')]
    [string]$Scope = 'Subscription',

    [string]$TenantId,

    [string[]]$SubscriptionId,

    [string]$ManagementGroupId,

    [string]$OutputDirectory = (Get-Location).Path,

    [string]$InventoryFile,

    [int]$MinResourceCount = 1,

    [switch]$IncludeStageRegions
)

$ErrorActionPreference = 'Stop'

# Force UTF-8 so region physical location names with accented characters (e.g. "Gävle") survive.
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch { }

# ------------------------------------------------------------------ helpers --

function Test-Prereq {
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        throw "Azure CLI ('az') is not on PATH. Install: https://learn.microsoft.com/cli/azure/install-azure-cli"
    }
    $acct = az account show 2>$null | ConvertFrom-Json
    if (-not $acct) { throw "Not signed in. Run 'az login' first." }
    $ext = az extension list --query "[?name=='resource-graph']" -o json | ConvertFrom-Json
    if (-not $ext) {
        Write-Host "Installing 'resource-graph' extension ..." -ForegroundColor Cyan
        az extension add --name resource-graph --only-show-errors | Out-Null
    }
    return $acct
}

function Get-NormalizedLocationName([string]$s) {
    if ($null -eq $s) { return '' }
    ($s -replace '\s','').ToLowerInvariant()
}

function ConvertTo-RegionSlug([string]$s) {
    ($s.ToLowerInvariant() -replace '\s+','-' -replace '[^a-z0-9\-]','' -replace '-+','-').Trim('-')
}

function Get-DeployedTypes {
    param(
        [string]$Region,
        [string]$ScopeKind,       # 'Subscription' | 'Tenant' | 'ManagementGroup'
        [string[]]$SubIds,
        [string]$MgId,
        [int]$MinCount
    )
    $kql = "Resources | where location =~ '$Region' | summarize c=count() by type | where c >= $MinCount | order by c desc"
    $args = @('graph','query','-q',$kql,'--first','1000','-o','json')
    switch ($ScopeKind) {
        'Subscription' {
            if (-not $SubIds -or $SubIds.Count -eq 0) {
                throw "Scope 'Subscription' requires at least one subscription ID."
            }
            $args += '--subscriptions'
            $args += $SubIds
        }
        'ManagementGroup' {
            if (-not $MgId) { throw "Scope 'ManagementGroup' requires -ManagementGroupId." }
            $args += @('--management-groups', $MgId)
        }
        'Tenant' {
            if (-not $SubIds -or $SubIds.Count -eq 0) {
                throw "Scope 'Tenant' requires an explicit list of tenant subscription IDs."
            }
            # ARG accepts up to 1000 subs in a single query. Chunk if larger.
            $chunkSize = 1000
            if ($SubIds.Count -le $chunkSize) {
                $args += '--subscriptions'
                $args += $SubIds
            } else {
                # Return here via chunking - handled in main flow
                $args += '--subscriptions'
                $args += ($SubIds | Select-Object -First $chunkSize)
                Write-Host ("  Note: {0} subscriptions truncated to first {1} due to ARG limit." -f $SubIds.Count, $chunkSize) -ForegroundColor Yellow
            }
        }
    }
    $resp = & az @args
    if ($LASTEXITCODE -ne 0) { throw "az graph query failed with exit code $LASTEXITCODE." }
    $parsed = $resp | Out-String | ConvertFrom-Json
    if (-not $parsed) { throw "Resource Graph query returned no response." }
    return $parsed.data
}

function Get-InScopeSubscriptions {
    param(
        [string]$ScopeKind,
        [string[]]$SubIds,
        [string]$MgId
    )
    switch ($ScopeKind) {
        'Subscription' {
            $all = az account list --query "[?state=='Enabled'].{id:id,name:name}" -o json | ConvertFrom-Json
            return $all | Where-Object { $SubIds -contains $_.id }
        }
        'Tenant' {
            return az account list --query "[?state=='Enabled'].{id:id,name:name}" -o json | ConvertFrom-Json
        }
        'ManagementGroup' {
            $kql = "ResourceContainers | where type =~ 'microsoft.resources/subscriptions' | project id=subscriptionId, name"
            $resp = az graph query -q $kql --management-groups $MgId --first 1000 -o json 2>$null | ConvertFrom-Json
            return $resp.data
        }
    }
}

function Get-ProviderResourceTypeLocations {
    Write-Host "Fetching resource provider metadata (30-60s) ..." -ForegroundColor Cyan
    $json = az provider list `
        --query "[].{ns:namespace, types:resourceTypes[].{rt:resourceType, locs:locations}}" `
        -o json
    $providers = $json | ConvertFrom-Json
    # Build: 'namespace/resourcetype' (lowercase) -> HashSet[string] of normalized locations, plus 'global' flag.
    $map = @{}
    foreach ($p in $providers) {
        foreach ($rt in $p.types) {
            $key = ($p.ns + '/' + $rt.rt).ToLowerInvariant()
            $locSet = New-Object System.Collections.Generic.HashSet[string]
            $isGlobal = $true
            if ($rt.locs) {
                foreach ($l in $rt.locs) {
                    $n = Get-NormalizedLocationName $l
                    if ($n) { [void]$locSet.Add($n); $isGlobal = $false }
                }
            }
            $map[$key] = [pscustomobject]@{
                Locations = $locSet
                IsGlobal  = $isGlobal
            }
        }
    }
    return $map
}

function Get-CandidateRegions {
    param(
        [string]$Geo,
        [string]$TargetName,
        [switch]$IncludeStage
    )
    $all = az account list-locations -o json | ConvertFrom-Json
    if ($TargetName) {
        $t = $all | Where-Object { $_.name -eq $TargetName -or $_.displayName -eq $TargetName }
        if (-not $t) { throw "Target region '$TargetName' not found. Try 'az account list-locations -o table'." }
        return @($t)
    }
    $g = $all | Where-Object {
        $_.metadata -and $_.metadata.geographyGroup -and
        $_.metadata.geographyGroup.ToLower() -eq $Geo.ToLower()
    }
    if (-not $g) {
        $groups = ($all.metadata.geographyGroup | Where-Object { $_ } | Sort-Object -Unique) -join ', '
        throw "No regions found for geography group '$Geo'. Try: $groups"
    }
    if (-not $IncludeStage) {
        $g = $g | Where-Object { $_.displayName -notmatch '\(Stage\)' -and $_.name -notmatch 'stg$' -and $_.name -notmatch 'euap$' }
    }
    return $g | Sort-Object displayName
}

function Restore-AzContext {
    if ($script:OriginalContextSub) {
        Write-Host ("Restoring original az context: {0}" -f $script:OriginalContextSub) -ForegroundColor DarkCyan
        az account set --subscription $script:OriginalContextSub 2>$null | Out-Null
        $script:OriginalContextSub = $null
    }
}

# ---------------------------------------------------------------- main flow --

trap {
    Restore-AzContext
    break
}

$acct = Test-Prereq
Write-Host ("Tenant:       {0}" -f $acct.tenantId) -ForegroundColor Green
Write-Host ("Identity:     {0}" -f $acct.user.name) -ForegroundColor Green

# ---- Inventory: from file (offline) or from Azure Resource Graph -----------
$deployed = $null
if ($InventoryFile) {
    if (-not (Test-Path $InventoryFile)) { throw "InventoryFile '$InventoryFile' not found." }
    Write-Host ("Scope:        Inventory loaded from file: {0}" -f (Resolve-Path $InventoryFile).Path) -ForegroundColor Green
    $rows = Import-Csv $InventoryFile
    $expected = @('ResourceType','Instances')
    foreach ($col in $expected) {
        if (-not ($rows[0].PSObject.Properties.Name -contains $col)) {
            throw "InventoryFile must have columns: $($expected -join ', '). Got: $($rows[0].PSObject.Properties.Name -join ', ')"
        }
    }
    $deployed = $rows | ForEach-Object {
        $n = [int]$_.Instances
        if ($n -ge $MinResourceCount) {
            [pscustomobject]@{ type = $_.ResourceType.Trim(); c = $n }
        }
    } | Where-Object { $_ }
    if (-not $deployed -or $deployed.Count -eq 0) {
        throw "No usable rows in '$InventoryFile' after applying -MinResourceCount $MinResourceCount."
    }
}
else {
    # ---- Resolve scope ----------------------------------------------------
    switch ($Scope) {
    'Subscription' {
        if (-not $SubscriptionId -or $SubscriptionId.Count -eq 0) {
            # Fall back to current 'az' subscription.
            $SubscriptionId = @($acct.id)
            Write-Host ("Scope:        Subscription (current): {0} ({1})" -f $acct.name, $acct.id) -ForegroundColor Green
        } else {
            Write-Host ("Scope:        Subscription ({0}): {1}" -f $SubscriptionId.Count, ($SubscriptionId -join ', ')) -ForegroundColor Green
        }
    }
    'Tenant' {
        $tenantForScope = if ($TenantId) { $TenantId } else { $acct.tenantId }
        $tenSubs = az account list --query "[?state=='Enabled' && tenantId=='$tenantForScope'].id" -o json | ConvertFrom-Json
        if (-not $tenSubs -or $tenSubs.Count -eq 0) {
            throw "No enabled subscriptions found in tenant '$tenantForScope'. Try 'az login --tenant $tenantForScope'."
        }
        # If our current az context isn't in that tenant, temporarily switch (ARG requires auth in the target tenant).
        if ($acct.tenantId -ne $tenantForScope) {
            $script:OriginalContextSub = $acct.id
            $switchTo = $tenSubs[0]
            Write-Host ("Switching az context to a subscription in tenant '{0}' (will be restored on exit) ..." -f $tenantForScope) -ForegroundColor DarkCyan
            az account set --subscription $switchTo | Out-Null
            $acct = az account show | ConvertFrom-Json
        }
        $script:TenantSubs = @($tenSubs)
        Write-Host ("Scope:        Tenant '{0}' ({1} enabled subscriptions accessible)" -f $tenantForScope, $script:TenantSubs.Count) -ForegroundColor Green
        if ($script:TenantSubs.Count -gt 500) {
            Write-Host ("              Large tenant. ARG queries handle up to 1000 subs/query; we're within that limit but expect a longer response.") -ForegroundColor Yellow
        }
    }
    'ManagementGroup' {
        if (-not $ManagementGroupId) {
            throw "Scope 'ManagementGroup' requires -ManagementGroupId."
        }
        Write-Host ("Scope:        Management group: {0}" -f $ManagementGroupId) -ForegroundColor Green
    }
  }

    # ---- Query Azure Resource Graph for source region inventory ---------
    Write-Host ("`nInventorying resource types in '{0}' via Azure Resource Graph ..." -f $SourceRegion) -ForegroundColor Cyan
    $subsForQuery = switch ($Scope) {
        'Subscription' { $SubscriptionId }
        'Tenant'       { $script:TenantSubs }
        default        { $null }
    }
    $deployed = Get-DeployedTypes -Region $SourceRegion -ScopeKind $Scope -SubIds $subsForQuery -MgId $ManagementGroupId -MinCount $MinResourceCount
    if (-not $deployed -or $deployed.Count -eq 0) {
        throw "No resources found in region '$SourceRegion' within the chosen scope. Check the region name and your scope."
    }
}

$srcSlug = ConvertTo-RegionSlug $SourceRegion
$totalInstances = ($deployed | Measure-Object c -Sum).Sum
Write-Host ("  {0} distinct resource types, {1} total resource instances." -f $deployed.Count, $totalInstances) -ForegroundColor Green

# Persist inventory.
if (-not (Test-Path $OutputDirectory)) { New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null }
$OutputDirectory = (Resolve-Path $OutputDirectory).Path
$deployedCsv = Join-Path $OutputDirectory ("deployed-types-{0}.csv" -f $srcSlug)
$deployed |
    Select-Object @{N='ResourceType';E={$_.type}}, @{N='Instances';E={$_.c}} |
    Sort-Object -Property Instances -Descending |
    Export-Csv -Path $deployedCsv -NoTypeInformation -Encoding UTF8
Write-Host ("  Wrote {0}" -f $deployedCsv)

# 2. Fetch provider metadata.
$rtMap = Get-ProviderResourceTypeLocations
Write-Host ("  Indexed {0} resource types across all providers." -f $rtMap.Count) -ForegroundColor Green

# Warn on RTs in inventory that don't appear in the provider metadata (rare).
$missingInMap = $deployed | Where-Object { -not $rtMap.ContainsKey($_.type.ToLowerInvariant()) }
if ($missingInMap) {
    Write-Host ("  Note: {0} deployed types have no provider metadata entry and will be treated as 'unknown':" -f $missingInMap.Count) -ForegroundColor Yellow
    $missingInMap | ForEach-Object { Write-Host ("    - {0} ({1} instances)" -f $_.type, $_.c) }
}

# 3. Determine candidate regions.
$candidates = Get-CandidateRegions -Geo $GeographyGroup -TargetName $TargetRegion -IncludeStage:$IncludeStageRegions
if ($TargetRegion) {
    Write-Host ("`nValidating single target: {0} ({1})" -f $candidates[0].displayName, $candidates[0].name) -ForegroundColor Cyan
} else {
    Write-Host ("`nScoring {0} regions in '{1}' geography ..." -f $candidates.Count, $GeographyGroup) -ForegroundColor Cyan
}

# 4. Score each candidate.
$srcNorm = Get-NormalizedLocationName $SourceRegion
$results = foreach ($cand in $candidates) {
    $tgtNorm = Get-NormalizedLocationName $cand.name
    $covered = @()
    $missing = @()
    $unknown = @()
    foreach ($d in $deployed) {
        $key = $d.type.ToLowerInvariant()
        if (-not $rtMap.ContainsKey($key)) {
            $unknown += $d
            continue
        }
        $info = $rtMap[$key]
        if ($info.IsGlobal) { $covered += $d; continue }
        if ($info.Locations.Contains($tgtNorm)) { $covered += $d } else { $missing += $d }
    }
    $totalConsidered = $covered.Count + $missing.Count
    $coveragePct = if ($totalConsidered -gt 0) { [math]::Round(100.0 * $covered.Count / $totalConsidered, 1) } else { 0 }
    $missingInstances = ($missing | Measure-Object c -Sum).Sum
    if (-not $missingInstances) { $missingInstances = 0 }
    [pscustomobject]@{
        RegionName        = $cand.name
        DisplayName       = $cand.displayName
        Physical          = $cand.metadata.physicalLocation
        RegionCategory    = $cand.metadata.regionCategory
        PairedWith        = if ($cand.metadata.pairedRegion) { $cand.metadata.pairedRegion[0].name } else { '' }
        CoveragePercent   = $coveragePct
        TypesCovered      = $covered.Count
        TypesMissing      = $missing.Count
        InstancesMissing  = $missingInstances
        TypesUnknown      = $unknown.Count
        MissingTypesList  = ($missing | Sort-Object -Property @{Expression='c';Descending=$true} |
                             ForEach-Object { "$($_.type) ($($_.c))" }) -join '; '
        UnknownTypesList  = ($unknown | ForEach-Object { $_.type }) -join '; '
        IsSource          = ($tgtNorm -eq $srcNorm)
    }
}

$results = $results | Sort-Object -Property `
    @{Expression='CoveragePercent';Descending=$true}, `
    @{Expression='InstancesMissing';Descending=$false}, `
    @{Expression='DisplayName';Descending=$false}

# 5. Emit summary CSV.
$sumCsv = Join-Path $OutputDirectory ("region-coverage-{0}.csv" -f $srcSlug)
$results | Export-Csv -Path $sumCsv -NoTypeInformation -Encoding UTF8
Write-Host ("  Wrote {0}" -f $sumCsv)

# 6. Emit markdown report.
$md = @()
$md += "# Region coverage report: source = ``$SourceRegion``"
$md += ""
$md += ("Generated: {0:yyyy-MM-dd HH:mm}" -f (Get-Date))
if ($InventoryFile) {
    $md += ("Scope: **Offline inventory** (loaded from ``{0}``)" -f (Split-Path $InventoryFile -Leaf))
} else {
    $md += ("Tenant: ``{0}``" -f $acct.tenantId)
    switch ($Scope) {
        'Subscription'    { $md += ("Scope: **Subscription** (``{0}``)" -f ($SubscriptionId -join '`, `')) }
        'Tenant'          { $md += "Scope: **Tenant** (all subscriptions visible to current identity)" }
        'ManagementGroup' { $md += ("Scope: **Management group** (``{0}``)" -f $ManagementGroupId) }
    }
}
$md += ""
$md += ("**Inventory:** {0} distinct resource types, {1} instances in ``{2}`` (min instances threshold: {3})." -f $deployed.Count, $totalInstances, $SourceRegion, $MinResourceCount)
$md += ""

if ($TargetRegion) {
    $t = $results[0]
    $md += "## Validation: ``$($t.RegionName)`` ($($t.DisplayName))"
    $md += ""
    if ($t.TypesMissing -eq 0) {
        $md += "✅ **Full coverage.** Every resource type deployed in ``$SourceRegion`` is available in ``$($t.RegionName)``."
    } else {
        $md += ("⚠️  **{0}% coverage.** {1} resource type(s) not available ({2} instances at risk):" -f $t.CoveragePercent, $t.TypesMissing, $t.InstancesMissing)
        $md += ""
        $missingList = $t.MissingTypesList -split '; '
        foreach ($m in $missingList) { $md += "- $m" }
    }
    if ($t.TypesUnknown -gt 0) {
        $md += ""
        $md += ("**Unknown types (not present in provider metadata, treat with caution):** {0}" -f $t.UnknownTypesList)
    }
} else {
    $md += "## Score ranking"
    $md += ""
    $md += "| Rank | Region | Physical | Coverage | Covered | Missing | Instances at risk |"
    $md += "| ---: | --- | --- | ---: | ---: | ---: | ---: |"
    $rank = 0
    foreach ($r in $results) {
        $rank++
        $marker = if ($r.IsSource) { ' (source)' } else { '' }
        $md += ("| {0} | ``{1}``{2} | {3} | {4}% | {5} | {6} | {7} |" -f `
            $rank, $r.RegionName, $marker, ($r.Physical -as [string]), $r.CoveragePercent, $r.TypesCovered, $r.TypesMissing, $r.InstancesMissing)
    }
    $md += ""
    $md += "## Detail per region"
    $md += ""
    $rank = 0
    foreach ($r in $results) {
        $rank++
        $marker = if ($r.IsSource) { ' (source)' } else { '' }
        $md += ("### {0}. {1} (``{2}``){3}" -f $rank, $r.DisplayName, $r.RegionName, $marker)
        $md += ("Coverage: **{0}%** | Covered: **{1}** | Missing: **{2}** | Instances at risk: **{3}**" -f $r.CoveragePercent, $r.TypesCovered, $r.TypesMissing, $r.InstancesMissing)
        $md += ""
        if ($r.TypesMissing -eq 0) {
            $md += "✅ All deployed resource types supported."
        } else {
            $md += "**Missing resource types (instance count in source):**"
            $md += ""
            $missingList = $r.MissingTypesList -split '; '
            foreach ($m in $missingList) { $md += "- $m" }
        }
        if ($r.TypesUnknown -gt 0) {
            $md += ""
            $md += ("⚠️  Unknown types: {0}" -f $r.UnknownTypesList)
        }
        $md += ""
    }
}

$mdPath = Join-Path $OutputDirectory ("region-coverage-{0}.md" -f $srcSlug)
$md -join "`n" | Set-Content -Path $mdPath -Encoding UTF8
Write-Host ("  Wrote {0}" -f $mdPath)

# 7. Console summary.
Write-Host ""
Write-Host ("=== Coverage summary (source: {0}) ===" -f $SourceRegion) -ForegroundColor Cyan
$results | Select-Object `
    @{N='Region';E={$_.RegionName}}, `
    @{N='Coverage';E={"$($_.CoveragePercent)%"}}, `
    @{N='Covered';E={$_.TypesCovered}}, `
    @{N='Missing';E={$_.TypesMissing}}, `
    @{N='InstancesAtRisk';E={$_.InstancesMissing}}, `
    @{N='Source';E={ if ($_.IsSource) {'*'} else {''} }} |
    Format-Table -AutoSize

Write-Host "Done." -ForegroundColor Green
Restore-AzContext
