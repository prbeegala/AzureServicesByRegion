# `data/`

Reference data used by [`Score-AzureRegionFit.ps1`](../Score-AzureRegionFit.ps1).
Every file in here is customer-shareable and derived from **public** Microsoft
sources unless explicitly noted.

## Files

| File | Purpose | Public source | Refresh cadence |
|------|---------|---------------|:---------------:|
| [`skus-by-region.json`](./skus-by-region.json) | Canonical SKU x region snapshot for 11 Tier 1 providers (APIM, Compute, Storage, Cache, CognitiveServices, Kusto, Synapse, MachineLearningServices, Web, Sql, DBforPostgreSQL) | ARM `/providers/{ns}/skus`, `/providers/Microsoft.Web/geoRegions?sku=X`, `/providers/{ns}/locations/{loc}/capabilities` | Weekly (auto, see [../.github/workflows/refresh-snapshots.yml](../.github/workflows/refresh-snapshots.yml)) |
| [`latency-baseline.json`](./latency-baseline.json) | Inter-region P50 RTT | [learn.microsoft.com — Azure network round-trip latency statistics](https://learn.microsoft.com/en-us/azure/networking/azure-network-latency) | 6-9 months (per Microsoft's own cadence) |
| [`egress-rates.json`](./egress-rates.json) | VNet peering + internet egress rates | [Azure Bandwidth Pricing](https://azure.microsoft.com/en-us/pricing/details/bandwidth/) | Annual (rates change infrequently) |
| [`scoring-weights.default.json`](./scoring-weights.default.json) | Default soft-scoring weights + 4 alternative profiles | This repo | On profile change |
| [`capacity-status-template.csv`](./capacity-status-template.csv) | Empty template for optional capacity override | (blank shape) | Whenever you refresh your Capacity Portal view |

## `skus-by-region.json`

Produced by [`../Get-AzureSkusByRegion.ps1`](../Get-AzureSkusByRegion.ps1)
and consumed by [`../Score-AzureRegionFit.ps1`](../Score-AzureRegionFit.ps1)
for its SKU-portability soft score. Also rendered as human-readable
Markdown/CSV under `../outputs/skus-by-region/<geo>/`.

Refresh manually with:

```powershell
./Get-AzureSkusByRegion.ps1 -GeographyGroup Europe
```

...or leave it to the weekly [Refresh snapshots](../.github/workflows/refresh-snapshots.yml)
workflow. See [`../docs/AUTOMATION.md`](../docs/AUTOMATION.md) for the OIDC
setup that lets Actions push refreshed data/ and outputs/ back to the repo.

Providers deferred to a Tier 2 backlog because their SKUs aren't cleanly
enumerable at subscription scope: DBforMySQL, EventHub, ServiceBus,
SignalRService, App/Container Apps, KeyVault, Search, Batch, DataFactory,
DocumentDB. See the GitHub issue tracker for the auto-discover feature that
would fold these in.

## `latency-baseline.json`

Microsoft publishes P50 round-trip time between every region pair on the
Azure backbone. This file is a snapshot; the schema is documented inside the
file's `notes` section.

**Coverage.** The Microsoft public dataset does not yet include the newest
regions (Belgium Central, Denmark East, Spain Central, Austria East, Qatar
Central for many pairs). For those, the tool falls back to a great-circle
distance estimate using `region_metadata.<region>.coords`. The estimate is
`5 ms + 0.01 ms per km` (Microsoft-WAN factor) — good enough for stack-ranking
but never treat as authoritative.

**Refresh.** When Microsoft updates the source page (usually every 6-9
months), re-snapshot. There is no first-class API; the source is an HTML
table. A future `Get-LatencyBaseline.ps1` script can be added to scrape it.
For now, refresh manually and update `snapshot_date`.

## `egress-rates.json`

Encodes VNet peering rates (in-region vs cross-region) and internet-egress
tiers. The primary use in the scoring model is the *delta* between in-region
peering ($0.01/GB) and cross-region peering ($0.02/GB within Zone 1, higher
across zones), which drives the egress-cost score for a "keep the hub, put
the new workload in region X" scenario.

**Zones.** Azure billing groups regions into 4 bandwidth zones. The mapping
is inside the file. If Microsoft adds a new region, add it to the appropriate
zone (usually Zone 1 for EU/US/UK/CA/MX; Zone 2 for APAC; Zone 3 for MEA and
LATAM).

## `scoring-weights.default.json`

Default weights that sum to 1.0. Also ships 4 alternative profiles
(`cost_optimised`, `latency_critical`, `capacity_first`, `critical_prod`) —
select via `Score-AzureRegionFit.ps1 -WeightsProfile <name>`. To use your
own weights, copy the file, edit, and pass via `-WeightsFile <path>`.

The scoring model itself is documented in
[`../docs/region-selection-framework.md` §8](../docs/region-selection-framework.md#8-scoring-approach--bridge-to-the-tool).

## `capacity-status-template.csv`

**Empty by design.** The Microsoft Capacity Portal export
([aka.ms/AzureCapacity](https://aka.ms/AzureCapacity)) is
**MICROSOFT INTERNAL ONLY** and cannot be committed to a public repo. This
template ships the column shape so that:

- Microsoft field team members can populate it from the Capacity Portal for
  a specific customer engagement.
- Customers whose Microsoft account team has shared current capacity status
  can enter the values themselves.

If the file is empty when `Score-AzureRegionFit.ps1` runs, capacity health is
scored as a neutral 0.5 for every region, and `-ExcludeConstrained` is a
no-op. Populate it to get meaningful capacity filtering.

## Refresh procedure

There is no automated refresh today. The commands below are manual snapshots:

```powershell
# Latency — currently manual. Copy the source URL's HTML tables and update
# latency-baseline.json in place. Increment snapshot_date.

# Egress rates — currently manual. Check the pricing page for changes.
# Update egress-rates.json in place. Increment snapshot_date.

# Weights — no refresh needed unless you tune the model.

# Capacity status — customer-specific, per-engagement.
```
