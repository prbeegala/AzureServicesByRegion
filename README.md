# Get-AzureServicesByRegion

> **A single self-contained PowerShell script that maps every Azure resource provider (service) to every region of any Azure geography — with friendly service names and categories.**

Point it at Europe, US, Asia Pacific, UK, Canada, Middle East, Africa, South America, Mexico — whatever geography your subscription can see. Get a CSV matrix, a Markdown breakdown, and a per-region summary. No dependencies beyond Azure CLI.

---

## Why this exists

Azure has more than 300 resource providers and rolls services out to new regions constantly. The "Azure products by region" marketing page is human-friendly but doesn't map cleanly to ARM namespaces, and it's a hassle to scrape.

This script uses the **authoritative source** — the ARM provider metadata (`az account list-locations` + `az provider list`) — to build an exhaustive, machine-readable matrix of *which services are available in which regions*, plus a curated friendly-name and category view.

## Quick start

```powershell
az login
git clone https://github.com/prbeegala/AzureServicesByRegion.git
cd AzureServicesByRegion
./Get-AzureServicesByRegion.ps1
```

Default run enumerates **Europe** using your current subscription and writes 5 files to the current directory.

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
