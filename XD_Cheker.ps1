$machinedata = (Get-Content -Path "$PSScriptRoot\Input.txt")

##---------------------------AUTO-GET section---------------------

##$allE1_PROD = Get-BrokerMachine -MachineName "DomainName1\XPE1-D?????" -AdminAddress XD_DDC_Name1 -MaxRecordCount 10000
##$allE2_PROD = Get-BrokerMachine -MachineName "DomainName2\XPE2-D?????" -AdminAddress XD_DDC_Name2 -MaxRecordCount 10000

#foreach mod example:

##foreach($XDObj in $allE1_PROD)
##{
##    $VisibleName = $XDObj.HostedMachineName
##
##    do xyz
##}


##---------------------------AUTO-GET section End---------------------

foreach($machine in $machinedata)
{
    if(($machine -like "XPE?-D?????_RD*") -or ($machine -like "XIE?-D?????_RD*"))
    {
        if($machine -like "XPE1-D*")
        {
            $newname = $machine.Substring(0,11)

            $XDObj = Get-BrokerMachine -HostedMachineName $newname -AdminAddress XD_DDC_Name1 -MaxRecordCount

            $MachineName = $XDObj.HostedMachineName

            $MachineVcenter = $XDObj.HypervisorConnectionName

            $machinecatalog = $XDObj.CatalogName

            $machineDG = $XDObj.DesktopGroupName

            $machinePWState = $XDObj.PowerState

            $machineMM = $XDObj.InMaintenanceMode
        
            $machineAssignedUser = $XDObj.AssociatedUserNames

            $machinelastconnuser = $XDObj.LastConnectionUser

            $machinelastconntime = $XDObj.LastConnectionTim

            $outputexists = Test-Path -Path "$PSScriptRoot\Output.txt" -PathType Leaf

            if($false -eq $outputexists)
            {
                Add-Content -Path "$PSScriptRoot\Output.txt" -Value "Machine Name`tHypervisor`tCatalogName`tDeliveryGroup`tPowerState`tMaintMode on?`tAssignedUsers`tLastConnectionUser`tLastConnectionTime"
            }

            Add-Content -Path "$PSScriptRoot\Output.txt" -Value "$newname`t$MachineVcenter`t$machinecatalog`t$machineDG`t$machinePWState`t$machineMM`t$machineAssignedUser`t$machinelastconnuser`t$machinelastconntime"
        }
        if($machine -like "XPE2-D*")
        {
            $newname = $machine.Substring(0,11)

            $machineXDData = Get-BrokerMachine -HostedMachineName $newname -AdminAddress XD_DDC_Name2

            $machineMM = $machineXDData.InMaintenanceMode

            $machineRegstate = $machineXDData.RegistrationState

            $outputexists = Test-Path -Path "$PSScriptRoot\Output.txt" -PathType Leaf

            if($false -eq $outputexists)
            {
                Add-Content -Path "$PSScriptRoot\Output.txt" -Value "Machine Name`tHypervisor`tCatalogName`tDeliveryGroup`tPowerState`tMaintMode on?`tAssignedUsers`tLastConnectionUser`tLastConnectionTime"
            }

            Add-Content -Path "$PSScriptRoot\Output.txt" -Value "$Machine`t$MachineVcenter`t$machinecatalog`t$machineDG`t$machinePWState`t$machineMM`t$machineAssignedUser`t$machinelastconnuser`t$machinelastconntime"
        }
    }

    if(($machine -like "XPE1-D?????") -or ($machine -like "XIE1-D?????"))
    {
        $XDObj = Get-BrokerMachine -HostedMachineName $machine -AdminAddress XD_DDC_Name1

        $MachineName = $XDObj.HostedMachineName

        $MachineVcenter = $XDObj.HypervisorConnectionName

        $machinecatalog = $XDObj.CatalogName

        $machineDG = $XDObj.DesktopGroupName

        $machinePWState = $XDObj.PowerState

        $machineMM = $XDObj.InMaintenanceMode
        
        $machineAssignedUser = $XDObj.AssociatedUserNames

        $machinelastconnuser = $XDObj.LastConnectionUser

        $machinelastconntime = $XDObj.LastConnectionTim

        $outputexists = Test-Path -Path "$PSScriptRoot\Output.txt" -PathType Leaf

        if($false -eq $outputexists)
        {
            Add-Content -Path "$PSScriptRoot\Output.txt" -Value "Machine Name`tHypervisor`tCatalogName`tDeliveryGroup`tPowerState`tMaintMode on?`tAssignedUsers`tLastConnectionUser`tLastConnectionTime"
        }

        Add-Content -Path "$PSScriptRoot\Output.txt" -Value "$MachineName`t$MachineVcenter`t$machinecatalog`t$machineDG`t$machinePWState`t$machineMM`t$machineAssignedUser`t$machinelastconnuser`t$machinelastconntime"

    }

    if(($machine -like "XPE2-D?????") -or ($machine -like "XIE2-D?????"))
    {
        $XDObj = Get-BrokerMachine -HostedMachineName $machine -AdminAddress XD_DDC_Name2

        if($null -eq $machineXDData)
        {
            $machineXDData = Get-BrokerMachine -HostedMachineName $machine -AdminAddress XD_DDC_Name3
        }

        $MachineName = $XDObj.HostedMachineName

        $MachineVcenter = $XDObj.HypervisorConnectionName

        $machinecatalog = $XDObj.CatalogName

        $machineDG = $XDObj.DesktopGroupName

        $machinePWState = $XDObj.PowerState

        $machineMM = $XDObj.InMaintenanceMode
        
        $machineAssignedUser = $XDObj.AssociatedUserNames

        $machinelastconnuser = $XDObj.LastConnectionUser

        $machinelastconntime = $XDObj.LastConnectionTime

        $outputexists = Test-Path -Path "$PSScriptRoot\Output.txt" -PathType Leaf

        if($false -eq $outputexists)
        {
            Add-Content -Path "$PSScriptRoot\Output.txt" -Value "Machine Name`tHypervisor`tCatalogName`tDeliveryGroup`tPowerState`tMaintMode on?`tAssignedUsers`tLastConnectionUser`tLastConnectionTime"
        }

        Add-Content -Path "$PSScriptRoot\Output.txt" -Value "$MachineName`t$MachineVcenter`t$machinecatalog`t$machineDG`t$machinePWState`t$machineMM`t$machineAssignedUser`t$machinelastconnuser`t$machinelastconntime"
    }

}