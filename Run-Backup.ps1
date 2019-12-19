
Import-Module .\BackupUtil.psd1 -Force

$Module = "SampleDataModel" # "Libs.Runtime"
Backup-FolderContents `
    "C:\Dev\Projects\ExpressAPI\Modules\$Module" `
    "E:\Projects.Archive\ExpressAPI\$Module" `
    -FullBackupInterval 10 `
    -IgnoreFolders @("obj", "bin", "packages", "node_modules", ".vscode", "backups", "MexUploads", "SharedLibs") `
    -IgnoreFileTypes @("*.zip", "*.user", "*.msi") `
    -Verbose -Debug
