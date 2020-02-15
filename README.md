# PSBackupUtil

Archives the files in the specified folder (excluding any subfolders, files, and/or file types you specify).

Each time the function is executed, it determines whether a full or partial backup should be performed based on the date/time and type of the last backup. 
- Full backups are created initially if no full backup exists, then every N days.
- Partial backups are created in the interim to archive any files that have changed since the last full or partial backup.

Full backups archive all files regardless of their last change date, whereas Partial backups only archive changed files.

## Install
There are no special dependencies other than PowerShell.

1. Clone the repo to your local system
2. Modify the PowerShell profile script (Microsoft.PowerShell_profile.ps1, located in C:\Users\<user>\Documents\PowerShell)
   Create the file, if it doesn't exist, and add the following line:  
   `Import-Module C:\path\to\BackupUtil\BackupUtil.psd1 -Force`
3. Create a script that uses the module to backup folders (see Samples section below).

Optionally, create a Windows Scheduler task to run your backup script daily, after you login each day, for instance.

## Archive Name
Archive files are simply Zip file. The zip file names are formated as follows:

`<base-name>[-<archive-mode-marker>]-<yyyy>-<MM>-<dd>-<HH>-<mm>.<extension>`

- `Base-Name ::= User specified, or if unspecified, name of source folder to be archived`
- `y, M, d, H, m ::= Component parts of the current date/time (in 24-hour format)`
- `Archive-Mode-Marker ::= 'Full' | 'Part' | <blank>`
- `Extension ::= User sepcified (default: 'zip')`

## Parameters
Parameter                |Required |Data Type    |Default |Description
:------------------------|:--------|:------------|:-------|:---------------------------------
$BaseName                |         |string       | Name of folder specified in $SourceFolder | The Base Name for the archive file
$SourceFolder            | True    |string       |       | Path to folder containing files to be backed up
$DestinationFolder       | True    |string       |       | Path to folder where archive file for the backup will be placed
$Extension               |         |string       |'zip'  | Archive file extension
$FullBackupInterval      |         |int          |7      | Number of days between full backups
$RemovePartialsAfterFull |         |bool         |False  | Remove prior period partial backup file(s) after creating a full-backup. CURRENTLY NOT IMPLEMENTED
$FullBackupMarker        |         |string       |'Full' | Marker text to use for Full backup archive names
$PartialBackupMarker     |         |string       |'Part' | Marker text to use for Partial backup archive names
$IgnoreFolders           |         |string array |       | Names of folders to omit from the backup
$IgnoreFileTypes         |         |string array |       | File types (ex: '*.zip') to omit from the backup
$IgnoreFiles             |         |string array |       | Names of specific files (name & extension, no path) to omit from the backup


## Sample

Here's a sample script that uses the BackupUtil module to backup project files.

```
##Requires -Module BackupUtil


$project = "MySampleProject"
$srcRoot = Join-Path "C:\Projects" $project
$dstRoot = Join-Path "D:\Archives\Projects" $project


#----------------------------------------------------------------------------------------------------------
# backup project source code...
$FoldersToIgnore = @(
    "obj", "bin", 
    "packages", "node_modules", "wwwroot"
)    
$FileTypesToIgnore = @("*.zip", "*.user", "*.msi")
$FilesToIgnore = @()

$nam = "ProjectCode"
$dir = "src"
$src = Join-Path $srcRoot $dir
$dst = Join-Path $dstRoot $dir

Backup-FolderContents `
    -BaseName = $nam `                      # the base name of the archive file (SourceFolder folder name used if omitted)
    -SourceFolder $src `                    # root folder containing files that will be backed up
    -DestinationFolder $dst `               # root folder where archived files will be backed up to
    -FullBackupInterval 10 `                # number of days between full backups
    -IgnoreFolders $FoldersToIgnore `       # list of folders to ignore (not backup)
    -IgnoreFileTypes $FileTypesToIgnore `   # List of file types to ignore (not backup)
    -IgnoreFiles $FilesToIgnore `           # List of specific files to ignore (not backup)
    -Verbose -Debug


#----------------------------------------------------------------------------------------------------------
# backup project docs...
$FoldersToIgnore = @()
$FileTypesToIgnore = @()
$FilesToIgnore = @()

$nam = "ProjectDocs"
$dir = "docs"
$src = Join-Path $srcRoot $dir
$dst = Join-Path $dstRoot $dir

Backup-FolderContents `
    -BaseName = $nam `                      # the base name of the archive file (SourceFolder folder name used if omitted)
    -SourceFolder $src `                    # root folder containing files that will be backed up
    -DestinationFolder $dst `               # root folder where archived files will be backed up to
    -FullBackupInterval 10 `                # number of days between full backups
    -IgnoreFolders $FoldersToIgnore `       # list of folders to ignore (not backup)
    -IgnoreFileTypes $FileTypesToIgnore `   # List of file types to ignore (not backup)
    -IgnoreFiles $FilesToIgnore `           # List of specific files to ignore (not backup)
    -Verbose -Debug
```


