# escape=`

FROM mcr.microsoft.com/windows:1809

LABEL `
	title="Evolved ASP (Active Server Pages) Windows Image" `
	maintainer="Nagao, Fabio Zendhi" `
	version="1809" `
	contribute="https://github.com/become-evolved/asp-docker/" `
	url="https://www.evolved.com.br" `
	twitter="@nagaozen" `
	usage="docker run -it -p 8080:80 -v ${PWD}\content\:C:\inetpub\wwwroot\ --rm --entrypoint powershell nagaozen/asp-docker:1809"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN `
	& DISM /Online /Enable-Feature /FeatureName:IIS-ASP /All /NoRestart ; `
	& DISM /Online /Enable-Feature /FeatureName:IIS-HttpCompressionDynamic /All /NoRestart ; `
	Remove-Item -Recurse C:\inetpub\wwwroot\* ; `
	Invoke-WebRequest -UseBasicParsing -Uri "https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.6/ServiceMonitor.exe" -OutFile C:\ServiceMonitor.exe

RUN `
	Invoke-WebRequest -UseBasicParsing -Uri "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi" -OutFile C:\rewrite_amd64_en-US.msi ; `
	Start-Process -FilePath "C:\\Windows\\System32\\msiexec.exe" -ArgumentList "/i", "C:\\rewrite_amd64_en-US.msi", "/qn", "/NoRestart" -NoNewWindow -Wait ; `
	Remove-Item C:\rewrite_amd64_en-US.msi -Force

RUN `
	Invoke-WebRequest -UseBasicParsing -Uri "https://download.microsoft.com/download/D/5/E/D5EEF288-A277-45C8-855B-8E2CB7E25B96/x64/msodbcsql.msi" -OutFile C:\msodbcsql.msi ; `
	Start-Process -FilePath "C:\\Windows\\System32\\msiexec.exe" -ArgumentList "/i", "C:\\msodbcsql.msi", "IACCEPTMSODBCSQLLICENSETERMS=YES", "ADDLOCAL=ALL", "/qn", "/NoRestart" -NoNewWindow -Wait ; `
	Remove-Item C:\msodbcsql.msi -Force

RUN `
	Invoke-WebRequest -UseBasicParsing -Uri "https://download.microsoft.com/download/6/1/C/61CC0718-ED0E-4351-BC54-46495EBF5CC3/iiscompression_amd64.msi" -OutFile C:\iiscompression_amd64.msi ; `
	Start-Process -FilePath "C:\\Windows\\System32\\msiexec.exe" -ArgumentList "/i", "C:\\iiscompression_amd64.msi", "/qn", "/NoRestart" -NoNewWindow -Wait ; `
	Remove-Item C:\iiscompression_amd64.msi -Force

RUN `
	Invoke-WebRequest -UseBasicParsing -Uri "https://www.python.org/ftp/python/3.7.2/python-3.7.2.exe" -OutFile C:\python.exe ; `
	Start-Process -FilePath "C:\\python.exe" -ArgumentList "/quiet", "InstallAllUsers=1", "DefaultAllUsersTargetDir=C:\\Python", "PrependPath=1", "Include_test=0" -NoNewWindow -Wait ; `
	Remove-Item C:\python.exe -Force

RUN `
	Start-Process -FilePath "C:\\Python\\Scripts\\pip.exe" -ArgumentList "install", "pywin32" -NoNewWindow -Wait ; `
	Start-Process -FilePath "C:\\Python\\python.exe" -ArgumentList "C:\\Python\\Scripts\\pywin32_postinstall.py", "-install" -NoNewWindow -Wait ; `
	Start-Process -FilePath "C:\\Python\\python.exe" -ArgumentList "C:\\Python\\lib\\site-packages\\win32comext\\axscript\\client\\pyscript.py" -NoNewWindow -Wait

WORKDIR /inetpub/wwwroot

EXPOSE 80

RUN `
	& c:\windows\system32\inetsrv\appcmd.exe unlock config /section:system.webServer/asp ; `
	& c:\windows\system32\inetsrv\appcmd.exe unlock config /section:system.webServer/handlers ; `
	& c:\windows\system32\inetsrv\appcmd.exe unlock config /section:system.webServer/modules ; `
	& c:\windows\system32\inetsrv\appcmd.exe set config /section:asp /codePage:65001 ; `
	& c:\windows\system32\inetsrv\appcmd.exe set config /section:asp /lcid:1033 ; `
	& c:\windows\system32\inetsrv\appcmd.exe set config /section:asp /runOnEndAnonymously:false ; `
	& c:\windows\system32\inetsrv\appcmd.exe set config /section:asp /lockAllAttributesExcept:"appAllowClientDebug,appAllowDebugging,scriptErrorSentToBrowser,enableParentPaths" ; `
	& c:\windows\system32\inetsrv\appcmd.exe set config /section:asp /limits.maxRequestEntityAllowed:67108864 ; `
	& c:\windows\system32\inetsrv\appcmd.exe set AppPool /AppPool.name:DefaultAppPool /Enable32bitAppOnWin64:true

ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]
