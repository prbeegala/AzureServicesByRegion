# Region coverage report: source = `northeurope`

Generated: 2026-07-08 18:10
Scope: **Offline inventory** (loaded from `example-inventory.csv`)

**Inventory:** 40 distinct resource types, 573 instances in `northeurope` (min instances threshold: 1).

## Score ranking

| Rank | Region | Physical | Coverage | Covered | Missing | Instances at risk |
| ---: | --- | --- | ---: | ---: | ---: | ---: |
| 1 | `westeurope` | Netherlands | 100% | 40 | 0 | 0 |
| 2 | `francecentral` | Paris | 97.5% | 39 | 1 | 6 |
| 3 | `germanywestcentral` | Frankfurt | 97.5% | 39 | 1 | 6 |
| 4 | `northeurope` (source) | Ireland | 97.5% | 39 | 1 | 6 |
| 5 | `norwayeast` | Norway | 97.5% | 39 | 1 | 6 |
| 6 | `swedencentral` | Gävle | 97.5% | 39 | 1 | 6 |
| 7 | `switzerlandnorth` | Zurich | 97.5% | 39 | 1 | 6 |
| 8 | `italynorth` | Milan | 95% | 38 | 2 | 7 |
| 9 | `polandcentral` | Warsaw | 92.5% | 37 | 3 | 8 |
| 10 | `spaincentral` | Madrid | 92.5% | 37 | 3 | 8 |
| 11 | `austriaeast` | Vienna | 85% | 34 | 6 | 23 |
| 12 | `belgiumcentral` | Brussels | 80% | 32 | 8 | 45 |
| 13 | `denmarkeast` | Copenhagen | 80% | 32 | 8 | 45 |
| 14 | `switzerlandwest` | Geneva | 30% | 12 | 28 | 445 |
| 15 | `francesouth` | Marseille | 25% | 10 | 30 | 513 |
| 16 | `germanynorth` | Berlin | 20% | 8 | 32 | 524 |
| 17 | `norwaywest` | Norway | 17.5% | 7 | 33 | 526 |

## Detail per region

### 1. West Europe (`westeurope`)
Coverage: **100%** | Covered: **40** | Missing: **0** | Instances at risk: **0**

✅ All deployed resource types supported.

### 2. France Central (`francecentral`)
Coverage: **97.5%** | Covered: **39** | Missing: **1** | Instances at risk: **6**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (6)

### 3. Germany West Central (`germanywestcentral`)
Coverage: **97.5%** | Covered: **39** | Missing: **1** | Instances at risk: **6**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (6)

### 4. North Europe (`northeurope`) (source)
Coverage: **97.5%** | Covered: **39** | Missing: **1** | Instances at risk: **6**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (6)

### 5. Norway East (`norwayeast`)
Coverage: **97.5%** | Covered: **39** | Missing: **1** | Instances at risk: **6**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (6)

### 6. Sweden Central (`swedencentral`)
Coverage: **97.5%** | Covered: **39** | Missing: **1** | Instances at risk: **6**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (6)

### 7. Switzerland North (`switzerlandnorth`)
Coverage: **97.5%** | Covered: **39** | Missing: **1** | Instances at risk: **6**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (6)

### 8. Italy North (`italynorth`)
Coverage: **95%** | Covered: **38** | Missing: **2** | Instances at risk: **7**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (6)
- microsoft.databricks/workspaces (1)

### 9. Poland Central (`polandcentral`)
Coverage: **92.5%** | Covered: **37** | Missing: **3** | Instances at risk: **8**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (6)
- microsoft.databricks/workspaces (1)
- microsoft.dashboard/grafana (1)

### 10. Spain Central (`spaincentral`)
Coverage: **92.5%** | Covered: **37** | Missing: **3** | Instances at risk: **8**

**Missing resource types (instance count in source):**

- microsoft.web/staticsites (6)
- microsoft.databricks/workspaces (1)
- microsoft.dashboard/grafana (1)

### 11. Austria East (`austriaeast`)
Coverage: **85%** | Covered: **34** | Missing: **6** | Instances at risk: **23**

**Missing resource types (instance count in source):**

- microsoft.app/containerapps (9)
- microsoft.web/staticsites (6)
- microsoft.cognitiveservices/accounts (4)
- microsoft.app/managedenvironments (2)
- microsoft.dashboard/grafana (1)
- microsoft.databricks/workspaces (1)

### 12. Belgium Central (`belgiumcentral`)
Coverage: **80%** | Covered: **32** | Missing: **8** | Instances at risk: **45**

**Missing resource types (instance count in source):**

- microsoft.insights/components (18)
- microsoft.app/containerapps (9)
- microsoft.web/staticsites (6)
- microsoft.operationalinsights/workspaces (4)
- microsoft.cognitiveservices/accounts (4)
- microsoft.app/managedenvironments (2)
- microsoft.dashboard/grafana (1)
- microsoft.databricks/workspaces (1)

### 13. Denmark East (`denmarkeast`)
Coverage: **80%** | Covered: **32** | Missing: **8** | Instances at risk: **45**

**Missing resource types (instance count in source):**

- microsoft.insights/components (18)
- microsoft.app/containerapps (9)
- microsoft.web/staticsites (6)
- microsoft.operationalinsights/workspaces (4)
- microsoft.cognitiveservices/accounts (4)
- microsoft.app/managedenvironments (2)
- microsoft.dashboard/grafana (1)
- microsoft.databricks/workspaces (1)

### 14. Switzerland West (`switzerlandwest`)
Coverage: **30%** | Covered: **12** | Missing: **28** | Instances at risk: **445**

**Missing resource types (instance count in source):**

- microsoft.web/sites (58)
- microsoft.storage/storageaccounts (45)
- microsoft.network/privateendpoints (41)
- microsoft.keyvault/vaults (38)
- microsoft.network/networksecuritygroups (34)
- microsoft.web/serverfarms (32)
- microsoft.network/networkinterfaces (28)
- microsoft.compute/disks (26)
- microsoft.sql/servers/databases (24)
- microsoft.network/publicipaddresses (22)
- microsoft.compute/virtualmachines (14)
- microsoft.network/virtualnetworks (12)
- microsoft.app/containerapps (9)
- microsoft.network/loadbalancers (8)
- microsoft.documentdb/databaseaccounts (8)
- microsoft.servicebus/namespaces (7)
- microsoft.web/staticsites (6)
- microsoft.sql/servers (6)
- microsoft.cache/redis (5)
- microsoft.eventgrid/topics (4)
- microsoft.compute/virtualmachinescalesets (4)
- microsoft.eventhub/namespaces (3)
- microsoft.network/applicationgateways (3)
- microsoft.app/managedenvironments (2)
- microsoft.apimanagement/service (2)
- microsoft.recoveryservices/vaults (2)
- microsoft.dashboard/grafana (1)
- microsoft.network/bastionhosts (1)

### 15. France South (`francesouth`)
Coverage: **25%** | Covered: **10** | Missing: **30** | Instances at risk: **513**

**Missing resource types (instance count in source):**

- microsoft.managedidentity/userassignedidentities (72)
- microsoft.web/sites (58)
- microsoft.storage/storageaccounts (45)
- microsoft.network/privateendpoints (41)
- microsoft.keyvault/vaults (38)
- microsoft.network/networksecuritygroups (34)
- microsoft.web/serverfarms (32)
- microsoft.network/networkinterfaces (28)
- microsoft.compute/disks (26)
- microsoft.sql/servers/databases (24)
- microsoft.network/publicipaddresses (22)
- microsoft.compute/virtualmachines (14)
- microsoft.network/virtualnetworks (12)
- microsoft.network/loadbalancers (8)
- microsoft.documentdb/databaseaccounts (8)
- microsoft.servicebus/namespaces (7)
- microsoft.web/staticsites (6)
- microsoft.sql/servers (6)
- microsoft.cache/redis (5)
- microsoft.eventgrid/topics (4)
- microsoft.compute/virtualmachinescalesets (4)
- microsoft.cognitiveservices/accounts (4)
- microsoft.eventhub/namespaces (3)
- microsoft.network/applicationgateways (3)
- microsoft.recoveryservices/vaults (2)
- microsoft.apimanagement/service (2)
- microsoft.search/searchservices (2)
- microsoft.network/bastionhosts (1)
- microsoft.databricks/workspaces (1)
- microsoft.dashboard/grafana (1)

### 16. Germany North (`germanynorth`)
Coverage: **20%** | Covered: **8** | Missing: **32** | Instances at risk: **524**

**Missing resource types (instance count in source):**

- microsoft.managedidentity/userassignedidentities (72)
- microsoft.web/sites (58)
- microsoft.storage/storageaccounts (45)
- microsoft.network/privateendpoints (41)
- microsoft.keyvault/vaults (38)
- microsoft.network/networksecuritygroups (34)
- microsoft.web/serverfarms (32)
- microsoft.network/networkinterfaces (28)
- microsoft.compute/disks (26)
- microsoft.sql/servers/databases (24)
- microsoft.network/publicipaddresses (22)
- microsoft.compute/virtualmachines (14)
- microsoft.network/virtualnetworks (12)
- microsoft.app/containerapps (9)
- microsoft.network/loadbalancers (8)
- microsoft.documentdb/databaseaccounts (8)
- microsoft.servicebus/namespaces (7)
- microsoft.web/staticsites (6)
- microsoft.sql/servers (6)
- microsoft.cache/redis (5)
- microsoft.compute/virtualmachinescalesets (4)
- microsoft.eventgrid/topics (4)
- microsoft.cognitiveservices/accounts (4)
- microsoft.network/applicationgateways (3)
- microsoft.eventhub/namespaces (3)
- microsoft.app/managedenvironments (2)
- microsoft.apimanagement/service (2)
- microsoft.datafactory/factories (2)
- microsoft.recoveryservices/vaults (2)
- microsoft.dashboard/grafana (1)
- microsoft.databricks/workspaces (1)
- microsoft.network/bastionhosts (1)

### 17. Norway West (`norwaywest`)
Coverage: **17.5%** | Covered: **7** | Missing: **33** | Instances at risk: **526**

**Missing resource types (instance count in source):**

- microsoft.managedidentity/userassignedidentities (72)
- microsoft.web/sites (58)
- microsoft.storage/storageaccounts (45)
- microsoft.network/privateendpoints (41)
- microsoft.keyvault/vaults (38)
- microsoft.network/networksecuritygroups (34)
- microsoft.web/serverfarms (32)
- microsoft.network/networkinterfaces (28)
- microsoft.compute/disks (26)
- microsoft.sql/servers/databases (24)
- microsoft.network/publicipaddresses (22)
- microsoft.compute/virtualmachines (14)
- microsoft.network/virtualnetworks (12)
- microsoft.app/containerapps (9)
- microsoft.network/loadbalancers (8)
- microsoft.documentdb/databaseaccounts (8)
- microsoft.servicebus/namespaces (7)
- microsoft.web/staticsites (6)
- microsoft.sql/servers (6)
- microsoft.cache/redis (5)
- microsoft.eventgrid/topics (4)
- microsoft.compute/virtualmachinescalesets (4)
- microsoft.cognitiveservices/accounts (4)
- microsoft.eventhub/namespaces (3)
- microsoft.network/applicationgateways (3)
- microsoft.datafactory/factories (2)
- microsoft.search/searchservices (2)
- microsoft.recoveryservices/vaults (2)
- microsoft.apimanagement/service (2)
- microsoft.app/managedenvironments (2)
- microsoft.dashboard/grafana (1)
- microsoft.databricks/workspaces (1)
- microsoft.network/bastionhosts (1)

