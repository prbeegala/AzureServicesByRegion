# Region scorecard: source = `southeastasia`

Generated: 2026-07-09 17:03
Geography: **Asia Pacific**
Weights profile: **default**
Inventory: **offline** — `example-inventory.csv`
Inventory summary: **37** resource types, **453** instances.

## Hard filters
| Filter | Value |
| --- | --- |
| Data residency | (none — geography = Asia Pacific) |
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
| 1 | `malaysiawest` | 0.851 | 97.3% | 9 | -9.9 | unknown |
| 2 | `southeastasia` (source) | 0.850 | 100% | 0 | 0.0 | unknown |
| 3 | `indonesiacentral` | 0.835 | 97.3% | 17 | -9.9 | unknown |
| 4 | `centralindia` | 0.749 | 100% | 59 | -15.2 | unknown |
| 5 | `eastasia` | 0.733 | 100% | 34 | +9.9 | unknown |
| 6 | `koreacentral` | 0.712 | 100% | 65 | -0.8 | unknown |
| 7 | `japanwest` | 0.700 | 100% | 66 | +1.7 | unknown |
| 8 | `japaneast` | 0.688 | 100% | 72 | +1.7 | unknown |
| 9 | `southindia` | 0.666 | 100% | 38 | +14.9 | unknown |
| 10 | `australiaeast` | 0.648 | 100% | 96 | -0.3 | unknown |
| 11 | `koreasouth` | 0.631 | 89.2% | 61 | -6.3 | unknown |
| 12 | `newzealandnorth` | 0.601 | 91.9% | 118 | +4.6 | unknown |
| 13 | `australiasoutheast` | 0.549 | 97.3% | 89 | +6.0 | unknown |
| 14 | `westindia` | 0.549 | 70.3% | 44 | +4.4 | unknown |
| 15 | `australiacentral` | 0.521 | 83.8% | 98 | -0.3 | unknown |
| 16 | `jioindiacentral` | 0.388 | 0% | ? | -15.2 | unknown |
| 17 | `jioindiawest` | 0.388 | 0% | ? | -15.2 | unknown |
| 18 | `australiacentral2` | 0.350 | 16.2% | 67 | -0.3 | unknown |

## Detail per region (accepted, ranked)

### 1. Malaysia West (`malaysiawest`)

- **Final score**: 0.851
- **Physical**: Kuala Lumpur
- **Geography**: Asia Pacific
- **AZ count**: 3
- **Paired region**: (none — 3+0 topology)
- **Coverage**: 97.3% (36 covered, 1 missing → 3 instances at risk)
- **Latency to `southeastasia`**: 9 ms
- **Compute price delta**: -9.9% vs source
- **Cross-region peering**: $0.03/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.973 | 0.25 | 0.243 |
| latency_to_source | 0.910 | 0.20 | 0.182 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.748 | 0.15 | 0.112 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.714 | 0.04 | 0.029 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.cognitiveservices/accounts (3)

### 2. Southeast Asia (`southeastasia`) *(source)*

- **Final score**: 0.850
- **Physical**: Singapore
- **Geography**: Asia Pacific
- **AZ count**: 3
- **Paired region**: `eastasia`
- **Coverage**: 100% (37 covered, 0 missing → 0 instances at risk)
- **Latency to `southeastasia`**: 0 ms
- **Compute price delta**: 0.0% vs source
- **Cross-region peering**: $0.01/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 1.000 | 0.25 | 0.250 |
| latency_to_source | 1.000 | 0.20 | 0.200 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.500 | 0.15 | 0.075 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 1.000 | 0.04 | 0.040 |
| region_maturity | 1.000 | 0.03 | 0.030 |

### 3. Indonesia Central (`indonesiacentral`)

- **Final score**: 0.835
- **Physical**: Jakarta
- **Geography**: Asia Pacific
- **AZ count**: 3
- **Paired region**: (none — 3+0 topology)
- **Coverage**: 97.3% (36 covered, 1 missing → 3 instances at risk)
- **Latency to `southeastasia`**: 17 ms
- **Compute price delta**: -9.9% vs source
- **Cross-region peering**: $0.03/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.973 | 0.25 | 0.243 |
| latency_to_source | 0.830 | 0.20 | 0.166 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.748 | 0.15 | 0.112 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.714 | 0.04 | 0.029 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.cognitiveservices/accounts (3)

### 4. Central India (`centralindia`)

- **Final score**: 0.749
- **Physical**: Pune
- **Geography**: Asia Pacific
- **AZ count**: 3
- **Paired region**: `southindia`
- **Coverage**: 100% (37 covered, 0 missing → 0 instances at risk)
- **Latency to `southeastasia`**: 59 ms
- **Compute price delta**: -15.2% vs source
- **Cross-region peering**: $0.08/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 1.000 | 0.25 | 0.250 |
| latency_to_source | 0.410 | 0.20 | 0.082 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.879 | 0.15 | 0.132 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.000 | 0.04 | 0.000 |
| region_maturity | 1.000 | 0.03 | 0.030 |

### 5. East Asia (`eastasia`)

- **Final score**: 0.733
- **Physical**: Hong Kong
- **Geography**: Asia Pacific
- **AZ count**: 3
- **Paired region**: `southeastasia`
- **Coverage**: 100% (37 covered, 0 missing → 0 instances at risk)
- **Latency to `southeastasia`**: 34 ms
- **Compute price delta**: +9.9% vs source
- **Cross-region peering**: $0.03/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 1.000 | 0.25 | 0.250 |
| latency_to_source | 0.660 | 0.20 | 0.132 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.252 | 0.15 | 0.038 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.714 | 0.04 | 0.029 |
| region_maturity | 1.000 | 0.03 | 0.030 |

### 6. Korea Central (`koreacentral`)

- **Final score**: 0.712
- **Physical**: Seoul
- **Geography**: Asia Pacific
- **AZ count**: 3
- **Paired region**: `koreasouth`
- **Coverage**: 100% (37 covered, 0 missing → 0 instances at risk)
- **Latency to `southeastasia`**: 65 ms
- **Compute price delta**: -0.8% vs source
- **Cross-region peering**: $0.03/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 1.000 | 0.25 | 0.250 |
| latency_to_source | 0.350 | 0.20 | 0.070 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.521 | 0.15 | 0.078 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.714 | 0.04 | 0.029 |
| region_maturity | 1.000 | 0.03 | 0.030 |

### 7. Japan West (`japanwest`)

- **Final score**: 0.700
- **Physical**: Osaka
- **Geography**: Asia Pacific
- **AZ count**: 3
- **Paired region**: `japaneast`
- **Coverage**: 100% (37 covered, 0 missing → 0 instances at risk)
- **Latency to `southeastasia`**: 66 ms
- **Compute price delta**: +1.7% vs source
- **Cross-region peering**: $0.03/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 1.000 | 0.25 | 0.250 |
| latency_to_source | 0.340 | 0.20 | 0.068 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.458 | 0.15 | 0.069 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.714 | 0.04 | 0.029 |
| region_maturity | 1.000 | 0.03 | 0.030 |

### 8. Japan East (`japaneast`)

- **Final score**: 0.688
- **Physical**: Tokyo, Saitama
- **Geography**: Asia Pacific
- **AZ count**: 3
- **Paired region**: `japanwest`
- **Coverage**: 100% (37 covered, 0 missing → 0 instances at risk)
- **Latency to `southeastasia`**: 72 ms
- **Compute price delta**: +1.7% vs source
- **Cross-region peering**: $0.03/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 1.000 | 0.25 | 0.250 |
| latency_to_source | 0.280 | 0.20 | 0.056 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.458 | 0.15 | 0.069 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.714 | 0.04 | 0.029 |
| region_maturity | 1.000 | 0.03 | 0.030 |

### 9. South India (`southindia`)

- **Final score**: 0.666
- **Physical**: Chennai
- **Geography**: Asia Pacific
- **AZ count**: 3
- **Paired region**: `centralindia`
- **Coverage**: 100% (37 covered, 0 missing → 0 instances at risk)
- **Latency to `southeastasia`**: 38 ms
- **Compute price delta**: +14.9% vs source
- **Cross-region peering**: $0.08/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 1.000 | 0.25 | 0.250 |
| latency_to_source | 0.620 | 0.20 | 0.124 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.129 | 0.15 | 0.019 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.000 | 0.04 | 0.000 |
| region_maturity | 0.600 | 0.03 | 0.018 |

### 10. Australia East (`australiaeast`)

- **Final score**: 0.648
- **Physical**: New South Wales
- **Geography**: Asia Pacific
- **AZ count**: 3
- **Paired region**: `australiasoutheast`
- **Coverage**: 100% (37 covered, 0 missing → 0 instances at risk)
- **Latency to `southeastasia`**: 96 ms
- **Compute price delta**: -0.3% vs source
- **Cross-region peering**: $0.03/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 1.000 | 0.25 | 0.250 |
| latency_to_source | 0.040 | 0.20 | 0.008 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.508 | 0.15 | 0.076 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.714 | 0.04 | 0.029 |
| region_maturity | 1.000 | 0.03 | 0.030 |

### 11. Korea South (`koreasouth`)

- **Final score**: 0.631
- **Physical**: Busan
- **Geography**: Asia Pacific
- **AZ count**: 0
- **Paired region**: `koreacentral`
- **Coverage**: 89.2% (33 covered, 4 missing → 15 instances at risk)
- **Latency to `southeastasia`**: 61 ms
- **Compute price delta**: -6.3% vs source
- **Cross-region peering**: $0.03/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.892 | 0.25 | 0.223 |
| latency_to_source | 0.390 | 0.20 | 0.078 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.656 | 0.15 | 0.098 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.714 | 0.04 | 0.029 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (8)
- microsoft.cognitiveservices/accounts (3)
- microsoft.datafactory/factories (2)

### 12. New Zealand North (`newzealandnorth`)

- **Final score**: 0.601
- **Physical**: Auckland
- **Geography**: Asia Pacific
- **AZ count**: 3
- **Paired region**: (none — 3+0 topology)
- **Coverage**: 91.9% (34 covered, 3 missing → 13 instances at risk)
- **Latency to `southeastasia`**: 118 ms
- **Compute price delta**: +4.6% vs source
- **Cross-region peering**: $0.03/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.919 | 0.25 | 0.230 |
| latency_to_source | 0.000 | 0.20 | 0.000 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.384 | 0.15 | 0.058 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.714 | 0.04 | 0.029 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (8)
- microsoft.cognitiveservices/accounts (3)

### 13. Australia Southeast (`australiasoutheast`)

- **Final score**: 0.549
- **Physical**: Victoria
- **Geography**: Asia Pacific
- **AZ count**: 0
- **Paired region**: `australiaeast`
- **Coverage**: 97.3% (36 covered, 1 missing → 3 instances at risk)
- **Latency to `southeastasia`**: 89 ms
- **Compute price delta**: +6.0% vs source
- **Cross-region peering**: $0.03/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.973 | 0.25 | 0.243 |
| latency_to_source | 0.110 | 0.20 | 0.022 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.349 | 0.15 | 0.052 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.714 | 0.04 | 0.029 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.cognitiveservices/accounts (3)

### 14. West India (`westindia`)

- **Final score**: 0.549
- **Physical**: Mumbai
- **Geography**: Asia Pacific
- **AZ count**: 0
- **Paired region**: `southindia`
- **Coverage**: 70.3% (26 covered, 11 missing → 46 instances at risk)
- **Latency to `southeastasia`**: 44 ms
- **Compute price delta**: +4.4% vs source
- **Cross-region peering**: $0.08/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.703 | 0.25 | 0.176 |
| latency_to_source | 0.560 | 0.20 | 0.112 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.390 | 0.15 | 0.058 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.000 | 0.04 | 0.000 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.dbformysql/flexibleservers (3)
- microsoft.appconfiguration/configurationstores (4)
- microsoft.insights/components (14)
- microsoft.operationalinsights/workspaces (3)
- microsoft.containerregistry/registries (2)
- microsoft.containerservice/managedclusters (3)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (8)
- microsoft.cognitiveservices/accounts (3)
- microsoft.search/searchservices (2)
- microsoft.datafactory/factories (2)

### 15. Australia Central (`australiacentral`)

- **Final score**: 0.521
- **Physical**: Canberra
- **Geography**: Asia Pacific
- **AZ count**: 0
- **Paired region**: `australiacentral2`
- **Coverage**: 83.8% (31 covered, 6 missing → 25 instances at risk)
- **Latency to `southeastasia`**: 98 ms
- **Compute price delta**: -0.3% vs source
- **Cross-region peering**: $0.03/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.838 | 0.25 | 0.209 |
| latency_to_source | 0.020 | 0.20 | 0.004 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.508 | 0.15 | 0.076 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.714 | 0.04 | 0.029 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (8)
- microsoft.cognitiveservices/accounts (3)
- microsoft.search/searchservices (2)
- microsoft.datafactory/factories (2)
- microsoft.logic/workflows (8)

### 16. Jio India Central (`jioindiacentral`)

- **Final score**: 0.388
- **Physical**: Nagpur
- **Geography**: Asia Pacific
- **AZ count**: 0
- **Paired region**: `jioindiawest`
- **Coverage**: 0% (0 covered, 37 missing → 453 instances at risk)
- **Latency to `southeastasia`**: unknown
- **Compute price delta**: -15.2% vs source
- **Cross-region peering**: $0.05/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.000 | 0.25 | 0.000 |
| latency_to_source | 0.500 | 0.20 | 0.100 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.879 | 0.15 | 0.132 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 0.200 | 0.08 | 0.016 |
| egress_cost | 0.429 | 0.04 | 0.017 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/sites (42)
- microsoft.web/serverfarms (24)
- microsoft.storage/storageaccounts (38)
- microsoft.keyvault/vaults (26)
- microsoft.managedidentity/userassignedidentities (54)
- microsoft.sql/servers (4)
- microsoft.sql/servers/databases (18)
- microsoft.documentdb/databaseaccounts (6)
- microsoft.dbformysql/flexibleservers (3)
- microsoft.cache/redis (4)
- microsoft.servicebus/namespaces (5)
- microsoft.eventhub/namespaces (3)
- microsoft.eventgrid/topics (3)
- microsoft.apimanagement/service (2)
- microsoft.appconfiguration/configurationstores (4)
- microsoft.insights/components (14)
- microsoft.operationalinsights/workspaces (3)
- microsoft.network/virtualnetworks (8)
- microsoft.network/networksecuritygroups (22)
- microsoft.network/publicipaddresses (18)
- microsoft.network/loadbalancers (6)
- microsoft.network/applicationgateways (3)
- microsoft.network/privateendpoints (32)
- microsoft.network/networkinterfaces (24)
- microsoft.network/bastionhosts (1)
- microsoft.compute/virtualmachines (18)
- microsoft.compute/disks (32)
- microsoft.compute/virtualmachinescalesets (4)
- microsoft.containerregistry/registries (2)
- microsoft.containerservice/managedclusters (3)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (8)
- microsoft.cognitiveservices/accounts (3)
- microsoft.search/searchservices (2)
- microsoft.datafactory/factories (2)
- microsoft.recoveryservices/vaults (2)
- microsoft.logic/workflows (8)

### 17. Jio India West (`jioindiawest`)

- **Final score**: 0.388
- **Physical**: Jamnagar
- **Geography**: Asia Pacific
- **AZ count**: 0
- **Paired region**: `jioindiacentral`
- **Coverage**: 0% (0 covered, 37 missing → 453 instances at risk)
- **Latency to `southeastasia`**: unknown
- **Compute price delta**: -15.2% vs source
- **Cross-region peering**: $0.05/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.000 | 0.25 | 0.000 |
| latency_to_source | 0.500 | 0.20 | 0.100 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.879 | 0.15 | 0.132 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 0.200 | 0.08 | 0.016 |
| egress_cost | 0.429 | 0.04 | 0.017 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/sites (42)
- microsoft.web/serverfarms (24)
- microsoft.storage/storageaccounts (38)
- microsoft.keyvault/vaults (26)
- microsoft.managedidentity/userassignedidentities (54)
- microsoft.sql/servers (4)
- microsoft.sql/servers/databases (18)
- microsoft.documentdb/databaseaccounts (6)
- microsoft.dbformysql/flexibleservers (3)
- microsoft.cache/redis (4)
- microsoft.servicebus/namespaces (5)
- microsoft.eventhub/namespaces (3)
- microsoft.eventgrid/topics (3)
- microsoft.apimanagement/service (2)
- microsoft.appconfiguration/configurationstores (4)
- microsoft.insights/components (14)
- microsoft.operationalinsights/workspaces (3)
- microsoft.network/virtualnetworks (8)
- microsoft.network/networksecuritygroups (22)
- microsoft.network/publicipaddresses (18)
- microsoft.network/loadbalancers (6)
- microsoft.network/applicationgateways (3)
- microsoft.network/privateendpoints (32)
- microsoft.network/networkinterfaces (24)
- microsoft.network/bastionhosts (1)
- microsoft.compute/virtualmachines (18)
- microsoft.compute/disks (32)
- microsoft.compute/virtualmachinescalesets (4)
- microsoft.containerregistry/registries (2)
- microsoft.containerservice/managedclusters (3)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (8)
- microsoft.cognitiveservices/accounts (3)
- microsoft.search/searchservices (2)
- microsoft.datafactory/factories (2)
- microsoft.recoveryservices/vaults (2)
- microsoft.logic/workflows (8)

### 18. Australia Central 2 (`australiacentral2`)

- **Final score**: 0.350
- **Physical**: Canberra
- **Geography**: Asia Pacific
- **AZ count**: 0
- **Paired region**: `australiacentral`
- **Coverage**: 16.2% (6 covered, 31 missing → 424 instances at risk)
- **Latency to `southeastasia`**: 67 ms
- **Compute price delta**: -0.3% vs source
- **Cross-region peering**: $0.03/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.162 | 0.25 | 0.041 |
| latency_to_source | 0.330 | 0.20 | 0.066 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.508 | 0.15 | 0.076 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 0.200 | 0.08 | 0.016 |
| egress_cost | 0.714 | 0.04 | 0.029 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/sites (42)
- microsoft.web/serverfarms (24)
- microsoft.storage/storageaccounts (38)
- microsoft.keyvault/vaults (26)
- microsoft.managedidentity/userassignedidentities (54)
- microsoft.sql/servers (4)
- microsoft.sql/servers/databases (18)
- microsoft.documentdb/databaseaccounts (6)
- microsoft.cache/redis (4)
- microsoft.servicebus/namespaces (5)
- microsoft.eventhub/namespaces (3)
- microsoft.eventgrid/topics (3)
- microsoft.apimanagement/service (2)
- microsoft.network/virtualnetworks (8)
- microsoft.network/networksecuritygroups (22)
- microsoft.network/publicipaddresses (18)
- microsoft.network/loadbalancers (6)
- microsoft.network/applicationgateways (3)
- microsoft.network/privateendpoints (32)
- microsoft.network/networkinterfaces (24)
- microsoft.network/bastionhosts (1)
- microsoft.compute/virtualmachines (18)
- microsoft.compute/disks (32)
- microsoft.compute/virtualmachinescalesets (4)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (8)
- microsoft.cognitiveservices/accounts (3)
- microsoft.search/searchservices (2)
- microsoft.datafactory/factories (2)
- microsoft.recoveryservices/vaults (2)
- microsoft.logic/workflows (8)

