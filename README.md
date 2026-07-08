# AzureServicesByRegion

> **Two self-contained PowerShell tools for Azure regional planning:**
>
> 1. **`Get-AzureServicesByRegion.ps1`** — map every Azure resource provider (service) to every region of any Azure geography, with friendly names and categories.
> 2. **`Compare-AzureRegionCoverage.ps1`** — take a region you actually deploy in and score every other region by how much of your workload it can host. Answers *"is Sweden Central a viable failover for my North Europe workload?"* or *"which European region best matches what I run today?"*

Point them at Europe, US, Asia Pacific, UK, Canada, Middle East, Africa, South America, Mexico — whatever geography your subscription or tenant can see. Get CSV matrices, Markdown breakdowns, and per-region summaries. No dependencies beyond Azure CLI.

---

## Why these exist

Azure has more than 300 resource providers and rolls services out to new regions constantly. The "Azure products by region" marketing page is human-friendly but doesn't map cleanly to ARM namespaces, and it's a hassle to scrape.

- **`Get-AzureServicesByRegion.ps1`** answers *"what's available where?"* — an exhaustive catalog built from the authoritative ARM provider metadata (`az account list-locations` + `az provider list`).
- **`Compare-AzureRegionCoverage.ps1`** answers *"where can I run **my** workload?"* — it inventories what you actually have deployed (via Azure Resource Graph) and cross-references against the catalog.

## Quick start

```powershell
az login
git clone https://github.com/prbeegala/AzureServicesByRegion.git
cd AzureServicesByRegion
./Get-AzureServicesByRegion.ps1
```

Default run enumerates **Europe** using your current subscription and writes 5 files to the current directory.

## See it before you run it

Sample outputs are checked in under [`outputs/`](./outputs) so you can inspect the file shapes and the friendly-name mapping before running anything:

- **`Get-AzureServicesByRegion`** snapshots:
  - [`outputs/europe/`](./outputs/europe) — 17 regions, West Europe (195 providers) → Denmark East (54)
  - [`outputs/us/`](./outputs/us) — 20 regions, East US leads with 209 providers
  - [`outputs/asia-pacific/`](./outputs/asia-pacific) — 20 regions, Australia East leads with 167 providers
- **`Compare-AzureRegionCoverage`** examples (four different source regions):
  - [`outputs/coverage-example-northeurope/`](./outputs/coverage-example-northeurope) — Europe geography (17 regions), 40 types, 573 instances. Includes validate-mode deep dives.
  - [`outputs/coverage-example-eastus/`](./outputs/coverage-example-eastus) — US geography (9 customer regions), 54 types, 1,327 instances.
  - [`outputs/coverage-example-southeastasia/`](./outputs/coverage-example-southeastasia) — Asia Pacific (18 regions), 37 types, 453 instances.
  - [`outputs/coverage-example-uksouth/`](./outputs/coverage-example-uksouth) — UK (2 regions) + Europe fallback, 37 types, 508 instances.
- [`outputs/README.md`](./outputs/README.md) — full ranking tables and notes on Stage / EUAP / Jio regions.

## Prerequisites

- **Azure CLI** (`az`) on PATH — install from <https://learn.microsoft.com/cli/azure/install-azure-cli>
- **PowerShell 5.1+** (Windows) or **PowerShell 7+** (Windows / macOS / Linux)
- Signed in: `az login`

The script is **read-only** — it only reads provider and location metadata. It does not create, modify, or delete any Azure resources.

## Usage

```powershell
# Europe, current subscription, current directory
./Get-AzureServicesByRegion.ps1

# Any geography
./Get-AzureServicesByRegion.ps1 -GeographyGroup 'US' -OutputDirectory ./out
./Get-AzureServicesByRegion.ps1 -GeographyGroup 'Asia Pacific' -OutputDirectory ./out

# Use a specific subscription
./Get-AzureServicesByRegion.ps1 `
    -GeographyGroup 'UK' `
    -SubscriptionId 00000000-0000-0000-0000-000000000000 `
    -OutputDirectory ./out

# List the geography groups + regions your subscription can see
./Get-AzureServicesByRegion.ps1 -List

# Raw only (skip friendly-name mapping)
./Get-AzureServicesByRegion.ps1 -SkipFriendly

# Full help
Get-Help ./Get-AzureServicesByRegion.ps1 -Detailed
```

**macOS / Linux (PowerShell 7):**

```bash
pwsh ./Get-AzureServicesByRegion.ps1 -GeographyGroup 'Europe' -OutputDirectory ./out
```

**Windows: "cannot be loaded because running scripts is disabled":**

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `-GeographyGroup` | `Europe` | Azure geography group (case-insensitive). Use `-List` to enumerate. |
| `-SubscriptionId` | current context | Subscription to use. Provider metadata is largely subscription-independent, so any active subscription works. |
| `-OutputDirectory` | current directory | Where to write outputs. Created if missing. |
| `-SkipFriendly` | *(off)* | Skip the friendly-name outputs. |
| `-List` | *(off)* | Print geography groups + regions and exit. No files written. |

### What is `-SubscriptionId` for?

`Get-AzureServicesByRegion.ps1` only reads **metadata** — `az account list-locations` and `az provider list`. It does not enumerate any of your deployed resources. So `-SubscriptionId` is really doing three things:

1. **Picks the tenant.** If you're `az login`-ed to multiple tenants, the sub you pass determines which tenant the metadata queries run against. Different tenants may see different region lists (e.g., **EUAP** preview regions are only visible to enrolled subs).
2. **Controls the `Registration` column.** The `Registration` value (`Registered` / `NotRegistered`) is per-subscription. Region availability of each resource type is identical across all subs — that's a platform-wide fact.
3. **Reproducibility.** Passing it explicitly means the run doesn't silently pick up a different context if someone `az account set`s later.

For a plain "what services are in what regions" view, any active subscription in the target tenant works.

## Outputs

The `<geo>` slug is derived from `-GeographyGroup` (e.g. `europe`, `us`, `asia-pacific`).

| File | Purpose |
| --- | --- |
| `services-by-<geo>-region.csv` | Raw matrix: `Namespace` + `Registration` + `ResourceTypes` + `Global` + one column per region (`yes` / `no` / `global`). |
| `services-by-<geo>-region.md` | Per-region **Available / Not available** lists (namespaces only). |
| `services-by-<geo>-region-friendly.csv` | Same matrix, with curated `ServiceName` and `Category` columns. |
| `services-by-<geo>-region-friendly.md` | Per-region breakdown grouped by category, using friendly names. |
| `<geo>-region-summary.csv` | Per-region counts of Available / Unavailable / Global providers. |

`global` means the provider has no region-scoped resource types (Entra ID, ARM, DNS, Traffic Manager, …). Those show as `global` in every region column.

## Example: Europe snapshot

```
Rank  Region                     Available  Not available
  1   West Europe (Netherlands)      195          81
  2   North Europe (Ireland)         183          93
  3   Germany West Central           143         133
  4   Sweden Central                 142         134
  5   France Central                 132         144
  6   Switzerland North              126         150
  7   Norway East                    119         157
  8   Italy North                    110         166
  9   Poland Central                  89         187
 10   Spain Central                   88         188
 …
 17   Denmark East                    54         222
```

(+42 global providers count in every region.)

## Categories

Providers are grouped into human-friendly categories: **Compute, Storage, Databases, Networking, AI + ML, Analytics, Integration, Security, Identity, IoT, Containers, Web, DevOps, Developer Tools, Monitor, Management, Migration, Backup / DR, Hybrid + Multicloud, Marketplace, Blockchain**, plus **third-party ISV services** (MongoDB Atlas, Oracle Database at Azure, Databricks, Dynatrace, New Relic, NGINX, Palo Alto, Pure Storage, Qumulo, and more).

## How it works

1. `az account list-locations` returns every region with its geography group. The script filters by `metadata.geographyGroup`.
2. `az provider list` returns every provider with its `resourceTypes[]`, and each resource type advertises the regions it supports. The script takes the **union** of resource-type locations per provider.
3. Cross-references the two sets to emit the region matrix.
4. Applies the built-in friendly-name mapping (`Get-FriendlyServiceMap` — ~300 entries). Anything not in the map falls back to a "strip `Microsoft.` + space out PascalCase" heuristic and is tagged `Unmapped`.

## Caveats

- Region availability at the *provider* level is a first cut. Some resource types are more restricted than others; for the true unit of availability inspect `resourceTypes[].locations` directly (the raw CSV preserves this at the provider level, but you can extend the script to keep the per-type view).
- Some SKUs are further gated by capacity / quota per region. Verify with `az vm list-skus -l <region>` or the [Retail Prices API](https://learn.microsoft.com/rest/api/cost-management/retail-prices/azure-retail-prices) before committing to a design.
- Preview / hidden providers may not appear until you register them (`az provider register --namespace <ns>`).
- The friendly-name mapping is a best-effort translation. `Namespace` is the authoritative identifier — treat `ServiceName` as human-readable metadata.
- This is a snapshot. Azure rolls out services to new regions continually; re-run whenever you need fresh data.

## Extending the friendly-name map

Open the script and edit the hashtable inside `Get-FriendlyServiceMap`. Keys are lower-case namespaces:

```powershell
'microsoft.mynewservice' = @('My New Service','Compute')
```

PRs welcome — see [Contributing](#contributing).

---

# Compare-AzureRegionCoverage.ps1

Answers two questions:

1. **"Are all the services I use in ``<SourceRegion>`` also available in ``<TargetRegion>``?"** — validate a specific failover target.
2. **"Which region in ``<Geography>`` is the best match for what I have deployed in ``<SourceRegion>``?"** — score every candidate region and rank by coverage %.

Uses **Azure Resource Graph** to inventory the *resource types* you have actually deployed in the source region, then cross-references each type against every candidate region's supported locations (from ARM provider metadata).

## Quick start

```powershell
# Rank every European region against my current subscription's North Europe deployments.
./Compare-AzureRegionCoverage.ps1 -SourceRegion northeurope

# Validate a specific target.
./Compare-AzureRegionCoverage.ps1 -SourceRegion northeurope -TargetRegion swedencentral
```

## Scope: subscription vs tenant vs management group

You can control *whose* deployments to inventory with `-Scope`:

```powershell
# 1) Just my current subscription (default).
./Compare-AzureRegionCoverage.ps1 -SourceRegion northeurope -Scope Subscription

# 2) One or more specific subscriptions.
./Compare-AzureRegionCoverage.ps1 -SourceRegion northeurope `
    -Scope Subscription -SubscriptionId <guid1>,<guid2>

# 3) The whole tenant (the tenant of your current az context, or an explicit one).
./Compare-AzureRegionCoverage.ps1 -SourceRegion northeurope -Scope Tenant
./Compare-AzureRegionCoverage.ps1 -SourceRegion northeurope -Scope Tenant `
    -TenantId 00000000-0000-0000-0000-000000000000

# 4) Everything under a management group.
./Compare-AzureRegionCoverage.ps1 -SourceRegion eastus -GeographyGroup 'US' `
    -Scope ManagementGroup -ManagementGroupId prod-mg
```

When you pick `-Scope Tenant` with a `-TenantId` that isn't your current `az` context, the script temporarily switches to a subscription in that tenant (required for Resource Graph auth), runs the query, and **restores your original context on exit** (including on error).

## Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `-SourceRegion` | *(required)* | The region whose deployments you want to reproduce (e.g. `northeurope`). |
| `-TargetRegion` | *(unset)* | If set, validate this single target region and produce a focused report. |
| `-GeographyGroup` | `Europe` | When ranking, restrict candidates to this geography group. |
| `-Scope` | `Subscription` | `Subscription` / `Tenant` / `ManagementGroup`. |
| `-TenantId` | *(current)* | For `-Scope Tenant`, an explicit tenant ID. |
| `-SubscriptionId` | *(current)* | For `-Scope Subscription`, one or more sub IDs. |
| `-ManagementGroupId` | *(unset)* | For `-Scope ManagementGroup`, the MG ID. |
| `-OutputDirectory` | current directory | Where to write outputs. |
| `-MinResourceCount` | `1` | Ignore resource types with fewer than N instances in source. |
| `-IncludeStageRegions` | *(off)* | Include Stage / EUAP regions in the candidate list. |

## Outputs

For source region `<src>`:

| File | Purpose |
| --- | --- |
| `deployed-types-<src>.csv` | Inventory of resource types found in the source region, with instance counts. |
| `region-coverage-<src>.csv` | Per-region coverage: `CoveragePercent`, `TypesCovered`, `TypesMissing`, `InstancesMissing`, `MissingTypesList`, and region metadata (paired region, physical location, category). |
| `region-coverage-<src>.md` | Human-readable report with ranking table + per-region gap details. |

## Example output — real-world Score mode

A tenant with **96 distinct resource types deployed in North Europe** produces (regions sorted by coverage):

```
Region             Coverage Covered Missing InstancesAtRisk
northeurope        100%          96       0               0   <-- source
westeurope         99.0%         95       1               1
swedencentral      97.9%         94       2               2
francecentral      96.9%         93       3               3
germanywestcentral 96.9%         93       3               3
norwayeast         96.9%         93       3               3
switzerlandnorth   96.9%         93       3               3
italynorth         92.7%         89       7             244
polandcentral      92.7%         89       7             244
spaincentral       92.7%         89       7             244
austriaeast        82.3%         79      17             414
belgiumcentral     72.9%         70      26             980
denmarkeast        72.9%         70      26             980
switzerlandwest    37.5%         36      60           6,936
francesouth        31.2%         30      66           8,617
germanynorth       26.0%         25      71           8,668
norwaywest         26.0%         25      71           8,660
```

The Markdown report drills into **which resource types are missing in each region**, with instance counts, so you can quickly see what would need re-architecting (or SKU substitution) to move.

## How it works

1. Inventory the source region's resource types via Azure Resource Graph:
   ```kusto
   Resources
   | where location =~ '<SourceRegion>'
   | summarize count() by type
   ```
2. Load the ARM provider catalog (`az provider list`) and index every `namespace/resourceType` to its supported locations.
3. For each candidate region, walk the inventory: each deployed type is either **covered** (target region supports it, or it's global), **missing**, or **unknown** (not in provider metadata — rare edge case).
4. Compute `coverage % = covered / (covered + missing)` and rank.

## Caveats

- Coverage at the resource-type level is a necessary condition, not a sufficient one. Regional SKU availability, quota, and capacity may still constrain deployment — verify with `az vm list-skus -l <region>` and the [Retail Prices API](https://learn.microsoft.com/rest/api/cost-management/retail-prices/azure-retail-prices).
- Resource Graph reflects your current permissions. Subscriptions you don't have Reader on won't appear.
- Very fresh deployments (created within ~5 minutes) may not appear in Resource Graph yet.
- The tool is read-only — Resource Graph queries + ARM metadata reads. It does not modify any resources.
- Global resources (`location = 'global'`) are naturally covered by every candidate.

---

## Contributing

Contributions welcome, especially:

- **Friendly-name additions / corrections** for new or missing providers.
- **Category refinements** — the current grouping is opinionated.
- **Alternative outputs** — Excel workbook, JSON, HTML, PDF.
- **Per-resource-type breakdown** — a `-Granularity ResourceType` mode.
- **Alternative auth** — Az PowerShell module fallback, service principal support.

Open an issue or PR. Keep the script standalone (single file, no external modules) unless there's a strong reason.

## License

[MIT](./LICENSE) — do what you like with it. Attribution appreciated but not required.
