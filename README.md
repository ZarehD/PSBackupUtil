![Platform](https://img.shields.io/badge/Platform-PowerShell%20|%20PowerShellCore-svg?color=blue)
&nbsp;
[![GitHub](https://img.shields.io/github/license/zarehd/psbackuputil?color=darkgreen&label=License)](https://zarehd.mit-license.org/)

<span align="center">
   <img src="https://github.com/ZarehD/PSBackupUtil/blob/master/logo.png" width="256" />
</span>

# PSBackupUtil

Utility for archiving files from a specified folder (excluding any specified subfolders, files, or file types), creating Full backups every N days, and Partial backups in between.

Each time the module is executed (Backup-FolderContents), it determines whether a Full or Partial backup should be performed based on the date/time and type (full/partial) of the last backup.

#### Full Backups
- Created when no previous full backup exists, otherwise every N days ($FullBackupInterval)
- Created only if there is at least one changed file since the last full backup
- Archives ALL eligible (not excluded) files, regardless of their last change date/time

#### Partial Backups
- Created in the interim time between full backups
- Archives only files changed since the last (full or partial) backup


## Install

> #### PsBackupUril has no external dependencies!

Install directly from the official Powershell Gallery:
```ps
PS> Install-Module -Name PsBackupUtil
```

## Ways to Use the Module
- To make the module available whenever you open a  PS prompt: modify the PowerShell profile script, `Microsoft.PowerShell_profile.ps1` (in `C:\Users\<user>\Documents\PowerShell`. Create the file if it doesn't exist).<br/>
   And add the following line in the file:
   `Import-Module C:\path\to\BackupUtil\BackupUtil.psd1 -Force`
- To archive a preset group of folders, create a script that uses the module to backup folders (see Samples section below).
- To run the archive script on a schedule, create a scheduled task (e.g. Windows Scheduler, cron job) to run your backup script (e.g. daily, after you login each day).


## Archive Name
The archive files are compressed Zip files, named using the following convention:

`<base-name>-<yyyy>-<MM>-<dd>-<HH>-<mm>-<ss>[-<archive-mode-marker>].<extension>`

- `Base-Name ::= User specified, or if unspecified, name of source folder to be archived. NOTE: Any '-' char in the base name will be replaced with '_'`
- `y, M, d, H, m, s ::= Component parts of the current date/time (in 24-hour format)`
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


## Samples

Here's a sample script that uses the BackupUtil module to backup project files.

#### MyBackupScript.ps1
```ps
##Requires -Module BackupUtil


$project = "MySampleProject"
$srcRoot = Join-Path "C:\Projects" $project
$dstRoot = Join-Path "D:\Archives\Projects" $project


#----------------------------------------------------------------------------------------------------------
# backup project source code...
$FoldersToIgnore = @(
    "obj", "bin", ".vs", ".git",
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

## License
[MIT](https://zarehd.mit-license.org/) [License](https://github.com/ZarehD/PSBackupUtil/blob/master/LICENSE)
