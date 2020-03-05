#------------------------------------------------------------------------------
# Backup-FolderContents
# Copyright © 2019-2020 Zareh DerGevorkian
#------------------------------------------------------------------------------
# Creates a Zip file containing the contents of the specified folder, 
# excluding any specified subfolders, files, and file types.
#
# Each time the script executes, it determines whether a full or partial 
# backup should be performed based on the date/time and type of the last 
# backup. Full backups are created initially, then every N days. Partial 
# backups are created in the interim to archive only files that have 
# changed since the last full or partial backup.
#
# Zip file names are formated as follows:
#  <base-name>-<yyyy>-<MM>-<dd>-<HH>-<mm>-<ss>[-<archive-mode-marker>].<extension>
#  Where:
#    <base-name> => User specified, or name of folder to be archived
#    y, M, d, H, m, s => components of current date/time in 24-hour format
#    <archive-mode-Marker> => Full | Part | <blank>
#    <extension> => User sepcified (default: 'zip')
#------------------------------------------------------------------------------


using namespace System.IO


function Backup-FolderContents {
    [CmdletBinding()]
    param (
        # Folder (contents of which are) to be archived.
        [parameter(Mandatory, HelpMessage = "The folder (contents of which are) to be archived.")]
        [ValidateScript( { Test-Path $_ } )]
        [ValidateNotNullOrEmpty()]
        [string] $SourceFolder,

        # Folder where the archive file for the backup will be placed.
        #[ValidateScript( { Test-Path $_ } )]
        [parameter(Mandatory, HelpMessage = "Folder where the archive file for the backup will be placed.")]
        [ValidateNotNullOrEmpty()]
        [string] $DestinationFolder,

        # The base name to use for naming the backup file (default: source folder name).
        [parameter(HelpMessage = "The base name to use for naming the backup file (default: source folder name).")]
        [string] $BaseName,

        # Extension for backup file name (default: 'zip').
        [parameter(HelpMessage = "Extension for backup file name (default: 'zip').")]
        [string]
        $Extension = "zip",

        # Number of days between full backups. Default = 7
        [Parameter(HelpMessage = "Number of days between full backups. Defaults to 7.")]
        [int] $FullBackupInterval = 7,

        # Remove prior period partial backup file(s) after creating a full-backup.
        [Parameter(HelpMessage = "Remove prior period partial backup file(s) after creating a full-backup.")]
        [switch] $RemovePartialsAfterFull,

        # Marker text for Full backup archive-file names (default: 'Full').
        [Parameter(HelpMessage = "Marker text for Full backup archive-file names (default: 'Full').")]
        [string] $FullBackupMarker = "Full",

        # Marker text for Partial backup archive-file names (default: 'Part').
        [Parameter(HelpMessage = "Marker text for Partial backup archive-file names (default: 'Part').")]
        [string] $PartialBackupMarker = "Part",

        # Names of folders to omit from the backup.
        [string[]] $IgnoreFolders,

        # File extensions for file types to omit from the backup,
        [string[]] $IgnoreFileTypes,

        # Names of files (name & extensions, no path) to omit from the backup.
        [string[]] $IgnoreFiles
    )

    try {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()

        $src = $SourceFolder
        $dst = $DestinationFolder
        $base = $BaseName

        Update-NameFormatOfExistingFiles $dst $Extension

        if ([string]::IsNullOrWhiteSpace($base)) {
            $base = Split-Path $src -Leaf
        }        

        $base = $base -replace "-", "_"

        $Mode = Get-NextBackupMode $base $dst $FullBackupInterval $Extension

        $type = if ($Mode -eq ([ArchiveMode]::Unknown)) { $null } else { "$Mode " }
        Write-Host "Performing $($type)Backup for $base" #-ForegroundColor Green

        New-Backup `
            $src $dst $Mode $base $Extension `
            -IgnoreFolders $IgnoreFolders `
            -IgnoreFileTypes $IgnoreFileTypes `
            -IgnoreFiles $IgnoreFiles

        Write-Host "Operation completed in $($sw.Elapsed.TotalSeconds) seconds for $base ($SourceFolder)" #-ForegroundColor Green
    }
    catch {
        Write-Error $_
    }
}


function New-Backup {
    param (
        # Folder containing fiels to be backed up.
        [parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ } )]
        [ValidateNotNullOrEmpty()]
        [string] $SourceFolder,

        # Folder where the archive file for the backup will be created/placed.
        #[ValidateScript( { Test-Path $_ } )]
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $DestinationFolder,

        # Backup mode: Full or Partial?
        [parameter(Mandatory)]
        [ValidateScript( { $_ -ne ([ArchiveMode]::Unknown) } )]
        [ArchiveMode] $ArchiveMode,

        # Base name for backup file.
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Basename,

        # File extension (default: 'zip').
        [string]
        $Extension = "zip",

        [string[]] $IgnoreFolders,
        [string[]] $IgnoreFileTypes,
        [string[]] $IgnoreFiles
    )

    $ArchiveName = New-ArchiveName $Basename $ArchiveMode $Extension
    $ArchiveName = join-path -Path $DestinationFolder -ChildPath $ArchiveName
    Write-Verbose "New-Backup: ArchiveName = $ArchiveName"


    $Files = Get-FilesForBackup `
        $SourceFolder `
        -IgnoreFolders $IgnoreFolders `
        -IgnoreFileTypes $IgnoreFileTypes `
        -IgnoreFiles $IgnoreFiles

    $CountFiles = ($Files | Measure-Object).Count
    
    Write-Debug "New-Backup: Count All Files = $CountFiles"
    
    # $Files | Select-Object -Property FullName

    if (($null -eq $Files) -or (0 -ge $CountFiles)) {
        Write-Warning "New-Backup: Source folder contains no files that can be archived."
        return
    }


    $DtLastFull = Get-DateMostRecentArchive $DestinationFolder $Basename ([ArchiveMode]::Full) $Extension
    $DtChangedAfter = $DtLastFull
    if ($null -eq $DtLastFull) { 
        $DtChangedAfter = [datetime]::MinValue
    }

    if ([ArchiveMode]::Partial -eq $ArchiveMode) {
        $DtLastPartial = Get-DateMostRecentArchive $DestinationFolder $Basename ([ArchiveMode]::Partial) $Extension
        if (($null -ne $DtLastPartial) -and ($DtLastPartial -gt $DtLastFull)) {
            $DtChangedAfter = $DtLastPartial 
        }

        $Files = $Files | Where-Object {
            $_.PSIsContainer -or
            $(!$_.PSIsContainer -and $_.LastWriteTime -gt $DtChangedAfter)
        }

        $CountFiles = ($Files | Measure-Object).Count

        Write-Debug "New-Backup: ArchiveMode = $ArchiveMode, DtChangedAfter = $DtChangedAfter, Count Changed Files = $CountFiles"

        if (($null -eq $Files) -or (0 -ge $CountFiles)) {
            Write-Host "Nothing to do. No changed files since last backup." -ForegroundColor Yellow
            return
        }
    }

    if ([ArchiveMode]::Partial -ne $ArchiveMode) {
        if ([datetime]::MinValue -ne $DtChangedAfter) {
            $CountChangedSinceLastFull = $($Files | Where-Object {
                    $_.PSIsContainer -or
                    $(!$_.PSIsContainer -and $_.LastWriteTime -gt $DtChangedAfter)
                } | Measure-Object Length).Count

            Write-Debug "New-Backup: ArchiveMode = $ArchiveMode, DtChangedAfter = $DtChangedAfter"

            if (0 -ge $CountChangedSinceLastFull) {
                Write-Host "Nothing to do. No changed files since last full backup." -ForegroundColor Yellow
                return
            }
        }
    }

    Write-Host "Backing Up $CountFiles files..."
    New-Archive $SourceFolder $DestinationFolder $ArchiveName $Files
}

function Get-FilesForBackup {
    param (
        # Folder containing fiels to be backed up.
        [parameter(Mandatory)]
        [ValidateScript( { Test-Path $_ } )]
        [ValidateNotNullOrEmpty()]
        [string] $SourceFolder,

        [string[]] $IgnoreFolders,
        [string[]] $IgnoreFileTypes,
        [string[]] $IgnoreFiles
    )

    $ignore = $IgnoreFiles + $IgnoreFileTypes

    $Files = `
        Get-ChildItem $SourceFolder -File -Exclude $ignore -Recurse -Force | `
        Where-Object { 
        $(
            # $(!$_.PSIsContainer -and $_.LastWriteTime -gt $DtChangedAfter) -or
            !$_.PSIsContainer -or
            $($_.PSIsContainer -and $_.Name -inotin $IgnoreFolders)
        ) -and
        $(
            foreach ($fig in $IgnoreFolders) { 
                if ($_ -imatch "\\$fig\\" ) {
                    return $false
                }
            }
            return $true
        ) } | `
        Select-Object | `
        Sort-Object -Property FullName, Name

    return $Files
}

function New-Archive {
    param (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $SourceFolder,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $DestinationFolder,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ArchiveName,

        [parameter(Mandatory)]
        [string[]] $Files
    )

    if (0 -ge $Files.Length) {
        Write-Warning "Nothing to do: No files to archive."
        return 
    }
    
    $FolderSeparator = [Path]::DirectorySeparatorChar.ToString()
    [bool] $haveFiles = $false

    $TempFolder = Join-Path -Path $DestinationFolder -ChildPath $(Split-Path $SourceFolder -Leaf)
    if (Test-path $TempFolder) {
        Remove-Item $TempFolder -Recurse -Force
    }
    New-Item -Path $TempFolder -ItemType Directory -ErrorAction Stop | Out-Null
    
    $Files | ForEach-Object {
        $relPath = $_.SubString($SourceFolder.Length) | Split-Path -Parent
        if (-not $relPath.Equals($FolderSeparator)) {
            $tempPath = Join-Path -Path $TempFolder -ChildPath $relPath
            if (-not (Test-Path $tempPath)) {
                New-Item -ItemType Directory -Path $tempPath -ErrorAction Stop | Out-Null
            }
        }
        else {
            $tempPath = $TempFolder
        }
        Copy-Item $_ -Destination $tempPath -ErrorAction Stop 
        $haveFiles = $true
    }

    if ($haveFiles) {
        Compress-Archive -Path $TempFolder -DestinationPath $ArchiveName -CompressionLevel Optimal
    }
    Remove-Item $TempFolder -Recurse -Force
}


function New-ArchiveName {
    param (
        # Base name for archive file.
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $BaseName,

        # Optional archive mode (default: Unknown).
        [parameter()]
        [ArchiveMode]
        $ArchiveType,
 
        # Optional file extension (default: 'zip').
        [parameter()]
        [string]
        $Extension = "zip"
    )
    $DtNow = [datetime]::Now
    $Marker = Get-ArchiveModeMarker $ArchiveType
    if (-not [string]::IsNullOrWhiteSpace($Marker)) { $Marker = "-$Marker" }

    return "$($BaseName)-$($DtNow.ToString('yyyy-MM-dd-HH-mm-ss'))$($Marker).$($Extension)"
}

function Get-NextBackupMode {
    param (
        # The base name for the archived files.
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Basename,

        # Folder in which backups are stored.
        [parameter(Mandatory)]
        [string] $BackupsFolder,

        # Number of days between full backups.
        [parameter(Mandatory)]
        [int] $DaysBetweenFullBackups,
        
        # The archive file extension (default: 'zip').
        [string]
        $Extension = "zip"
    )

    if (-not $(Test-Path $BackupsFolder)) {
        return [ArchiveMode]::Full
    }

    $DtLastFullBackup = Get-DateMostRecentArchive $BackupsFolder $Basename ([ArchiveMode]::Full) $Extension

    if ($null -eq $DtLastFullBackup) {
        return [ArchiveMode]::Full
    }

    $NumDaysSince = ([timespan] ([datetime]::Now - $DtLastFullBackup)).Days
    if ($NumDaysSince -ge $DaysBetweenFullBackups) {
        return [ArchiveMode]::Full
    }
    else {
        return [ArchiveMode]::Partial
    }
}

function Get-DateMostRecentArchive {
    param (
        # Folder where backup files are stored.
        #[ValidateScript( { Test-Path $_ } )]
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $BackupsFolder,

        # Base name of archive file.
        [parameter(Mandatory)]
        [string]
        $BaseName,

        # Archive type to look for: Full or Partial?
        [parameter(Mandatory)]
        [ArchiveMode]
        $ArchiveType,

        # Archive file name extension (defaults to 'zip').
        [parameter()]
        [string]
        $Extension = "zip"
    )

    if (-not $(Test-Path $BackupsFolder)) { return $null }

    $OldCwd = [Directory]::GetCurrentDirectory()
    $Cwd = Get-Location
    [Directory]::SetCurrentDirectory($Cwd)
    try {
        $Marker = Get-ArchiveModeMarker $ArchiveType
        if (-not [string]::IsNullOrWhiteSpace($Marker)) { $Marker = "-$Marker" }

        $Path = Join-Path -Path $BackupsFolder -ChildPath "$($BaseName)*$($Marker).$($Extension)"
        $Path = [Path]::GetFullPath($Path)

        if (0 -ge (Get-ChildItem $Path | Measure-Object).Count) {
            return $null
        }

        $ArchiveName = Get-ChildItem $Path | Sort-Object -Property FullName | Select-Object -Last 1 | Split-Path -Leaf
        Write-Verbose "Get-DateMostRecentArchive: Mode = $ArchiveType, Archive = $ArchiveName"

        return Get-DateFromArchiveName $ArchiveName
    }
    finally {
        [Directory]::SetCurrentDirectory($OldCwd)
    }
}

function Get-DateFromArchiveName {
    param (
        # The name of the archive file (expected format: [<base-name>][-<marker>]-<yyyy>-<MM>-<dd>-<HH>-<mm>.<extension>).
        #[ValidateRegEx()]
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ArchiveName
    )

    $Name = [Path]::GetFileNameWithoutExtension($ArchiveName)

    $DtParts = $Name.Split("-") | Select-Object -Skip 1 -First 6
    $DtString = $DtParts | Select-Object -First 3 | Join-String -Separator "-"
    $DtString += " " + $($DtParts | Select-Object -Last 3 | Join-String -Separator ":")

    Write-Verbose "Get-DateFromArchiveName: DtString = $DtString"

    return [datetime]::ParseExact($DtString, "yyyy-MM-dd HH:mm:ss", $null)
}

function Get-ArchiveModeMarker {
    param (
        [parameter(Mandatory)]
        [ArchiveMode]
        $ArchiveMode
    )
    
    $Marker = [ArchiveMode]::Unknown

    switch ($ArchiveMode) {
        ([ArchiveMode]::Full) { $Marker = "Full" }
        ([ArchiveMode]::Partial) { $Marker = "Part" }
        Default { $Marker = "" }
    }

    return $Marker
}


enum ArchiveMode {
    Unknown
    Full
    Partial
}


function Update-NameFormatOfExistingFiles {
    [CmdletBinding()]
    param (
        # Folder where archive files are located
        [parameter(Mandatory, HelpMessage = "Folder containing archive files with old naming style.")]
        # [ValidateNotNullOrEmpty()]
        # [ValidateScript( { Test-Path $_ } )]
        [string] $ArchiveFolder,

        # Extension for backup file name (default: 'zip').
        [parameter(HelpMessage = "Extension for backup file name (default: 'zip').")]
        [string]
        $Extension = "zip"
    )
    try {
        if ([string]::IsNullOrWhiteSpace($ArchiveFolder) -or
            ($true -ne (Test-Path $ArchiveFolder))) {
            return
        }
    
        $MarkerFull = Get-ArchiveModeMarker ([ArchiveMode]::Full)
        $MarkerPart = Get-ArchiveModeMarker ([ArchiveMode]::Partial)
        $FileSpec = Join-Path $ArchiveFolder "*.$($Extension)"
        $Files = Get-ChildItem $FileSpec -File -Recurse -Force

        $Files | ForEach-Object {
            $PathName = $_.FullName
            $FileName = [Path]::GetFileNameWithoutExtension($PathName)
            $FileExt = [Path]::GetExtension($PathName)

            $NameParts = $FileName.Split("-")
            $BaseName = $NameParts | Select-Object -First 1
            $Mode = $NameParts | Select-Object -Skip 1 -First 1

            $IsMode = $Mode -iin ($MarkerFull, $MarkerPart) -and -not "$Mode".StartsWith("20")

            if ($IsMode) {
                $DtParts = $NameParts | Select-Object -Last 5
                $DtString = $DtParts | Join-String -Separator "-"
            
                $NewName = "$BaseName-$DtString-00-$Mode$FileExt"
            
                Rename-Item -Path $PathName $NewName
            }
        }
    }
    catch {
        Write-Error $_
    }
}



Export-ModuleMember "Backup-FolderContents"
