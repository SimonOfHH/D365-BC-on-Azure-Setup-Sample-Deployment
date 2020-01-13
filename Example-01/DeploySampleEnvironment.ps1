$ErrorActionPreference = "Stop"
$VerbosePreference = "SilentlyContinue" # Avoid output of "Import-Module"-commands
Clear-Host

$reconnectAccount = $false
if ($reconnectAccount) {
    Connect-AzAccount -Force
    $context = Get-AzSubscription -SubscriptionName $subscriptionName
    Set-AzContext $context | Out-Null
}
$modules = @("Az.Resources", "Az.Storage", "Az.KeyVault", "Az.Accounts", "Az.Compute", "Az.Network", "PSWorkflow")
foreach ($module in $modules){
    if (-not (Get-Module -Name $module -ListAvailable)) {
        Write-Verbose "Installing module $module"
        Install-Module -Name $module -Force
    }
    Write-Verbose "Importing Module $module"
    Import-Module -Name $module
}

$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
. ("$ScriptDirectory\Parameters.ps1")
. ("$ScriptDirectory\PrivateParameters.ps1")

if (Get-Module -Name D365BCOnAzureDeployment -ListAvailable) {
    Update-Module -Name D365BCOnAzureDeployment -Force
} else {
    Install-Module -Name D365BCOnAzureDeployment -Force
}
Import-Module -Name D365BCOnAzureDeployment

$VerbosePreference = "Continue"
Write-Verbose "Test"
$testParameters = @{
    ResourceGroupName  = $ResourceGroupName
    ObjectID           = $objectID
    SubscriptionName   = $subscriptionName
    KeyVaultName       = $nameSettings.KeyVaultName
    StorageAccountName = $nameSettings.StorageAccountName
}
if (-not(Test-Parameters @testParameters)) {
    throw "Mandatory Parameters are missing. Please check your configuration. To see which parameters are missing, use the -Verbose switch to call this script."
    return
}
Test-AzContextHelper

$resourceArgs = Get-ResourceGroupParams

#region Create Sample Domain-deployment
$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -Location $resourceLocation -ErrorAction SilentlyContinue
if (-not($resourceGroup)) {
    Write-Verbose "Creating Resource Group $resourceGroupName..."
    $resourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $resourceLocation    
    Write-Verbose "Resource Group $resourceGroupName created"

    Write-Verbose "Deploying Sample Environment... (takes about 20 minutes)..."
    $params = Get-ResourceGroupDeploymentParams
    $domainJob = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
        -TemplateUri $sampleDomainTemplate `
        -TemplateParameterObject $params -AsJob
    Write-Verbose "Sample Deployment running as job in parallel..."
}
#endregion

#region Deploy Storage Account and Create Tables
if (-not(Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $nameSettings.StorageAccountName -ErrorAction SilentlyContinue)) {
    Write-Verbose "Deploying Storage Account..."
    $params = Get-StorageAccountDeploymentParams
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $storageAccountTemplate -TemplateParameterObject $params | Out-Null
}
# We can not create Storage Tables via ARM (yet), so do it via code instead
Write-Verbose "Validating Storage Tables..."
$tables = Get-StorageAccountTables
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $nameSettings.StorageAccountName
$storageAccountContext = $storageAccount.Context
New-StorageTables -ResourceGroupName $resourceGroupName -ResourceLocation $resourceLocation -StorageAccountContext $storageAccountContext -Tables $tables
#endregion

#region Deploy Key Vault
if (-not(Get-AzKeyVault -ResourceGroupName $resourceGroupName -VaultName $nameSettings.KeyVaultName -ErrorAction SilentlyContinue)) {    
    Write-Verbose "Deploying Key Vault..."
    $params = Get-KeyVaultDeploymentParams
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $keyVaultTemplate -TemplateParameterObject $params | Out-Null
}
#endregion

#region Create Image for Application Server
$params = Get-ApplicationServerImageParams
$params = Merge-Hashtables $params $resourceArgs
$apsJob = New-ScaleSetImage @params -AsJob
#endregion

#region Create Image for Web Server
$params = Get-WebServerImageParams
$params = Merge-Hashtables $params $resourceArgs
$webJob = New-ScaleSetImage @params -AsJob
#endregion

# Wait on Jobs before proceeding
$apsJob | Receive-Job -Wait -Verbose
$webJob | Receive-Job -Wait -Verbose
if ($domainJob) {
    $domainJob | Receive-Job -Wait -Verbose
}

#region Create Demo SQL Server...
$params = Get-SqlDemoParams
if (-not(Get-AzVM -ResourceGroupName $resourceGroupName -Name $params.VirtualMachineName -ErrorAction SilentlyContinue)) {
    Write-Verbose "Deploying SQL Server..."
    $sqlJob = New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name "Demo-SQL-deploy" -TemplateUri $sqlServerTemplate -TemplateParameterObject $params -AsJob
}
#endregion

#region Create Scale Set for Application Server
$params = Get-ApplicationScaleSetParams
$params = Merge-Hashtables $params $resourceArgs
$apsScaleJob = New-ScaleSet @params -AsJob
#endregion

#region Create Scale Set for Web Server
$params = Get-WebScaleSetParams
$params = Merge-Hashtables $params $resourceArgs
$webScaleJob = New-ScaleSet @params -AsJob
#endregion

$apsScaleJob | Receive-Job -Wait -Verbose
$webScaleJob | Receive-Job -Wait -Verbose

#region Create Public Load Balancer ...
$params = Get-PublicLoadBalancerParams
$params = Merge-Hashtables $params $resourceArgs
New-LoadBalancer @params
#endregion 

#region Create and configure internal Load Balancer ...
$params = Get-LoadBalancerParams
$params = Merge-Hashtables $params $resourceArgs
New-LoadBalancer @params

$params = Get-InfrastructureUpdateParams
$params = Merge-Hashtables $params $resourceArgs
Set-InfrastructureData @params

$params = Get-LoadBalancerConfigParams
$params = Merge-Hashtables $params $resourceArgs
Set-LoadBalancerConfiguration  @params
#endregion

if ($sqlJob) {
    $sqlJob | Receive-Job -Wait -Verbose
}

#region Create and configure Application Gateway ...
$params = Get-ApplicationGatewayParams
$params = Merge-Hashtables $params $resourceArgs
New-ApplicationGateway @params
#endregion 

# Mark Setup as complete and Restart Scale Sets to apply configuration (first step)
Set-StorageTableSetupDone -ResourceGroupName $ResourceGroupName -StorageAccountName $nameSettings.StorageAccountName -StorageTableNameSetup $storageTableNames.Setup
Write-Verbose "Restarting Scale Sets..."
$restart1 = Restart-AzVmss -ResourceGroupName $resourceGroupName -VMScaleSetName $nameSettings.APSScaleSetName -AsJob
$restart2 = Restart-AzVmss -ResourceGroupName $resourceGroupName -VMScaleSetName $nameSettings.WEBScaleSetName -AsJob
$restart1, $restart2 | Receive-Job -Wait | Out-Null

# Now you'll have to login once to the Application Scale Set and Start the BC Windows Client/IDE; this will do some necessary first-run-settings
# After that please execute the block after the last 5 lines again
# Mark Setup as complete and Restart Scale Sets to apply configuration (second step)
Write-Verbose "Please connect now to the Application-server (should be appscales000000 or appscales000001) and start the BC Client."
Write-Verbose "This will set some first run-settings in the demo-database. After that you need to re-run the last 5 lines of this script."