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
