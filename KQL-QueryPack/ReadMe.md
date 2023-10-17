# Invictus: Cloud Incident Response Query Pack
The cloud incident response query pack is part of our [HANDS-ON INCIDENT RESPONSE IN THE CLOUD](https://www.invictus-ir.com/training) training. The query pack is used in this training but is also free to use by everyone because we like to deliver open-source cloud incident response tools to the community. Queries from the following tables are included:
- AuditLogs
- AzureActivity
- SigninLogs
- AzureDiagnostics

All queries are focussed on performing incident response on Microsoft Azure and Microsoft 365 data incidents.

## Deploy to Azure
To load the KQL query pack click the Deploy to Azure button. Alternatively, load in via Azure Portal - Custom deployment

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fgithub.com%2Finvictus-ir%2FInvictus-training%2Fblob%2Fmain%2FKQL-QueryPack%2Ftemplate.json)

## Included KQL Queries
- Register connector
- Update application – Certificates and secrets management
- Eligible member added to a PIM role (setup)
- List Storage Account Keys
- Add policy
- Add service principal
- NSG Change
- Update policy
- Add member to role (activation of a role)
- Azure Keyvault logging
- Create role assignment
- Enriched IP info SigninLogs
- Add application
- GuestUser Operations
- Update application – Certificates and secrets management AuditLogs
- Table Entries

## Query Details

### Register connector
```kql
AuditLogs
| where OperationName == "Register connector"
```
### Update application – Certificates and secrets management
```KQL
AzureActivity
| where OperationNameValue == "MICROSOFT.KEYVAULT/VAULTS/WRITE"
```
### Eligible member added to a PIM role (setup)
```KQL
AuditLogs
| where OperationName == "Add eligible member to role"
| extend Target = parse_json(TargetResources[0]).userPrincipalName
| extend RoleID = parse_json(TargetResources[1]).id
```
### List Storage Account Keys
```KQL
AzureActivity
| where OperationNameValue == "MICROSOFT.STORAGE/STORAGEACCOUNTS/LISTKEYS/ACTION"
```
### Add policy
```KQL
AuditLogs
| where OperationName == "Add policy"
| extend Actor = tostring(parse_json(tostring(InitiatedBy.user)).userPrincipalName)
| extend Policy = tostring(TargetResources[0].displayName)
```
### Add service principal
```KQL
AuditLogs
| where OperationName == "Add service principal"
| extend Actor = tostring(parse_json(tostring(InitiatedBy.app)).displayName)
| where Result == "success"
```
### NSG Change
```KQL
AzureActivity
| where OperationNameValue=="MICROSOFT.NETWORK/NETWORKSECURITYGROUPS/SECURITYRULES/WRITE"
| extend ParsedProperties = parse_json(Properties)
| where ActivityStatusValue == "Accept"
| extend NSGResponseBody = ParsedProperties.responseBody
| extend RawNSGRule = parse_json(tostring(ParsedProperties.responseBody)).properties
| project TimeGenerated, CallerIpAddress, HTTPRequest, ResourceGroup, _ResourceId, ActivityStatusValue, ActivitySubstatusValue, RawNSGRule
| evaluate bag_unpack(RawNSGRule)
```
### Update policy
```KQL
AuditLogs
| where OperationName == "Update policy"
| extend Actor = tostring(parse_json(tostring(InitiatedBy.user)).userPrincipalName)
| extend Policy = tostring(TargetResources[0].displayName)
```
### Add member to role (activation of a role)
```KQL
AuditLogs
| where OperationName == "Add member to role completed (PIM activation)"
```
### Azure Keyvault logging
```KQL
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
```
### Create role assignment
```KQL
AuditLogs
| where OperationName == "Add app role assignment grant to user"
| extend Actor = tostring(parse_json(tostring(InitiatedBy.user)).userPrincipalName)
| extend Application = parse_json(TargetResources[0]).displayName
| extend Target = parse_json(TargetResources[1]).userPrincipalName
```
### Enriched IP info SigninLogs
```KQL
SigninLogs
| extend GeoIPInfo = geo_info_from_ip_address(IPAddress)
| extend country = tostring(parse_json(GeoIPInfo).country), state = tostring(parse_json(GeoIPInfo).state), city = tostring(parse_json(GeoIPInfo).city), latitude = tostring(parse_json(GeoIPInfo).latitude), longitude = tostring(parse_json(GeoIPInfo).longitude)
```
### Add application
```KQL
AuditLogs
| where OperationName == "Consent to application"
```
### GuestUser Operations
```KQL
let ExternalUsers = SigninLogs
| where TimeGenerated > ago(30d)
| where UserType == 'Guest'
| distinct UserId;
AuditLogs
| where InitiatedBy.user.id in (ExternalUsers)
| project TimeGenerated, Id, OperationName
```
### Update application – Certificates and secrets management AuditLogs
```KQL
AuditLogs
| where OperationName == "Update application – Certificates and secrets management "
```
### Table Entries
```KQL
union withsource=DataSource *
| where TimeGenerated > ago(30d)
| summarize TotalEntries = count() by DataSource
| sort by TotalEntries
```
