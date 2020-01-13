function Get-ResourceGroupParams {
    $deployArgs = @{        
        ResourceGroupName = $resourceGroupName
        ResourceLocation  = $resourceLocation        
    }
    $deployArgs
}
function Get-ResourceGroupDeploymentParams {
    $deployArgs = @{        
        adminUsername = $vmAdminUser
        adminPassword = $vmadminPass
        domainName    = $nameSettings.Domain
        dnsPrefix     = $dnsNameLabelPrefix
        vmSize        = $vmSizes.DomainController
    }
    $deployArgs
}
function Get-StorageAccountDeploymentParams {
    $deployArgs = @{        
        StorageAccountName    = $nameSettings.StorageAccountName
        StorageAccountSkuName = $storageAccountSku
        resourceTags          = $resourceTagsAllResources
    }
    $deployArgs
}
function Get-KeyVaultDeploymentParams {
    $secretsObject = @(
        @{
            secretName  = "DomainAdminUsername"
            secretValue = $domainAdminUser
        },
        @{
            secretName  = "DomainAdminPassword"
            secretValue = $domainAdminPass
        },
        @{
            secretName  = "DomainName"
            secretValue = $nameSettings.Domain
        }
    )
    $secrets = @{secrets = $secretsObject }
    $deployArgs = @{        
        KeyVaultName  = $nameSettings.KeyVaultName
        objectId      = $objectID
        secretsObject = $secrets
        resourceTags  = $resourceTagsAllResources
    }
    $deployArgs
}
function Get-SqlDemoParams {
    $resourceTags = @{"Type" = "SQL" }
    $resourceTags += $resourceTagsAllResources
    $deployArgs = @{
        VirtualMachineName          = $nameSettings.SQLComputerName
        VirtualNetworkName          = $ipsettings.VirtualNetworkName
        SubnetName                  = $ipsettings.SubnetName
        PrivateIpAddress            = $ipsettings.SQL1
        EnableAcceleratedNetworking = $true
        VmSize                      = $vmSizes.SqlServer
        VmAdminUserName             = $vmAdminUser
        VmAdminPassword             = $vmadminPass
        DomainName                  = $nameSettings.Domain
        BCVersion                   = $BCVersion
        BCCumulativeUpdate          = $BCCumulativeUpdate
        BCLanguage                  = $BCLanguage
        resourceTags                = $resourceTags
    }
    $deployArgs
}
function Get-ApplicationServerImageParams {
    $resourceTags = @{"Created For" = "Image Preparation"; "Type" = "App" }
    $resourceTags += $resourceTagsAllResources
    $deployArgs = @{
        ImageName          = $nameSettings.APSImageName
        ScaleSetName       = $nameSettings.APSScaleSetName
        VirtualMachineName = $nameSettings.APSComputerName
        StorageAccountName = $nameSettings.StorageAccountName
        VirtualNetworkName = $ipsettings.VirtualNetworkName
        SubnetName         = $ipsettings.SubnetName
        PrivateIpAddress   = $ipsettings.APS1
        KeyVaultName       = $nameSettings.KeyVaultName
        BCVersion          = $BCVersion
        BCCumulativeUpdate = $BCCumulativeUpdate
        BCLanguage         = $BCLanguage
        VmAdminUserName    = $vmAdminUser
        VmAdminPassword    = $vmadminPass
        VmSize             = $vmSizes.ApplicationServer
        VmOperatingSystem  = "2019-Datacenter"
        InstallationType   = "App"
        resourceTags       = $resourceTags
    }
    $deployArgs
}
function Get-WebServerImageParams {
    $resourceTags = @{"Created For" = "Image Preparation"; "Type" = "Web" }
    $resourceTags += $resourceTagsAllResources
    $deployArgs = @{
        ImageName          = $nameSettings.WEBImageName
        ScaleSetName       = $nameSettings.WEBScaleSetName
        VirtualMachineName = $nameSettings.WEBComputerName
        StorageAccountName = $nameSettings.StorageAccountName
        VirtualNetworkName = $ipsettings.VirtualNetworkName
        SubnetName         = $ipsettings.SubnetName
        PrivateIpAddress   = $ipsettings.WEB1
        KeyVaultName       = $nameSettings.KeyVaultName
        BCVersion          = $BCVersion
        BCCumulativeUpdate = $BCCumulativeUpdate
        BCLanguage         = $BCLanguage
        VmAdminUserName    = $vmAdminUser
        VmAdminPassword    = $vmadminPass
        VmSize             = $vmSizes.WebServer
        VmOperatingSystem  = "2019-Datacenter"
        InstallationType   = "Web"
        resourceTags       = $resourceTags
    }
    $deployArgs
}
function Get-ApplicationScaleSetParams {
    $resourceTags = @{"Type" = "App" }
    $resourceTags += $resourceTagsAllResources
    $deployArgs = @{
        ImageName          = $nameSettings.APSImageName
        ScaleSetName       = $nameSettings.APSScaleSetName
        VirtualNetworkName = $ipsettings.VirtualNetworkName
        SubnetName         = $ipsettings.SubnetName
        KeyVaultName       = $nameSettings.KeyVaultName
        VmAdminUserName    = $vmAdminUser
        VmAdminPassword    = $vmadminPass
        VmSize             = $vmSizes.ApplicationServerScaleSet
        InstanceCount      = 1
        resourceTags       = $resourceTags
    }
    $deployArgs
}
function Get-WebScaleSetParams {
    $resourceTags = @{"Type" = "Web" }
    $resourceTags += $resourceTagsAllResources
    $deployArgs = @{
        ImageName          = $nameSettings.WEBImageName
        ScaleSetName       = $nameSettings.WEBScaleSetName
        VirtualNetworkName = $ipsettings.VirtualNetworkName
        SubnetName         = $ipsettings.SubnetName
        KeyVaultName       = $nameSettings.KeyVaultName
        VmAdminUserName    = $vmAdminUser
        VmAdminPassword    = $vmadminPass
        VmSize             = $vmSizes.WebServerScaleSet
        InstanceCount      = 1
        resourceTags       = $resourceTags
    }
    $deployArgs
}
function Get-LoadBalancerParams {
    $resourceTags = @{"Type" = "App" }
    $resourceTags += $resourceTagsAllResources
    $deployArgs = @{
        LoadBalancerName   = $nameSettings.LoadBalancerNameInternal 
        VMScaleSetName     = $nameSettings.APSScaleSetName
        VirtualNetworkName = $ipsettings.VirtualNetworkName
        SubnetName         = $ipsettings.SubnetName
        PrivateIpAddress   = $ipsettings.APSLoadBalancer
        LoadBalancerSku    = "Standard"
        Tags               = $resourceTags
    }
    $deployArgs
}
function Get-PublicLoadBalancerParams {
    $resourceTags = @{"Type" = "App" }
    $resourceTags += $resourceTagsAllResources
    $deployArgs = @{
        LoadBalancerName    = $nameSettings.LoadBalancerNamePublic
        VMScaleSetName      = $nameSettings.APSScaleSetName
        VirtualNetworkName  = $ipsettings.VirtualNetworkName
        SubnetName          = $ipsettings.SubnetName
        PublicIpAddressName = $nameSettings.APSLoadBalancerPublicIPName
        DomainNameLabel     = "$($dnsNameLabelPrefix)lb01"
        UpdateScaleSet      = $false
        LoadBalancerSku     = "Standard"
        Tags                = $resourceTags
    }
    $deployArgs
}
function Get-LoadBalancerConfigParams {
    $deployArgs = @{
        LoadBalancerName      = $nameSettings.LoadBalancerNameInternal 
        StorageAccountName    = $nameSettings.StorageAccountName
        TableNameEnvironments = $storageTableNames.Environments
        EnvironmentTypeFilter = "TEST"
    }
    $deployArgs
}
function Get-InfrastructureUpdateParams {
    $deployArgs = @{
        StorageAccountName      = $nameSettings.StorageAccountName 
        LoadBalancerName        = $nameSettings.LoadBalancerNameInternal 
        TableNameInfrastructure = $storageTableNames.Infrastructure
        AppScaleSetName         = $nameSettings.APSScaleSetName
        WebScaleSetName         = $nameSettings.WEBScaleSetName
    }
    $deployArgs
}
function Get-ApplicationGatewayParams {
    $resourceTags = @{"Type" = "App" }
    $resourceTags += $resourceTagsAllResources
    $deployArgs = @{
        ApplicationGatewayName = $nameSettings.ApplicationGatewayName 
        VMScaleSetName         = $nameSettings.WEBScaleSetName
        VirtualNetworkName     = $ipsettings.VirtualNetworkName
        SubnetName             = $ipsettings.SubnetNameApplicationGateway
        SubnetAddressPrefix    = $ipsettings.ApplicationGatewaySubnetAddressPrefix
        PrivateIpAddress       = $ipsettings.ApplicationGateway
        PublicIpAddressName    = $nameSettings.ApplicationGatewayPublicIPName
        StorageAccountName     = $nameSettings.StorageAccountName
        TableNameEnvironments  = $storageTableNames.Environments
        EnvironmentTypeFilter  = "TEST"
        Tags                   = $resourceTags
    }
    $deployArgs
}
function Get-StorageAccountTables {
    $tables = (
        [pscustomobject]@{ #Setup
            TableName = $storageTableNames.Setup
            Values    = 
            @{
                PartitionKey     = 0
                RowKey           = "000"
                Command          = "SetupNotDone"
                ObjectName       = ""
                Parameter1       = "ClearLog"
                Parameter2       = ""
                RestartNecessary = $true
            },
            @{
                PartitionKey     = 1
                RowKey           = "001"
                Command          = "CreateInstances"
                ObjectName       = "AppScaleSet"
                Parameter1       = "TEST"
                Parameter2       = ""
                RestartNecessary = $true
            },
            @{
                PartitionKey     = 1
                RowKey           = "002"
                Command          = "CreateWebInstances"
                ObjectName       = "WebScaleSet"
                Parameter1       = "TEST"
                Parameter2       = ""
                RestartNecessary = $true
            },
            @{
                PartitionKey     = 1
                RowKey           = "003"
                Command          = "UpdateInstanceConfiguration"
                ObjectName       = "AppScaleSet"
                Parameter1       = "TEST"
                Parameter2       = ""
                RestartNecessary = $true
            },
            @{
                PartitionKey     = 1
                RowKey           = "004"
                Command          = "UpdateWebInstances"
                ObjectName       = "WebScaleSet"
                Parameter1       = "TEST"
                Parameter2       = ""
                RestartNecessary = $true
            },
            @{
                PartitionKey     = 1
                RowKey           = "005"
                Command          = "CreateSPN"
                ObjectName       = "AppScaleSet"
                Parameter1       = "TEST"
                Parameter2       = ""
                RestartNecessary = $false
            },
            @{
                PartitionKey     = 1
                RowKey           = "006"
                Command          = "SetLoadbalancerDNSRecord"
                ObjectName       = "AppScaleSet"
                Parameter1       = "TEST"
                Parameter2       = ""
                RestartNecessary = $false
            },
            @{
                PartitionKey     = 1
                RowKey           = "007"
                Command          = "SetupDelegation"
                ObjectName       = "AppScaleSet"
                Parameter1       = "TEST"
                Parameter2       = ""
                RestartNecessary = $false
            },
            @{
                PartitionKey     = 1
                RowKey           = "008"
                Command          = "SetupNotDone"
                ObjectName       = ""
                Parameter1       = ""
                Parameter2       = ""
                RestartNecessary = $false
            },
            @{
                PartitionKey     = 1
                RowKey           = "009"
                Command          = "UpdateLicense"
                ObjectName       = "AppScaleSet"
                Parameter1       = "TEST"
                Parameter2       = "DEMO"
                RestartNecessary = $false
            },
            @{
                PartitionKey     = 1
                RowKey           = "010"
                Command          = "RestartServices"
                ObjectName       = "AppScaleSet"
                Parameter1       = "TEST"
                Parameter2       = ""
                RestartNecessary = $false
            },
            @{
                PartitionKey     = 1
                RowKey           = "011"
                Command          = "RestartIIS"
                ObjectName       = "WebScaleSet"
                Parameter1       = "TEST"
                Parameter2       = ""
                RestartNecessary = $false
            },
            @{
                PartitionKey     = 1
                RowKey           = "012"
                Command          = "AddUsers"
                ObjectName       = "AppScaleSet"
                Parameter1       = "TEST"
                Parameter2       = ""
                RestartNecessary = $false
            }
        },
        [pscustomobject]@{ #Environments
            TableName = $storageTableNames.Environments
            Values    = 
            @{
                PartitionKey           = 1
                RowKey                 = 1
                ServiceName            = "BCDefault"
                AuthType               = "Windows"
                ManagementServicesPort = "7045"
                ClientServicesPort     = "7046"
                SoapServicesPort       = "7047"
                ODataServicesPort      = "7048"
                DeveloperServicesPort  = "7049"
                DatabaseServer         = "SQL01"
                DatabaseInstance       = ""
                DatabaseName           = "Demo Database NAV (14-0)"
                Type                   = "TEST"
                KVCredentialIdentifier = ""
            }
        },
        [pscustomobject]@{ #EnvironmentDefaultValues
            TableName = $storageTableNames.EnvironmentDefaults
            Values    = 
            @{
                PartitionKey = 1
                RowKey       = 1
                KeyName      = "ApiServicesEnabled"
                KeyValue     = "True"
                ServiceName  = ""
                Webconfig    = $false
            },
            @{
                PartitionKey = 1
                RowKey       = 2
                KeyName      = "ODataServicesEnabled"
                KeyValue     = "True"
                ServiceName  = ""
                Webconfig    = $false
            },
            @{
                PartitionKey = 1
                RowKey       = 3
                KeyName      = "SOAPServicesEnabled"
                KeyValue     = "True"
                ServiceName  = ""
                Webconfig    = $false
            },
            @{
                PartitionKey = 1
                RowKey       = 4
                KeyName      = "EnableDebugging"
                KeyValue     = "True"
                ServiceName  = ""
                Webconfig    = $false
            },
            @{
                PartitionKey = 1
                RowKey       = 5
                KeyName      = "EnableSymbolLoadingAtServerStartup"
                KeyValue     = "True"
                ServiceName  = ""
                Webconfig    = $false
            },
            @{
                PartitionKey = 1
                RowKey       = 6
                KeyName      = "EnableTaskScheduler"
                KeyValue     = "True"
                ServiceName  = ""
                Webconfig    = $false
            },
            @{
                PartitionKey = 1
                RowKey       = 7
                KeyName      = "ServicesCertificateThumbprint"
                KeyValue     = ""
                ServiceName  = ""
                Webconfig    = $true
            }
        },
        [pscustomobject]@{ #LogTable
            TableName = $storageTableNames.LogTable
            Values    = 
            @{
                PartitionKey        = 0
                RowKey              = 0
                LogPartitionKey     = 0
                LogRowKey           = 0
                LogCommand          = "Init Log Entry"
                LogObjectName       = ""
                LogComputerName     = ""
                LogParameter1       = ""
                LogParameter2       = ""
                LogRestartNecessary = $false
            }
        },
        [pscustomobject]@{ #Infrastructure
            TableName = $storageTableNames.Infrastructure
            Values    = 
            @{
                PartitionKey                          = 0
                RowKey                                = 0
                Type                                  = "TEST"
                SetupTable                            = $storageTableNames.Setup
                EnvironmentsTable                     = $storageTableNames.Environments
                EnvironmentDefaultsTable              = $storageTableNames.EnvironmentDefaults
                LogTable                              = $storageTableNames.LogTable
                UsersTable                            = $storageTableNames.UsersTable
                ApplicationServerLoadBalancerIP       = ""
                DnsIdentity                           = ""
                DomainFqdn                            = $nameSettings.Domain
                ApplicationServerLoadBalancerHostName = $nameSettings.APSLoadBalancerHostName
                DomainControllerComputerName          = "adVM" # NOTE: From Sample Deployment
                AppServerComputerNamePrefix           = ""
                WebserverComputerNamePrefix           = ""
            }
        },
        [pscustomobject]@{ #Users
            TableName = $storageTableNames.UsersTable
            Values    = 
            @{
                PartitionKey       = 0
                RowKey             = 0
                UserName           = "$($nameSettings.DomainNetBios)\$domainAdminUser"
                UserFullname       = "Admin User"
                AuthenticationType = "Windows"
                PermissionSetId    = "SUPER"
                Password           = ""
            }
        }
    )
    $tables
}
$resourceTagsAllResources = @{"Staging" = "Sample Deployment" }

$BCVersion = "14"
$BCCumulativeUpdate = "CU02"
$BCLanguage = "DE"

# Credentials
$domainAdminUser = 'vmadmin'
$domainAdminPass = 'SuperSecurePassword!'
$domainAdminPassSecure = ConvertTo-SecureString $domainAdminPass -AsPlainText -Force

$vmAdminUser = $domainAdminUser
$vmadminPass = $domainAdminPass
$vmadminPassSecure = ConvertTo-SecureString $vmadminPass -AsPlainText -Force

# Main Resource infos
$resourceLocation = 'West Europe'
$resourceGroupSuffix = "001"
$resourceGroupName = "RG_ScaleSet$($resourceGroupSuffix)"

# Additional Parameters
$dnsNameLabelPrefix = "$($resourceGroupName)".Replace('_', '').Replace('-', '').ToLower() # mydnsname.westus.cloudapp.azure.com

# Used Templates
$sampleDomainTemplate = 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/active-directory-new-domain/azuredeploy.json'
$storageAccountTemplate = "https://raw.githubusercontent.com/SimonOfHH/ARM-Templates/master/Templates/D365BCOnAzure/Storage-Account.json"
$keyVaultTemplate = "https://raw.githubusercontent.com/SimonOfHH/ARM-Templates/master/Templates/D365BCOnAzure/Key-Vault.json"
$sqlServerTemplate = "https://raw.githubusercontent.com/SimonOfHH/ARM-Templates/master/Templates/D365BCOnAzure/Demo-Sql-Server.json"

# Storage Account infos
$storageAccountSku = 'Standard_LRS'
$storageTableNames = @{
    Setup               = "Setup"
    Environments        = "Environments"
    EnvironmentDefaults = "EnvironmentDefaultValues"
    Infrastructure      = "InfrastructureData"
    LogTable            = "Log"
    UsersTable          = "Users"
}

# ScaleSetName max 15 characters
$nameSettings = @{
    Domain                         = "bctest.local"
    DomainNetBios                  = "BCTEST"
    SQL                            = "sql01"
    SQLComputerName                = "SQL01"
    APS                            = "aps01"
    APSComputerName                = "APS01"
    APSScaleSetName                = "AppScaleSet"    
    APSLoadBalancerHostName        = "applb"
    APSLoadBalancerPublicIPName    = "AppScaleSetLB-PublicIP"
    WEB                            = "web01"
    WEBComputerName                = "WEB01"
    WEBScaleSetName                = "WebScaleSet"
    APSImageName                   = "ApplicationServerBaseImg_v1"
    WEBImageName                   = "WebServerBaseImg_v1"
    StorageAccountName             = "setupstorage001$($resourceGroupSuffix)".Replace("-", "").ToLower()
    KeyVaultName                   = "SetupValues001$($resourceGroupSuffix)"
    LoadBalancerNameInternal       = "AppScaleSetLB"
    LoadBalancerNamePublic         = "AppScaleSetLB-public"
    ApplicationGatewayName         = "WebScaleSet-AppGW"
    ApplicationGatewayPublicIPName = "WebScaleSet-AppGW-PublicIP"
}
$ipsettings = @{
    VirtualNetworkAddressPrefix           = "10.0.0.0/16"
    VirtualNetworkName                    = "adVNET" # NOTE: from Sample Deployment
    SubnetName                            = "adSubnet" # NOTE: from Sample Deployment
    SubnetNameApplicationGateway          = "ApplicationGateway" # Application Gate needs its own Subnet
    PrimarySubnetAddressPrefix            = "10.0.0.0/24"
    ApplicationGatewaySubnetAddressPrefix = "10.0.1.0/24" # Application Gate needs its own Subnet
    SQL1                                  = "10.0.0.10" # SQL Server 1              
    APS1                                  = "10.0.0.20" # Application Server 1 (temporary)
    WEB1                                  = "10.0.0.30" # Web Server 1 (temporary)
    APSLoadBalancer                       = "10.0.0.50"
    ApplicationGateway                    = "10.0.1.20"
}
# Default: "Standard_DS3_v2" for everything
$vmSizes = @{
    DomainController          = "Standard_DS3_v2"
    SqlServer                 = "Standard_DS3_v2"
    ApplicationServer         = "Standard_DS3_v2"
    ApplicationServerScaleSet = "Standard_DS3_v2"
    WebServer                 = "Standard_DS3_v2"
    WebServerScaleSet         = "Standard_DS3_v2"
}