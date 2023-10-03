# Minecraft Backup Script für Windows - Copyright Gitacular 2023 - https://github.com/Gitacular
# Variablen-Initialisierung - Passe sie nach deinen Vorlieben an.

$serverDir = "C:\Pfad\zum\MinecraftServer" # Hauptverzeichnis des Minecraftservers
$serverIP = "127.0.0.1" # Die IP-Adresse deines Minecraftservers. Wenn lokal, dann nicht verändern.
$portRCON = "25575" # Der Remote Console Port deines Minecraftservers. Standardmäßig nicht verändern.
$rconPwd = "SuPeRsIcHeReSpAsSwOrT" # Dein RCON-Passwort
$backupDir = "D:\Pfad\zum\BackupVerzeichnis" # Dein Backup-Verzeichnis
$sevenZip = "C:\Pfad\zur\7za.exe" # Dein Verzeichnis, in dem du die 7za liegen hast
$logFile = "$backupDir\backup.log" # Am besten so belassen, speichert die MasterLog standardmäßig in das Backupverzeichnis.
$ignorePatterns = @(".*", "._*")  # Muster der zu ignorierenden Dateien und Verzeichnisse - ggf. anpassen.
$daysKeepTo = "30" # Wie viele Tage deine Backups aufbewahrt werden.

# Erstelle nun in der Aufgabenplanung (Suche über Startmenü) einen Task mit dem Pfad zur backupstartV3.bat
# und gib als Trigger die gewünschten Zeiten an, zu denen das Serverbackup durchgeführt werden soll.
# Wenn das Skript nicht auf dem gleichen Server wie dein Minecraftserver läuft, vergiss nicht den RCON-Port zu öffnen. 

# ===========================================================
# Ab hier nichts mehr verändern, außer du weißt, was du tust.
# ===========================================================


# Logging-Funktion
Function Write-Log {
    Param ([string]$logString)
    Add-Content $logFile -Value ("[" + (Get-Date).ToString() + "] " + $logString)
}

# Start-Log und Zeitmessung
Write-Log "Backup-Prozess gestartet."
$start_time = Get-Date

# Speichere Minecraft-Welt und deaktiviere automatisches Speichern
Write-Log "RCON-Befehl sichert Spielstand und deaktiviert AutoSave..."
& .\rcon-cli.exe --host $serverIP --port $portRCON --password $rconPwd /save-all
& .\rcon-cli.exe --host $serverIP --port $portRCON --password $rconPwd /save-off
& .\rcon-cli.exe --host $serverIP --port $portRCON --password $rconPwd /say Backup gestartet.

# Temporäres Verzeichnis für die Kopie
$tempDir = "$backupDir\temp"

# Rekursive Kopie des Serververzeichnisses
Write-Log "Kopiere Serververzeichnis..."
Get-ChildItem -Path $serverDir -Recurse | 
    Where-Object {
        $shouldCopy = $true
        foreach ($pattern in $ignorePatterns) {
            if ($_.Name -like $pattern -or $_.Attributes -match 'Hidden') {
                $shouldCopy = $false
                break
            }
        }
        return $shouldCopy
    } | 
    ForEach-Object {
        $destination = $_.FullName.Replace($serverDir, $tempDir)
        $destinationDir = [System.IO.Path]::GetDirectoryName($destination)

        # Erstelle das Zielverzeichnis, falls es nicht existiert
        if (-not (Test-Path $destinationDir)) {
            New-Item -Path $destinationDir -ItemType Directory
        }

        # Versuche, die Datei zu kopieren und fange eventuelle Fehler ab
        try {
            Copy-Item -Path $_.FullName -Destination $destination -Force
        } catch {
            Write-Log "WARNUNG: Konnte $_.FullName nicht kopieren. Fehler: $_"
        }
    }

# Ermittlung der Originalgröße
$originalSize = (Get-ChildItem -Path $tempDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB

# Erstellung des 7zip-Archivs
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$archiveFile = "$backupDir\backup_$timestamp.7z"

Write-Log "Erstelle 7zip-Archiv..."
& $sevenZip a -t7z $archiveFile $tempDir\*

# Ermittlung der gepackten Größe
$archiveSize = (Get-Item -Path $archiveFile).Length / 1MB

# Temporäres Verzeichnis löschen
Write-Log "Lösche temporäres Verzeichnis..."
Remove-Item -Path $tempDir -Recurse -Force

# Alte Backups löschen
Write-Log "Bereinige alte Backups..."
$limit = (Get-Date).AddDays(-$daysKeepTo)
Get-ChildItem -Path $backupDir -Recurse | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force

# Aktiviere Automatisches Speichern wieder.
Write-Log "RCON-Befehl aktiviert AutoSave wieder..."
& .\rcon-cli.exe --host $serverIP --port $portRCON --password $rconPwd /save-on

# Abschluss-Log und Zeitmessung
$end_time = Get-Date
$duration = $end_time - $start_time
Write-Log "Backup-Prozess abgeschlossen."
Write-Log ("Dauer des Backups: " + $duration)
Write-Log ("Originalgröße: " + "{0:N2}" -f $originalSize + " MB")
Write-Log ("Gepackte Größe: " + "{0:N2}" -f $archiveSize + " MB")

& .\rcon-cli.exe --host $serverIP --port $portRCON --password $rconPwd /say Backup abgeschlossen. Dauer: $duration Gesichert: $archiveSize aus $originalSize MB.