<#
.SYNOPSIS
    Enumerate Azure resource providers (services) and their availability across the regions
    of a chosen geography (e.g. Europe, US, Asia Pacific).

.DESCRIPTION
    Uses ARM provider metadata to build a matrix of Azure resource providers x regions
    for the geography you choose. Also produces a "friendly name" view that maps ARM
    namespaces to marketing service names and categories.

    Output files (written to -OutputDirectory):
      - <geo>-region-summary.csv                 Per-region counts (available / not / global).
      - services-by-<geo>-region.csv             Raw namespace x region matrix.
      - services-by-<geo>-region.md              Per-region Available / Not available lists (namespaces).
      - services-by-<geo>-region-friendly.csv    Matrix with friendly ServiceName + Category.
      - services-by-<geo>-region-friendly.md     Per-region Available / Not available lists (friendly).

    Notes:
      - Region availability is taken from the union of resourceTypes[].locations for each provider.
      - Providers with no locations on any resource type are treated as "global" (Entra, ARM, DNS, etc.)
        and are marked 'global' in the region cells.
      - Some SKUs are gated further by capacity/quota; verify with 'az vm list-skus -l <region>' or
        the Retail Prices API before committing to a design.

.PARAMETER GeographyGroup
    Azure geography group to enumerate. Common values: 'Europe', 'US', 'Asia Pacific',
    'Canada', 'South America', 'Middle East', 'Africa', 'Australia'.
    Default: 'Europe'. Case-insensitive.
    Use -List to see the values available in your tenant.

.PARAMETER SubscriptionId
    Subscription to use. If omitted, uses the currently-selected 'az' subscription.
    Provider metadata is largely subscription-independent, so any active subscription works.

.PARAMETER OutputDirectory
    Directory to write outputs into. Created if it doesn't exist. Default: current directory.

.PARAMETER SkipFriendly
    Skip the friendly-name outputs (produces only the raw CSV + MD + summary).

.PARAMETER List
    List the geography groups and regions visible to the current subscription and exit.

.EXAMPLE
    ./Get-AzureServicesByRegion.ps1
    # Europe, using the current subscription. Writes 5 files to the current directory.

.EXAMPLE
    ./Get-AzureServicesByRegion.ps1 -GeographyGroup 'US' -OutputDirectory './out'

.EXAMPLE
    ./Get-AzureServicesByRegion.ps1 -GeographyGroup 'Asia Pacific' `
        -SubscriptionId 00000000-0000-0000-0000-000000000000

.EXAMPLE
    ./Get-AzureServicesByRegion.ps1 -List
    # Just print the geography groups and regions available.

.NOTES
    Requires: Azure CLI (`az`) on PATH, and PowerShell 5.1+ (or PowerShell 7+ on any OS).
    You must be logged in ('az login').

    Version: 1.0.0
    License: MIT
#>
[CmdletBinding()]
param(
    [string]$GeographyGroup = 'Europe',
    [string]$SubscriptionId,
    [string]$OutputDirectory = (Get-Location).Path,
    [switch]$SkipFriendly,
    [switch]$List
)

$ErrorActionPreference = 'Stop'

# Force UTF-8 so region physical location names with accented characters (e.g. "Gävle") survive.
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch { }

# ------------------------------------------------------------------ helpers --

function Test-Prereq {
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        throw "Azure CLI ('az') is not on PATH. Install from https://learn.microsoft.com/cli/azure/install-azure-cli"
    }
    $acct = az account show 2>$null | ConvertFrom-Json
    if (-not $acct) {
        throw "Not signed in. Run 'az login' first."
    }
    return $acct
}

function Set-ActiveSubscription([string]$SubId) {
    if ($SubId) {
        Write-Host "Setting subscription to $SubId ..." -ForegroundColor Cyan
        az account set --subscription $SubId | Out-Null
    }
    return (az account show | ConvertFrom-Json)
}

function ConvertTo-Slug([string]$s) {
    ($s.ToLowerInvariant() -replace '\s+','-' -replace '[^a-z0-9\-]','' -replace '-+','-').Trim('-')
}

function Get-NormalizedLocation([string]$s) {
    if ($null -eq $s) { return '' }
    ($s -replace '\s','').ToLowerInvariant()
}

# Curated ARM namespace -> [FriendlyName, Category] mapping. Extend as needed.
function Get-FriendlyServiceMap {
    return @{
        'microsoft.aad'                              = @('Azure Active Directory Domain Services','Identity')
        'microsoft.aadcustomsecurityattributesdiagnosticsettings' = @('Entra Custom Security Attributes Diagnostic Settings','Identity')
        'microsoft.aadiam'                           = @('Entra ID (IAM diagnostic)','Identity')
        'microsoft.addons'                           = @('Azure Support Add-ons','Management')
        'microsoft.adhybridhealthservice'            = @('Entra Connect Health','Identity')
        'microsoft.advisor'                          = @('Azure Advisor','Management')
        'microsoft.alertsmanagement'                 = @('Azure Monitor Alerts','Monitor')
        'microsoft.analysisservices'                 = @('Azure Analysis Services','Analytics')
        'microsoft.apicenter'                        = @('Azure API Center','Integration')
        'microsoft.apimanagement'                    = @('Azure API Management','Integration')
        'microsoft.app'                              = @('Azure Container Apps','Containers')
        'microsoft.appassessment'                    = @('Azure App Assessment','Migration')
        'microsoft.appcomplianceautomation'          = @('App Compliance Automation','Security')
        'microsoft.appconfiguration'                 = @('Azure App Configuration','Developer Tools')
        'microsoft.applicationmigration'             = @('Application Migration','Migration')
        'microsoft.applink'                          = @('App Link','Developer Tools')
        'microsoft.appplatform'                      = @('Azure Spring Apps','Containers')
        'microsoft.approvals'                        = @('Azure Approvals','Management')
        'microsoft.arccontainerstorage'              = @('Azure Container Storage (Arc)','Storage')
        'microsoft.attestation'                      = @('Azure Attestation','Security')
        'microsoft.authorization'                    = @('Azure RBAC / Authorization','Identity')
        'microsoft.automanage'                       = @('Azure Automanage','Management')
        'microsoft.automation'                       = @('Azure Automation','Management')
        'microsoft.avs'                              = @('Azure VMware Solution','Compute')
        'microsoft.awsconnector'                     = @('AWS Connector for Azure Arc','Hybrid + Multicloud')
        'microsoft.azureactivedirectory'             = @('Azure AD B2C','Identity')
        'microsoft.azurearcdata'                     = @('Azure Arc-enabled Data Services','Hybrid + Multicloud')
        'microsoft.azurebusinesscontinuity'          = @('Azure Business Continuity Center','Backup / DR')
        'microsoft.azurecontextcache'                = @('Azure Context Cache','Management')
        'microsoft.azuredatatransfer'                = @('Azure Data Transfer','Storage')
        'microsoft.azurefleet'                       = @('Azure Compute Fleet','Compute')
        'microsoft.azureimagetestingforlinux'        = @('Azure Image Testing for Linux','Compute')
        'microsoft.azurelargeinstance'               = @('Azure Large Instances','Compute')
        'microsoft.azureplaywrightservice'           = @('Azure Playwright Testing','Developer Tools')
        'microsoft.azureresiliencemanagement'        = @('Azure Resilience Management','Management')
        'microsoft.azurescan'                        = @('Azure Scan (Defender)','Security')
        'microsoft.azuresphere'                      = @('Azure Sphere','IoT')
        'microsoft.azurestack'                       = @('Azure Stack','Hybrid + Multicloud')
        'microsoft.azurestackhci'                    = @('Azure Local (Stack HCI)','Hybrid + Multicloud')
        'microsoft.azureterraform'                   = @('Azure Terraform','DevOps')
        'microsoft.backupsolutions'                  = @('Backup Solutions','Backup / DR')
        'microsoft.baremetal'                        = @('Azure BareMetal','Compute')
        'microsoft.baremetalinfrastructure'          = @('BareMetal Infrastructure','Compute')
        'microsoft.batch'                            = @('Azure Batch','Compute')
        'microsoft.billing'                          = @('Azure Billing','Management')
        'microsoft.billingbenefits'                  = @('Azure Savings Plans','Management')
        'microsoft.billingtrust'                     = @('Azure Billing Trust','Management')
        'microsoft.bing'                             = @('Bing Search','AI + ML')
        'microsoft.blockchaintokens'                 = @('Azure Blockchain Tokens','Blockchain')
        'microsoft.blueprint'                        = @('Azure Blueprints','Management')
        'microsoft.botservice'                       = @('Azure Bot Service','AI + ML')
        'microsoft.cache'                            = @('Azure Cache for Redis','Databases')
        'microsoft.capacity'                         = @('Azure Reserved Capacity','Management')
        'microsoft.carbon'                           = @('Microsoft Sustainability Manager','Management')
        'microsoft.cdn'                              = @('Azure CDN / Front Door','Networking')
        'microsoft.certificateregistration'          = @('App Service Certificates','Web')
        'microsoft.changesafety'                     = @('Change Safety','Management')
        'microsoft.chaos'                            = @('Azure Chaos Studio','Developer Tools')
        'microsoft.cleanroom'                        = @('Azure Confidential Clean Room','Security')
        'microsoft.clouddeviceplatform'              = @('Cloud Device Platform','Management')
        'microsoft.cloudhealth'                      = @('Cloud Health','Management')
        'microsoft.cloudshell'                       = @('Azure Cloud Shell','Developer Tools')
        'microsoft.cloudtest'                        = @('Cloud Test','Developer Tools')
        'microsoft.codesigning'                      = @('Trusted Signing','Security')
        'microsoft.cognitiveservices'                = @('Azure AI Services (Cognitive Services / OpenAI)','AI + ML')
        'microsoft.commerce'                         = @('Azure Commerce','Management')
        'microsoft.communication'                    = @('Azure Communication Services','Integration')
        'microsoft.compute'                          = @('Azure Virtual Machines','Compute')
        'microsoft.computebulkactions'               = @('Compute Bulk Actions','Compute')
        'microsoft.computelimit'                     = @('Compute Limits','Compute')
        'microsoft.computeschedule'                  = @('Compute Schedule','Compute')
        'microsoft.confidentialledger'               = @('Azure Confidential Ledger','Security')
        'microsoft.confluent'                        = @('Confluent Cloud (Azure Native)','Analytics')
        'microsoft.connectedcache'                   = @('Connected Cache','Networking')
        'microsoft.connectedcredentials'             = @('Connected Credentials','Identity')
        'microsoft.connectedopenstack'               = @('Connected OpenStack','Hybrid + Multicloud')
        'microsoft.connectedvehicle'                 = @('Connected Vehicle Platform','IoT')
        'microsoft.connectedvmwarevsphere'           = @('Azure Arc-enabled VMware vSphere','Hybrid + Multicloud')
        'microsoft.consumption'                      = @('Azure Consumption','Management')
        'microsoft.containerinstance'                = @('Azure Container Instances','Containers')
        'microsoft.containerregistry'                = @('Azure Container Registry','Containers')
        'microsoft.containerservice'                 = @('Azure Kubernetes Service (AKS)','Containers')
        'microsoft.costmanagement'                   = @('Microsoft Cost Management','Management')
        'microsoft.costmanagementexports'            = @('Cost Management Exports','Management')
        'microsoft.customerlockbox'                  = @('Customer Lockbox','Security')
        'microsoft.customproviders'                  = @('Custom Providers','Management')
        'microsoft.d365customerinsights'             = @('Dynamics 365 Customer Insights','Integration')
        'microsoft.dashboard'                        = @('Azure Managed Grafana','Monitor')
        'microsoft.databasefleetmanager'             = @('Database Fleet Manager','Databases')
        'microsoft.databasewatcher'                  = @('Database Watcher (SQL)','Databases')
        'microsoft.databox'                          = @('Azure Data Box','Storage')
        'microsoft.databoxedge'                      = @('Azure Data Box Edge / Stack Edge','Storage')
        'microsoft.databricks'                       = @('Azure Databricks','Analytics')
        'microsoft.datadog'                          = @('Datadog on Azure','Monitor')
        'microsoft.datafactory'                      = @('Azure Data Factory','Analytics')
        'microsoft.datalakeanalytics'                = @('Azure Data Lake Analytics','Analytics')
        'microsoft.datalakestore'                    = @('Azure Data Lake Storage Gen1','Storage')
        'microsoft.datamigration'                    = @('Azure Database Migration Service','Migration')
        'microsoft.dataprotection'                   = @('Azure Backup','Backup / DR')
        'microsoft.datareplication'                  = @('Azure Site Recovery','Backup / DR')
        'microsoft.datashare'                        = @('Azure Data Share','Analytics')
        'microsoft.dbformariadb'                     = @('Azure Database for MariaDB','Databases')
        'microsoft.dbformysql'                       = @('Azure Database for MySQL','Databases')
        'microsoft.dbforpostgresql'                  = @('Azure Database for PostgreSQL','Databases')
        'microsoft.dependencymap'                    = @('Service Map / Dependency','Monitor')
        'microsoft.desktopvirtualization'            = @('Azure Virtual Desktop','Compute')
        'microsoft.devcenter'                        = @('Microsoft Dev Box','Developer Tools')
        'microsoft.developmentwindows365'            = @('Windows 365 (development)','Compute')
        'microsoft.devhub'                           = @('Azure Deployment Environments','Developer Tools')
        'microsoft.deviceonboarding'                 = @('Device Onboarding','IoT')
        'microsoft.deviceregistry'                   = @('Azure Device Registry','IoT')
        'microsoft.devices'                          = @('Azure IoT Hub','IoT')
        'microsoft.deviceupdate'                     = @('Device Update for IoT Hub','IoT')
        'microsoft.devopsinfrastructure'             = @('Managed DevOps Pools','DevOps')
        'microsoft.devtestlab'                       = @('Azure DevTest Labs','Developer Tools')
        'microsoft.diagnostics'                      = @('Azure Diagnostics','Monitor')
        'microsoft.digitaltwins'                     = @('Azure Digital Twins','IoT')
        'microsoft.directorystore'                   = @('Directory Store','Identity')
        'microsoft.discovery'                        = @('Discovery Service','Management')
        'microsoft.documentdb'                       = @('Azure Cosmos DB','Databases')
        'microsoft.domainregistration'               = @('App Service Domains','Web')
        'microsoft.durabletask'                      = @('Azure Durable Task','Integration')
        'microsoft.easm'                             = @('Defender External Attack Surface Management','Security')
        'microsoft.edge'                             = @('Azure Edge','IoT')
        'microsoft.edgemarketplace'                  = @('Edge Marketplace','Marketplace')
        'microsoft.edgeorder'                        = @('Azure Edge Order','Storage')
        'microsoft.edgeorderpartner'                 = @('Edge Order Partner','Storage')
        'microsoft.edgezones'                        = @('Azure Edge Zones','Networking')
        'microsoft.elastic'                          = @('Elastic on Azure','Monitor')
        'microsoft.elasticsan'                       = @('Azure Elastic SAN','Storage')
        'microsoft.enterprisesupport'                = @('Enterprise Support','Management')
        'microsoft.entitlementmanagement'            = @('Entra Entitlement Management','Identity')
        'microsoft.entraidgovernance'                = @('Entra ID Governance','Identity')
        'microsoft.entraidgovernanceaccelerator'     = @('Entra ID Governance Accelerator','Identity')
        'microsoft.eventgrid'                        = @('Azure Event Grid','Integration')
        'microsoft.eventhub'                         = @('Azure Event Hubs','Integration')
        'microsoft.experimentation'                  = @('Azure Experimentation','Developer Tools')
        'microsoft.extendedlocation'                 = @('Azure Extended Locations','Hybrid + Multicloud')
        'microsoft.fabric'                           = @('Microsoft Fabric','Analytics')
        'microsoft.falcon'                           = @('Falcon (internal)','Management')
        'microsoft.features'                         = @('Azure Feature Registrations','Management')
        'microsoft.fileshares'                       = @('Azure File Shares','Storage')
        'microsoft.fluidrelay'                       = @('Azure Fluid Relay','Developer Tools')
        'microsoft.gcpconnector'                     = @('GCP Connector for Azure Arc','Hybrid + Multicloud')
        'microsoft.genome'                           = @('Microsoft Genomics','AI + ML')
        'microsoft.graphservices'                    = @('Microsoft Graph Services','Identity')
        'microsoft.guestconfiguration'               = @('Azure Policy Guest Configuration','Management')
        'microsoft.hanaonazure'                      = @('SAP HANA on Azure Large Instances','Compute')
        'microsoft.hardware'                         = @('Azure Hardware','Compute')
        'microsoft.hardwaresecuritymodules'          = @('Azure Dedicated HSM / Managed HSM','Security')
        'microsoft.hdinsight'                        = @('Azure HDInsight','Analytics')
        'microsoft.healthbot'                        = @('Azure Health Bot','AI + ML')
        'microsoft.healthcareapis'                   = @('Azure Health Data Services','AI + ML')
        'microsoft.healthcareinterop'                = @('Healthcare Interop','AI + ML')
        'microsoft.healthdataaiservices'             = @('Health Data AI Services','AI + ML')
        'microsoft.healthmodel'                      = @('Health Model','Monitor')
        'microsoft.healthplatform'                   = @('Health Platform','AI + ML')
        'microsoft.help'                             = @('Azure Help + Support','Management')
        'microsoft.horizondb'                        = @('Horizon DB','Databases')
        'microsoft.hybridcloud'                      = @('Hybrid Cloud','Hybrid + Multicloud')
        'microsoft.hybridcompute'                    = @('Azure Arc-enabled Servers','Hybrid + Multicloud')
        'microsoft.hybridconnectivity'               = @('Azure Arc Hybrid Connectivity','Hybrid + Multicloud')
        'microsoft.hybridcontainerservice'           = @('AKS on Azure Local','Hybrid + Multicloud')
        'microsoft.hybridnetwork'                    = @('Azure Operator Nexus','Networking')
        'microsoft.impact'                           = @('Azure Impact Reporting','Management')
        'microsoft.inferenceservice'                 = @('Azure Inference Service','AI + ML')
        'microsoft.insights'                         = @('Azure Monitor / Application Insights','Monitor')
        'microsoft.integrationspaces'                = @('Azure Integration Environments','Integration')
        'microsoft.iotcentral'                       = @('Azure IoT Central','IoT')
        'microsoft.iotfirmwaredefense'               = @('Defender for IoT Firmware Analysis','IoT')
        'microsoft.iotoperations'                    = @('Azure IoT Operations','IoT')
        'microsoft.iotoperationsdataprocessor'       = @('IoT Operations Data Processor','IoT')
        'microsoft.iotsecurity'                      = @('Defender for IoT','IoT')
        'microsoft.keyvault'                         = @('Azure Key Vault','Security')
        'microsoft.kubernetes'                       = @('Azure Arc-enabled Kubernetes','Hybrid + Multicloud')
        'microsoft.kubernetesconfiguration'          = @('Kubernetes Configuration (Flux/GitOps)','Containers')
        'microsoft.kubernetesruntime'                = @('Kubernetes Runtime','Containers')
        'microsoft.kusto'                            = @('Azure Data Explorer (Kusto)','Analytics')
        'microsoft.labservices'                      = @('Azure Lab Services','Developer Tools')
        'microsoft.loadtestservice'                  = @('Azure Load Testing','Developer Tools')
        'microsoft.logic'                            = @('Azure Logic Apps','Integration')
        'microsoft.machinelearningservices'          = @('Azure Machine Learning','AI + ML')
        'microsoft.maintenance'                      = @('Azure Maintenance','Management')
        'microsoft.managedidentity'                  = @('Managed Identities','Identity')
        'microsoft.managednetworkfabric'             = @('Azure Managed Network Fabric','Networking')
        'microsoft.managedops'                       = @('Managed Ops','Management')
        'microsoft.managedservices'                  = @('Azure Lighthouse','Management')
        'microsoft.management'                       = @('Azure Management Groups','Management')
        'microsoft.maps'                             = @('Azure Maps','AI + ML')
        'microsoft.marketplace'                      = @('Azure Marketplace','Marketplace')
        'microsoft.marketplaceordering'              = @('Azure Marketplace Ordering','Marketplace')
        'microsoft.messagingcatalog'                 = @('Messaging Catalog','Integration')
        'microsoft.messagingconnectors'              = @('Messaging Connectors','Integration')
        'microsoft.migrate'                          = @('Azure Migrate','Migration')
        'microsoft.mission'                          = @('Mission (internal)','Management')
        'microsoft.monitor'                          = @('Azure Monitor Workspace (Prometheus)','Monitor')
        'microsoft.mysqldiscovery'                   = @('MySQL Discovery','Databases')
        'microsoft.netapp'                           = @('Azure NetApp Files','Storage')
        'microsoft.network'                          = @('Azure Networking (VNet/LB/Firewall/etc)','Networking')
        'microsoft.networkcloud'                     = @('Azure Operator Nexus - Network Cloud','Networking')
        'microsoft.networkfunction'                  = @('Azure Network Function Manager','Networking')
        'microsoft.nexusidentity'                    = @('Operator Nexus Identity','Networking')
        'microsoft.notificationhubs'                 = @('Azure Notification Hubs','Integration')
        'microsoft.nutanix'                          = @('Nutanix Cloud Clusters on Azure','Compute')
        'microsoft.objectstore'                      = @('Object Store','Storage')
        'microsoft.offazure'                         = @('Azure Migrate - Off-Azure discovery','Migration')
        'microsoft.offazurespringboot'               = @('Migrate Spring Boot to Azure','Migration')
        'microsoft.onlineexperimentation'            = @('Azure Online Experimentation','Developer Tools')
        'microsoft.openenergyplatform'               = @('Microsoft Energy Data Services','Analytics')
        'microsoft.operationalinsights'              = @('Log Analytics','Monitor')
        'microsoft.operationsmanagement'             = @('Operations Management Suite','Monitor')
        'microsoft.operatorvoicemail'                = @('Operator Voicemail','Networking')
        'microsoft.orbital'                          = @('Azure Orbital Ground Station','Networking')
        'microsoft.partnerenrollment'                = @('Partner Enrollment','Management')
        'microsoft.partnermanagedconsumerrecurrence' = @('Partner Managed Consumer Recurrence','Management')
        'microsoft.peering'                          = @('Azure Peering Service','Networking')
        'microsoft.pki'                              = @('Azure Cloud PKI','Security')
        'microsoft.policyinsights'                   = @('Azure Policy Insights','Management')
        'microsoft.portal'                           = @('Azure Portal Dashboards','Management')
        'microsoft.portalservices'                   = @('Azure Portal Services','Management')
        'microsoft.powerbi'                          = @('Power BI Embedded','Analytics')
        'microsoft.powerbidedicated'                 = @('Power BI Dedicated','Analytics')
        'microsoft.powerplatform'                    = @('Power Platform','Integration')
        'microsoft.powerplatformmonitoringhub'       = @('Power Platform Monitoring Hub','Integration')
        'microsoft.premonition'                      = @('Premonition','Management')
        'microsoft.professionalservice'              = @('Professional Services','Management')
        'microsoft.programenrollment'                = @('Program Enrollment','Management')
        'microsoft.providerhub'                      = @('Provider Hub','Management')
        'microsoft.purview'                          = @('Microsoft Purview','Analytics')
        'microsoft.quantum'                          = @('Azure Quantum','AI + ML')
        'microsoft.quota'                            = @('Azure Quota','Management')
        'microsoft.recoveryservices'                 = @('Azure Recovery Services (Backup/ASR)','Backup / DR')
        'microsoft.redhatopenshift'                  = @('Azure Red Hat OpenShift','Containers')
        'microsoft.relationships'                    = @('Resource Relationships','Management')
        'microsoft.relay'                            = @('Azure Relay','Integration')
        'microsoft.resourcebuilder'                  = @('Resource Builder','Management')
        'microsoft.resourceconnector'                = @('Azure Arc Resource Bridge','Hybrid + Multicloud')
        'microsoft.resourcegraph'                    = @('Azure Resource Graph','Management')
        'microsoft.resourcehealth'                   = @('Azure Resource Health','Management')
        'microsoft.resourceintelligence'             = @('Resource Intelligence','Management')
        'microsoft.resourcenotifications'            = @('Azure Resource Notifications','Management')
        'microsoft.resources'                        = @('Azure Resource Manager (ARM)','Management')
        'microsoft.saas'                             = @('Azure SaaS','Marketplace')
        'microsoft.saashub'                          = @('SaaS Hub','Marketplace')
        'microsoft.scom'                             = @('Azure Monitor SCOM Managed Instance','Monitor')
        'microsoft.scvmm'                            = @('Azure Arc-enabled SCVMM','Hybrid + Multicloud')
        'microsoft.search'                           = @('Azure AI Search','AI + ML')
        'microsoft.secretsynccontroller'             = @('Secret Sync Controller','Security')
        'microsoft.security'                         = @('Microsoft Defender for Cloud','Security')
        'microsoft.securitycopilot'                  = @('Microsoft Security Copilot','Security')
        'microsoft.securitydetonation'               = @('Security Detonation','Security')
        'microsoft.securityinsights'                 = @('Microsoft Sentinel','Security')
        'microsoft.securityplatform'                 = @('Security Platform','Security')
        'microsoft.sentinelplatformservices'         = @('Sentinel Platform Services','Security')
        'microsoft.serialconsole'                    = @('Azure Serial Console','Compute')
        'microsoft.servicebus'                       = @('Azure Service Bus','Integration')
        'microsoft.servicefabric'                    = @('Azure Service Fabric','Compute')
        'microsoft.servicefabricmesh'                = @('Service Fabric Mesh','Compute')
        'microsoft.servicelinker'                    = @('Service Connector','Developer Tools')
        'microsoft.servicenetworking'                = @('Azure Service Networking (App Gw for Containers)','Networking')
        'microsoft.serviceshub'                      = @('Services Hub','Management')
        'microsoft.signalrservice'                   = @('Azure SignalR / Web PubSub','Web')
        'microsoft.singularity'                      = @('Singularity (AI Supercomputer)','AI + ML')
        'microsoft.softwareplan'                     = @('Azure Hybrid Benefit / Software Plans','Management')
        'microsoft.solutions'                        = @('Azure Managed Applications','Management')
        'microsoft.sovereign'                        = @('Azure Sovereign','Management')
        'microsoft.sql'                              = @('Azure SQL Database / Managed Instance','Databases')
        'microsoft.sqlvirtualmachine'                = @('SQL Server on Azure VM','Databases')
        'microsoft.standbypool'                      = @('Azure Standby VM Pool','Compute')
        'microsoft.storage'                          = @('Azure Storage (Blob/File/Queue/Table)','Storage')
        'microsoft.storageactions'                   = @('Storage Actions','Storage')
        'microsoft.storagecache'                     = @('Azure HPC Cache / Managed Lustre','Storage')
        'microsoft.storagediscovery'                 = @('Storage Discovery','Storage')
        'microsoft.storagemover'                     = @('Azure Storage Mover','Storage')
        'microsoft.storagesync'                      = @('Azure File Sync','Storage')
        'microsoft.storagetasks'                     = @('Storage Actions Tasks','Storage')
        'microsoft.streamanalytics'                  = @('Azure Stream Analytics','Analytics')
        'microsoft.subscription'                     = @('Azure Subscriptions','Management')
        'microsoft.supercomputerinfrastructure'      = @('Supercomputer Infrastructure','Compute')
        'microsoft.support'                          = @('Azure Support','Management')
        'microsoft.sustainabilityservices'           = @('Sustainability Services','Management')
        'microsoft.synapse'                          = @('Azure Synapse Analytics','Analytics')
        'microsoft.syntex'                           = @('Microsoft Syntex','AI + ML')
        'microsoft.toolchainorchestrator'            = @('Toolchain Orchestrator','DevOps')
        'microsoft.updatemanager'                    = @('Azure Update Manager','Management')
        'microsoft.usagebilling'                     = @('Usage Billing','Management')
        'microsoft.validate'                         = @('Validate','Management')
        'microsoft.verifiedid'                       = @('Microsoft Entra Verified ID','Identity')
        'microsoft.videoindexer'                     = @('Azure AI Video Indexer','AI + ML')
        'microsoft.virtualmachineimages'             = @('Azure VM Image Builder','Compute')
        'microsoft.visualstudio'                     = @('Azure DevOps / Visual Studio','DevOps')
        'microsoft.vmware'                           = @('VMware (legacy)','Compute')
        'microsoft.web'                              = @('Azure App Service / Functions','Web')
        'microsoft.weightsandbiases'                 = @('Weights and Biases on Azure','AI + ML')
        'microsoft.windows365'                       = @('Windows 365 Cloud PC','Compute')
        'microsoft.windowspushnotificationservices'  = @('Windows Push Notification Services','Integration')
        'microsoft.workloadbuilder'                  = @('Workload Builder','Management')
        'microsoft.workloads'                        = @('Azure Workloads (SAP)','Compute')
        'microsoft.zerotrustsegmentation'            = @('Zero Trust Segmentation','Security')
        # Third-party ISV native services
        'anyscale.platform'                          = @('Anyscale on Azure (Ray)','AI + ML (3rd party)')
        'arizeai.observabilityeval'                  = @('Arize AI Observability','AI + ML (3rd party)')
        'astronomer.astro'                           = @('Astronomer Astro (Airflow)','Analytics (3rd party)')
        'commvault.contentstore'                     = @('Commvault Cloud','Backup / DR (3rd party)')
        'dell.storage'                               = @('Dell APEX File Storage','Storage (3rd party)')
        'dynatrace.observability'                    = @('Dynatrace on Azure','Monitor (3rd party)')
        'github.network'                             = @('GitHub Enterprise Cloud Networking','DevOps (3rd party)')
        'informatica.datamanagement'                 = @('Informatica IDMC on Azure','Analytics (3rd party)')
        'lambdatest.hyperexecute'                    = @('LambdaTest HyperExecute','Developer Tools (3rd party)')
        'liftrbasic.samplerp'                        = @('Liftr Sample RP','Management (3rd party)')
        'mongodb.atlas'                              = @('MongoDB Atlas on Azure','Databases (3rd party)')
        'napster.companionapi'                       = @('Napster Companion','Media (3rd party)')
        'newrelic.observability'                     = @('New Relic on Azure','Monitor (3rd party)')
        'nginx.nginxplus'                            = @('NGINX Plus on Azure','Networking (3rd party)')
        'oracle.database'                            = @('Oracle Database at Azure','Databases (3rd party)')
        'paloaltonetworks.cloudngfw'                 = @('Palo Alto Networks Cloud NGFW','Security (3rd party)')
        'pinecone.vectordb'                          = @('Pinecone Vector DB on Azure','AI + ML (3rd party)')
        'purestorage.block'                          = @('Pure Storage Cloud Block Store','Storage (3rd party)')
        'qumulo.storage'                             = @('Qumulo on Azure','Storage (3rd party)')
    }
}

function Get-FriendlyName {
    param([string]$Namespace, [hashtable]$Map)
    $k = $Namespace.ToLowerInvariant()
    if ($Map.ContainsKey($k)) { return $Map[$k] }
    # Fallback: strip 'Microsoft.' and space out PascalCase.
    $short = $Namespace
    if ($short -match '^(?i)microsoft\.') { $short = $short.Substring(10) }
    $spaced = ($short -creplace '(?<=[a-z0-9])(?=[A-Z])',' ' -replace '\.',' ' -replace '\s+',' ').Trim()
    $cat = if ($Namespace -notmatch '^(?i)microsoft\.') { '3rd Party / Unmapped' } else { 'Unmapped' }
    return @($spaced, $cat)
}

# ---------------------------------------------------------------- main flow --

$acct = Test-Prereq
$acct = Set-ActiveSubscription -SubId $SubscriptionId
Write-Host ("Subscription: {0} ({1})" -f $acct.name, $acct.id) -ForegroundColor Green
Write-Host ("Tenant:       {0}" -f $acct.tenantId) -ForegroundColor Green

# Fetch all locations once.
Write-Host "Fetching locations ..." -ForegroundColor Cyan
$allLocations = az account list-locations -o json | ConvertFrom-Json

if ($List) {
    Write-Host "`nGeography groups visible to this subscription:" -ForegroundColor Yellow
    $allLocations |
        Where-Object { $_.metadata.geographyGroup } |
        Group-Object { $_.metadata.geographyGroup } |
        Sort-Object Name |
        ForEach-Object {
            Write-Host ("`n[{0}]" -f $_.Name) -ForegroundColor Yellow
            $_.Group | Sort-Object displayName |
                Select-Object @{N='Name';E={$_.name}}, @{N='DisplayName';E={$_.displayName}},
                              @{N='Physical';E={$_.metadata.physicalLocation}},
                              @{N='Category';E={$_.metadata.regionCategory}} |
                Format-Table -AutoSize | Out-String | Write-Host
        }
    return
}

$regions = $allLocations |
    Where-Object { $_.metadata -and $_.metadata.geographyGroup -and $_.metadata.geographyGroup.ToLower() -eq $GeographyGroup.ToLower() } |
    Sort-Object displayName

if (-not $regions) {
    $available = ($allLocations.metadata.geographyGroup | Where-Object { $_ } | Sort-Object -Unique) -join ', '
    throw "No regions found for geography group '$GeographyGroup'. Available groups: $available"
}

Write-Host ("Geography group '{0}' has {1} regions." -f $GeographyGroup, $regions.Count) -ForegroundColor Green

# Fetch all providers with their resource-type-level locations.
Write-Host "Fetching resource providers (this may take 30-60s) ..." -ForegroundColor Cyan
$providersJson = az provider list `
    --query "[].{ns:namespace, state:registrationState, types:resourceTypes[].{rt:resourceType, locs:locations}}" `
    -o json
$providers = $providersJson | ConvertFrom-Json
Write-Host ("Providers: {0}, Resource types: {1}" -f $providers.Count, ((($providers | ForEach-Object { $_.types.Count }) | Measure-Object -Sum).Sum)) -ForegroundColor Green

# Prepare output directory + slug.
if (-not (Test-Path $OutputDirectory)) { New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null }
$OutputDirectory = (Resolve-Path $OutputDirectory).Path
$slug = ConvertTo-Slug $GeographyGroup

# Build region column definitions.
$regionCols = $regions | ForEach-Object {
    [pscustomobject]@{
        Name    = $_.name
        Display = $_.displayName
        Norm    = (Get-NormalizedLocation $_.name)
    }
}

# Build raw rows: one per provider.
Write-Host "Building region availability matrix ..." -ForegroundColor Cyan
$rawRows = foreach ($p in $providers) {
    $locSet = New-Object System.Collections.Generic.HashSet[string]
    foreach ($rt in $p.types) {
        if ($rt.locs) { foreach ($l in $rt.locs) { [void]$locSet.Add((Get-NormalizedLocation $l)) } }
    }
    $isGlobal = ($locSet.Count -eq 0)
    $row = [ordered]@{
        Namespace     = $p.ns
        Registration  = $p.state
        ResourceTypes = $p.types.Count
        Global        = $isGlobal
    }
    foreach ($c in $regionCols) {
        $row[$c.Display] = if ($isGlobal) { 'global' } elseif ($locSet.Contains($c.Norm)) { 'yes' } else { 'no' }
    }
    [pscustomobject]$row
}

# ---------- raw CSV ----------
$rawCsv = Join-Path $OutputDirectory ("services-by-{0}-region.csv" -f $slug)
$rawRows | Sort-Object Namespace | Export-Csv -Path $rawCsv -NoTypeInformation -Encoding UTF8
Write-Host "  Wrote $rawCsv"

# ---------- summary CSV ----------
$summary = foreach ($c in $regionCols) {
    $yes = ($rawRows | Where-Object { $_.($c.Display) -eq 'yes' }).Count
    $no  = ($rawRows | Where-Object { $_.($c.Display) -eq 'no'  }).Count
    $glb = ($rawRows | Where-Object { $_.($c.Display) -eq 'global' }).Count
    [pscustomobject]@{
        Region              = $c.Name
        DisplayName         = $c.Display
        ProvidersAvailable  = $yes
        ProvidersUnavailable= $no
        GlobalProviders     = $glb
    }
}
$sumCsv = Join-Path $OutputDirectory ("{0}-region-summary.csv" -f $slug)
$summary | Sort-Object ProvidersAvailable -Descending | Export-Csv -Path $sumCsv -NoTypeInformation -Encoding UTF8
Write-Host "  Wrote $sumCsv"

# ---------- raw markdown ----------
$md = @()
$md += "# Azure resource providers by $GeographyGroup region"
$md += ""
$md += ("Generated: {0:yyyy-MM-dd} | Subscription: {1} | Providers: {2}" -f (Get-Date), $acct.name, $providers.Count)
$md += "Source: az account list-locations + az provider list. 'global' = provider not tied to any region."
$md += ""
foreach ($c in $regionCols) {
    $avail   = $rawRows | Where-Object { $_.($c.Display) -eq 'yes' } | Select-Object -ExpandProperty Namespace | Sort-Object
    $unavail = $rawRows | Where-Object { $_.($c.Display) -eq 'no'  } | Select-Object -ExpandProperty Namespace | Sort-Object
    $md += "## $($c.Display) ($($avail.Count) available / $($unavail.Count) not available)"
    $md += ""
    $md += "### Available"
    $md += ($avail | ForEach-Object { "- $_" })
    $md += ""
    $md += "### Not available"
    $md += ($unavail | ForEach-Object { "- $_" })
    $md += ""
}
$rawMd = Join-Path $OutputDirectory ("services-by-{0}-region.md" -f $slug)
$md -join "`n" | Set-Content -Path $rawMd -Encoding UTF8
Write-Host "  Wrote $rawMd"

if ($SkipFriendly) {
    Write-Host "Done." -ForegroundColor Green
    return
}

# ---------- friendly outputs ----------
Write-Host "Applying friendly-name mapping ..." -ForegroundColor Cyan
$map = Get-FriendlyServiceMap

$friendlyRows = foreach ($r in $rawRows) {
    $fc = Get-FriendlyName -Namespace $r.Namespace -Map $map
    $row = [ordered]@{
        ServiceName  = $fc[0]
        Category     = $fc[1]
        Namespace    = $r.Namespace
        Registration = $r.Registration
        Global       = $r.Global
    }
    foreach ($c in $regionCols) { $row[$c.Display] = $r.($c.Display) }
    [pscustomobject]$row
}

$friendlyCsv = Join-Path $OutputDirectory ("services-by-{0}-region-friendly.csv" -f $slug)
$friendlyRows | Sort-Object Category, ServiceName | Export-Csv -Path $friendlyCsv -NoTypeInformation -Encoding UTF8
Write-Host "  Wrote $friendlyCsv"

# Friendly markdown grouped by Category.
$mdF = @()
$mdF += "# Azure services by $GeographyGroup region (friendly names)"
$mdF += ""
$mdF += ("Generated: {0:yyyy-MM-dd} | Subscription: {1}" -f (Get-Date), $acct.name)
$mdF += "Service = ARM provider namespace with a curated friendly name and category."
$mdF += "'global' = provider not tied to any region (Entra, ARM, DNS, ...)."
$mdF += ""
foreach ($c in $regionCols) {
    $avail   = $friendlyRows | Where-Object { $_.($c.Display) -eq 'yes' } | Sort-Object Category, ServiceName
    $unavail = $friendlyRows | Where-Object { $_.($c.Display) -eq 'no'  } | Sort-Object Category, ServiceName
    $mdF += "## $($c.Display)"
    $mdF += "Available: **$($avail.Count)** | Not available: **$($unavail.Count)**"
    $mdF += ""
    $mdF += "### Available"
    $lastCat = ''
    foreach ($item in $avail) {
        if ($item.Category -ne $lastCat) { $mdF += ""; $mdF += "**$($item.Category)**"; $lastCat = $item.Category }
        $mdF += "- $($item.ServiceName) ``($($item.Namespace))``"
    }
    $mdF += ""
    $mdF += "### Not available"
    $lastCat = ''
    foreach ($item in $unavail) {
        if ($item.Category -ne $lastCat) { $mdF += ""; $mdF += "**$($item.Category)**"; $lastCat = $item.Category }
        $mdF += "- $($item.ServiceName) ``($($item.Namespace))``"
    }
    $mdF += ""
}
$friendlyMd = Join-Path $OutputDirectory ("services-by-{0}-region-friendly.md" -f $slug)
$mdF -join "`n" | Set-Content -Path $friendlyMd -Encoding UTF8
Write-Host "  Wrote $friendlyMd"

$unmapped = ($friendlyRows | Where-Object { $_.Category -match 'Unmapped' }).Count
if ($unmapped -gt 0) {
    Write-Host ("Note: {0} providers used the heuristic fallback (category 'Unmapped'). Add them to Get-FriendlyServiceMap to name them explicitly." -f $unmapped) -ForegroundColor Yellow
}

Write-Host "Done." -ForegroundColor Green
