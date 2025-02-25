Function Remove-PSWorkItemCategory {
    [cmdletbinding(SupportsShouldProcess)]
    [OutputType("None")]
    Param(
        [Parameter(
            HelpMessage = 'The path to the PSWorkItem SQLite database file. It must end in .db'
        )]
        [ValidatePattern('\.db$')]
        [ValidateScript(
            {Test-Path $_},
            ErrorMessage = "Could not validate the database path."
        )]
        [String]$Path = $PSWorkItemPath
    )
    DynamicParam {
        # Added 27 Sept 2023 to support dynamic categories based on path
            if (-Not $PSBoundParameters.ContainsKey("Path")) {
                $Path = $global:PSWorkItemPath
            }
            If (Test-Path $Path) {

            $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary

            # Defining parameter attributes
            $attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
            $attributes = New-Object System.Management.Automation.ParameterAttribute
            $attributes.Position = 0
            $attributes.ValueFromPipeline = $True
            $attributes.ValueFromPipelineByPropertyName = $True
            $attributes.HelpMessage = 'Specify the category name'

            # Adding ValidateSet parameter validation
            #only get categories used in the Archive table
            #It is possible categories might be entered in different cases in the database
            [string[]]$values = (Get-PSWorkItemData -Table Categories -Path $Path).Category |
            ForEach-Object { [CultureInfo]::CurrentCulture.TextInfo.ToTitleCase($_) } |
            Select-Object -Unique | Sort-Object
            $v = New-Object System.Management.Automation.ValidateSetAttribute($values)
            $AttributeCollection.Add($v)

            # Adding ValidateNotNullOrEmpty parameter validation
            $v = New-Object System.Management.Automation.ValidateNotNullOrEmptyAttribute
            $AttributeCollection.Add($v)
            $attributeCollection.Add($attributes)

            # Adding a parameter alias
            $dynAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList 'Name'
            $attributeCollection.Add($dynAlias)

            # Defining the runtime parameter
            $dynParam1 = New-Object -Type System.Management.Automation.RuntimeDefinedParameter('Category', [String], $attributeCollection)
            $paramDictionary.Add('Category', $dynParam1)

            return $paramDictionary
        } # end if
    } #end DynamicParam
    Begin {
        StartTimer
        $PSDefaultParameterValues["_verbose:Command"] = $MyInvocation.MyCommand
        $PSDefaultParameterValues["_verbose:block"] = "Begin"
        _verbose -message $strings.Starting
        if ($MyInvocation.CommandOrigin -eq 'Runspace') {
            #Hide this metadata when the command is called from another command
            _verbose -message ($strings.PSVersion -f $PSVersionTable.PSVersion)
            _verbose -message ($strings.UsingHost -f $host.Name)
            _verbose -message ($strings.UsingOS -f $PSVersionTable.OS)
            _verbose -message ($strings.UsingModule -f $ModuleVersion)
            _verbose -message ($strings.UsingDB -f $path)
            _verbose ($strings.DetectedCulture -f (Get-Culture))
        }
        Write-Debug "Using bound parameters"
        $PSBoundParameters | Out-String | Write-Debug
        _verbose -message $strings.OpenDBConnection
        Try {
            $conn = Open-MySQLiteDB -Path $Path -ErrorAction Stop
            $conn | Out-String | Write-Debug
        }
        Catch {
            Throw "$($MyInvocation.MyCommand): $($strings.FailToOpen -f $Path)"
        }
    } #begin

    Process {
        $PSDefaultParameterValues["_verbose:block"] = "Process"
        $Category = $PSBoundParameters['Category']
        if ($conn.state -eq 'open') {
            foreach ($item in $Category ) {
                _verbose -message ($strings.RemoveCategory -f $item)
                $query = "DELETE FROM categories WHERE category = '$item'"
                _verbose -message $query
                if ($PSCmdlet.ShouldProcess($item)) {
                    Invoke-MySQLiteQuery -Query $query -Connection $conn -KeepAlive
                }
            }
        }
        else {
            Write-Warning $strings.DatabaseConnectionNotOpen
        }
    } #process

    End {
        $PSDefaultParameterValues["_verbose:block"] = "End"
        $PSDefaultParameterValues["_verbose:Command"] = $MyInvocation.MyCommand
        if ($conn.state -eq 'open') {
            _verbose -message $strings.CloseDBConnection
            Close-MySQLiteDB -Connection $conn
        }
        _verbose -message $strings.Ending
        _verbose -message ($strings.RunTime -f (StopTimer))
    } #end
}
