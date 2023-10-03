# MinecraftServerBackup-Windows
Minecraft-Server Backup Script (Java-Serverversion, Rcon, 7za, Windows, Automatisierung)

Was kann das Script?

In der backupfileV3.ps1 definierst du die Variablen und führst die backupstartV3.bat entweder händisch aus oder planst sie über die Aufgabenplanung regelmäßig.

Voraussetzungen

- Windows 7 oder höher bzw. Windows Server 2012 R2 oder höher
- Aktuellste 7zip-Konsolenversion, diese findest du hier: https://7-zip.de/
- Powershell muss aktiviert sein (standardmäßig an)
- Berechtigung auf alle angegebenen Pfade
- Installierter Java Minecraft Server
- Entsprechend aktuelle Java-Version

Definierbare Variablen

- Minecraft Serververzeichnis
- Minecraft Server IP
- Minecraft Server RCON Port
- Minecraft Server RCON Passwort
- Backupverzeichnis
- Pfad zur 7zip-Konsolenversion (7za.exe)
- Name der MasterLog-Datei
- Per Pattern ausschließbare Dateien und/ oder Verzeichnisse
- In Tagen aufzubewahrende

Zusätzlicher Inhalt
rcon-cli.exe, rcon-cli.LICENSE und rcon-cli-README.md. Das GitHub-Repository ist in der ReadMe verlinkt.

Installation

- Downloade die aktuellste 7za Konsolenversion (siehe oben) und entpacke die Dateien zusammen mit der 7za.exe in das backupsystem/v1.0/ Verzeichnis
- Kopiere das Verzeichnis v1.0 in ein Verzeichnis deiner Wahl. Achte darauf, dass vom gewählten Verzeichnis Leserechte existieren.
- Wiederhole den Schritt, wenn du mehrere Server backuppen möchtest und benenne das v1.0 Verzeichnis einfach in z. B. deinen Servernamen um.
- Öffne die backupfileV3.ps1 mit einem Texteditor (z. B. Windows Notepad, Notepad2 oder Notepad++) und passe die Variablen für jeden Server an. Speichere sie ab.
- Erstelle in der Aufgabenplanung (Öffnen per WIN+R -> taskschd.msc /s oder über das Startmenü danach suchen) eine neue Aufgabe.
- Vergib im Reiter "Allgemein" einen Namen und eine Beschreibung,
- Im Reiter "Trigger" erstellst du jeweils einen Trigger, wann deine Aufgabe ausgeführt werden soll. z. B. Täglich.
- Im Reiter "Aktionen" wählst du "Neu..." und "Durchsuchen..." bei Programm/Skript. Verwende die backupstartV3.bat und bestätige alles mit "OK".

Deinstallation

- Zum Deinstallieren lösche einfach die Aufgabe aus der Aufgabenplanung und die Verzeichnisse, die du erstellt/kopiert hast. 
