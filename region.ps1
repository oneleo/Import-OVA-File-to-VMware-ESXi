
##########
##
## region.ps1
##
##########

## 註：不要執行兩個以上的 PowerCLI 視窗，其中一個會當掉。

## 指定來源資料夾（請參考該 Server 情況填寫）, 請注意本程式碼僅支援有兩個以上的 Templates 才可正常運作。
param ( [string]$sourceFolder = $( throw "參數遺失，請加入此參數: -sourceFolder sourceFolder" ))

## 指定目的地資料夾名稱（請參考該 Server 情況填寫）
$destinationFolderName = "Destination Folder Name"

## 目的地 Server IP（請參考該 Server 情況填寫）
$serverIP = "xxx.xxx.xxx.xxx"

## 目的地 Server 帳號（請參考該 Server 情況填寫）
$serverUser = "User Name"

## 目的地 Server 密碼（請參考該 Server 情況填寫）
$serverPassword = "Password"

## 指定目的地叢集名稱（請參考該 Server 情況填寫）
$destinationClusterName = "Cluster Name"

## 指定目的資源池名稱（請參考該 Server 情況填寫）
$destinationPoolName = $NULL
## 註：若沒有 Pool 的話則要把下方有兩個地方要註解與解開
$destinationPoolName = "Pool Name"

## 指定目的地儲存點名稱（請參考該 Server 情況填寫）
$destinationStorageName = "Storage Name"

## 指定目的地 VM 的預設網卡名稱（請參考該 Server 情況填寫）
$networkName = "VM Network"

##--------------------------------------------------

$displayMessage = "會將此目錄底下的 Templates 上傳到 vCenter：$sourceFolder"
Write-Host $displayMessage -foregroundcolor black -backgroundcolor darkyellow
$displayMessage >> ".\Message.txt"

$allTextFile = Get-ChildItem -Path $sourceFolder -Recurse -Filter "*.ova"

$displayMessage = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " 連線至 $serverIP …"
Write-Host $displayMessage -foregroundcolor black -backgroundcolor darkyellow
$displayMessage >> ".\Message.txt"
Write-Host;
"" >> ".\message.txt"

$connectServer01 = Connect-VIServer -Server $serverIP -User $serverUser -Password $serverPassword

$displayMessage = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " $serverIP 連線完成！"
Write-Host $displayMessage -foregroundcolor black -backgroundcolor darkyellow
$displayMessage >> ".\Message.txt"
Write-Host;
"" >> ".\message.txt"

##--------------------------------------------------

$getCluster = Get-Cluster -Server $connectServer01 -name $destinationClusterName

## 若無 Pool 則要把下面註解掉：
If ( $destinationPoolName -eq $NULL)
	{
		$getPool = $NULL
	}
Else
	{
		$getPool = Get-ResourcePool -Server $connectServer01 -name $destinationPoolName
	}

$getVMHost = $getCluster | Get-VMHost | Select-Object -first 1

$getDatastore = Get-datastore -Server $connectServer01 -name $destinationStorageName | Select-Object -first 1

##--------------------------------------------------

# le 的意思是 less than or equal 如同 "<="
# lt 的意思是 less than 如同 "<"
# ge 的意思是 greater than or equal 如同 ">="
# gt 的意思是 greater than 如同 ">"
# eq 的意思是 equal 如同 "="
# ne 的意思是 not equal 如同 "<>"

##--------------------------------------------------

$displayMessage = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " 檢查是否沒有 JV- 開頭的 VM："
Write-Host $displayMessage -foregroundcolor black -backgroundcolor darkyellow
$displayMessage >> ".\Message.txt"

Write-Host;
"" >> ".\message.txt"

for ( $i = 0; $i -lt $allTextFile.length; $i ++ )
	{			
		$getVMName = $allTextFile[$i].Name -Replace (".ova","")
		## $getVMName = $allTextFile[$i].Name -Replace (".ova","") -Replace ("Part of VM Name","")
		$getTemplate = Get-VM -Server $connectServer01 -Name $getVMName
			
		If ( $getTemplate.Count -ge 1 )
			{
				$displayMessage = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " 在 " + $fileTitle + " 中；" + $getVMName + "：出現 " + $getTemplate.Length + " 個（Template）。"
				Write-Host $displayMessage -foregroundcolor red -backgroundcolor white
				$displayMessage >> ".\Message.txt"
				
				Write-Host;
				"" >> ".\message.txt"
				
				$displayMessage = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " 請檢查已存在於 VMware ESXi 內的 VM 是否全數刪除，此程序強制停止！"
				Write-Host $displayMessage -foregroundcolor red -backgroundcolor white

				cmd /c "Pause"
				exit
				Write-Host "This message will be not to see."
			}
		Else
			{
				$displayMessage = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " 沒有找到任何已存在於 VMware ESXi $getVMName 的 VM，系統上方顯示之黑底紅字警告可忽略。"
				Write-Host $displayMessage -foregroundcolor black -backgroundcolor darkyellow
				$displayMessage >> ".\Message.txt"
				
				Write-Host;
				"" >> ".\message.txt"
			}		
	}

##--------------------------------------------------

## 開始上傳

##--------------------------------------------------

for ( $i = 0; $i -lt $allTextFile.length; $i ++ )
	{

		$getOvfConfig = Get-OvfConfiguration -ovf $allTextFile[$i].FullName | Select-Object -first 1

		$getNetworkName = Get-VirtualPortGroup -Server $connectServer01 -Name $networkName -VMHost $getVMHost | Select-Object -first 1

		$getOvfConfig.NetworkMapping.V_1200.Value = $getNetworkName

		(Get-Date).ToString("yyyy-mm-dd HH:mm:ss") + " 開始上傳 VM！"
		
		## 若沒有 Pool 則要執行沒有 -Location 參數的指令
		If ( $getPool -eq $NULL)
			{
				Import-vApp -Server $connectServer01 -VMHost $getVMHost -Source $allTextFile[$i].FullName -Datastore $getDatastore -OvfConfiguration $getOvfConfig -DiskStorageFormat thin
			}
		Else
			{
				Import-vApp -Server $connectServer01 -VMHost $getVMHost -Source $allTextFile[$i].FullName -Datastore $getDatastore -OvfConfiguration $getOvfConfig -Location $getPool -DiskStorageFormat thin
			}
			
		(Get-Date).ToString("yyyy-mm-dd HH:mm:ss") + " VM 上傳完畢，開始將此 VM 移動至指定資料夾：" + $destinationFolderName

		$getVMName = $allTextFile[$i].Name -Replace (".ova","")

		## 選擇第一層資料夾找到的 VM 位置
		$getLastVM = Get-VM -Server $connectServer01 -Name $getVMName | Select-Object -first 1

		$getDestinationFolder = Get-Folder -Server $connectServer01 -Name $destinationFolderName | Select-Object -first 1

		Move-VM -Server $connectServer01 -VM $getLastVM -Destination $getDestinationFolder

		(Get-Date).ToString("yyyy-mm-dd HH:mm:ss") + " 移動至指定資料夾完成！"
	}
