---
severity: Critical
pillar: Security
category: Encryption
resource: Azure Database for MariaDB
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MariaDB.MinTLS/
---

# Minimum TLS version

## SYNOPSIS

Azure Database for MariaDB servers should reject TLS versions older than 1.2.

## DESCRIPTION

The minimum version of TLS that Azure Database for MariaDB servers accept is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Azure lets you disable outdated protocols and require connections to use a minimum of TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

## RECOMMENDATION

Configure the minimum supported TLS version to be 1.2.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for MariaDB Servers that pass this rule:

- Set the `properties.minimalTlsVersion` property to `TLS1_2`.

For example:

```json
{
  "type": "Microsoft.DBforMariaDB/servers",
  "apiVersion": "2018-06-01",
  "name": "[parameters('serverName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "[parameters('skuName')]",
    "tier": "GeneralPurpose",
    "capacity": "[parameters('SkuCapacity')]",
    "size": "[format('{0}', parameters('skuSizeMB'))]",
    "family": "[parameters('skuFamily')]"
  },
  "properties": {
    "minimalTlsVersion": "TLS1_2",
    "createMode": "Default",
    "version": "[parameters('mariadbVersion')]",
    "administratorLogin": "[parameters('administratorLogin')]",
    "administratorLoginPassword": "[parameters('administratorLoginPassword')]",
    "storageProfile": {
      "storageMB": "[parameters('skuSizeMB')]",
      "backupRetentionDays": 7,
      "geoRedundantBackup": "Enabled"
    }
  }
}
```

### Configure with Bicep

To deploy Azure Database for MariaDB Servers that pass this rule:

- Set the `properties.minimalTlsVersion` property to `TLS1_2`.

For example:

```bicep
resource mariaDbServer 'Microsoft.DBforMariaDB/servers@2018-06-01' = {
  name: serverName
  location: location
  sku: {
    name: skuName
    tier: 'GeneralPurpose'
    capacity: skuCapacity
    size: '${skuSizeMB}' 
    family: skuFamily
  }
  properties: {
    minimalTlsVersion: 'TLS1_2'
    createMode: 'Default'
    version: mariadbVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storageProfile: {
      storageMB: skuSizeMB
      backupRetentionDays: 7
      geoRedundantBackup: 'Enabled'
    }
  }
}
```

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [TLS enforcement in Azure Database for MariaDB](https://learn.microsoft.com/azure/mariadb/concepts-ssl-connection-security#tls-enforcement-in-azure-database-for-mariadb)
- [Set TLS configurations for Azure Database for MariaDB](https://learn.microsoft.com/azure/mariadb/howto-tls-configurations)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbformariadb/servers)
