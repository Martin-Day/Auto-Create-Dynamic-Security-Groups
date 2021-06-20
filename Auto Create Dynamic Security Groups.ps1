# Automatically create dynamic security groups based on a unique list of any user attribute. 
# Simply select a user attribute to use and a dynamic group will be created for each unique value currently in AAD.

# Created by Martin Day
# https://martinday.co

$attribute         = "Department"   # Change to the attribute you would like to use
$displayNamePrefix = "sg-dyn-dept-" # Optionally set a Prefix for the group name
$displayNameSuffix = ""             # Optionally set a Suffix for the group name

Connect-AzureAD

$users = Get-AzureADUser -All $true
$uniqueList = $users | select $attribute -Unique | ? $attribute -ne $null

$uniqueList.($attribute) | ForEach-Object {

    Write-Host "Creating Group for $($_)"
    $cleanName = ($_) -replace '[*\\~;(%?.:@/,&+-]' -replace ' '
    $displayName = $displayNamePrefix + $cleanName + $displayNameSuffix
    
    $args = @{
        DisplayName = $displayName
        Description = "Dynamic Group for $($_)"
        MailEnabled = $false
        MailNickname = "dynamicGroup"
        SecurityEnabled = $true
        GroupTypes = "DynamicMembership"
        MembershipRule = "(user.$($attribute) -eq ""$($_)"")"
        MembershipRuleProcessingState = "On"
    }
    
    $dg = New-AzureADMSGroup @args
    Write-Host "Group Created: $displayName"
}