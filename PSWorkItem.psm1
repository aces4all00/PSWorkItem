# used for culture debugging
# write-host "Importing with culture $(Get-Culture)"

if ((Get-Culture).Name -match '\w+') {
    Import-LocalizedData -BindingVariable strings
}
else {
    #force using En-US if no culture found, which might happen on non-Windows systems.
    Import-LocalizedData -BindingVariable strings -FileName PSWorkItem.psd1 -BaseDirectory $PSScriptRoot\en-us
}

#Adding a failsafe check for Windows PowerShell
if ($IsMacOS -or ($PSEdition -eq 'Desktop')) {
    Write-Warning $Strings.Unsupported
    #bail out
    Return
}

Get-ChildItem $PSScriptRoot\functions\*.ps1 -Recurse |
ForEach-Object {
    . $_.FullName
}

#testing localization
#Write-Host $strings.Testing -fore cyan

#region assembly loading

#there may be version conflicts

#required versions
[version]$NStackVersion = '1.1.1.0'
[version]$TerminalGuiVersion = '1.17.1'

$dlls = "$PSScriptRoot\assemblies\NStack.dll", "$PSScriptRoot\assemblies\Terminal.Gui.dll"
foreach ($dll in $dlls) {
    $name = Split-Path -Path $dll -Leaf
    #write-host "Loading $dll" -fore yellow
    Try {
        Add-Type -Path $dll -ErrorAction Stop
    }
    Catch {
        $msg = ($strings.WarnAssemblyLoaded -f $Name)
        Write-Warning $msg

        #$verMessage = "Detected version $($PSStyle.Foreground.Red){0}$($PSStyle.Reset) which is less than the expected version of $($PSStyle.Foreground.Green){1}$($PSStyle.Reset). $($PSStyle.Italic)There may be unexpected behavior$($PSStyle.Reset). You may need to start a new PowerShell session and load this module first."
        Switch ($Name) {
            'NStack.dll' {
                #get currently loaded version
                $ver = [System.Reflection.Assembly]::GetAssembly([NStack.uString]).GetName().version
                if ($ver -lt $NStackVersion) {
                    $Detail = $strings.WarnDetected -f $ver, $NStackVersion, $PSStyle.Foreground.Red, $PSStyle.Foreground.Green, $PSStyle.Italic, $PSStyle.Reset
                }
            }
            'Terminal.Gui.dll' {
                $ver = [System.Reflection.Assembly]::GetAssembly([Terminal.Gui.Application]).GetName().version
                if ($ver -lt $TerminalGuiVersion) {
                    $Detail = $strings.WarnDetected -f $ver, $TerminalGuiVersion, $PSStyle.Foreground.Red, $PSStyle.Foreground.Green, $PSStyle.Italic, $PSStyle.Reset
                }
            }
        } #switch
        if ($Detail) {
            Write-Warning $Detail
        }
    }
}
#endregion

#region class definitions
<#
classes for PSWorkItem and PSWorkItemArchive
#>
#define base PSWorkItem class
class PSWorkItemBase {
    [int]$ID
    [String]$Name
    [String]$Category
    [String]$Description
    [DateTime]$TaskCreated = (Get-Date)
    [DateTime]$TaskModified = (Get-Date)
    [boolean]$Completed
    [String]$Path
    #this will be last resort GUID to ensure uniqueness
    hidden[guid]$TaskID = (New-Guid).Guid

}
class PSWorkItem:PSWorkItemBase {
    [DateTime]$DueDate = (Get-Date).AddDays(30)
    [int]$Progress = 0

    PSWorkItem ([String]$Name, [String]$Category) {
        $this.Name = $Name
        $this.Category = $Category
    }
    PSWorkItem() {
        $this
    }
}

Class PSWorkItemArchive:PSWorkItemBase {
    [DateTime]$DueDate
    [int]$Progress
}

class PSWorkItemCategory {
    [String]$Category
    [String]$Description

    #constructor
    PSWorkItemCategory([String]$Category, [String]$Description) {
        $this.Category = $Category
        $this.Description = $Description
    }
}

class PSWorkItemDatabase {
    [String]$Path
    [DateTime]$Created
    [DateTime]$LastModified
    [int32]$Size
    [int32]$TaskCount
    [int32]$CategoryCount
    [int32]$ArchiveCount
    [String]$Encoding
    [int32]$PageCount
    [int32]$PageSize
    [string]$SQLiteVersion
    [string]$CreatedBy
}

#endregion

#region type extensions

Update-TypeData -TypeName PSWorkItemCategory -MemberType ScriptProperty -MemberName ANSIString -Value { $PSWorkItemCategory[$this.Category] -replace "`e",
    "``e" } -Force
#endregion

#region settings and configuration
<#
Default categories when creating a new database file.
This will be a module-scoped variable, not exposed to the user
#>

$script:PSWorkItemDefaultCategories = 'Work', 'Personal', 'Project', 'Other'

#a global hashtable used for formatting PSWorkItems
$global:PSWorkItemCategory = @{
    'Work'     = $PSStyle.Foreground.Cyan
    'Personal' = $PSStyle.Foreground.Green
}

<#
a hash table to store ANSI escape sequences for different commands
used in verbose output with the private _verbose helper function
#>
$VerboseANSI = @{
    'Get-PSWorkItem'                = '[1;38;5;122m'
    'Get-PSWorkItemCategory'        = '[1;38;5;111m'
    'Set-PSWorkItem'                = '[1;96m'
    'New-PSWorkItem'                = '[1;38;5;10m'
    'Complete-PSWorkItem'           = '[1;38;5;208m'
    'Get-PSWorkItemReport'          = '[1;38;5;159m'
    'Get-PSWorkItemDatabase'        = '[1;38;5;195m'
    'Initialize-PSWorkItemDatabase' = '[1;38;5;214m'
    'Get-PSWorkItemArchive'         = '[1;38;5;228m'
    'Remove-PSWorkItem'             = '[1;38;5;197m'
    Default                         = '[1;38;5;51m'
}

#used in verbose messaging
$ModuleVersion = '1.11.0'

#import and use the preference file if found
$PreferencePath = Join-Path -Path $HOME -ChildPath '.psworkitempref.json'
If (Test-Path $PreferencePath) {
    $importPref = Get-Content $PreferencePath | ConvertFrom-Json
    $global:PSWorkItemPath = $importPref.Path
    $importPref.categories.foreach({ $PSWorkItemCategory[$_.category] = $_.ansi })
    if ($importPref.DefaultDays) {
        $global:PSWorkItemDefaultDays = $importPref.DefaultDays
    }
    If ($importPref.DefaultCategory) {
        $global:PSDefaultParameterValues['New-PSWorkItem:Category'] = $importPref.DefaultCategory
    }
}
else {
    #make this variable global instead of exporting so that I don't have to use Export-ModuleMember 7/28/2022 JDH
    $global:PSWorkItemPath = Join-Path -Path $HOME -ChildPath 'PSWorkItem.db'
    $global:PSWorkItemDefaultDays = 30
}

#endregion

#region auto completers

Register-ArgumentCompleter -CommandName Set-PSWorkItem, Remove-PSWorkItem, Complete-PSWorkItem -ParameterName ID -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    Invoke-MySQLiteQuery 'Select Name,ID,Completed from Tasks' -database $PSWorkItemPath |
    ForEach-Object {
        [System.Management.Automation.CompletionResult]::new([int]$_.ID, [int]$_.ID, 'ParameterValue', $_.Name)
    }
}

#endregion

