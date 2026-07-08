# Sample outputs

Point-in-time snapshots produced by running `Get-AzureServicesByRegion.ps1`
against three representative Azure geographies on **2026-07-08**.

Provided so you can see the exact shape of the outputs *before* running the
tool yourself. To regenerate against a live Azure subscription, run:

```powershell
./Get-AzureServicesByRegion.ps1 -GeographyGroup 'Europe' -OutputDirectory ./outputs/europe
./Get-AzureServicesByRegion.ps1 -GeographyGroup 'US'     -OutputDirectory ./outputs/us
./Get-AzureServicesByRegion.ps1 -GeographyGroup 'Asia Pacific' -OutputDirectory ./outputs/asia-pacific
```

Every geography snapshot contains the same 5 files:

| File | Purpose |
| --- | --- |
| `services-by-<geo>-region.csv` | Raw matrix of every provider × region, cells `yes` / `no` / `global`. |
| `services-by-<geo>-region.md` | Per-region **Available / Not available** lists (namespaces only). |
| `services-by-<geo>-region-friendly.csv` | Same matrix with curated `ServiceName` and `Category`. |
| `services-by-<geo>-region-friendly.md` | Per-region breakdown grouped by category, using friendly names. |
| `<geo>-region-summary.csv` | Per-region counts of Available / Unavailable / Global providers. |

Total providers observed: **318** (42 global, 276 region-scoped).

## Europe (17 regions) — [`outputs/europe/`](./europe)

| Rank | Region | Physical | Available | Not available |
| ---: | --- | --- | ---: | ---: |
| 1 | West Europe | Netherlands | 195 | 81 |
| 2 | North Europe | Ireland | 183 | 93 |
| 3 | Germany West Central | Frankfurt | 143 | 133 |
| 4 | Sweden Central | Gävle | 142 | 134 |
| 5 | France Central | Paris | 132 | 144 |
| 6 | Switzerland North | Zurich | 126 | 150 |
| 7 | Norway East | Norway | 119 | 157 |
| 8 | Italy North | Milan | 110 | 166 |
| 9 | Poland Central | Warsaw | 89 | 187 |
| 10 | Spain Central | Madrid | 88 | 188 |
| 11 | Switzerland West | Geneva | 82 | 194 |
| 12 | France South | Marseille | 65 | 211 |
| 13 | Norway West | Norway | 61 | 215 |
| 14 | Austria East | Vienna | 61 | 215 |
| 15 | Germany North | Berlin | 59 | 217 |
| 16 | Belgium Central | Brussels | 57 | 219 |
| 17 | Denmark East | Copenhagen | 54 | 222 |

## United States (20 regions) — [`outputs/us/`](./us)

| Rank | Region | Physical | Available | Not available |
| ---: | --- | --- | ---: | ---: |
| 1 | East US | Virginia | 209 | 67 |
| 2 | West US 2 | Washington | 180 | 96 |
| 3 | East US 2 | Virginia | 171 | 105 |
| 4 | South Central US | Texas | 164 | 112 |
| 5 | West US | California | 159 | 117 |
| 6 | Central US | Iowa | 158 | 118 |
| 7 | West US 3 | Phoenix | 148 | 128 |
| 8 | West Central US | Wyoming | 139 | 137 |
| 9 | North Central US | Illinois | 124 | 152 |
| 10 | East US 2 EUAP | *(early access)* | 64 | 212 |
| 11 | Central US EUAP | *(early access)* | 55 | 221 |
| — | Stage / STG regions (8) | *(internal)* | 0 | 276 |

**Note:** *Stage* and *STG* regions are internal Microsoft testing regions and
are not customer-selectable. *EUAP* (Early Update Access Program) regions are
where new features roll out first — customers with EUAP access can use them.
That's why they show 0 or low provider counts.

## Asia Pacific (20 regions) — [`outputs/asia-pacific/`](./asia-pacific)

| Rank | Region | Physical | Available | Not available |
| ---: | --- | --- | ---: | ---: |
| 1 | Australia East | New South Wales | 167 | 109 |
| 2 | Southeast Asia | Singapore | 163 | 113 |
| 3 | Japan East | Tokyo, Saitama | 146 | 130 |
| 4 | Central India | Pune | 141 | 135 |
| 5 | East Asia | Hong Kong | 132 | 144 |
| 6 | Korea Central | Seoul | 129 | 147 |
| 7 | Australia Southeast | Victoria | 122 | 154 |
| 8 | South India | Chennai | 115 | 161 |
| 9 | Japan West | Osaka | 114 | 162 |
| 10 | Korea South | Busan | 89 | 187 |
| 11 | Australia Central | Canberra | 81 | 195 |
| 12 | Malaysia West | Kuala Lumpur | 76 | 200 |
| 13 | Indonesia Central | Jakarta | 71 | 205 |
| 14 | New Zealand North | Auckland | 70 | 206 |
| 15 | West India | Mumbai | 69 | 207 |
| 16 | Australia Central 2 | Canberra | 54 | 222 |
| — | Stage / Jio India regions (4) | *(internal / partner)* | 0 | 276 |

**Note:** *Stage* regions are internal. *Jio India* regions are operated by
Jio Platforms and require a separate partnership to consume.

## `Compare-AzureRegionCoverage.ps1` examples

Sample outputs for **`Compare-AzureRegionCoverage.ps1`** are provided for
**four different source regions across four geographies**, each with a
different synthetic workload profile so you can see how the tool behaves for
small, medium, and large estates. No real customer data — every inventory is
hand-crafted.

| Folder | Source region | Geography | Types | Instances |
| --- | --- | --- | ---: | ---: |
| [`coverage-example-northeurope/`](./coverage-example-northeurope) | `northeurope` | Europe (17 regions) | 40 | 573 |
| [`coverage-example-eastus/`](./coverage-example-eastus) | `eastus` | US (9 customer regions) | 54 | 1,327 |
| [`coverage-example-southeastasia/`](./coverage-example-southeastasia) | `southeastasia` | Asia Pacific (18 regions) | 37 | 453 |
| [`coverage-example-uksouth/`](./coverage-example-uksouth) | `uksouth` | UK (2 regions) + Europe fallback | 37 | 508 |

Each folder contains:
- `example-inventory.csv` — the synthetic workload (`ResourceType`, `Instances`).
- `deployed-types-<src>.csv` — the normalised inventory the script produces.
- `region-coverage-<src>.csv` — score matrix (every candidate region).
- `region-coverage-<src>.md` — human-readable ranking + gap analysis.

The North Europe example additionally has `validate-swedencentral/` and
`validate-eastus/` sub-folders demonstrating Validate mode (single-target).
The UK South example has `europe-fallback/` which scores UK South against
all European regions — useful for cross-geography failover planning.

### Reproduce

```powershell
# Score every European region against a synthetic North Europe workload
./Compare-AzureRegionCoverage.ps1 -SourceRegion northeurope `
    -InventoryFile ./outputs/coverage-example-northeurope/example-inventory.csv `
    -OutputDirectory ./out

# Score every US region against a synthetic East US workload
./Compare-AzureRegionCoverage.ps1 -SourceRegion eastus -GeographyGroup 'US' `
    -InventoryFile ./outputs/coverage-example-eastus/example-inventory.csv `
    -OutputDirectory ./out

# Score every Asia Pacific region against a synthetic Southeast Asia workload
./Compare-AzureRegionCoverage.ps1 -SourceRegion southeastasia -GeographyGroup 'Asia Pacific' `
    -InventoryFile ./outputs/coverage-example-southeastasia/example-inventory.csv `
    -OutputDirectory ./out

# UK South workload, first against UK, then failover into Europe
./Compare-AzureRegionCoverage.ps1 -SourceRegion uksouth -GeographyGroup 'UK' `
    -InventoryFile ./outputs/coverage-example-uksouth/example-inventory.csv `
    -OutputDirectory ./out
./Compare-AzureRegionCoverage.ps1 -SourceRegion uksouth -GeographyGroup 'Europe' `
    -InventoryFile ./outputs/coverage-example-uksouth/example-inventory.csv `
    -OutputDirectory ./out/europe-fallback

# Validate a single specific target
./Compare-AzureRegionCoverage.ps1 -SourceRegion northeurope `
    -InventoryFile ./outputs/coverage-example-northeurope/example-inventory.csv `
    -TargetRegion swedencentral `
    -OutputDirectory ./out
```

### Sample ranking — Europe (source: `northeurope`, 40 types, 573 instances)

| Rank | Region | Coverage | Missing | Instances at risk |
| ---: | --- | ---: | ---: | ---: |
| 1 | West Europe | 100.0% | 0 | 0 |
| 2 | France Central | 97.5% | 1 | 6 |
| 3 | Germany West Central | 97.5% | 1 | 6 |
| 4 | North Europe *(source)* | 97.5% | 1 | 6 |
| 5 | Norway East | 97.5% | 1 | 6 |
| 6 | Sweden Central | 97.5% | 1 | 6 |
| 7 | Switzerland North | 97.5% | 1 | 6 |
| 8 | Italy North | 95.0% | 2 | 7 |
| 9 | Poland Central | 92.5% | 3 | 8 |
| 10 | Spain Central | 92.5% | 3 | 8 |
| 11 | Austria East | 85.0% | 6 | 23 |
| 12 | Belgium Central | 80.0% | 8 | 45 |
| 13 | Denmark East | 80.0% | 8 | 45 |
| 14 | Switzerland West | 30.0% | 28 | 445 |
| 15 | France South | 25.0% | 30 | 513 |
| 16 | Germany North | 20.0% | 32 | 524 |
| 17 | Norway West | 17.5% | 33 | 526 |

### Sample ranking — US (source: `eastus`, 54 types, 1,327 instances)

| Rank | Region | Coverage | Missing | Instances at risk |
| ---: | --- | ---: | ---: | ---: |
| 1 | Central US | 98.1% | 1 | 2 |
| 2 | East US 2 | 98.1% | 1 | 2 |
| 3 | West US 2 | 96.3% | 2 | 5 |
| 4 | East US *(source)* | 96.3% | 2 | 20 |
| 5 | South Central US | 96.3% | 2 | 20 |
| 6 | West US | 96.3% | 2 | 20 |
| 7 | West US 3 | 94.4% | 3 | 23 |
| 8 | North Central US | 92.6% | 4 | 25 |
| 9 | West Central US | 92.6% | 4 | 61 |

**Notable finding:** East US (source) shows 96.3% because a couple of newer
services (Redis Enterprise, Front Door Premium features) aren't listed in
every East US resource type's regions array. Central US and East US 2 are
the natural DR pairs — 98.1% coverage each.

### Sample ranking — Asia Pacific (source: `southeastasia`, 37 types, 453 instances)

| Rank | Region | Coverage | Missing | Instances at risk |
| ---: | --- | ---: | ---: | ---: |
| 1 | Australia East | 100.0% | 0 | 0 |
| 2 | Central India | 100.0% | 0 | 0 |
| 3 | East Asia | 100.0% | 0 | 0 |
| 4 | Japan East | 100.0% | 0 | 0 |
| 5 | Japan West | 100.0% | 0 | 0 |
| 6 | Korea Central | 100.0% | 0 | 0 |
| 7 | South India | 100.0% | 0 | 0 |
| 8 | Southeast Asia *(source)* | 100.0% | 0 | 0 |
| 9 | Australia Southeast | 97.3% | 1 | 3 |
| 10 | Indonesia Central | 97.3% | 1 | 3 |
| 11 | Malaysia West | 97.3% | 1 | 3 |
| 12 | New Zealand North | 91.9% | 3 | 13 |
| 13 | Korea South | 89.2% | 4 | 15 |
| 14 | Australia Central | 83.8% | 6 | 25 |
| 15 | West India | 70.3% | 11 | 46 |
| 16 | Australia Central 2 | 16.2% | 31 | 424 |
| 17 | Jio India Central | 0.0% | 37 | 453 |
| 18 | Jio India West | 0.0% | 37 | 453 |

**Notable finding:** APAC has an unusually wide spread of viable failover
regions (8 regions at 100%). Jio India regions score 0% because they are
partner-operated and expose almost no Microsoft.* resource types to
non-Jio subscriptions.

### Sample ranking — UK (source: `uksouth`, 37 types, 508 instances)

| Rank | Region | Coverage | Missing | Instances at risk |
| ---: | --- | ---: | ---: | ---: |
| 1 | UK South *(source)* | 97.3% | 1 | 8 |
| 2 | UK West | 94.6% | 2 | 9 |

**UK South failover into Europe** (see `coverage-example-uksouth/europe-fallback/`):

| Rank | Region | Coverage | Missing | Instances at risk |
| ---: | --- | ---: | ---: | ---: |
| 1 | West Europe | 100.0% | 0 | 0 |
| 2-8 | France Central / Germany WC / Italy North / North Europe / Norway East / Sweden Central / Switzerland North | 97.3% | 1 | 8 |
| 11 | Austria East | 86.5% | 5 | 25 |
| 14 | Switzerland West | 27.0% | 27 | 394 |
| 17 | Norway West | 16.2% | 31 | 466 |

**Notable finding:** UK has only 2 regions, so for real DR planning you often
have to cross into Europe. West Europe offers 100% coverage for this
synthetic workload, making it the natural cross-geo pair.

## What "global" means

Every geography's summary includes 42 **global providers** — resource
providers that have no region-scoped resource types. Examples:

- Entra ID / Azure Active Directory
- Azure Resource Manager (`Microsoft.Resources`)
- Azure DNS, Traffic Manager, Front Door
- Azure Policy, Blueprints, Management Groups
- Azure Advisor, Resource Health, Cost Management

Those show as `global` in every region column of the CSVs and appear in
every region's Available list of the friendly markdown.

## Snapshot metadata

- **Generated:** 2026-07-08
- **Providers:** 318 (42 global, 276 region-scoped)
- **Resource types:** 4,663
- **Tool version:** `Get-AzureServicesByRegion.ps1` @ initial import
- **Source subscription:** an active EA subscription in `AzureCloud`. Provider
  metadata is largely subscription-independent, so any active subscription
  should produce equivalent results.
