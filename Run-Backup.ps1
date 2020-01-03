Import-Module .\BackupUtil.psd1 -Force
# Requires -Module BackupUtil

$mod = "SampleDataModel" # "Libs.Runtime"
$src = "C:\Dev\Projects\ExpressAPI\Modules\$mod"
$dst = "E:\Projects.Archive\ExpressAPI\$mod"

$igFolders = @(
    "obj", "bin", 
    "packages", "node_modules", "wwwroot", 
    ".git", ".vs", 
    "backups", "MexUploads", "SharedLibs", 
    "SqlServerTypes\\x64", "SqlServerTypes\\x86"
)    
$igTypes = @("*.zip", "*.user", "*.msi")
$igFiles = @()

Backup-FolderContents `
    -SourceFolder $src `
    -DestinationFolder $dst `
    -FullBackupInterval 10 `
    -IgnoreFolders $igFolders `
    -IgnoreFileTypes $igTypes `
    -IgnoreFiles $igFiles `
    -Verbose -Debug
