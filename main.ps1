# 第一次使用 Script 要先執行：Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# 可以使用 Get-ExecutionPolicy -List 指令查看穩私權狀態
cd "X:\Scripts\Files\Path\"

$sourceFolder = "X:\OVA\Files\Path\"

Write-Host "會將此目錄底下的 Templates 上傳到 vCenter：$sourceFolder"

# 找到此附檔名的檔案，請注意若只找到一個則會出現錯誤
$allTextFile = Get-ChildItem -Path $sourceFolder -Recurse -Filter "*.ova"

if ( ( $allTextFile.length -le 1 ) -or ( $allTextFile.length -ge 100 ) )
	{
		Write-Host;
		Write-Host "PowerShell 找到的 ova 檔案數為：" -foregroundcolor red -backgroundcolor white -nonewline
		Write-Host $allTextFile.length -foregroundcolor red -backgroundcolor white -nonewline		
		Write-Host " 個。" -foregroundcolor red -backgroundcolor white
		
		Write-Host "因為當找到的 ova 檔案數只有" -foregroundcolor red -backgroundcolor white -nonewline
		Write-Host " 1 個以下" -foregroundcolor red -backgroundcolor green -nonewline
		Write-Host "時就會出現錯誤！" -foregroundcolor red -backgroundcolor white
		Write-Host "所以程式強制停止！請按任意鍵離開。" -foregroundcolor red -backgroundcolor white
		Write-Host;
		cmd /c "Pause"
		exit
		Write-Host "This message will be not to see."
	}

. ".\region.ps1" -sourceFolder $sourceFolder