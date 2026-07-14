<#
.SYNOPSIS
    Rank Azure regions by fit for your workload — coverage, latency, price,
    capacity, egress, and more — and emit a defensible per-region scorecard.

.DESCRIPTION
    Answers: "Given my workload in <SourceRegion>, which alternative region
    should I put new capacity in?"  Extends the service-coverage view of
    Compare-AzureRegionCoverage.ps1 with the additional decision dimensions
    that show up once you actually try to move a workload:

      - Service / provider coverage         (like Compare-AzureRegionCoverage)
      - Availability Zone support           (region metadata)
      - Data residency / geography          (hard filter)
      - Compute pricing delta               (Retail Prices API, cached)
      - Inter-region latency (P50 RTT)      (public Microsoft dataset)
      - Cross-region peering / egress cost  (public bandwidth rates)
      - Capacity constraint status          (optional CSV override)
      - Paired-region topology              (informational)
      - SKU family portability              (soft score)
      - Region maturity                     (soft score)

    Applies hard filters (data residency, AZ requirement, min coverage,
    exclude constrained), computes weighted soft scores per remaining region,
    and produces:
      - region-scorecard-<src>.csv   Per-region breakdown, one row per candidate.
      - region-scorecard-<src>.md    Human-readable ranking + per-region drill.
      - region-scorecard-<src>.json  Machine-readable full breakdown.

    The framework driving the scoring is in ./docs/region-selection-framework.md.

.PARAMETER SourceRegion
    Your current / source region (e.g. 'northeurope'). Case-insensitive. Required.

.PARAMETER GeographyGroup
    Restrict candidates to this Azure geography group. Default: 'Europe'.
    Use -List (on Get-AzureServicesByRegion.ps1) to enumerate.

.PARAMETER InventoryFile
    Path to a CSV with columns 'ResourceType' and 'Instances' (the shape
    produced by Compare-AzureRegionCoverage.ps1's deployed-types file).
    When set, Azure Resource Graph is NOT queried. Overrides -Scope,
    -SubscriptionId, -TenantId, -ManagementGroupId.

.PARAMETER Scope
    Which subscriptions to inventory. 'Subscription' | 'Tenant' |
    'ManagementGroup'. Default: 'Subscription'.

.PARAMETER TenantId
    (Scope=Tenant) Tenant to inventory. Defaults to current 'az' context.

.PARAMETER SubscriptionId
    (Scope=Subscription) One or more sub IDs. Defaults to current context.

.PARAMETER ManagementGroupId
    (Scope=ManagementGroup) The MG ID.

.PARAMETER OutputDirectory
    Where to write outputs. Default: current directory.

.PARAMETER MinResourceCount
    Only consider resource types with at least this many instances. Default: 1.

.PARAMETER IncludeStageRegions
    Include Stage/EUAP/internal regions in candidates. Default: excluded.

.PARAMETER WeightsFile
    Path to a custom soft-scoring weights JSON (schema matches
    data/scoring-weights.default.json). Overrides -WeightsProfile.

.PARAMETER WeightsProfile
    Which named profile from data/scoring-weights.default.json to use.
    One of: 'default', 'cost_optimised', 'latency_critical', 'capacity_first',
    'critical_prod'. Default: 'default'.

.PARAMETER LatencyDataFile
    Path to the latency baseline JSON. Default: ./data/latency-baseline.json.

.PARAMETER EgressRatesFile
    Path to the egress rates JSON. Default: ./data/egress-rates.json.

.PARAMETER CapacityStatusFile
    Path to a filled Capacity Portal CSV (see data/capacity-status-template.csv
    for the shape). If empty or missing, capacity health is scored neutrally
    and -ExcludeConstrained is a no-op.

.PARAMETER DataResidency
    Hard filter: only candidates in this geography group are considered.
    Equivalent to setting -GeographyGroup, but expresses the *policy intent*
    (a rejection reason of "data residency" rather than "not in this
    geography").

.PARAMETER RequireAZ
    Hard filter: reject candidate regions that do not have Availability Zones.

.PARAMETER ExcludeConstrained
    Hard filter: reject candidates whose capacity status shows "All new
    subscriptions restricted". Requires -CapacityStatusFile to be populated.

.PARAMETER MinCoverage
    Hard filter: reject candidates below this % of source resource-type
    coverage. Default: 0 (no floor). Set to e.g. 70 to reject weak candidates.

.PARAMETER SkuBasket
    Comma-separated list of VM SKU names to price-check via the Retail
    Prices API. Default: 'Standard_D4s_v5,Standard_E4s_v5' which are broadly
    available and representative of Intel general-purpose + memory-optimised.

.PARAMETER SkuDataFile
    Path to a canonical SKU-by-region snapshot produced by
    Get-AzureSkusByRegion.ps1 (default: ./data/skus-by-region.json). When
    present, the SKU-portability soft score is upgraded from the coarse
    "does Microsoft.Compute exist in this region?" heuristic to a real
    per-provider coverage check: for every deployed provider that appears
    in the Tier 1 catalogue (APIM, Compute, Storage, Cache, CognitiveServices,
    Kusto, Synapse, MachineLearningServices, Web, Sql, DBforPostgreSQL) the
    score is (SKUs supported in both source and target) / (SKUs supported
    in source), averaged across the deployed providers. When the file is
    missing or older than 30 days, a warning is written and the script
    falls back to the legacy heuristic.

.PARAMETER SkipPriceFetch
    Skip the Retail Prices API call. Compute-price-delta score is set to a
    neutral 0.5 for every region. Useful for offline / firewalled runs.

.EXAMPLE
    ./Score-AzureRegionFit.ps1 -SourceRegion northeurope
    # Score every European region against the current subscription's NE inventory.

.EXAMPLE
    ./Score-AzureRegionFit.ps1 -SourceRegion northeurope `
        -InventoryFile ./outputs/coverage/northeurope/example-inventory.csv `
        -OutputDirectory ./out
    # Offline scoring against a synthetic inventory.

.EXAMPLE
    ./Score-AzureRegionFit.ps1 -SourceRegion northeurope `
        -WeightsProfile latency_critical `
        -RequireAZ -MinCoverage 80
    # Score with latency-heavy weights and hard filters for user-facing prod workloads.

.EXAMPLE
    ./Score-AzureRegionFit.ps1 -SourceRegion northeurope `
        -CapacityStatusFile ./my-capacity-2026-06-08.csv `
        -ExcludeConstrained
    # Score, but reject any region with "all new subs restricted" per the
    # Capacity Portal snapshot you supplied.

.NOTES
    Requires: Azure CLI ('az') with 'resource-graph' extension, PowerShell 5.1+.
    Read-only: only queries Resource Graph, ARM metadata, and public
    Retail Prices API.

    Version: 1.0.0
    License: MIT

    The framework doc explaining every criterion is at
    ./docs/region-selection-framework.md.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$SourceRegion,

    [string]$GeographyGroup = 'Europe',

    [ValidateSet('Subscription','Tenant','ManagementGroup')]
    [string]$Scope = 'Subscription',

    [string]$TenantId,

    [string[]]$SubscriptionId,

    [string]$ManagementGroupId,

    [string]$InventoryFile,

    [string]$OutputDirectory = (Get-Location).Path,

    [int]$MinResourceCount = 1,

    [switch]$IncludeStageRegions,

    [string]$WeightsFile,

    [ValidateSet('default','cost_optimised','latency_critical','capacity_first','critical_prod')]
    [string]$WeightsProfile = 'default',

    [string]$LatencyDataFile,

    [string]$EgressRatesFile,

    [string]$CapacityStatusFile,

    [string]$DataResidency,

    [switch]$RequireAZ,

    [switch]$ExcludeConstrained,

    [double]$MinCoverage = 0,

    [string]$SkuBasket = 'Standard_D4s_v5,Standard_E4s_v5',

    [string]$SkuDataFile,

    [switch]$SkipPriceFetch
)

$ErrorActionPreference = 'Stop'

# UTF-8 so region physical location names (e.g. "Gävle") survive round-trip.
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

function Get-DataFilePath {
    param([string]$Explicit, [string]$DefaultRelative)
    if ($Explicit) {
        if (-not (Test-Path $Explicit)) { throw "Data file not found: $Explicit" }
        return (Resolve-Path $Explicit).Path
    }
    $candidate = Join-Path $PSScriptRoot $DefaultRelative
    if (Test-Path $candidate) { return (Resolve-Path $candidate).Path }
    return $null
}

function Get-DeployedTypes {
    param(
        [string]$Region, [string]$ScopeKind, [string[]]$SubIds, [string]$MgId, [int]$MinCount
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
            $args += '--subscriptions'
            $args += ($SubIds | Select-Object -First 1000)
        }
    }
    $resp = & az @args
    if ($LASTEXITCODE -ne 0) { throw "az graph query failed with exit code $LASTEXITCODE." }
    $parsed = $resp | Out-String | ConvertFrom-Json
    if (-not $parsed) { throw "Resource Graph query returned no response." }
    return $parsed.data
}

function Get-ProviderResourceTypeLocations {
    Write-Host "Fetching resource provider metadata (30-60s) ..." -ForegroundColor Cyan
    $json = az provider list `
        --query "[].{ns:namespace, types:resourceTypes[].{rt:resourceType, locs:locations}}" `
        -o json
    $providers = $json | ConvertFrom-Json
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
    param([string]$Geo, [switch]$IncludeStage)
    $all = az account list-locations -o json | ConvertFrom-Json
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

function Get-Haversine-Km {
    param([double]$Lat1,[double]$Lon1,[double]$Lat2,[double]$Lon2)
    $R = 6371.0
    $toRad = { param($d) $d * [math]::PI / 180.0 }
    $dLat = & $toRad ($Lat2 - $Lat1)
    $dLon = & $toRad ($Lon2 - $Lon1)
    $a = [math]::Sin($dLat/2)*[math]::Sin($dLat/2) +
         [math]::Cos((& $toRad $Lat1))*[math]::Cos((& $toRad $Lat2)) *
         [math]::Sin($dLon/2)*[math]::Sin($dLon/2)
    $c = 2 * [math]::Atan2([math]::Sqrt($a), [math]::Sqrt(1-$a))
    return $R * $c
}

function Get-LatencyMs {
    param($LatencyData, [string]$SourceRegion, [string]$TargetRegion)
    $src = $SourceRegion.ToLower()
    $tgt = $TargetRegion.ToLower()
    if ($src -eq $tgt) { return 0 }
    # Published direct pair.
    if ($LatencyData.rtt_ms.PSObject.Properties[$src] -and
        $LatencyData.rtt_ms.$src.PSObject.Properties[$tgt] -and
        $LatencyData.rtt_ms.$src.$tgt -ne $null) {
        $val = $LatencyData.rtt_ms.$src.$tgt
        if ($val -gt 0) { return [int]$val }
    }
    # Try reverse (matrix is close to symmetric).
    if ($LatencyData.rtt_ms.PSObject.Properties[$tgt] -and
        $LatencyData.rtt_ms.$tgt.PSObject.Properties[$src] -and
        $LatencyData.rtt_ms.$tgt.$src -ne $null) {
        $val = $LatencyData.rtt_ms.$tgt.$src
        if ($val -gt 0) { return [int]$val }
    }
    # Fallback: great-circle distance estimate.
    $srcMeta = $LatencyData.region_metadata.PSObject.Properties[$src]
    $tgtMeta = $LatencyData.region_metadata.PSObject.Properties[$tgt]
    if ($srcMeta -and $tgtMeta) {
        $km = Get-Haversine-Km `
            $srcMeta.Value.coords.lat $srcMeta.Value.coords.lon `
            $tgtMeta.Value.coords.lat $tgtMeta.Value.coords.lon
        # ~5ms base + 0.01ms per km (Microsoft WAN, roughly light in fiber x2).
        return [int]([math]::Round(5 + 0.01 * $km))
    }
    return $null  # Truly unknown.
}

function Get-BandwidthZone {
    param($EgressData, [string]$Region)
    $r = $Region.ToLower()
    foreach ($z in @('zone1','zone2','zone3','zone4')) {
        if ($EgressData.billing_zones.$z.regions -contains $r) { return $z }
    }
    return 'zone1'  # default assumption
}

function Get-CrossRegionRate {
    param($EgressData, [string]$FromRegion, [string]$ToRegion)
    $fromZ = Get-BandwidthZone $EgressData $FromRegion
    $toZ   = Get-BandwidthZone $EgressData $ToRegion
    if ($fromZ -eq $toZ) {
        if ($fromZ -eq 'zone1') { return $EgressData.vnet_peering.cross_region_within_zone1.rate_per_gb }
        # Approximate other same-zone rates
        return $EgressData.vnet_peering.cross_region_within_zone1.rate_per_gb * 1.5
    }
    if (($fromZ -eq 'zone1' -and $toZ -eq 'zone2') -or ($fromZ -eq 'zone2' -and $toZ -eq 'zone1')) {
        return $EgressData.vnet_peering.cross_region_zone1_to_zone2.rate_per_gb
    }
    if (($fromZ -eq 'zone1' -and $toZ -eq 'zone3') -or ($fromZ -eq 'zone3' -and $toZ -eq 'zone1')) {
        return $EgressData.vnet_peering.cross_region_zone1_to_zone3.rate_per_gb
    }
    # Fallback: use highest known rate.
    return $EgressData.vnet_peering.cross_region_zone1_to_zone3.rate_per_gb
}

function Get-CapacityStatus {
    param([string]$CsvPath, [string]$Region)
    if (-not $CsvPath -or -not (Test-Path $CsvPath)) { return $null }
    $rows = Import-Csv $CsvPath | Where-Object { $_.Region -and $_.Region.Trim() -and (-not $_.Region.StartsWith('#')) }
    $regionRows = $rows | Where-Object { $_.Region.ToLower() -eq $Region.ToLower() }
    if (-not $regionRows) { return $null }
    # Prefer the 'region' row over AZ-level rows for the summary status.
    $summary = $regionRows | Where-Object { $_.AZ -eq 'region' -or -not $_.AZ }
    if (-not $summary) { $summary = $regionRows }
    return $summary | Select-Object -First 1
}

function ConvertTo-CapacityHealthScore {
    param($Status)
    if (-not $Status) { return 0.5 }  # neutral for unknown
    $challenge = ($Status.ComputeCapacityChallenge -as [string]).Trim()
    $restriction = ($Status.OfferRestriction -as [string]).Trim()
    # Any "all new subscriptions restricted" is a hard 0.
    if ($restriction -match 'All new subscriptions restricted') { return 0.0 }
    if (-not $challenge -or $challenge -match 'Only classic/specialty') { return 1.0 }
    if ($challenge -match 'Short-term server gap') { return 0.7 }
    if ($challenge -match 'Long-term gap') { return 0.4 }
    if ($challenge -match 'No longer expanding') { return 0.2 }
    return 0.5
}

function Test-IsHardRestricted {
    param($Status)
    if (-not $Status) { return $false }
    $restriction = ($Status.OfferRestriction -as [string]).Trim()
    return ($restriction -match 'All new subscriptions restricted')
}

function Get-RetailPrices {
    param([string[]]$SkuNames, [string[]]$Regions)
    $prices = @{}
    foreach ($sku in $SkuNames) {
        $prices[$sku] = @{}
    }
    foreach ($sku in $SkuNames) {
        Write-Host ("  Fetching Retail Prices for {0} ..." -f $sku) -ForegroundColor DarkCyan
        $filter = "serviceName eq 'Virtual Machines' and armSkuName eq '$sku' and priceType eq 'Consumption'"
        $url = "https://prices.azure.com/api/retail/prices?`$filter=" + [uri]::EscapeDataString($filter) + "&`$top=1000"
        try {
            $resp = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 60
            foreach ($item in $resp.Items) {
                if (-not $item.armRegionName) { continue }
                if ($item.unitOfMeasure -ne '1 Hour') { continue }
                if ($item.productName -match 'Windows') { continue }  # Linux-only for a consistent basket
                if ($item.skuName -match 'Low Priority|Spot') { continue }
                $r = $item.armRegionName.ToLower()
                if ($prices[$sku].ContainsKey($r)) {
                    # Prefer lower price (some regions have multiple listings)
                    if ($item.retailPrice -lt $prices[$sku][$r]) { $prices[$sku][$r] = [double]$item.retailPrice }
                } else {
                    $prices[$sku][$r] = [double]$item.retailPrice
                }
            }
            # Paginate if NextPageLink present.
            $next = $resp.NextPageLink
            while ($next) {
                $resp = Invoke-RestMethod -Uri $next -Method Get -TimeoutSec 60
                foreach ($item in $resp.Items) {
                    if (-not $item.armRegionName) { continue }
                    if ($item.unitOfMeasure -ne '1 Hour') { continue }
                    if ($item.productName -match 'Windows') { continue }
                    if ($item.skuName -match 'Low Priority|Spot') { continue }
                    $r = $item.armRegionName.ToLower()
                    if ($prices[$sku].ContainsKey($r)) {
                        if ($item.retailPrice -lt $prices[$sku][$r]) { $prices[$sku][$r] = [double]$item.retailPrice }
                    } else {
                        $prices[$sku][$r] = [double]$item.retailPrice
                    }
                }
                $next = $resp.NextPageLink
            }
        } catch {
            Write-Host ("    Warning: Retail Prices fetch for {0} failed: {1}" -f $sku, $_.Exception.Message) -ForegroundColor Yellow
        }
    }
    return $prices
}

function Get-PriceDeltaPercent {
    param($Prices, [string]$SourceRegion, [string]$TargetRegion)
    $src = $SourceRegion.ToLower()
    $tgt = $TargetRegion.ToLower()
    if ($src -eq $tgt) { return 0 }
    $deltas = @()
    foreach ($sku in $Prices.Keys) {
        $srcPrice = $Prices[$sku][$src]
        $tgtPrice = $Prices[$sku][$tgt]
        if ($srcPrice -and $tgtPrice -and $srcPrice -gt 0) {
            $deltas += 100.0 * ($tgtPrice - $srcPrice) / $srcPrice
        }
    }
    if ($deltas.Count -eq 0) { return $null }  # Unknown
    return [math]::Round(($deltas | Measure-Object -Average).Average, 2)
}

# --- SKU-portability helpers -------------------------------------------------

# Load and index the SKU snapshot from Get-AzureSkusByRegion.ps1. Returns a
# hashtable: providerNs (lowercase) -> array of @{ Name; NormLocations }.
# Returns $null if the file is missing or unparseable.
function Import-SkuData {
    param([string]$Path)
    if (-not $Path -or -not (Test-Path $Path)) { return $null }
    try {
        $raw = Get-Content $Path -Raw | ConvertFrom-Json -Depth 12
    } catch {
        Write-Host ("Warning: could not parse SKU data file '{0}' - falling back to heuristic." -f $Path) -ForegroundColor DarkYellow
        return $null
    }
    if (-not $raw.providers) { return $null }
    # Age check.
    if ($raw.snapshot_date) {
        try {
            $age = (Get-Date) - [datetime]::Parse($raw.snapshot_date)
            if ($age.TotalDays -gt 30) {
                Write-Host ("Warning: SKU data snapshot is {0:N0} days old ('{1}'). Refresh via Get-AzureSkusByRegion.ps1." -f $age.TotalDays, $Path) -ForegroundColor DarkYellow
            }
        } catch { }
    }
    $index = @{}
    foreach ($p in $raw.providers.PSObject.Properties) {
        $skus = foreach ($s in @($p.Value.skus)) {
            $locSet = New-Object System.Collections.Generic.HashSet[string]
            foreach ($l in @($s.locations)) { if ($l) { [void]$locSet.Add(($l -replace '\s','').ToLowerInvariant()) } }
            [pscustomobject]@{ Name = $s.name; NormLocations = $locSet }
        }
        $index[$p.Name.ToLowerInvariant()] = @($skus)
    }
    return $index
}

# Extract unique provider namespaces (lowercase) from a deployed-types list.
# Each entry has .type like 'microsoft.compute/virtualmachines'; we want
# 'microsoft.compute'.
function Get-DeployedProviders {
    param([object[]]$Deployed)
    $set = New-Object System.Collections.Generic.HashSet[string]
    foreach ($d in $Deployed) {
        $t = ($d.type -as [string])
        if (-not $t) { continue }
        $slash = $t.IndexOf('/')
        $ns = if ($slash -gt 0) { $t.Substring(0, $slash) } else { $t }
        [void]$set.Add($ns.ToLowerInvariant())
    }
    return $set
}

# Compute the SKU-portability score for a candidate region.
# Returns a value in [0, 1]:
#   - For each deployed provider in the SKU catalogue, ratio = (SKUs available
#     in BOTH source and target) / (SKUs available in source). Providers not
#     available in source are ignored (zero-source-SKUs case).
#   - Score is the equal-weight average across providers.
#   - Falls back to the legacy Compute-VM heuristic when the SKU index is
#     empty or none of the deployed providers is in the catalogue.
function Get-SkuPortabilityScore {
    param(
        [hashtable]$SkuIndex,
        [System.Collections.Generic.HashSet[string]]$DeployedNs,
        [string]$SrcNorm,
        [string]$TgtNorm,
        [hashtable]$RtMap
    )
    # Legacy heuristic used as a fallback.
    $legacy = if ($RtMap.ContainsKey('microsoft.compute/virtualmachines')) {
        if ($RtMap['microsoft.compute/virtualmachines'].Locations.Contains($TgtNorm)) { 1.0 } else { 0.2 }
    } else { 0.7 }

    if (-not $SkuIndex -or $SkuIndex.Count -eq 0 -or -not $DeployedNs) { return $legacy }

    $ratios = @()
    foreach ($ns in $DeployedNs) {
        if (-not $SkuIndex.ContainsKey($ns)) { continue }
        $skus = $SkuIndex[$ns]
        $inSrc = @($skus | Where-Object { $_.NormLocations.Contains($SrcNorm) })
        if ($inSrc.Count -eq 0) { continue }
        $inBoth = @($inSrc | Where-Object { $_.NormLocations.Contains($TgtNorm) })
        $ratios += ($inBoth.Count / $inSrc.Count)
    }
    if ($ratios.Count -eq 0) { return $legacy }
    return [math]::Round((($ratios | Measure-Object -Average).Average), 3)
}

function ConvertTo-LatencyScore {
    param([Nullable[int]]$RttMs)
    if ($RttMs -eq $null) { return 0.5 }  # neutral for unknown
    $val = 1.0 - [math]::Min($RttMs / 100.0, 1.0)
    return [math]::Round($val, 3)
}

function ConvertTo-PriceScore {
    param([Nullable[double]]$DeltaPct)
    if ($DeltaPct -eq $null) { return 0.5 }
    # -20% or better -> 1.0; +20% or worse -> 0.0; 0% -> 0.5
    $val = 0.5 + [math]::Max([math]::Min(-$DeltaPct / 40.0, 0.5), -0.5)
    return [math]::Round($val, 3)
}

function ConvertTo-EgressScore {
    param([double]$RatePerGb, [double]$BaselineRate, [double]$MaxRate)
    if ($MaxRate -eq $BaselineRate) { return 1.0 }
    $val = 1.0 - ($RatePerGb - $BaselineRate) / ($MaxRate - $BaselineRate)
    return [math]::Round([math]::Max([math]::Min($val, 1.0), 0.0), 3)
}

function ConvertTo-MaturityScore {
    param($RegionMetadata)
    # Best effort: Microsoft's own regionCategory metadata is 'Recommended' / 'Other'
    $cat = ($RegionMetadata.regionCategory -as [string])
    if ($cat -eq 'Recommended') { return 1.0 }
    if ($cat -eq 'Other') { return 0.6 }
    return 0.5
}

function Get-AZCountFromMetadata {
    param($RegionMetadata)
    if (-not $RegionMetadata) { return 0 }
    # Newer az CLI versions expose availabilityZoneMappings.
    $azMappings = $RegionMetadata.availabilityZoneMappings
    if ($azMappings) { return @($azMappings).Count }
    # Fallback via well-known list — updated per region as of 2026-06.
    $azSupported = @(
        'northeurope','westeurope','uksouth','swedencentral','norwayeast','francecentral',
        'germanywestcentral','italynorth','polandcentral','switzerlandnorth','spaincentral',
        'belgiumcentral','denmarkeast','austriaeast',
        'eastus','eastus2','centralus','southcentralus','westus2','westus3','canadacentral',
        'brazilsouth','mexicocentral',
        'southeastasia','eastasia','japaneast','koreacentral','centralindia','southindia',
        'australiaeast','indonesiacentral',
        'israelcentral','uaenorth','qatarcentral','southafricanorth'
    )
    if ($azSupported -contains $RegionMetadata.name) { return 3 }
    return 0
}

# ---------------------------------------------------------------- main flow --

$acct = Test-Prereq
Write-Host ("Tenant:       {0}" -f $acct.tenantId) -ForegroundColor Green
Write-Host ("Identity:     {0}" -f $acct.user.name) -ForegroundColor Green

# ---- Resolve reference data paths --------------------------------------------
$latencyPath  = Get-DataFilePath $LatencyDataFile 'data/latency-baseline.json'
$egressPath   = Get-DataFilePath $EgressRatesFile 'data/egress-rates.json'
$weightsPath  = Get-DataFilePath $WeightsFile     'data/scoring-weights.default.json'
$capacityPath = Get-DataFilePath $CapacityStatusFile 'data/capacity-status-template.csv'

if (-not $latencyPath) { throw "Latency data file not found. Expected at ./data/latency-baseline.json or pass -LatencyDataFile." }
if (-not $egressPath)  { throw "Egress rates file not found. Expected at ./data/egress-rates.json or pass -EgressRatesFile." }
if (-not $weightsPath) { throw "Weights file not found. Expected at ./data/scoring-weights.default.json or pass -WeightsFile." }

Write-Host ("Reference data:") -ForegroundColor Green
Write-Host ("  Latency  : {0}" -f $latencyPath)
Write-Host ("  Egress   : {0}" -f $egressPath)
Write-Host ("  Weights  : {0}" -f $weightsPath)
if ($capacityPath) { Write-Host ("  Capacity : {0}" -f $capacityPath) } else { Write-Host "  Capacity : (none — capacity health scored as neutral 0.5)" -ForegroundColor Yellow }

$latencyData = Get-Content $latencyPath -Raw | ConvertFrom-Json
$egressData  = Get-Content $egressPath  -Raw | ConvertFrom-Json
$weightsJson = Get-Content $weightsPath -Raw | ConvertFrom-Json

# Select the weight profile.
$weights = $null
if ($WeightsFile) {
    # Assume the custom file follows the same schema and use its top-level weights.
    $weights = $weightsJson.weights
    Write-Host ("Weights   : custom (from {0})" -f (Split-Path $WeightsFile -Leaf)) -ForegroundColor Green
} elseif ($WeightsProfile -eq 'default') {
    $weights = $weightsJson.weights
    Write-Host ("Weights   : profile 'default'") -ForegroundColor Green
} else {
    if ($weightsJson.alternative_profiles.PSObject.Properties[$WeightsProfile]) {
        $weights = $weightsJson.alternative_profiles.$WeightsProfile
        Write-Host ("Weights   : profile '{0}'" -f $WeightsProfile) -ForegroundColor Green
    } else {
        throw "Weights profile '$WeightsProfile' not found in $weightsPath. Available profiles: default, $($weightsJson.alternative_profiles.PSObject.Properties.Name -join ', ')."
    }
}

# Convert weights to a hashtable for easier iteration.
$weightMap = @{}
foreach ($p in $weights.PSObject.Properties) {
    if ($p.Name -ne '$comment') { $weightMap[$p.Name] = [double]$p.Value }
}
$weightSum = ($weightMap.Values | Measure-Object -Sum).Sum
if ([math]::Abs($weightSum - 1.0) -gt 0.02) {
    Write-Host ("  Warning: weights sum to {0:N3} (expected 1.0). Ranking is still deterministic but scores are not normalised." -f $weightSum) -ForegroundColor Yellow
}

# ---- Inventory: from file or Azure Resource Graph --------------------------
$deployed = $null
if ($InventoryFile) {
    if (-not (Test-Path $InventoryFile)) { throw "InventoryFile '$InventoryFile' not found." }
    Write-Host ("`nScope:        Inventory loaded from file: {0}" -f (Resolve-Path $InventoryFile).Path) -ForegroundColor Green
    $rows = Import-Csv $InventoryFile
    $expected = @('ResourceType','Instances')
    foreach ($col in $expected) {
        if (-not ($rows[0].PSObject.Properties.Name -contains $col)) {
            throw "InventoryFile must have columns: $($expected -join ', '). Got: $($rows[0].PSObject.Properties.Name -join ', ')"
        }
    }
    $deployed = $rows | ForEach-Object {
        $n = [int]$_.Instances
        if ($n -ge $MinResourceCount) { [pscustomobject]@{ type = $_.ResourceType.Trim(); c = $n } }
    } | Where-Object { $_ }
    if (-not $deployed -or $deployed.Count -eq 0) {
        throw "No usable rows in '$InventoryFile' after applying -MinResourceCount $MinResourceCount."
    }
} else {
    switch ($Scope) {
        'Subscription' {
            if (-not $SubscriptionId -or $SubscriptionId.Count -eq 0) {
                $SubscriptionId = @($acct.id)
                Write-Host ("`nScope:        Subscription (current): {0} ({1})" -f $acct.name, $acct.id) -ForegroundColor Green
            } else {
                Write-Host ("`nScope:        Subscription ({0})" -f $SubscriptionId.Count) -ForegroundColor Green
            }
        }
        'Tenant' {
            $tenantForScope = if ($TenantId) { $TenantId } else { $acct.tenantId }
            $script:TenantSubs = @(az account list --query "[?state=='Enabled' && tenantId=='$tenantForScope'].id" -o json | ConvertFrom-Json)
            if (-not $script:TenantSubs) { throw "No enabled subscriptions found in tenant '$tenantForScope'." }
            Write-Host ("`nScope:        Tenant '{0}' ({1} subs)" -f $tenantForScope, $script:TenantSubs.Count) -ForegroundColor Green
        }
        'ManagementGroup' {
            if (-not $ManagementGroupId) { throw "Scope 'ManagementGroup' requires -ManagementGroupId." }
            Write-Host ("`nScope:        Management group '{0}'" -f $ManagementGroupId) -ForegroundColor Green
        }
    }
    Write-Host ("Inventorying resource types in '{0}' via Azure Resource Graph ..." -f $SourceRegion) -ForegroundColor Cyan
    $subsForQuery = switch ($Scope) {
        'Subscription' { $SubscriptionId }
        'Tenant'       { $script:TenantSubs }
        default        { $null }
    }
    $deployed = Get-DeployedTypes -Region $SourceRegion -ScopeKind $Scope -SubIds $subsForQuery -MgId $ManagementGroupId -MinCount $MinResourceCount
    if (-not $deployed -or $deployed.Count -eq 0) {
        throw "No resources found in region '$SourceRegion' within the chosen scope."
    }
}

$srcSlug = ConvertTo-RegionSlug $SourceRegion
$totalInstances = ($deployed | Measure-Object c -Sum).Sum
Write-Host ("  {0} distinct resource types, {1} total instances." -f $deployed.Count, $totalInstances) -ForegroundColor Green

# ---- Provider catalog -------------------------------------------------------
$rtMap = Get-ProviderResourceTypeLocations
Write-Host ("  Indexed {0} resource types across all providers." -f $rtMap.Count) -ForegroundColor Green

# ---- SKU snapshot (optional data provider) ----------------------------------
$skuIndex = $null
$defaultSkuPath = Join-Path $PSScriptRoot 'data\skus-by-region.json'
$skuPath = if ($SkuDataFile) { $SkuDataFile } elseif (Test-Path $defaultSkuPath) { $defaultSkuPath } else { $null }
if ($skuPath) {
    $skuIndex = Import-SkuData -Path $skuPath
    if ($skuIndex) {
        Write-Host ("  Loaded SKU snapshot: {0} providers indexed from '{1}'." -f $skuIndex.Count, $skuPath) -ForegroundColor Green
    }
} else {
    Write-Host "  No SKU snapshot found — SKU portability will use the legacy Compute-VM heuristic. Run Get-AzureSkusByRegion.ps1 to enable per-provider portability scoring." -ForegroundColor DarkYellow
}
$deployedNs = Get-DeployedProviders -Deployed $deployed

# ---- Candidate regions ------------------------------------------------------
$geoForCandidates = if ($DataResidency) { $DataResidency } else { $GeographyGroup }
$candidates = Get-CandidateRegions -Geo $geoForCandidates -IncludeStage:$IncludeStageRegions
Write-Host ("`nEvaluating {0} candidate regions in '{1}' geography ..." -f $candidates.Count, $geoForCandidates) -ForegroundColor Cyan

# ---- Retail Prices (optional) -----------------------------------------------
$prices = $null
if (-not $SkipPriceFetch) {
    $skuList = $SkuBasket -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    Write-Host ("`nFetching Retail Prices for {0} SKUs across {1} regions ..." -f $skuList.Count, $candidates.Count) -ForegroundColor Cyan
    $regionsForPricing = $candidates | ForEach-Object { $_.name }
    $regionsForPricing += $SourceRegion
    $prices = Get-RetailPrices -SkuNames $skuList -Regions $regionsForPricing
    $skuCoverage = ($prices.Keys | ForEach-Object { ($prices[$_].Keys).Count } | Measure-Object -Sum).Sum
    Write-Host ("  Retrieved {0} SKU-region price points." -f $skuCoverage) -ForegroundColor Green
} else {
    Write-Host "`nSkipping Retail Prices fetch — compute-price-delta score set to neutral 0.5." -ForegroundColor Yellow
}

# ---- Score each candidate ---------------------------------------------------
$srcNorm = Get-NormalizedLocationName $SourceRegion
$srcCandidate = $candidates | Where-Object { (Get-NormalizedLocationName $_.name) -eq $srcNorm } | Select-Object -First 1
$sourceIsInGeo = [bool]$srcCandidate

# Baseline peering rate (in-region) for egress normalisation.
$baselineRate = $egressData.vnet_peering.in_region.rate_per_gb
$maxRate = $egressData.vnet_peering.cross_region_zone1_to_zone3.rate_per_gb

$results = foreach ($cand in $candidates) {
    $tgtNorm = Get-NormalizedLocationName $cand.name
    $isSource = ($tgtNorm -eq $srcNorm)

    # --- Compute coverage (also used as hard-floor filter)
    $covered = 0; $missing = 0; $missingInstances = 0; $missingList = @(); $unknown = 0
    foreach ($d in $deployed) {
        $key = $d.type.ToLowerInvariant()
        if (-not $rtMap.ContainsKey($key)) { $unknown++; continue }
        $info = $rtMap[$key]
        if ($info.IsGlobal) { $covered++; continue }
        if ($info.Locations.Contains($tgtNorm)) { $covered++ } else {
            $missing++
            $missingInstances += $d.c
            $missingList += ("{0} ({1})" -f $d.type, $d.c)
        }
    }
    $totalConsidered = $covered + $missing
    $coveragePct = if ($totalConsidered -gt 0) { [math]::Round(100.0 * $covered / $totalConsidered, 1) } else { 0 }

    # --- Region metadata
    $azCount = Get-AZCountFromMetadata $cand
    $paired = if ($cand.metadata.pairedRegion) { $cand.metadata.pairedRegion[0].name } else { '' }

    # --- Capacity
    $capStatus = Get-CapacityStatus -CsvPath $capacityPath -Region $cand.name
    $capHardRestricted = Test-IsHardRestricted $capStatus
    $capScore = ConvertTo-CapacityHealthScore $capStatus

    # --- Hard filters
    $rejections = @()
    if ($RequireAZ -and $azCount -lt 3) {
        $rejections += ("AZ requirement: region has {0} AZ(s), requires 3" -f $azCount)
    }
    if ($MinCoverage -gt 0 -and $coveragePct -lt $MinCoverage) {
        $rejections += ("Min coverage: {0}% below floor {1}%" -f $coveragePct, $MinCoverage)
    }
    if ($ExcludeConstrained -and $capHardRestricted) {
        $rejections += ("Capacity: all new subscriptions restricted")
    }
    if ($DataResidency -and $cand.metadata.geographyGroup -and
        $cand.metadata.geographyGroup.ToLower() -ne $DataResidency.ToLower()) {
        $rejections += ("Data residency: region in '{0}', policy requires '{1}'" -f $cand.metadata.geographyGroup, $DataResidency)
    }

    # --- Latency
    $rttMs = Get-LatencyMs -LatencyData $latencyData -SourceRegion $SourceRegion -TargetRegion $cand.name
    $latencyScore = ConvertTo-LatencyScore $rttMs

    # --- Compute price delta
    $priceDeltaPct = $null; $priceScore = 0.5
    if ($prices) {
        $priceDeltaPct = Get-PriceDeltaPercent -Prices $prices -SourceRegion $SourceRegion -TargetRegion $cand.name
        $priceScore = ConvertTo-PriceScore $priceDeltaPct
    }

    # --- Egress
    $peeringRate = if ($isSource) { $baselineRate } else { Get-CrossRegionRate -EgressData $egressData -FromRegion $SourceRegion -ToRegion $cand.name }
    $egressScore = ConvertTo-EgressScore $peeringRate $baselineRate $maxRate

    # --- AZ score
    $azScore = if ($RequireAZ) { if ($azCount -ge 3) { 1.0 } elseif ($azCount -ge 1) { 0.5 } else { 0.0 } } else { if ($azCount -ge 3) { 1.0 } elseif ($azCount -ge 1) { 0.7 } else { 0.3 } }

    # --- Coverage score
    $coverageScore = [math]::Round($coveragePct / 100.0, 3)

    # --- SKU family portability (SKU snapshot if present, else legacy heuristic)
    $skuPortabilityScore = Get-SkuPortabilityScore -SkuIndex $skuIndex -DeployedNs $deployedNs -SrcNorm $srcNorm -TgtNorm $tgtNorm -RtMap $rtMap

    # --- Maturity
    $maturityScore = ConvertTo-MaturityScore $cand.metadata

    # --- Combine
    $scoreMap = @{
        coverage            = $coverageScore
        latency_to_source   = $latencyScore
        capacity_health     = $capScore
        compute_price_delta = $priceScore
        az_support          = $azScore
        sku_portability     = $skuPortabilityScore
        egress_cost         = $egressScore
        region_maturity     = $maturityScore
    }
    $totalScore = 0.0
    foreach ($k in $weightMap.Keys) {
        if ($scoreMap.ContainsKey($k)) {
            $totalScore += $weightMap[$k] * $scoreMap[$k]
        }
    }
    $totalScore = [math]::Round($totalScore, 3)

    [pscustomobject]@{
        RegionName            = $cand.name
        DisplayName           = $cand.displayName
        Physical              = $cand.metadata.physicalLocation
        RegionCategory        = $cand.metadata.regionCategory
        Geography             = $cand.metadata.geographyGroup
        PairedWith            = $paired
        AZCount               = $azCount
        IsSource              = $isSource
        Rejected              = ($rejections.Count -gt 0)
        RejectionReasons      = ($rejections -join '; ')
        FinalScore            = $totalScore
        CoveragePercent       = $coveragePct
        CoverageScore         = $coverageScore
        TypesCovered          = $covered
        TypesMissing          = $missing
        InstancesMissing      = $missingInstances
        TypesUnknown          = $unknown
        MissingTypesList      = ($missingList -join '; ')
        LatencyMs             = $rttMs
        LatencyScore          = $latencyScore
        PriceDeltaPercent     = $priceDeltaPct
        PriceScore            = $priceScore
        PeeringRatePerGb      = $peeringRate
        EgressScore           = $egressScore
        AZScore               = $azScore
        SKUPortabilityScore   = $skuPortabilityScore
        MaturityScore         = $maturityScore
        CapacityStatus        = if ($capStatus) { ($capStatus.ComputeCapacityChallenge -as [string]) } else { 'unknown' }
        CapacityRestriction   = if ($capStatus) { ($capStatus.OfferRestriction -as [string]) } else { '' }
        CapacityMitigation    = if ($capStatus) { ($capStatus.MitigationTimeline -as [string]) } else { '' }
        CapacityScore         = $capScore
    }
}

# --- Sort: rejected regions last, then by FinalScore desc.
$sorted = $results | Sort-Object -Property `
    @{Expression='Rejected'; Descending=$false}, `
    @{Expression='FinalScore'; Descending=$true}, `
    @{Expression='DisplayName'; Descending=$false}

# --- Emit outputs ------------------------------------------------------------
if (-not (Test-Path $OutputDirectory)) { New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null }
$OutputDirectory = (Resolve-Path $OutputDirectory).Path

# CSV
$csvPath = Join-Path $OutputDirectory ("region-scorecard-{0}.csv" -f $srcSlug)
$sorted | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
Write-Host ("`n  Wrote {0}" -f $csvPath)

# JSON
$jsonPath = Join-Path $OutputDirectory ("region-scorecard-{0}.json" -f $srcSlug)
$jsonPayload = [pscustomobject]@{
    generatedAt      = (Get-Date).ToString('o')
    sourceRegion     = $SourceRegion
    geographyGroup   = $geoForCandidates
    inventoryCount   = $deployed.Count
    inventoryInstances = $totalInstances
    weightProfile    = if ($WeightsFile) { 'custom' } else { $WeightsProfile }
    weights          = $weightMap
    hardFilters      = [pscustomobject]@{
        dataResidency      = $DataResidency
        requireAZ          = [bool]$RequireAZ
        excludeConstrained = [bool]$ExcludeConstrained
        minCoverage        = $MinCoverage
    }
    dataSources = [pscustomobject]@{
        latencyBaseline = $latencyData.snapshot_date
        egressRates     = $egressData.snapshot_date
        capacityStatus  = if ($capacityPath) { (Split-Path $capacityPath -Leaf) } else { $null }
    }
    results = $sorted
}
$jsonPayload | ConvertTo-Json -Depth 6 | Set-Content -Path $jsonPath -Encoding UTF8
Write-Host ("  Wrote {0}" -f $jsonPath)

# Markdown
$md = @()
$md += "# Region scorecard: source = ``$SourceRegion``"
$md += ""
$md += ("Generated: {0:yyyy-MM-dd HH:mm}" -f (Get-Date))
$md += ("Geography: **{0}**" -f $geoForCandidates)
$wpDisplay = if ($WeightsFile) { "custom ($(Split-Path $WeightsFile -Leaf))" } else { $WeightsProfile }
$md += ("Weights profile: **{0}**" -f $wpDisplay)
if ($InventoryFile) {
    $md += ("Inventory: **offline** — ``{0}``" -f (Split-Path $InventoryFile -Leaf))
} else {
    $md += ("Tenant: ``{0}``" -f $acct.tenantId)
}
$md += ("Inventory summary: **{0}** resource types, **{1}** instances." -f $deployed.Count, $totalInstances)
$md += ""
$md += "## Hard filters"
$md += "| Filter | Value |"
$md += "| --- | --- |"
$drDisplay = if ($DataResidency) { $DataResidency } else { '(none — geography = ' + $GeographyGroup + ')' }
$raDisplay = if ($RequireAZ) { 'yes (3 AZ required)' } else { 'no' }
$ecDisplay = if ($ExcludeConstrained) { 'yes' } else { 'no' }
$md += ("| Data residency | {0} |" -f $drDisplay)
$md += ("| Require AZs | {0} |" -f $raDisplay)
$md += ("| Exclude constrained | {0} |" -f $ecDisplay)
$md += ("| Min coverage | {0}% |" -f $MinCoverage)
$md += ""
$md += "## Weights"
$md += "| Criterion | Weight |"
$md += "| --- | ---: |"
foreach ($k in ($weightMap.Keys | Sort-Object)) { $md += ("| {0} | {1:N2} |" -f $k, $weightMap[$k]) }
$md += ""

$accepted = $sorted | Where-Object { -not $_.Rejected }
$rejected = $sorted | Where-Object { $_.Rejected }

$md += "## Ranking"
$md += ""
if ($accepted.Count -eq 0) {
    $md += "⚠️  **No region passed hard filters.** See rejection reasons below."
} else {
    $md += "| Rank | Region | Score | Coverage | Latency (ms) | Price Δ % | Capacity |"
    $md += "| ---: | --- | ---: | ---: | ---: | ---: | --- |"
    $rank = 0
    foreach ($r in $accepted) {
        $rank++
        $marker = if ($r.IsSource) { ' (source)' } else { '' }
        $latDisp = if ($r.LatencyMs -eq $null) { '?' } else { $r.LatencyMs }
        $priceDisp = if ($r.PriceDeltaPercent -eq $null) { '?' } else { ("{0:+0.0;-0.0;0.0}" -f $r.PriceDeltaPercent) }
        $capDisp = if ($r.CapacityStatus -eq 'unknown') { 'unknown' } else { $r.CapacityStatus }
        $md += ("| {0} | ``{1}``{2} | {3:N3} | {4}% | {5} | {6} | {7} |" -f `
            $rank, $r.RegionName, $marker, $r.FinalScore, $r.CoveragePercent, $latDisp, $priceDisp, $capDisp)
    }
}
$md += ""

if ($rejected.Count -gt 0) {
    $md += "## Rejected (hard filters)"
    $md += ""
    $md += "| Region | Reason |"
    $md += "| --- | --- |"
    foreach ($r in $rejected) {
        $md += ("| ``{0}`` | {1} |" -f $r.RegionName, $r.RejectionReasons)
    }
    $md += ""
}

$md += "## Detail per region (accepted, ranked)"
$md += ""
$rank = 0
foreach ($r in $accepted) {
    $rank++
    $marker = if ($r.IsSource) { ' *(source)*' } else { '' }
    $md += ("### {0}. {1} (``{2}``){3}" -f $rank, $r.DisplayName, $r.RegionName, $marker)
    $md += ""
    $md += ("- **Final score**: {0:N3}" -f $r.FinalScore)
    $md += ("- **Physical**: {0}" -f $r.Physical)
    $md += ("- **Geography**: {0}" -f $r.Geography)
    $md += ("- **AZ count**: {0}" -f $r.AZCount)
    $pairedDisplay = if ($r.PairedWith) { "``$($r.PairedWith)``" } else { '(none — 3+0 topology)' }
    $md += ("- **Paired region**: {0}" -f $pairedDisplay)
    $md += ("- **Coverage**: {0}% ({1} covered, {2} missing → {3} instances at risk)" -f $r.CoveragePercent, $r.TypesCovered, $r.TypesMissing, $r.InstancesMissing)
    $latShow = if ($r.LatencyMs -eq $null) { 'unknown' } else { "$($r.LatencyMs) ms" }
    $md += ("- **Latency to ``{0}``**: {1}" -f $SourceRegion, $latShow)
    $priceShow = if ($r.PriceDeltaPercent -eq $null) { 'unknown' } else { ("{0:+0.0;-0.0;0.0}% vs source" -f $r.PriceDeltaPercent) }
    $md += ("- **Compute price delta**: {0}" -f $priceShow)
    $md += ("- **Cross-region peering**: `${0}/GB" -f $r.PeeringRatePerGb)
    $capDisplay = if ($r.CapacityStatus -eq 'unknown') { 'unknown (populate data/capacity-status-template.csv for status)' } else { "$($r.CapacityStatus) — $($r.CapacityRestriction) — mitigation: $($r.CapacityMitigation)" }
    $md += ("- **Capacity**: {0}" -f $capDisplay)
    $md += ""
    $md += "**Per-criterion scores:**"
    $md += ""
    $md += "| Criterion | Score | Weight | Weighted |"
    $md += "| --- | ---: | ---: | ---: |"
    $rows = @(
        @{ Name='coverage'; Score=$r.CoverageScore },
        @{ Name='latency_to_source'; Score=$r.LatencyScore },
        @{ Name='capacity_health'; Score=$r.CapacityScore },
        @{ Name='compute_price_delta'; Score=$r.PriceScore },
        @{ Name='az_support'; Score=$r.AZScore },
        @{ Name='sku_portability'; Score=$r.SKUPortabilityScore },
        @{ Name='egress_cost'; Score=$r.EgressScore },
        @{ Name='region_maturity'; Score=$r.MaturityScore }
    )
    foreach ($row in $rows) {
        $w = if ($weightMap.ContainsKey($row.Name)) { $weightMap[$row.Name] } else { 0 }
        $weighted = $row.Score * $w
        $md += ("| {0} | {1:N3} | {2:N2} | {3:N3} |" -f $row.Name, $row.Score, $w, $weighted)
    }
    $md += ""
    if ($r.TypesMissing -gt 0) {
        $md += "**Missing resource types:**"
        $md += ""
        $missingList = $r.MissingTypesList -split '; '
        foreach ($m in $missingList) { $md += "- $m" }
        $md += ""
    }
}

$mdPath = Join-Path $OutputDirectory ("region-scorecard-{0}.md" -f $srcSlug)
$md -join "`n" | Set-Content -Path $mdPath -Encoding UTF8
Write-Host ("  Wrote {0}" -f $mdPath)

# --- Console summary ---------------------------------------------------------
Write-Host ""
Write-Host ("=== Region scorecard summary (source: {0}) ===" -f $SourceRegion) -ForegroundColor Cyan
$rank = 0
foreach ($r in $accepted | Select-Object -First 10) {
    $rank++
    $marker = if ($r.IsSource) { ' *' } else { '  ' }
    $rttShow = if ($r.LatencyMs -eq $null) { '?' } else { $r.LatencyMs }
    $priceShowSummary = if ($r.PriceDeltaPercent -eq $null) { '?' } else { $r.PriceDeltaPercent }
    $capShowSummary = if ($r.CapacityStatus -eq 'unknown') { 'unknown' } else { 'known' }
    Write-Host ("  #{0,2}{1} {2,-24}  score={3:N3}  cov={4,5}%  rtt={5,4}ms  price={6,6}%  cap={7}" -f `
        $rank, $marker, $r.RegionName, $r.FinalScore, $r.CoveragePercent,
        $rttShow, $priceShowSummary, $capShowSummary)
}
if ($rejected.Count -gt 0) {
    Write-Host ("`n  Rejected by hard filters ({0}):" -f $rejected.Count) -ForegroundColor Yellow
    foreach ($r in $rejected) {
        Write-Host ("    - {0}: {1}" -f $r.RegionName, $r.RejectionReasons) -ForegroundColor DarkYellow
    }
}
Write-Host ("`n  See {0} for the full report." -f $mdPath) -ForegroundColor Green
