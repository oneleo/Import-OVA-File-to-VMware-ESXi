# �Ĥ@���ϥ� Script �n������GSet-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# �i�H�ϥ� Get-ExecutionPolicy -List ���O�d��í�p�v���A
cd "X:\Scripts\Files\Path\"

$sourceFolder = "X:\OVA\Files\Path\"

Write-Host "�|�N���ؿ����U�� Templates �W�Ǩ� vCenter�G$sourceFolder"

# ��즹���ɦW���ɮסA�Ъ`�N�Y�u���@�ӫh�|�X�{���~
$allTextFile = Get-ChildItem -Path $sourceFolder -Recurse -Filter "*.ova"

if ( ( $allTextFile.length -le 1 ) -or ( $allTextFile.length -ge 100 ) )
	{
		Write-Host;
		Write-Host "PowerShell ��쪺 ova �ɮ׼Ƭ��G" -foregroundcolor red -backgroundcolor white -nonewline
		Write-Host $allTextFile.length -foregroundcolor red -backgroundcolor white -nonewline		
		Write-Host " �ӡC" -foregroundcolor red -backgroundcolor white
		
		Write-Host "�]�����쪺 ova �ɮ׼ƥu��" -foregroundcolor red -backgroundcolor white -nonewline
		Write-Host " 1 �ӥH�U" -foregroundcolor red -backgroundcolor green -nonewline
		Write-Host "�ɴN�|�X�{���~�I" -foregroundcolor red -backgroundcolor white
		Write-Host "�ҥH�{���j���I�Ы����N�����}�C" -foregroundcolor red -backgroundcolor white
		Write-Host;
		cmd /c "Pause"
		exit
		Write-Host "This message will be not to see."
	}

. ".\region.ps1" -sourceFolder $sourceFolder