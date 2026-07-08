# Region coverage report: source = `uksouth`

Generated: 2026-07-08 18:25
Scope: **Offline inventory** (loaded from `example-inventory.csv`)

**Inventory:** 37 distinct resource types, 508 instances in `uksouth` (min instances threshold: 1).

## Score ranking

| Rank | Region | Physical | Coverage | Covered | Missing | Instances at risk |
| ---: | --- | --- | ---: | ---: | ---: | ---: |
| 1 | `westeurope` | Netherlands | 100% | 37 | 0 | 0 |
| 2 | `francecentral` | Paris | 97.3% | 36 | 1 | 8 |
| 3 | `germanywestcentral` | Frankfurt | 97.3% | 36 | 1 | 8 |
| 4 | `italynorth` | Milan | 97.3% | 36 | 1 | 8 |
| 5 | `northeurope` | Ireland | 97.3% | 36 | 1 | 8 |
| 6 | `norwayeast` | Norway | 97.3% | 36 | 1 | 8 |
| 7 | `swedencentral` | Gävle | 97.3% | 36 | 1 | 8 |
| 8 | `switzerlandnorth` | Zurich | 97.3% | 36 | 1 | 8 |
| 9 | `polandcentral` | Warsaw | 94.6% | 35 | 2 | 9 |
| 10 | `spaincentral` | Madrid | 94.6% | 35 | 2 | 9 |
| 11 | `austriaeast` | Vienna | 86.5% | 32 | 5 | 25 |
| 12 | `belgiumcentral` | Brussels | 81.1% | 30 | 7 | 45 |
| 13 | `denmarkeast` | Copenhagen | 81.1% | 30 | 7 | 45 |
| 14 | `switzerlandwest` | Geneva | 27% | 10 | 27 | 394 |
| 15 | `francesouth` | Marseille | 24.3% | 9 | 28 | 452 |
| 16 | `germanynorth` | Berlin | 18.9% | 7 | 30 | 464 |
| 17 | `norwaywest` | Norway | 16.2% | 6 | 31 | 466 |

## Detail per region

### 1. West Europe (`westeurope`)
Coverage: **100%** | Covered: **37** | Missing: **0** | Instances at risk: **0**

✅ All deployed resource types supported.

### 2. France Central (`francecentral`)
Coverage: **97.3%** | Covered: **36** | Missing: **1** | Instances at risk: **8**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (8)

### 3. Germany West Central (`germanywestcentral`)
Coverage: **97.3%** | Covered: **36** | Missing: **1** | Instances at risk: **8**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (8)

### 4. Italy North (`italynorth`)
Coverage: **97.3%** | Covered: **36** | Missing: **1** | Instances at risk: **8**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (8)

### 5. North Europe (`northeurope`)
Coverage: **97.3%** | Covered: **36** | Missing: **1** | Instances at risk: **8**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (8)

### 6. Norway East (`norwayeast`)
Coverage: **97.3%** | Covered: **36** | Missing: **1** | Instances at risk: **8**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (8)

### 7. Sweden Central (`swedencentral`)
Coverage: **97.3%** | Covered: **36** | Missing: **1** | Instances at risk: **8**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (8)

### 8. Switzerland North (`switzerlandnorth`)
Coverage: **97.3%** | Covered: **36** | Missing: **1** | Instances at risk: **8**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (8)

### 9. Poland Central (`polandcentral`)
Coverage: **94.6%** | Covered: **35** | Missing: **2** | Instances at risk: **9**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (8)
- microsoft.dashboard/grafana (1)

### 10. Spain Central (`spaincentral`)
Coverage: **94.6%** | Covered: **35** | Missing: **2** | Instances at risk: **9**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (8)
- microsoft.dashboard/grafana (1)

### 11. Austria East (`austriaeast`)
Coverage: **86.5%** | Covered: **32** | Missing: **5** | Instances at risk: **25**

**Missing resource types (instance count in source):**

- microsoft.app/containerapps (10)
- microsoft.web/staticsites (8)
- microsoft.cognitiveservices/accounts (4)
- microsoft.app/managedenvironments (2)
- microsoft.dashboard/grafana (1)

### 12. Belgium Central (`belgiumcentral`)
Coverage: **81.1%** | Covered: **30** | Missing: **7** | Instances at risk: **45**

**Missing resource types (instance count in source):**

- microsoft.insights/components (16)
- microsoft.app/containerapps (10)
- microsoft.web/staticsites (8)
- microsoft.operationalinsights/workspaces (4)
- microsoft.cognitiveservices/accounts (4)
- microsoft.app/managedenvironments (2)
- microsoft.dashboard/grafana (1)

### 13. Denmark East (`denmarkeast`)
Coverage: **81.1%** | Covered: **30** | Missing: **7** | Instances at risk: **45**

**Missing resource types (instance count in source):**

- microsoft.insights/components (16)
- microsoft.app/containerapps (10)
- microsoft.web/staticsites (8)
- microsoft.operationalinsights/workspaces (4)
- microsoft.cognitiveservices/accounts (4)
- microsoft.app/managedenvironments (2)
- microsoft.dashboard/grafana (1)

### 14. Switzerland West (`switzerlandwest`)
Coverage: **27%** | Covered: **10** | Missing: **27** | Instances at risk: **394**

**Missing resource types (instance count in source):**

- microsoft.web/sites (48)
- microsoft.storage/storageaccounts (42)
- microsoft.network/privateendpoints (36)
- microsoft.keyvault/vaults (32)
- microsoft.web/serverfarms (28)
- microsoft.network/networksecuritygroups (28)
- microsoft.network/networkinterfaces (26)
- microsoft.compute/disks (22)
- microsoft.sql/servers/databases (22)
- microsoft.network/publicipaddresses (20)
- microsoft.compute/virtualmachines (12)
- microsoft.app/containerapps (10)
- microsoft.network/virtualnetworks (10)
- microsoft.network/loadbalancers (8)
- microsoft.web/staticsites (8)
- microsoft.documentdb/databaseaccounts (7)
- microsoft.servicebus/namespaces (6)
- microsoft.sql/servers (5)
- microsoft.eventgrid/topics (4)
- microsoft.cache/redis (4)
- microsoft.eventhub/namespaces (3)
- microsoft.network/applicationgateways (3)
- microsoft.compute/virtualmachinescalesets (3)
- microsoft.recoveryservices/vaults (2)
- microsoft.app/managedenvironments (2)
- microsoft.apimanagement/service (2)
- microsoft.dashboard/grafana (1)

### 15. France South (`francesouth`)
Coverage: **24.3%** | Covered: **9** | Missing: **28** | Instances at risk: **452**

**Missing resource types (instance count in source):**

- microsoft.managedidentity/userassignedidentities (64)
- microsoft.web/sites (48)
- microsoft.storage/storageaccounts (42)
- microsoft.network/privateendpoints (36)
- microsoft.keyvault/vaults (32)
- microsoft.web/serverfarms (28)
- microsoft.network/networksecuritygroups (28)
- microsoft.network/networkinterfaces (26)
- microsoft.sql/servers/databases (22)
- microsoft.compute/disks (22)
- microsoft.network/publicipaddresses (20)
- microsoft.compute/virtualmachines (12)
- microsoft.network/virtualnetworks (10)
- microsoft.network/loadbalancers (8)
- microsoft.web/staticsites (8)
- microsoft.documentdb/databaseaccounts (7)
- microsoft.servicebus/namespaces (6)
- microsoft.sql/servers (5)
- microsoft.cognitiveservices/accounts (4)
- microsoft.eventgrid/topics (4)
- microsoft.cache/redis (4)
- microsoft.compute/virtualmachinescalesets (3)
- microsoft.network/applicationgateways (3)
- microsoft.eventhub/namespaces (3)
- microsoft.search/searchservices (2)
- microsoft.apimanagement/service (2)
- microsoft.recoveryservices/vaults (2)
- microsoft.dashboard/grafana (1)

### 16. Germany North (`germanynorth`)
Coverage: **18.9%** | Covered: **7** | Missing: **30** | Instances at risk: **464**

**Missing resource types (instance count in source):**

- microsoft.managedidentity/userassignedidentities (64)
- microsoft.web/sites (48)
- microsoft.storage/storageaccounts (42)
- microsoft.network/privateendpoints (36)
- microsoft.keyvault/vaults (32)
- microsoft.web/serverfarms (28)
- microsoft.network/networksecuritygroups (28)
- microsoft.network/networkinterfaces (26)
- microsoft.compute/disks (22)
- microsoft.sql/servers/databases (22)
- microsoft.network/publicipaddresses (20)
- microsoft.compute/virtualmachines (12)
- microsoft.app/containerapps (10)
- microsoft.network/virtualnetworks (10)
- microsoft.network/loadbalancers (8)
- microsoft.web/staticsites (8)
- microsoft.documentdb/databaseaccounts (7)
- microsoft.servicebus/namespaces (6)
- microsoft.sql/servers (5)
- microsoft.eventgrid/topics (4)
- microsoft.cache/redis (4)
- microsoft.cognitiveservices/accounts (4)
- microsoft.eventhub/namespaces (3)
- microsoft.network/applicationgateways (3)
- microsoft.compute/virtualmachinescalesets (3)
- microsoft.recoveryservices/vaults (2)
- microsoft.app/managedenvironments (2)
- microsoft.datafactory/factories (2)
- microsoft.apimanagement/service (2)
- microsoft.dashboard/grafana (1)

### 17. Norway West (`norwaywest`)
Coverage: **16.2%** | Covered: **6** | Missing: **31** | Instances at risk: **466**

**Missing resource types (instance count in source):**

- microsoft.managedidentity/userassignedidentities (64)
- microsoft.web/sites (48)
- microsoft.storage/storageaccounts (42)
- microsoft.network/privateendpoints (36)
- microsoft.keyvault/vaults (32)
- microsoft.network/networksecuritygroups (28)
- microsoft.web/serverfarms (28)
- microsoft.network/networkinterfaces (26)
- microsoft.compute/disks (22)
- microsoft.sql/servers/databases (22)
- microsoft.network/publicipaddresses (20)
- microsoft.compute/virtualmachines (12)
- microsoft.app/containerapps (10)
- microsoft.network/virtualnetworks (10)
- microsoft.network/loadbalancers (8)
- microsoft.web/staticsites (8)
- microsoft.documentdb/databaseaccounts (7)
- microsoft.servicebus/namespaces (6)
- microsoft.sql/servers (5)
- microsoft.eventgrid/topics (4)
- microsoft.cache/redis (4)
- microsoft.cognitiveservices/accounts (4)
- microsoft.compute/virtualmachinescalesets (3)
- microsoft.network/applicationgateways (3)
- microsoft.eventhub/namespaces (3)
- microsoft.app/managedenvironments (2)
- microsoft.apimanagement/service (2)
- microsoft.search/searchservices (2)
- microsoft.datafactory/factories (2)
- microsoft.recoveryservices/vaults (2)
- microsoft.dashboard/grafana (1)

