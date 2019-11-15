#!/bin/bash

export RG=$1
export location=$2
export functionAppName=$3
export cosmosDBAccountName=$4
export storageAccountName=$5

#az login 
az group create -n ${RG} -l ${location}

#Create Storage Account 
az storage account create --name ${storageAccountName} --location ${location} --resource-group ${RG} --sku Standard_LRS
storageKey=`az storage account keys list -n ${storageAccountName} --query '[0].value' -o tsv`
storageConnectionString="DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageKey}"

# Create Container
az storage container create -n documents --account-name ${storageAccountName} --account-key ${storageKey}

#Create Cosmos
az cosmosdb create -g ${RG} -n ${cosmosDBAccountName} --kind GlobalDocumentDB 
az cosmosdb database create  -g ${RG} -n ${cosmosDBAccountName} -d ToDoList
az cosmosdb collection create -g ${RG} -n ${cosmosDBAccountName} -d ToDoList -c Items --partition-key-path '/_partitionKey'
az cosmosdb collection create -g ${RG} -n ${cosmosDBAccountName} -d ToDoList -c leases --partition-key-path '/_partitionKey'
cosmosConnectionString=`az cosmosdb list-connection-strings -n ${cosmosDBAccountName} -g $RG --query 'connectionStrings[0].connectionString' -o tsv`

#Create Function App
funcStorageName=${functionAppName}sa
az storage account create --name ${funcStorageName} --location ${location} --resource-group ${RG} --sku Standard_LRS
az functionapp create --name ${functionAppName} --storage-account ${funcStorageName} --consumption-plan-location ${location} --resource-group ${RG}

az functionapp config appsettings set -g ${RG} -n ${functionAppName} --settings bjdchangefeed001_STORAGE=${storageConnectionString}
az functionapp config appsettings set -g ${RG} -n ${functionAppName} --settings bjdcosmos001_DOCUMENTDB=${cosmosConnectionString}
az functionapp config appsettings set -g ${RG} -n ${functionAppName} --settings FUNCTIONS_WORKER_RUNTIME=dotnet
