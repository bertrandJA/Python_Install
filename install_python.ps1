#This script installs Python with common libraries. It must be executed in PowerShell ISE
$python_url = 'https://www.python.org/ftp/python/3.10.5/python-3.10.5-amd64.exe' #Change URL if you need a different version
$installPython = $false #Set to false if Python is installed, and you only want to install/update libraries
$list_libraries = 'pip', 'pandas', 'PySide6' #list of common libraries to install or update
$behindFirewall = $false #Set to $true if you are on l'Oréal laptop at the office, and $false otherwise
$proxy = 'http://00.0.0.0:8080' #enter here the IP of your proxy if you are behind a firewall

if ($installPython) {
	#Specify the target location in the user's Downloads folder
	$downloadFolder = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
	$downloadFileName = Split-Path -Path $python_url -Leaf
    $downloadFilePath = Join-Path -Path $downloadFolder -ChildPath $downloadFileName
	#launch download of the desired version
	Invoke-WebRequest -Uri $python_url -OutFile $downloadFilePath

	#Command to execute an install for the current user (no admin rights required)
    Start-Process -FilePath "$downloadFilePath" -ArgumentList "InstallAllUsers=0", "InstallLauncherAllUsers=0", "PrependPath=1" -wait
    #Wait the end of installation process to continue
}
#Refresh environment variable Path:
$Env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
python --version #Check installed version

#Install or upgrade all dependancies (pip,...)
$proxy_chain = if($behindFirewall) {' --trusted-host pypi.org --trusted-host files.pythonhosted.org --proxy=' + $proxy} else {''}
Foreach ($lib in $list_libraries) {
	#$command = 'python -m pip install --upgrade ' + $lib + $proxy_chain
	#Invoke-Expression $command
	Start-Process -FilePath "python" -ArgumentList "-m", "pip", "install", "--upgrade", $lib, $proxy_chain -wait
}