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

## `Compare-AzureRegionCoverage.ps1` example — [`outputs/coverage-example-northeurope/`](./coverage-example-northeurope)

Sample outputs for **`Compare-AzureRegionCoverage.ps1`** produced against a
**synthetic mid-sized enterprise workload** (40 resource types, 573 instances)
that plausibly lives in North Europe. No real customer data — the inventory is
hand-crafted so anyone can reproduce or modify it.

Files:

| Path | Purpose |
| --- | --- |
| [`example-inventory.csv`](./coverage-example-northeurope/example-inventory.csv) | The synthetic workload profile (ResourceType, Instances). Feed it back into the script with `-InventoryFile` for your own what-if runs. |
| [`deployed-types-northeurope.csv`](./coverage-example-northeurope/deployed-types-northeurope.csv) | The normalised inventory the script produces from the input. |
| [`region-coverage-northeurope.csv`](./coverage-example-northeurope/region-coverage-northeurope.csv) | **Score mode** result — every European region ranked by how well it covers the workload. |
| [`region-coverage-northeurope.md`](./coverage-example-northeurope/region-coverage-northeurope.md) | Human-readable score-mode report with per-region gap details. |
| [`validate-swedencentral/`](./coverage-example-northeurope/validate-swedencentral) | **Validate mode** result — deep dive on Sweden Central as a specific target. |
| [`validate-eastus/`](./coverage-example-northeurope/validate-eastus) | **Validate mode** — East US, to illustrate cross-geo validation. |

### Reproduce

```powershell
# Score every European region
./Compare-AzureRegionCoverage.ps1 -SourceRegion northeurope `
    -InventoryFile ./outputs/coverage-example-northeurope/example-inventory.csv `
    -OutputDirectory ./out

# Validate a single target
./Compare-AzureRegionCoverage.ps1 -SourceRegion northeurope `
    -InventoryFile ./outputs/coverage-example-northeurope/example-inventory.csv `
    -TargetRegion swedencentral `
    -OutputDirectory ./out
```

### Sample ranking (synthetic workload)

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

**Notable finding:** even the source region (`northeurope`) shows 97.5% because
`microsoft.web/staticsites` (Static Web Apps) is region-restricted in ARM to
West Europe and a few other regions, not North Europe. The tool surfaces this
kind of subtle regional gap even for regions users assume "have everything".

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
