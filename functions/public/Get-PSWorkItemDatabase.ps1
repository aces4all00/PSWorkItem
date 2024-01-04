Function Get-PSWorkItemDatabase {
    [cmdletbinding()]
    [OutputType("PSWorkItemDatabase")]
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
    Begin {
        StartTimer
        $PSDefaultParameterValues["_verbose:Command"] = $MyInvocation.MyCommand
        $PSDefaultParameterValues["_verbose:block"] = "Begin"
        _verbose -message $strings.Starting
        _verbose -message ($strings.PSVersion -f $PSVersionTable.PSVersion)
        _verbose -message ($strings.UsingModule -f (Get-Command -name $MyInvocation.MyCommand).Version)
        _verbose -message ($strings.UsingDB -f $path)
    } #begin

    Process {
        $PSDefaultParameterValues["_verbose:block"] = "Process"
        _verbose -message ($strings.GetData -f $Path)
        Try {
            $db = Get-MySQLiteDB -Path $Path -ErrorAction Stop
        }
        Catch {
            Throw $_
        }
        if ($db) {
            _verbose -message $strings.OpenDBConnection
            $conn = Open-MySQLiteDB -Path $path
            _verbose -message $strings.TaskCount
            $tasks = Invoke-MySQLiteQuery -Connection $conn -KeepAlive -Query "Select Count() from tasks" -ErrorAction Stop
            _verbose -message $strings.ArchiveCount
            $archived = Invoke-MySQLiteQuery -Connection $conn -KeepAlive -Query "Select Count() from archive" -ErrorAction Stop
            _verbose -message $strings.CategoryCount
            $categories = Invoke-MySQLiteQuery -Connection $conn -KeepAlive -Query "Select Count() from categories" -ErrorAction Stop
            _verbose -message $strings.GetMetadata
            $metadata = invoke-MySQLiteQuery -Connection $conn -KeepAlive -Query "Select * from metadata"
            Close-MySQLiteDB -Connection $conn
            _verbose -message $strings.CloseDBConnection

            #create a new PSWorkItemDatabase object from the class definition
            $out = [PSWorkItemDatabase]::new()
            #define properties
            $out.Path = $db.Path
            $out.Created = $metadata.Created
            $out.LastModified = $db.Modified
            $out.size = $db.Size
            $out.TaskCount = $tasks.'Count()'
            $out.ArchiveCount = $archived.'Count()'
            $out.CategoryCount = $categories.'Count()'
            $out.encoding = $db.Encoding
            $out.PageCount = $db.PageCount
            $out.PageSize = $db.PageSize
            $out.SQLiteVersion = $db.SQLiteVersion
            $out.CreatedBy = $metadata.Author
        }
        #write the object to the pipeline
        $out
    } #process

    End {
        $PSDefaultParameterValues["_verbose:block"] = "End"
        $PSDefaultParameterValues["_verbose:Command"] = $MyInvocation.MyCommand
        _verbose -message $strings.Ending
        _verbose -message ($strings.RunTime -f (StopTimer))
    } #end

} #close Get-PSWorkItemDatabase