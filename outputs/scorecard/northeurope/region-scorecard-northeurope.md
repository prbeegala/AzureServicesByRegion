# Region scorecard: source = `northeurope`

Generated: 2026-07-09 16:41
Geography: **Europe**
Weights profile: **default**
Inventory: **offline** — `example-inventory.csv`
Inventory summary: **40** resource types, **573** instances.

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
| 1 | `northeurope` (source) | 0.844 | 97.5% | 0 | 0.0 | unknown |
| 2 | `swedencentral` | 0.792 | 97.5% | 32 | -4.8 | unknown |
| 3 | `spaincentral` | 0.786 | 92.5% | 20 | 0.0 | unknown |
| 4 | `francecentral` | 0.782 | 97.5% | 19 | +4.8 | unknown |
| 5 | `westeurope` | 0.774 | 100% | 21 | +7.6 | unknown |
| 6 | `germanywestcentral` | 0.757 | 97.5% | 26 | +7.6 | unknown |
| 7 | `italynorth` | 0.744 | 95% | 35 | +4.8 | unknown |
| 8 | `belgiumcentral` | 0.740 | 80% | 13 | +7.6 | unknown |
| 9 | `austriaeast` | 0.734 | 85% | 22 | +7.6 | unknown |
| 10 | `denmarkeast` | 0.732 | 80% | 17 | +7.6 | unknown |
| 11 | `polandcentral` | 0.727 | 92.5% | 35 | +7.6 | unknown |
| 12 | `norwayeast` | 0.713 | 97.5% | 28 | +18.3 | unknown |
| 13 | `switzerlandnorth` | 0.707 | 97.5% | 31 | +18.3 | unknown |
| 14 | `francesouth` | 0.378 | 25% | 29 | +36.3 | unknown |
| 15 | `germanynorth` | 0.369 | 20% | 27 | +39.9 | unknown |
| 16 | `switzerlandwest` | 0.364 | 30% | 42 | +55.2 | unknown |
| 17 | `norwaywest` | 0.363 | 17.5% | 27 | +54.0 | unknown |

## Detail per region (accepted, ranked)

### 1. North Europe (`northeurope`) *(source)*

- **Final score**: 0.844
- **Physical**: Ireland
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: `westeurope`
- **Coverage**: 97.5% (39 covered, 1 missing → 6 instances at risk)
- **Latency to `northeurope`**: 0 ms
- **Compute price delta**: 0.0% vs source
- **Cross-region peering**: $0.01/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.975 | 0.25 | 0.244 |
| latency_to_source | 1.000 | 0.20 | 0.200 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.500 | 0.15 | 0.075 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 1.000 | 0.04 | 0.040 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (6)

### 2. Sweden Central (`swedencentral`)

- **Final score**: 0.792
- **Physical**: G�vle
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: `swedensouth`
- **Coverage**: 97.5% (39 covered, 1 missing → 6 instances at risk)
- **Latency to `northeurope`**: 32 ms
- **Compute price delta**: -4.8% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.975 | 0.25 | 0.244 |
| latency_to_source | 0.680 | 0.20 | 0.136 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.620 | 0.15 | 0.093 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (6)

### 3. Spain Central (`spaincentral`)

- **Final score**: 0.786
- **Physical**: Madrid
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: (none — 3+0 topology)
- **Coverage**: 92.5% (37 covered, 3 missing → 8 instances at risk)
- **Latency to `northeurope`**: 20 ms
- **Compute price delta**: 0.0% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.925 | 0.25 | 0.231 |
| latency_to_source | 0.800 | 0.20 | 0.160 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.500 | 0.15 | 0.075 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.dashboard/grafana (1)
- microsoft.databricks/workspaces (1)
- microsoft.web/staticsites (6)

### 4. France Central (`francecentral`)

- **Final score**: 0.782
- **Physical**: Paris
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: `francesouth`
- **Coverage**: 97.5% (39 covered, 1 missing → 6 instances at risk)
- **Latency to `northeurope`**: 19 ms
- **Compute price delta**: +4.8% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.975 | 0.25 | 0.244 |
| latency_to_source | 0.810 | 0.20 | 0.162 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.380 | 0.15 | 0.057 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (6)

### 5. West Europe (`westeurope`)

- **Final score**: 0.774
- **Physical**: Netherlands
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: `northeurope`
- **Coverage**: 100% (40 covered, 0 missing → 0 instances at risk)
- **Latency to `northeurope`**: 21 ms
- **Compute price delta**: +7.6% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 1.000 | 0.25 | 0.250 |
| latency_to_source | 0.790 | 0.20 | 0.158 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.309 | 0.15 | 0.046 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

### 6. Germany West Central (`germanywestcentral`)

- **Final score**: 0.757
- **Physical**: Frankfurt
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: `germanynorth`
- **Coverage**: 97.5% (39 covered, 1 missing → 6 instances at risk)
- **Latency to `northeurope`**: 26 ms
- **Compute price delta**: +7.6% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.975 | 0.25 | 0.244 |
| latency_to_source | 0.740 | 0.20 | 0.148 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.309 | 0.15 | 0.046 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (6)

### 7. Italy North (`italynorth`)

- **Final score**: 0.744
- **Physical**: Milan
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: (none — 3+0 topology)
- **Coverage**: 95% (38 covered, 2 missing → 7 instances at risk)
- **Latency to `northeurope`**: 35 ms
- **Compute price delta**: +4.8% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.950 | 0.25 | 0.237 |
| latency_to_source | 0.650 | 0.20 | 0.130 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.380 | 0.15 | 0.057 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.databricks/workspaces (1)
- microsoft.web/staticsites (6)

### 8. Belgium Central (`belgiumcentral`)

- **Final score**: 0.740
- **Physical**: Brussels
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: (none — 3+0 topology)
- **Coverage**: 80% (32 covered, 8 missing → 45 instances at risk)
- **Latency to `northeurope`**: 13 ms
- **Compute price delta**: +7.6% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.800 | 0.25 | 0.200 |
| latency_to_source | 0.870 | 0.20 | 0.174 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.309 | 0.15 | 0.046 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.insights/components (18)
- microsoft.operationalinsights/workspaces (4)
- microsoft.dashboard/grafana (1)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (9)
- microsoft.cognitiveservices/accounts (4)
- microsoft.databricks/workspaces (1)
- microsoft.web/staticsites (6)

### 9. Austria East (`austriaeast`)

- **Final score**: 0.734
- **Physical**: Vienna
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: (none — 3+0 topology)
- **Coverage**: 85% (34 covered, 6 missing → 23 instances at risk)
- **Latency to `northeurope`**: 22 ms
- **Compute price delta**: +7.6% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.850 | 0.25 | 0.212 |
| latency_to_source | 0.780 | 0.20 | 0.156 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.309 | 0.15 | 0.046 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.dashboard/grafana (1)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (9)
- microsoft.cognitiveservices/accounts (4)
- microsoft.databricks/workspaces (1)
- microsoft.web/staticsites (6)

### 10. Denmark East (`denmarkeast`)

- **Final score**: 0.732
- **Physical**: Copenhagen
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: (none — 3+0 topology)
- **Coverage**: 80% (32 covered, 8 missing → 45 instances at risk)
- **Latency to `northeurope`**: 17 ms
- **Compute price delta**: +7.6% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.800 | 0.25 | 0.200 |
| latency_to_source | 0.830 | 0.20 | 0.166 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.309 | 0.15 | 0.046 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.insights/components (18)
- microsoft.operationalinsights/workspaces (4)
- microsoft.dashboard/grafana (1)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (9)
- microsoft.cognitiveservices/accounts (4)
- microsoft.databricks/workspaces (1)
- microsoft.web/staticsites (6)

### 11. Poland Central (`polandcentral`)

- **Final score**: 0.727
- **Physical**: Warsaw
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: (none — 3+0 topology)
- **Coverage**: 92.5% (37 covered, 3 missing → 8 instances at risk)
- **Latency to `northeurope`**: 35 ms
- **Compute price delta**: +7.6% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.925 | 0.25 | 0.231 |
| latency_to_source | 0.650 | 0.20 | 0.130 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.309 | 0.15 | 0.046 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.dashboard/grafana (1)
- microsoft.databricks/workspaces (1)
- microsoft.web/staticsites (6)

### 12. Norway East (`norwayeast`)

- **Final score**: 0.713
- **Physical**: Norway
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: `norwaywest`
- **Coverage**: 97.5% (39 covered, 1 missing → 6 instances at risk)
- **Latency to `northeurope`**: 28 ms
- **Compute price delta**: +18.3% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.975 | 0.25 | 0.244 |
| latency_to_source | 0.720 | 0.20 | 0.144 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.042 | 0.15 | 0.006 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (6)

### 13. Switzerland North (`switzerlandnorth`)

- **Final score**: 0.707
- **Physical**: Zurich
- **Geography**: Europe
- **AZ count**: 3
- **Paired region**: `switzerlandwest`
- **Coverage**: 97.5% (39 covered, 1 missing → 6 instances at risk)
- **Latency to `northeurope`**: 31 ms
- **Compute price delta**: +18.3% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.975 | 0.25 | 0.244 |
| latency_to_source | 0.690 | 0.20 | 0.138 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.042 | 0.15 | 0.006 |
| az_support | 1.000 | 0.10 | 0.100 |
| sku_portability | 1.000 | 0.08 | 0.080 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 1.000 | 0.03 | 0.030 |

**Missing resource types:**

- microsoft.web/staticsites (6)

### 14. France South (`francesouth`)

- **Final score**: 0.378
- **Physical**: Marseille
- **Geography**: Europe
- **AZ count**: 0
- **Paired region**: `francecentral`
- **Coverage**: 25% (10 covered, 30 missing → 513 instances at risk)
- **Latency to `northeurope`**: 29 ms
- **Compute price delta**: +36.3% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.250 | 0.25 | 0.062 |
| latency_to_source | 0.710 | 0.20 | 0.142 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.000 | 0.15 | 0.000 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 0.200 | 0.08 | 0.016 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/sites (58)
- microsoft.web/serverfarms (32)
- microsoft.storage/storageaccounts (45)
- microsoft.keyvault/vaults (38)
- microsoft.managedidentity/userassignedidentities (72)
- microsoft.sql/servers (6)
- microsoft.sql/servers/databases (24)
- microsoft.documentdb/databaseaccounts (8)
- microsoft.cache/redis (5)
- microsoft.servicebus/namespaces (7)
- microsoft.eventgrid/topics (4)
- microsoft.eventhub/namespaces (3)
- microsoft.apimanagement/service (2)
- microsoft.dashboard/grafana (1)
- microsoft.network/virtualnetworks (12)
- microsoft.network/networksecuritygroups (34)
- microsoft.network/publicipaddresses (22)
- microsoft.network/loadbalancers (8)
- microsoft.network/applicationgateways (3)
- microsoft.network/privateendpoints (41)
- microsoft.network/networkinterfaces (28)
- microsoft.network/bastionhosts (1)
- microsoft.compute/virtualmachines (14)
- microsoft.compute/disks (26)
- microsoft.compute/virtualmachinescalesets (4)
- microsoft.cognitiveservices/accounts (4)
- microsoft.search/searchservices (2)
- microsoft.databricks/workspaces (1)
- microsoft.web/staticsites (6)
- microsoft.recoveryservices/vaults (2)

### 15. Germany North (`germanynorth`)

- **Final score**: 0.369
- **Physical**: Berlin
- **Geography**: Europe
- **AZ count**: 0
- **Paired region**: `germanywestcentral`
- **Coverage**: 20% (8 covered, 32 missing → 524 instances at risk)
- **Latency to `northeurope`**: 27 ms
- **Compute price delta**: +39.9% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.200 | 0.25 | 0.050 |
| latency_to_source | 0.730 | 0.20 | 0.146 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.000 | 0.15 | 0.000 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 0.200 | 0.08 | 0.016 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/sites (58)
- microsoft.web/serverfarms (32)
- microsoft.storage/storageaccounts (45)
- microsoft.keyvault/vaults (38)
- microsoft.managedidentity/userassignedidentities (72)
- microsoft.sql/servers (6)
- microsoft.sql/servers/databases (24)
- microsoft.documentdb/databaseaccounts (8)
- microsoft.cache/redis (5)
- microsoft.servicebus/namespaces (7)
- microsoft.eventgrid/topics (4)
- microsoft.eventhub/namespaces (3)
- microsoft.apimanagement/service (2)
- microsoft.dashboard/grafana (1)
- microsoft.network/virtualnetworks (12)
- microsoft.network/networksecuritygroups (34)
- microsoft.network/publicipaddresses (22)
- microsoft.network/loadbalancers (8)
- microsoft.network/applicationgateways (3)
- microsoft.network/privateendpoints (41)
- microsoft.network/networkinterfaces (28)
- microsoft.network/bastionhosts (1)
- microsoft.compute/virtualmachines (14)
- microsoft.compute/disks (26)
- microsoft.compute/virtualmachinescalesets (4)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (9)
- microsoft.cognitiveservices/accounts (4)
- microsoft.datafactory/factories (2)
- microsoft.databricks/workspaces (1)
- microsoft.web/staticsites (6)
- microsoft.recoveryservices/vaults (2)

### 16. Switzerland West (`switzerlandwest`)

- **Final score**: 0.364
- **Physical**: Geneva
- **Geography**: Europe
- **AZ count**: 0
- **Paired region**: `switzerlandnorth`
- **Coverage**: 30% (12 covered, 28 missing → 445 instances at risk)
- **Latency to `northeurope`**: 42 ms
- **Compute price delta**: +55.2% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.300 | 0.25 | 0.075 |
| latency_to_source | 0.580 | 0.20 | 0.116 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.000 | 0.15 | 0.000 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 0.200 | 0.08 | 0.016 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/sites (58)
- microsoft.web/serverfarms (32)
- microsoft.storage/storageaccounts (45)
- microsoft.keyvault/vaults (38)
- microsoft.sql/servers (6)
- microsoft.sql/servers/databases (24)
- microsoft.documentdb/databaseaccounts (8)
- microsoft.cache/redis (5)
- microsoft.servicebus/namespaces (7)
- microsoft.eventgrid/topics (4)
- microsoft.eventhub/namespaces (3)
- microsoft.apimanagement/service (2)
- microsoft.dashboard/grafana (1)
- microsoft.network/virtualnetworks (12)
- microsoft.network/networksecuritygroups (34)
- microsoft.network/publicipaddresses (22)
- microsoft.network/loadbalancers (8)
- microsoft.network/applicationgateways (3)
- microsoft.network/privateendpoints (41)
- microsoft.network/networkinterfaces (28)
- microsoft.network/bastionhosts (1)
- microsoft.compute/virtualmachines (14)
- microsoft.compute/disks (26)
- microsoft.compute/virtualmachinescalesets (4)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (9)
- microsoft.web/staticsites (6)
- microsoft.recoveryservices/vaults (2)

### 17. Norway West (`norwaywest`)

- **Final score**: 0.363
- **Physical**: Norway
- **Geography**: Europe
- **AZ count**: 0
- **Paired region**: `norwayeast`
- **Coverage**: 17.5% (7 covered, 33 missing → 526 instances at risk)
- **Latency to `northeurope`**: 27 ms
- **Compute price delta**: +54.0% vs source
- **Cross-region peering**: $0.02/GB
- **Capacity**: unknown (populate data/capacity-status-template.csv for status)

**Per-criterion scores:**

| Criterion | Score | Weight | Weighted |
| --- | ---: | ---: | ---: |
| coverage | 0.175 | 0.25 | 0.044 |
| latency_to_source | 0.730 | 0.20 | 0.146 |
| capacity_health | 0.500 | 0.15 | 0.075 |
| compute_price_delta | 0.000 | 0.15 | 0.000 |
| az_support | 0.300 | 0.10 | 0.030 |
| sku_portability | 0.200 | 0.08 | 0.016 |
| egress_cost | 0.857 | 0.04 | 0.034 |
| region_maturity | 0.600 | 0.03 | 0.018 |

**Missing resource types:**

- microsoft.web/sites (58)
- microsoft.web/serverfarms (32)
- microsoft.storage/storageaccounts (45)
- microsoft.keyvault/vaults (38)
- microsoft.managedidentity/userassignedidentities (72)
- microsoft.sql/servers (6)
- microsoft.sql/servers/databases (24)
- microsoft.documentdb/databaseaccounts (8)
- microsoft.cache/redis (5)
- microsoft.servicebus/namespaces (7)
- microsoft.eventgrid/topics (4)
- microsoft.eventhub/namespaces (3)
- microsoft.apimanagement/service (2)
- microsoft.dashboard/grafana (1)
- microsoft.network/virtualnetworks (12)
- microsoft.network/networksecuritygroups (34)
- microsoft.network/publicipaddresses (22)
- microsoft.network/loadbalancers (8)
- microsoft.network/applicationgateways (3)
- microsoft.network/privateendpoints (41)
- microsoft.network/networkinterfaces (28)
- microsoft.network/bastionhosts (1)
- microsoft.compute/virtualmachines (14)
- microsoft.compute/disks (26)
- microsoft.compute/virtualmachinescalesets (4)
- microsoft.app/managedenvironments (2)
- microsoft.app/containerapps (9)
- microsoft.cognitiveservices/accounts (4)
- microsoft.search/searchservices (2)
- microsoft.datafactory/factories (2)
- microsoft.databricks/workspaces (1)
- microsoft.web/staticsites (6)
- microsoft.recoveryservices/vaults (2)

