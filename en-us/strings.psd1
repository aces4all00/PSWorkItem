#localized string data for verbose messaging, errors, and warnings.
ConvertFrom-StringData @'
AddArchive = ...archive table
AddCategories = ...category table
AddCategory = Adding PSWorkItem category {0}
AddDefaultCategories = Adding default categories {0}
AddIDColumn = Adding the ID column to the database table
AddTables = Adding database tables
AddTask = Adding PSWorkItem {0} with category {1} due {2}
AddTasks = ...task table
ArchiveCount = Getting a archive count
CannotVerifyIDColumn = Cannot verify the tasks table column ID. Please run Update-PSWorkItemDatabase to update the table then try completing the command again. It is recommended that you backup your database before updating the table.
CategoryCount = Getting a category count
CategoryExists = The PSWorkItem category {0} already exists
CategoryExistsOverwrite = The PSWorkItem category {0} already exists and will be overwritten
CloseDBConnection = Closing the SQLite database connection
CompleteTask = Completing PSWorkItem with id {0}
CreateCategory = Creating PSWorkItem category -> {0}
CutOffDate = Cutoff date is {0}
DatabaseConnectionNotOpen = The database connection is not open or active
DetectedCulture = Detected culture {0}
DetectedParameterSet = Detected parameter set {0}
Ending = Ending command
FailedArchiveID = Cannot verify the archive table column ID. Please run Update-PSWorkItemDatabase to update the table then try completing the command again. It is recommended that you backup your database before updating the table.
FailedQuery = Failed to execute query {0}
FailedToFind = Failed to find an open PSWorkItem with id {0}
FailedToFindArchiveID = Failed to find an archived work item with an ID of {0}
FailedToFindArchiveCategory = Failed to find matching archived work items in the {0} category
FailedToFindArchiveName = Failed to find any archived work items called {0}
FailedToFindArchivedTasks = Failed to find any matching archived PSWorkItems
FailedToValidate = Failed to validate {0}
FailedVerifyTaskID = Could not verify that PSWorkitem {0}} [{1}] was copied to the archive table.
FailToOpen = Failed to open the database {0}
FilterItemsDue = Filtering for PSWorkItems due before {0}
FoundCategories = Found {0} PSWorkItem categories
FoundMatching = Found {0} matching PSWorkItem tasks
GetAllCategories = Getting all PSWorkItem categories
GetCategory = Getting category {0}
GetData = Getting SQLite database information from {0}
GetPreferences = Getting PSWorkItem preferences from {0}
GetRaw = Getting raw data for table {0} from {1}
GetReport = Getting work item report from {0}
IDColumnExists = The column ID already exists in the archive table. No further action needed.
InitializingDB = Initializing PSWorkItem database {0}
InvalidCategory = The PSWorkItem category {0} is not valid
InvalidHost = This must be run in a console host. Detected PowerShell host: {0}
MoveItem = Moving PSWorkItem to Archive.
NoPreferenceFile = No PSWorkItem preference file found at {0}. Run Update-PSWorkItemPreferences to create it."
OpenDBConnection = Opening a SQLite database connection
ProcessCategory = Processing {PSWorkItem category {0}
PSVersion = Running under PowerShell version {0}
Refiltering = Re-Filtering found {0} PSWorkItems
RefilteringTasks = Re-filtering for PSWorkItems due in the next {0} day(s)
RemoveArchivedTask = Removing archived PSWorkItem with ID {0}
RemoveArchivedTaskCategory = Removing archived tasks in the {0} category
RemoveArchivedTaskName = Removing archived PSWorkItems by name {0}
RemoveCategory = Removing category {0}
RemoveTask = Removing the original PSWorkItem
RemoveTaskID = Removing PSWorkItem with ID {0}
SavingPreference = Saving preferences to {0}
SetTask = Setting PSWorkItem
Sorting = Sorting {0} items
Starting = Starting command
TaskCount = Getting a PSWorkItem count
TaskCreated = PSWorkItem {0} created
Testing = I am a localized message
TestingColumnID = Testing database for ID column
UpdateArchiveTable = Updating archive table value
UpdatePreference = Updating PSWorkItem user preferences
UpdateTaskTable = Updating tasks table values
UsingDB = Using SQLite database {0}
ValidateCategory = Validating PSWorkItem category {0}
ValidateMove = Validating the move
WarnNoTasksFound = Failed to find any matching open PSWorkItems
WarnDescriptionOrName = You must specify either a description or a new name
WarnAssemblyLoaded = Assembly {0} is already loaded in this PowerShell session
WarnDetected = Detected version {2}{0}{5} which is less than the expected version of {3}{1}{5}. {4}There may be unexpected behavior in Terminal.Gui commands{5}. You may need to start a new PowerShell session and load this module first.
WindowsOnly = This module requires a Windows platform.
'@