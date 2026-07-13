# Region scorecard: source = `eastus`

Generated: 2026-07-09 16:43
Geography: **US**
Weights profile: **default**
Inventory: **offline** — `example-inventory.csv`
Inventory summary: **54** resource types, **1327** instances.

## Hard filters
| Filter | Value |
| --- | --- |
| Data residency | (none — geography = US) |
| Require AZs | no |
| Exclude constrained | no |
| Min coverage | 0% |

## Weights
| Criterion | Weight |
| --- | ---: |
| az_support | 0.10 |
| capacity_health | 0.15 |
| compute_price_delta | 0.15 |
| coverage | 0.25 |
| egress_cost | 0.04 |
| latency_to_source | 0.20 |
| region_maturity | 0.03 |
| sku_portability | 0.08 |

## Ranking

| Rank | Region | Score | Coverage | Latency (ms) | Price Δ % | Capacity |
| ---: | --- | ---: | ---: | ---: | ---: | --- |
| 1 | `eastus` (source) | 0.841 | 96.3% | 0 | 0.0 | unknown |
| 2 | `eastus2` | 0.808 | 98.1% | 10 | 0.0 | unknown |
| 3 | `centralus` | 0.733 | 98.1% | 29 | +13.1 | unknown |
| 4 | `northcentralus` | 0.704 | 92.6% | 20 | 0.0 | unknown |
| 5 | `westus3` | 0.704 | 94.4% | 57 | 0.0 | unknown |
| 6 | `southcentralus` | 0.677 | 96.3% | 36 | +19.8 | unknown |
| 7 | `westus2` | 0.677 | 96.3% | 79 | 0.0 | unknown |
| 8 | `westcentralus` | 0.564 | 92.6% | 53 | +19.8 | unknown |
| 9 | `westus` | 0.553 | 96.3% | 74 | +13.9 | unknown |

## Detail per region (accepted, ranked)

### 1. East US (`eastus`) *(source)*

- **Final score**: 0.841
- **Physical**: Virginia
- **Geography**: US
- **AZ count**: 3
- **Paired region**: `westus`
- **Coverage**: 96.3% (52 covered, 2 missing → 20 instances at risk)
- **Latency to `eastus`**: 0 ms
- **Compute price delta**: 0.0% vs source
- **Cross-region peering**: $0.01/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.963 | 0.25 | 0.241 |
| latency_to_source | 1.000 | 0.20 | 0.200 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.500 | 0.15 | 0.075 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 1.000 | 0.04 | 0.040 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (18)
- microsoft.communication/communicationservices (2)

### 2. East US 2 (`eastus2`)

- **Final score**: 0.808
- **Physical**: Virginia
- **Geography**: US
- **AZ count**: 3
- **Paired region**: `centralus`
- **Coverage**: 98.1% (53 covered, 1 missing → 2 instances at risk)
- **Latency to `eastus`**: 10 ms
- **Compute price delta**: 0.0% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.981 | 0.25 | 0.245 |
| latency_to_source | 0.900 | 0.20 | 0.180 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.500 | 0.15 | 0.075 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.communication/communicationservices (2)

### 3. Central US (`centralus`)

- **Final score**: 0.733
- **Physical**: Iowa
- **Geography**: US
- **AZ count**: 3
- **Paired region**: `eastus2`
- **Coverage**: 98.1% (53 covered, 1 missing → 2 instances at risk)
- **Latency to `eastus`**: 29 ms
- **Compute price delta**: +13.1% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.981 | 0.25 | 0.245 |
| latency_to_source | 0.710 | 0.20 | 0.142 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.174 | 0.15 | 0.026 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.communication/communicationservices (2)

### 4. North Central US (`northcentralus`)

- **Final score**: 0.704
- **Physical**: Illinois
- **Geography**: US
- **AZ count**: 0
- **Paired region**: `southcentralus`
- **Coverage**: 92.6% (50 covered, 4 missing → 25 instances at risk)
- **Latency to `eastus`**: 20 ms
- **Compute price delta**: 0.0% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.926 | 0.25 | 0.232 |
| latency_to_source | 0.800 | 0.20 | 0.160 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.500 | 0.15 | 0.075 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/staticsites (18)
- microsoft.dashboard/grafana (2)
- microsoft.monitor/accounts (3)
- microsoft.communication/communicationservices (2)

### 5. West US 3 (`westus3`)

- **Final score**: 0.704
- **Physical**: Phoenix
- **Geography**: US
- **AZ count**: 3
- **Paired region**: `eastus`
- **Coverage**: 94.4% (51 covered, 3 missing → 23 instances at risk)
- **Latency to `eastus`**: 57 ms
- **Compute price delta**: 0.0% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.944 | 0.25 | 0.236 |
| latency_to_source | 0.430 | 0.20 | 0.086 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.500 | 0.15 | 0.075 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/staticsites (18)
- microsoft.network/frontdoors (3)
- microsoft.communication/communicationservices (2)

### 6. South Central US (`southcentralus`)

- **Final score**: 0.677
- **Physical**: Texas
- **Geography**: US
- **AZ count**: 3
- **Paired region**: `northcentralus`
- **Coverage**: 96.3% (52 covered, 2 missing → 20 instances at risk)
- **Latency to `eastus`**: 36 ms
- **Compute price delta**: +19.8% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.963 | 0.25 | 0.241 |
| latency_to_source | 0.640 | 0.20 | 0.128 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.005 | 0.15 | 0.001 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/staticsites (18)
- microsoft.communication/communicationservices (2)

### 7. West US 2 (`westus2`)

- **Final score**: 0.677
- **Physical**: Washington
- **Geography**: US
- **AZ count**: 3
- **Paired region**: `westcentralus`
- **Coverage**: 96.3% (52 covered, 2 missing → 5 instances at risk)
- **Latency to `eastus`**: 79 ms
- **Compute price delta**: 0.0% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.963 | 0.25 | 0.241 |
| latency_to_source | 0.210 | 0.20 | 0.042 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.500 | 0.15 | 0.075 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.network/frontdoors (3)
- microsoft.communication/communicationservices (2)

### 8. West Central US (`westcentralus`)

- **Final score**: 0.564
- **Physical**: Wyoming
- **Geography**: US
- **AZ count**: 0
- **Paired region**: `westus2`
- **Coverage**: 92.6% (50 covered, 4 missing → 61 instances at risk)
- **Latency to `eastus`**: 53 ms
- **Compute price delta**: +19.8% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.926 | 0.25 | 0.232 |
| latency_to_source | 0.470 | 0.20 | 0.094 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.005 | 0.15 | 0.001 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/staticsites (18)
- microsoft.insights/components (38)
- microsoft.network/frontdoors (3)
- microsoft.communication/communicationservices (2)

### 9. West US (`westus`)

- **Final score**: 0.553
- **Physical**: California
- **Geography**: US
- **AZ count**: 0
- **Paired region**: `eastus`
- **Coverage**: 96.3% (52 covered, 2 missing → 20 instances at risk)
- **Latency to `eastus`**: 74 ms
- **Compute price delta**: +13.9% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.963 | 0.25 | 0.241 |
| latency_to_source | 0.260 | 0.20 | 0.052 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.153 | 0.15 | 0.023 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/staticsites (18)
- microsoft.communication/communicationservices (2)

