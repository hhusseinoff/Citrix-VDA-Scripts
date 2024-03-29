﻿##ALL SAC AD GROUPS MUST ALREADY BE set in the XD Group settings
##The max desktop count for every user in the XD group  must be set to something very high like 100


param([string]$Region)

function debug($message)
{
    write-host "$(Get-Date -Format yyyy-MM-dd--HH-mm-ss) $message" -BackgroundColor Black -ForegroundColor Green
    Add-Content -Path "$PSScriptRoot\VerboseLogs\SAC_Assignment.log" -Value "$(Get-Date -Format yyyy-MM-dd--HH-mm-ss) $message" 
}

function debug_FailSkip([string]$Type,[string]$Reason,[string]$ADGroupName,[string]$XDGroupName,[string]$UserIdentifier)
{
    $FileExists = Test-Path -Path "$PSScriptRoot\FailSkipLogs\P1_UserResolution_FailSkip.txt" -PathType Leaf

    if($false -eq $FileExists)
    {
        Add-Content -Path "$PSScriptRoot\FailSkipLogs\P1_UserResolution_FailSkip.txt" -Value "--Timestamp(UTC)--`tType`tReason`tAD Group Name`tXD Group name`tUser Identifier" 
    }

    Add-Content -Path "$PSScriptRoot\FailSkipLogs\P1_UserResolution_FailSkip.txt" -Value "$($(Get-Date).ToUniversalTime())`t$Type`t$Reason`t$ADGroupName`t$XDGroupName`t$UserIdentifier" 
}

function debug_FailSkipPhase2([string]$Type,[string]$Reason,[string]$ADGroupName,[string]$XDGroupName,[string]$UserIdentifier,[string]$Desktop,[string]$Controller)
{
    $FileExists = Test-Path -Path "$PSScriptRoot\FailSkipLogs\P2_DesktopAssignment_FailSkip.txt" -PathType Leaf

    if($false -eq $FileExists)
    {
        Add-Content -Path "$PSScriptRoot\FailSkipLogs\P2_DesktopAssignment_FailSkip.txt" -Value "--Timestamp(UTC)--`tType`tReason`tAD Group Name`tXD Group name`tUser Identifier`tMachineName`tXD Controller" 
    }

    Add-Content -Path "$PSScriptRoot\FailSkipLogs\P2_DesktopAssignment_FailSkip.txt" -Value "$($(Get-Date).ToUniversalTime())`t$Type`t$Reason`t$ADGroupName`t$XDGroupName`t$UserIdentifier`t$Desktop`t$Controller" 
}

function debug_UserResolutionSuccess([string]$ADGroupName,[string]$XDGroupName,[string]$UserIdentifier,[string]$DomainFullAddress)
{
    $FileExists = Test-Path -Path "$PSScriptRoot\SuccessLogs\P1_UserResolutionSuccess.txt" -PathType Leaf

    if($false -eq $FileExists)
    {
        Add-Content -Path "$PSScriptRoot\SuccessLogs\P1_UserResolutionSuccess.txt" -Value "--Timestamp(UTC)--`tAD Group Name`tXD Group name`tUser Identifier`tDomain Full Address" 
    }

    Add-Content -Path "$PSScriptRoot\SuccessLogs\P1_UserResolutionSuccess.txt" -Value "$($(Get-Date).ToUniversalTime())`t$ADGroupName`t$XDGroupName`t$UserIdentifier`t$DomainFullAddress" 
}

function debug_UserDesktopAssignmentSuccess([string]$ADGroupName,[string]$XDGroupName,[string]$UserIdentifier,[string]$Desktop,[string]$Controller)
{
    $FileExists = Test-Path -Path "$PSScriptRoot\SuccessLogs\P2_UserDesktopAssignmentSuccess.txt" -PathType Leaf

    if($false -eq $FileExists)
    {
        Add-Content -Path "$PSScriptRoot\SuccessLogs\P2_UserDesktopAssignmentSuccess.txt" -Value "--Timestamp(UTC)--`tAD Group Name`tXD Group name`tUser Identifier`tMachine Name`tXD Controller" 
    }

    Add-Content -Path "$PSScriptRoot\SuccessLogs\P2_UserDesktopAssignmentSuccess.txt" -Value "$($(Get-Date).ToUniversalTime())`t$ADGroupName`t$XDGroupName`t$UserIdentifier`t$Desktop`t$Controller" 
}

##Create Log folders at the script root if they dont exist
##---------------------------------------------------------------------------------------------------------------------------------
$VerboseLogsFolderExists = Test-path -Path "$PSScriptRoot\VerboseLogs" -PathType Container

if($false -eq $VerboseLogsFolderExists)
{
    New-Item -Path "$PSScriptRoot" -Name "VerboseLogs" -ItemType Directory -Force -Confirm:$false -ErrorAction Stop | Out-Null
}

$SuccessLogsFolderExists = Test-path -Path "$PSScriptRoot\SuccessLogs" -PathType Container

if($false -eq $SuccessLogsFolderExists)
{
    New-Item -Path "$PSScriptRoot" -Name "SuccessLogs" -ItemType Directory -Force -Confirm:$false -ErrorAction Stop | Out-Null
}

$FailSkiLogsFolderExists = Test-path -Path "$PSScriptRoot\FailSkipLogs" -PathType Container

if($false -eq $FailSkiLogsFolderExists)
{
    New-Item -Path "$PSScriptRoot" -Name "FailSkipLogs" -ItemType Directory -Force -Confirm:$false -ErrorAction Stop | Out-Null
}

##Check if input file exists. If Not, script will not run
##---------------------------------------------------------------------------------------------------------------------------------

$InputExists = Test-Path -Path "$PSScriptRoot\AD_XD_MappingEU_E2.txt" -PathType Leaf

if($false -eq $InputExists)
{
    debug "Script will not run. Input file not found!"

    Exit 1
}

debug "------SAC Assignment script by Señor José Garcia initiated------"

debug "Loading input file..."

$InputData = (Get-Content -Path "$PSScriptRoot\AD_XD_MappingEU_E2.txt")

if($null -eq $InputData)
{
    debug "Script will not run. Input file failed to load!"
}

##Delete Non-Verbose Logs from Last run (will interfere, causing double, triple assignment)
##---------------------------------------------------------------------------------------------------------------------------------

$Phase1FailLogExists = Test-Path -Path "$PSScriptRoot\FailSkipLogs\P1_UserResolution_FailSkip.txt" -PathType Leaf

if($true -eq $Phase1FailLogExists)
{
    Remove-Item -Path "$PSScriptRoot\FailSkipLogs\P1_UserResolution_FailSkip.txt" -Force -Confirm:$false
}

$Phase2FailLogExists = Test-Path -Path "$PSScriptRoot\FailSkipLogs\P2_DesktopAssignment_FailSkip.txt" -PathType Leaf

if($true -eq $Phase1FailLogExists)
{
    Remove-Item -Path "$PSScriptRoot\FailSkipLogs\P2_DesktopAssignment_FailSkip.txt" -Force -Confirm:$false
}

$Phase1SuccessogExists = Test-Path -Path "$PSScriptRoot\SuccessLogs\P1_UserResolutionSuccess.txt" -PathType Leaf

if($true -eq $Phase1FailLogExists)
{
    Remove-Item -Path "$PSScriptRoot\SuccessLogs\P1_UserResolutionSuccess.txt" -Force -Confirm:$false
}

$Phase2SuccessogExists = Test-Path -Path "$PSScriptRoot\SuccessLogs\P2_UserDesktopAssignmentSuccess.txt" -PathType Leaf

if($true -eq $Phase1FailLogExists)
{
    Remove-Item -Path "$PSScriptRoot\SuccessLogs\P2_UserDesktopAssignmentSuccess.txt" -Force -Confirm:$false
}

##---------------------------------------------------------------------------------------------------------------------------------

debug "Input File loaded"

:MainLoop foreach($Entry in $InputData)
{
    if($Entry -like "*AD Group Name*")
    {
        continue MainLoop
    }

    debug "Working on $Entry"

    $FragmentedArray = $Entry.Split("`t")

    $ExtractedRegion = $FragmentedArray[0]
    $ExtractedSAC_ADGroup = $FragmentedArray[1]
    $ExtractedXD_DG = $FragmentedArray[2]
    $ExtractedXD_Controller = $FragmentedArray[3]

    debug "Extracted Region: $ExtractedRegion"
    debug "Extracted SAC AD Group Name: $ExtractedSAC_ADGroup"
    debug "Extracted XenDesktop Delivery Group name: $ExtractedXD_DG"
    debug "Extracted XenDesktop Controller for the DG: $ExtractedXD_Controller"

    if("EU" -eq $ExtractedRegion)
    {
        $DefaultInternalDomain = "something"

        $DefaultInternalDomainNetBIOS = "something"
        
        debug "Default Internal domain set to $DefaultInternalDomain"

        debug "Default Internal domain NetBIOS name set to $DefaultInternalDomainNetBIOS"

        debug "Proceeding to Get the AD Group object..."

        try
        {
            $AD_GroupObj = Get-ADGroup -Identity $ExtractedSAC_ADGroup -Properties Members -Server $DefaultInternalDomain
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
        {
            $FailSkipReason = "Group Not Found"

            debug_FailSkip -Type "Skip" -Reason $FailSkipReason -ADGroupName $ExtractedSAC_ADGroup -XDGroupName $ExtractedXD_DG -UserIdentifier "Invalid"

            continue MainLoop
        }

        debug "Group Found, aquiring user count..."

        $GroupUserCount = $AD_GroupObj.Members.Value

        $GroupUserCountNumber = $GroupUserCount.Length

        if($null -eq $GroupUserCount)
        {
            $FailSkipReason = "Group Has NO Members"

            debug_FailSkip -Type "Skip" -Reason $FailSkipReason -ADGroupName $ExtractedSAC_ADGroup -XDGroupName $ExtractedXD_DG -UserIdentifier "Invalid"

            continue MainLoop
        }

        debug "User Count aquired."

        debug "$ExtractedSAC_ADGroup has $GroupUserCountNumber members."

        debug "-----Starting Phase 1: Resolving users by DistinguishedName-----"

        :ResolveUsers foreach($DistinguishedName in $GroupUserCount)
        {
            debug "Working on $DistinguishedName"

            if($DistinguishedName -like "*CN=ForeignSecurityPrincipals*")
            {
                debug "Working on a User in an EXTERNAL Domain/Forest..."

                try
                {
                    $ExternalUserObj = Get-ADObject -Identity $DistinguishedName
                }
                catch
                {
                    debug "Failed to Construct an AD Object for an External User."

                    $FailSkipReason = "Failed to Construct an AD Object for an External User."

                    debug_FailSkip -Type "Skip" -Reason $FailSkipReason -ADGroupName $ExtractedSAC_ADGroup -XDGroupName $ExtractedXD_DG -UserIdentifier $DistinguishedName

                    continue ResolveUsers
                }

                debug "Attempting to create a System.Security.Principal.SecurityIdentifier Object based on the user SID..."

                try
                {
                    $SID_Object = New-Object System.Security.Principal.SecurityIdentifier($ExternalUserObj.Name)
                }
                catch
                {
                    debug "Failed to Construct an AD SID Object for an External User."

                    $FailSkipReason = "Failed to Construct an AD SID Object for an External User."

                    debug_FailSkip -Type "Skip" -Reason $FailSkipReason -ADGroupName $ExtractedSAC_ADGroup -XDGroupName $ExtractedXD_DG -UserIdentifier $DistinguishedName

                    continue ResolveUsers
                }

                debug "Attempting to translate the User SID..."

                try
                {
                    $TranslatedUserObject = $SID_Object.Translate([System.Security.Principal.NTAccount])
                }
                catch
                {
                    debug "Failed to Translate a User SID for an External User."

                    $FailSkipReason = "Failed to Translate a User SID for an External User."

                    debug_FailSkip -Type "Skip" -Reason $FailSkipReason -ADGroupName $ExtractedSAC_ADGroup -XDGroupName $ExtractedXD_DG -UserIdentifier $DistinguishedName

                    continue ResolveUsers
                }

                $ResolvedUser = $TranslatedUserObject.Value

                debug "User resolved: $ResolvedUser"

                debug "Attempting to find the Full Domain Address..."

                $TempArray1 = $ResolvedUser.Split("\")

                $ResolvedDomainName = $TempArray1[0]

                try
                {
                    $DomainObject = Get-ADDomain -Identity $ResolvedDomainName
                }
                catch
                {
                    debug "Failed to construct a Domain Object for an External User's Domain. Not a terminal error."

                    $FailSkipReason = "Failed to construct a Domain Object for an External User's Domain. Not a terminal error."

                    debug_FailSkip -Type "NonfatalFail" -Reason $FailSkipReason -ADGroupName $ExtractedSAC_ADGroup -XDGroupName $ExtractedXD_DG -UserIdentifier $ResolvedUser

                    debug_UserResolutionSuccess -ADGroupName $ExtractedSAC_ADGroup -XDGroupName $ExtractedXD_DG -UserIdentifier $ResolvedUser -DomainFullAddress "Failed To Retrieve"

                    continue ResolveUsers
                }

                $DomainFullAddress = $DomainObj.DNSRoot

                debug "Resolved Full Domain Address: $DomainFullAddress"
                
                debug "Appending Data to the User Resolution Success Log..."

                debug_UserResolutionSuccess -ADGroupName $ExtractedSAC_ADGroup -XDGroupName $ExtractedXD_DG -UserIdentifier $ResolvedUser -DomainFullAddress $DomainFullAddress
                
            }
            else
            {
                debug "Working on a User in an INTERNAL Domain/Forest.."

                debug "Extracting the internal domain address..."

                $InternalDomain = ($DistinguishedName.replace(',DC=',';').split(';')[1])

                debug "Extracted internal domain name: $InternalDomain"

                $InternalDomainFullAddress = $InternalDomain + ".rootdom.net"

                debug "Constructed internal domain full address: $InternalDomainFullAddress"

                debug "Proceeding to get the user..."

                try
                {
                    $AD_UserObject = Get-ADUser -Identity $DistinguishedName -Server $InternalDomainFullAddress
                }
                catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]
                {
                    $FailSkipReason = "Failed to construct an AD Object for an INTERNAL user."

                    debug_FailSkip -Type "Skip" -Reason $FailSkipReason -ADGroupName $ExtractedSAC_ADGroup -XDGroupName $ExtractedXD_DG -UserIdentifier $DistinguishedName

                    continue ResolveUsers
                }

                $InternalUsername = $AD_UserObject.Name

                $ResolvedUser = "$InternalDomain\$InternalUsername"

                debug "Resolved User: $ResolvedUser"

                debug "Appending Data to the User Resolution Success Log..."

                debug_UserResolutionSuccess -ADGroupName $ExtractedSAC_ADGroup -XDGroupName $ExtractedXD_DG -UserIdentifier $ResolvedUser -DomainFullAddress $InternalDomainFullAddress


            }
        }

        debug "-----Phase 1: Resolving users by DistinguishedName FINISHED-----"

        debug "-----Starting Phase 2: XenDesktop Assignment-----"

        $SnapinLoadCheck = $null

        $SnapinLoadCheck = Get-PSSnapin -Name Citrix.Broker.Admin.V2 -ErrorAction SilentlyContinue

        if($null -eq $SnapinLoadCheck)
        {
            debug "Citrix Broker Snapin not loaded, attempting to load..."

            Add-PSSnapin -Name Citrix.Broker.Admin.V2

            $SnapinLoadCheck2 = Get-PSSnapin -Name Citrix.Broker.Admin.V2 -ErrorAction SilentlyContinue

            if($null -eq $SnapinLoadCheck2)
            {
                debug "Failed to Load the Citrix Broker Snapin. Check if it's registered and rerun the script."

                $FailSkipReason = "Failed to Load the Citrix Broker Snapin."

                debug_FailSkip -Type "FatalError" -Reason $FailSkipReason -ADGroupName $ExtractedSAC_ADGroup -XDGroupName $ExtractedXD_DG -UserIdentifier "Invalid"

                continue MainLoop
            }
        }

        debug "Citrix Broker Snapin loaded."

        $ResolvedUsersInputData = (Get-Content -Path "$PSScriptRoot\SuccessLogs\P1_UserResolutionSuccess.txt")

        if($null -eq $ResolvedUsersInputData)
        {
            debug "Failed to retrieve successfully resolved users from $PSScriptRoot\SuccessLogs\P1_UserResolutionSuccess.txt"

            $FailSkipReason = "Failed to retrieve successfully resolved users from $PSScriptRoot\SuccessLogs\P1_UserResolutionSuccess.txt"

            debug_FailSkip -Type "FatalError" -Reason $FailSkipReason -ADGroupName $ExtractedSAC_ADGroup -XDGroupName $ExtractedXD_DG -UserIdentifier "Invalid"

            continue MainLoop
        }

        :ParseSuccesfullyResolvedUsersFile foreach($Entry2 in $ResolvedUsersInputData)
        {
            if($Entry2 -like "*AD Group Name*")
            {
                continue ParseSuccesfullyResolvedUsersFile
            }

            $Entry2Array = $Entry2.Split("`t")

            debug "Working on $Entry2"

            $ExtractedSAC_ADGroup_L2 = $Entry2Array[1]

            $ExtractedXD_DG_L2 = $Entry2Array[2]

            $ExtractedUserIdentifier = $Entry2Array[3]

            debug "Extracted SAC AD group name from successfully resolved users output file: $ExtractedSAC_ADGroup_L2"

            debug "Extracted XenDesktop Delivery Group from successfully resolved users output file: $ExtractedXD_DG_L2"

            debug "Extracted User Identifier from successfully resolved users output file: $ExtractedUserIdentifier"

            if(($ExtractedSAC_ADGroup -ne $ExtractedSAC_ADGroup_L2) -and ($ExtractedXD_DG -ne $ExtractedXD_DG_L2))
            {
                debug "Extracted data for a different SAC / XD group pair than the currently looping one. Skipping without entering logging data."

                continue ParseSuccesfullyResolvedUsersFile
            }

            debug "Retrieving all Desktops from $ExtractedXD_DG_L2 on Controller $ExtractedXD_Controller"

            $DesktopsArray = Get-BrokerMachine -DesktopGroupName $ExtractedXD_DG_L2 -AdminAddress $ExtractedXD_Controller

            if($null -eq $DesktopsArray)
            {
                debug "Failed to Retrieve Desktops for $ExtractedXD_DG_L2"

                $FailSkipReason = "Failed to Retrieve Desktops"

                debug_FailSkip -Type "FatalError" -Reason $FailSkipReason -ADGroupName $ExtractedSAC_ADGroup_L2 -XDGroupName $ExtractedXD_DG_L2 -UserIdentifier $ExtractedUserIdentifier

                continue ParseSuccesfullyResolvedUsersFile
            }

            debug "Proceeding to assign $ExtractedUserIdentifier to ALL machines from the array..."

            :AssignDesktops foreach($Desktop in $DesktopsArray)
            {
                $DesktopName = $Desktop.MachineName
                
                Add-BrokerUser -Name $ExtractedUserIdentifier -PrivateDesktop $DesktopName -AdminAddress $ExtractedXD_Controller

                ##Start-Sleep -Seconds 3

                $Verify = Get-BrokerMachine -MachineName $DesktopName -AdminAddress $ExtractedXD_Controller

                $VerifyUser = $Verify.AssociatedUserNames

                if($VerifyUser -like "*$ExtractedUserIdentifier*")
                {
                    debug "Assignment successful for $DesktopName".

                    debug_UserDesktopAssignmentSuccess -ADGroupName $ExtractedSAC_ADGroup_L2 -XDGroupName $ExtractedXD_DG_L2 -UserIdentifier $ExtractedUserIdentifier -Desktop $DesktopName -Controller $ExtractedXD_Controller

                    continue AssignDesktops
                }
                else
                {
                    debug "Assignment FAILED for $DesktopName"

                    $FailSkipReason = "Assignment FAILED for $DesktopName"

                    debug_FailSkipPhase2 -Type "Error" -Reason $FailSkipReason -ADGroupName $ExtractedSAC_ADGroup_L2 -XDGroupName $ExtractedXD_DG_L2 -UserIdentifier $ExtractedUserIdentifier -Desktop $Desktop -Controller $ExtractedXD_Controller

                    continue AssignDesktops
                }
            }
        }


        debug "-----Phase 2: XenDesktop Assignment Finished-----"

        debug "Script execution finished. Exiting..."

    }
}