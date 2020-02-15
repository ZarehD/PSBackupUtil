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
