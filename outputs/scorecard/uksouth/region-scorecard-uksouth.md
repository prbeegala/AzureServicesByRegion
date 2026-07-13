# Region scorecard: source = `uksouth`

Generated: 2026-07-09 17:04
Geography: **Europe**
Weights profile: **default**
Inventory: **offline** — `example-inventory.csv`
Inventory summary: **37** resource types, **508** instances.

## Hard filters
| Filter | Value |
| --- | --- |
| Data residency | (none — geography = Europe) |
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
| 1 | `northeurope` | 0.827 | 97.3% | 13 | -4.2 | unknown |
| 2 | `francecentral` | 0.816 | 97.3% | 10 | +0.5 | unknown |
| 3 | `swedencentral` | 0.811 | 97.3% | 30 | -8.8 | unknown |
| 4 | `spaincentral` | 0.810 | 94.6% | 18 | -4.2 | unknown |
| 5 | `westeurope` | 0.798 | 100% | 17 | +3.2 | unknown |
| 6 | `germanywestcentral` | 0.792 | 97.3% | 17 | +3.2 | unknown |
| 7 | `italynorth` | 0.782 | 97.3% | 27 | +0.5 | unknown |
| 8 | `belgiumcentral` | 0.769 | 81.1% | 8 | +3.2 | unknown |
| 9 | `austriaeast` | 0.765 | 86.5% | 17 | +3.2 | unknown |
| 10 | `polandcentral` | 0.759 | 94.6% | 30 | +3.2 | unknown |
| 11 | `denmarkeast` | 0.755 | 81.1% | 15 | +3.2 | unknown |
| 12 | `norwayeast` | 0.739 | 97.3% | 24 | +13.4 | unknown |
| 13 | `switzerlandnorth` | 0.739 | 97.3% | 24 | +13.4 | unknown |
| 14 | `francesouth` | 0.394 | 24.3% | 20 | +30.6 | unknown |
| 15 | `switzerlandwest` | 0.393 | 27% | 24 | +48.8 | unknown |
| 16 | `norwaywest` | 0.378 | 16.2% | 18 | +47.6 | unknown |
| 17 | `germanynorth` | 0.377 | 18.9% | 22 | +34.1 | unknown |

## Detail per region (accepted, ranked)

### 1. North Europe (`northeurope`)

- **Final score**: 0.827
- **Physical**: Ireland
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: `westeurope`
- **Coverage**: 97.3% (36 covered, 1 missing → 8 instances at risk)
- **Latency to `uksouth`**: 13 ms
- **Compute price delta**: -4.2% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.973 | 0.25 | 0.243 |
| latency_to_source | 0.870 | 0.20 | 0.174 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.604 | 0.15 | 0.091 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (8)

### 2. France Central (`francecentral`)

- **Final score**: 0.816
- **Physical**: Paris
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: `francesouth`
- **Coverage**: 97.3% (36 covered, 1 missing → 8 instances at risk)
- **Latency to `uksouth`**: 10 ms
- **Compute price delta**: +0.5% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.973 | 0.25 | 0.243 |
| latency_to_source | 0.900 | 0.20 | 0.180 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.489 | 0.15 | 0.073 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (8)

### 3. Sweden Central (`swedencentral`)

- **Final score**: 0.811
- **Physical**: G�vle
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: `swedensouth`
- **Coverage**: 97.3% (36 covered, 1 missing → 8 instances at risk)
- **Latency to `uksouth`**: 30 ms
- **Compute price delta**: -8.8% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.973 | 0.25 | 0.243 |
| latency_to_source | 0.700 | 0.20 | 0.140 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.720 | 0.15 | 0.108 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (8)

### 4. Spain Central (`spaincentral`)

- **Final score**: 0.810
- **Physical**: Madrid
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: (none — 3+0 topology)
- **Coverage**: 94.6% (35 covered, 2 missing → 9 instances at risk)
- **Latency to `uksouth`**: 18 ms
- **Compute price delta**: -4.2% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.946 | 0.25 | 0.236 |
| latency_to_source | 0.820 | 0.20 | 0.164 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.604 | 0.15 | 0.091 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (8)
- microsoft.dashboard/grafana (1)

### 5. West Europe (`westeurope`)

- **Final score**: 0.798
- **Physical**: Netherlands
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: `northeurope`
- **Coverage**: 100% (37 covered, 0 missing → 0 instances at risk)
- **Latency to `uksouth`**: 17 ms
- **Compute price delta**: +3.2% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 1.000 | 0.25 | 0.250 |
| latency_to_source | 0.830 | 0.20 | 0.166 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.421 | 0.15 | 0.063 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

### 6. Germany West Central (`germanywestcentral`)

- **Final score**: 0.792
- **Physical**: Frankfurt
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: `germanynorth`
- **Coverage**: 97.3% (36 covered, 1 missing → 8 instances at risk)
- **Latency to `uksouth`**: 17 ms
- **Compute price delta**: +3.2% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.973 | 0.25 | 0.243 |
| latency_to_source | 0.830 | 0.20 | 0.166 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.421 | 0.15 | 0.063 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (8)

### 7. Italy North (`italynorth`)

- **Final score**: 0.782
- **Physical**: Milan
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: (none — 3+0 topology)
- **Coverage**: 97.3% (36 covered, 1 missing → 8 instances at risk)
- **Latency to `uksouth`**: 27 ms
- **Compute price delta**: +0.5% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.973 | 0.25 | 0.243 |
| latency_to_source | 0.730 | 0.20 | 0.146 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.489 | 0.15 | 0.073 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (8)

### 8. Belgium Central (`belgiumcentral`)

- **Final score**: 0.769
- **Physical**: Brussels
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: (none — 3+0 topology)
- **Coverage**: 81.1% (30 covered, 7 missing → 45 instances at risk)
- **Latency to `uksouth`**: 8 ms
- **Compute price delta**: +3.2% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.811 | 0.25 | 0.203 |
| latency_to_source | 0.920 | 0.20 | 0.184 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.421 | 0.15 | 0.063 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (8)
- microsoft.insights/components (16)
- microsoft.operationalinsights/workspaces (4)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (10)
- microsoft.cognitiveservices/accounts (4)
- microsoft.dashboard/grafana (1)

### 9. Austria East (`austriaeast`)

- **Final score**: 0.765
- **Physical**: Vienna
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: (none — 3+0 topology)
- **Coverage**: 86.5% (32 covered, 5 missing → 25 instances at risk)
- **Latency to `uksouth`**: 17 ms
- **Compute price delta**: +3.2% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.865 | 0.25 | 0.216 |
| latency_to_source | 0.830 | 0.20 | 0.166 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.421 | 0.15 | 0.063 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (8)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (10)
- microsoft.cognitiveservices/accounts (4)
- microsoft.dashboard/grafana (1)

### 10. Poland Central (`polandcentral`)

- **Final score**: 0.759
- **Physical**: Warsaw
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: (none — 3+0 topology)
- **Coverage**: 94.6% (35 covered, 2 missing → 9 instances at risk)
- **Latency to `uksouth`**: 30 ms
- **Compute price delta**: +3.2% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.946 | 0.25 | 0.236 |
| latency_to_source | 0.700 | 0.20 | 0.140 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.421 | 0.15 | 0.063 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (8)
- microsoft.dashboard/grafana (1)

### 11. Denmark East (`denmarkeast`)

- **Final score**: 0.755
- **Physical**: Copenhagen
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: (none — 3+0 topology)
- **Coverage**: 81.1% (30 covered, 7 missing → 45 instances at risk)
- **Latency to `uksouth`**: 15 ms
- **Compute price delta**: +3.2% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.811 | 0.25 | 0.203 |
| latency_to_source | 0.850 | 0.20 | 0.170 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.421 | 0.15 | 0.063 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (8)
- microsoft.insights/components (16)
- microsoft.operationalinsights/workspaces (4)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (10)
- microsoft.cognitiveservices/accounts (4)
- microsoft.dashboard/grafana (1)

### 12. Norway East (`norwayeast`)

- **Final score**: 0.739
- **Physical**: Norway
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: `norwaywest`
- **Coverage**: 97.3% (36 covered, 1 missing → 8 instances at risk)
- **Latency to `uksouth`**: 24 ms
- **Compute price delta**: +13.4% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.973 | 0.25 | 0.243 |
| latency_to_source | 0.760 | 0.20 | 0.152 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.165 | 0.15 | 0.025 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (8)

### 13. Switzerland North (`switzerlandnorth`)

- **Final score**: 0.739
- **Physical**: Zurich
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: `switzerlandwest`
- **Coverage**: 97.3% (36 covered, 1 missing → 8 instances at risk)
- **Latency to `uksouth`**: 24 ms
- **Compute price delta**: +13.4% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.973 | 0.25 | 0.243 |
| latency_to_source | 0.760 | 0.20 | 0.152 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.165 | 0.15 | 0.025 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (8)

### 14. France South (`francesouth`)

- **Final score**: 0.394
- **Physical**: Marseille
- **Geography**: Europe
- **AZ count**: 0
- **Paired region**: `francecentral`
- **Coverage**: 24.3% (9 covered, 28 missing → 452 instances at risk)
- **Latency to `uksouth`**: 20 ms
- **Compute price delta**: +30.6% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.243 | 0.25 | 0.061 |
| latency_to_source | 0.800 | 0.20 | 0.160 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.000 | 0.15 | 0.000 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 0.200 | 0.08 | 0.016 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/sites (48)
- microsoft.web/serverfarms (28)
- microsoft.web/staticsites (8)
- microsoft.storage/storageaccounts (42)
- microsoft.keyvault/vaults (32)
- microsoft.managedidentity/userassignedidentities (64)
- microsoft.sql/servers (5)
- microsoft.sql/servers/databases (22)
- microsoft.documentdb/databaseaccounts (7)
- microsoft.cache/redis (4)
- microsoft.servicebus/namespaces (6)
- microsoft.eventgrid/topics (4)
- microsoft.eventhub/namespaces (3)
- microsoft.apimanagement/service (2)
- microsoft.network/virtualnetworks (10)
- microsoft.network/networksecuritygroups (28)
- microsoft.network/publicipaddresses (20)
- microsoft.network/loadbalancers (8)
- microsoft.network/applicationgateways (3)
- microsoft.network/privateendpoints (36)
- microsoft.network/networkinterfaces (26)
- microsoft.compute/virtualmachines (12)
- microsoft.compute/disks (22)
- microsoft.compute/virtualmachinescalesets (3)
- microsoft.cognitiveservices/accounts (4)
- microsoft.search/searchservices (2)
- microsoft.recoveryservices/vaults (2)
- microsoft.dashboard/grafana (1)

### 15. Switzerland West (`switzerlandwest`)

- **Final score**: 0.393
- **Physical**: Geneva
- **Geography**: Europe
- **AZ count**: 0
- **Paired region**: `switzerlandnorth`
- **Coverage**: 27% (10 covered, 27 missing → 394 instances at risk)
- **Latency to `uksouth`**: 24 ms
- **Compute price delta**: +48.8% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.270 | 0.25 | 0.068 |
| latency_to_source | 0.760 | 0.20 | 0.152 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.000 | 0.15 | 0.000 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 0.200 | 0.08 | 0.016 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/sites (48)
- microsoft.web/serverfarms (28)
- microsoft.web/staticsites (8)
- microsoft.storage/storageaccounts (42)
- microsoft.keyvault/vaults (32)
- microsoft.sql/servers (5)
- microsoft.sql/servers/databases (22)
- microsoft.documentdb/databaseaccounts (7)
- microsoft.cache/redis (4)
- microsoft.servicebus/namespaces (6)
- microsoft.eventgrid/topics (4)
- microsoft.eventhub/namespaces (3)
- microsoft.apimanagement/service (2)
- microsoft.network/virtualnetworks (10)
- microsoft.network/networksecuritygroups (28)
- microsoft.network/publicipaddresses (20)
- microsoft.network/loadbalancers (8)
- microsoft.network/applicationgateways (3)
- microsoft.network/privateendpoints (36)
- microsoft.network/networkinterfaces (26)
- microsoft.compute/virtualmachines (12)
- microsoft.compute/disks (22)
- microsoft.compute/virtualmachinescalesets (3)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (10)
- microsoft.recoveryservices/vaults (2)
- microsoft.dashboard/grafana (1)

### 16. Norway West (`norwaywest`)

- **Final score**: 0.378
- **Physical**: Norway
- **Geography**: Europe
- **AZ count**: 0
- **Paired region**: `norwayeast`
- **Coverage**: 16.2% (6 covered, 31 missing → 466 instances at risk)
- **Latency to `uksouth`**: 18 ms
- **Compute price delta**: +47.6% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.162 | 0.25 | 0.041 |
| latency_to_source | 0.820 | 0.20 | 0.164 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.000 | 0.15 | 0.000 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 0.200 | 0.08 | 0.016 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/sites (48)
- microsoft.web/serverfarms (28)
- microsoft.web/staticsites (8)
- microsoft.storage/storageaccounts (42)
- microsoft.keyvault/vaults (32)
- microsoft.managedidentity/userassignedidentities (64)
- microsoft.sql/servers (5)
- microsoft.sql/servers/databases (22)
- microsoft.documentdb/databaseaccounts (7)
- microsoft.cache/redis (4)
- microsoft.servicebus/namespaces (6)
- microsoft.eventgrid/topics (4)
- microsoft.eventhub/namespaces (3)
- microsoft.apimanagement/service (2)
- microsoft.network/virtualnetworks (10)
- microsoft.network/networksecuritygroups (28)
- microsoft.network/publicipaddresses (20)
- microsoft.network/loadbalancers (8)
- microsoft.network/applicationgateways (3)
- microsoft.network/privateendpoints (36)
- microsoft.network/networkinterfaces (26)
- microsoft.compute/virtualmachines (12)
- microsoft.compute/disks (22)
- microsoft.compute/virtualmachinescalesets (3)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (10)
- microsoft.cognitiveservices/accounts (4)
- microsoft.search/searchservices (2)
- microsoft.datafactory/factories (2)
- microsoft.recoveryservices/vaults (2)
- microsoft.dashboard/grafana (1)

### 17. Germany North (`germanynorth`)

- **Final score**: 0.377
- **Physical**: Berlin
- **Geography**: Europe
- **AZ count**: 0
- **Paired region**: `germanywestcentral`
- **Coverage**: 18.9% (7 covered, 30 missing → 464 instances at risk)
- **Latency to `uksouth`**: 22 ms
- **Compute price delta**: +34.1% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.189 | 0.25 | 0.047 |
| latency_to_source | 0.780 | 0.20 | 0.156 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.000 | 0.15 | 0.000 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 0.200 | 0.08 | 0.016 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/sites (48)
- microsoft.web/serverfarms (28)
- microsoft.web/staticsites (8)
- microsoft.storage/storageaccounts (42)
- microsoft.keyvault/vaults (32)
- microsoft.managedidentity/userassignedidentities (64)
- microsoft.sql/servers (5)
- microsoft.sql/servers/databases (22)
- microsoft.documentdb/databaseaccounts (7)
- microsoft.cache/redis (4)
- microsoft.servicebus/namespaces (6)
- microsoft.eventgrid/topics (4)
- microsoft.eventhub/namespaces (3)
- microsoft.apimanagement/service (2)
- microsoft.network/virtualnetworks (10)
- microsoft.network/networksecuritygroups (28)
- microsoft.network/publicipaddresses (20)
- microsoft.network/loadbalancers (8)
- microsoft.network/applicationgateways (3)
- microsoft.network/privateendpoints (36)
- microsoft.network/networkinterfaces (26)
- microsoft.compute/virtualmachines (12)
- microsoft.compute/disks (22)
- microsoft.compute/virtualmachinescalesets (3)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (10)
- microsoft.cognitiveservices/accounts (4)
- microsoft.datafactory/factories (2)
- microsoft.recoveryservices/vaults (2)
- microsoft.dashboard/grafana (1)

