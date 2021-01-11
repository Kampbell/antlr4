echo off
rem echo Usage:
rem echo ------
rem echo pack [vsvers] [version]       // pack 2019 4.9.1
rem echo ------
setlocal enableextensions enabledelayedexpansion

if "%1"=="" goto usage
if "%2"=="" goto usage

set PLATFORM=Win32

rem -version ^^[16.0^^,17.0^^)
set VS_VERSION=vs%1
rem  should be set "VSWHERE='%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe  -property installationPath -version ^[16.0^,17.0^)'"
if %VS_VERSION%==vs2019 (
  set "VSWHERE='C:\PROGRA~2\"Microsoft Visual Studio"\Installer\vswhere.exe  -latest -property installationPath -version ^[16.0^,17.0^)'"
) else (
if %VS_VERSION%==vs2017 (
  set "VSWHERE='C:\PROGRA~2\"Microsoft Visual Studio"\Installer\vswhere.exe  -latest -property installationPath -version ^[15.0^,16.0^)'"
)
)
for /f " delims=" %%a in (%VSWHERE%) do @set "VSCOMNTOOLS=%%a"

echo ============= %VSCOMNTOOLS% =============

if %VS_VERSION%==vs2019 (
  set VS_VARSALL=..\..\VC\Auxiliary\Build\vcvarsall.bat
  set "VS160COMNTOOLS=%VSCOMNTOOLS%\Common7\Tools\"
) else (
  if %VS_VERSION%==vs2017 (
    set VS_VARSALL=..\..\VC\Auxiliary\Build\vcvarsall.bat
    set "VS150COMNTOOLS=%VSCOMNTOOLS%\Common7\Tools\"
  ) else (
    set VS_VARSALL=..\..\VC\vcvarsall.bat
  )
)

if not defined VCINSTALLDIR (
  if %VS_VERSION%==vs2015 (
    if %PLATFORM%==x64 (
      call "%VS140COMNTOOLS%%VS_VARSALL%" x86_amd64 8.1
    ) else (
      call "%VS140COMNTOOLS%%VS_VARSALL%" x86 8.1
    )
  ) else (
    if %VS_VERSION%==vs2017 (
      if %PLATFORM%==x64 (
        call "%VS150COMNTOOLS%%VS_VARSALL%" x86_amd64 8.1
      ) else (
        call "%VS150COMNTOOLS%%VS_VARSALL%" x86 8.1
      )
    ) else (
      if %VS_VERSION%==vs2019 (
        if %PLATFORM%==x64 (
          call "%VS160COMNTOOLS%%VS_VARSALL%" x86_amd64 8.1
        ) else (
          call "%VS160COMNTOOLS%%VS_VARSALL%" x86 8.1
        )
      )
    )
  )
)

if not defined VSINSTALLDIR (
  echo Error: No Visual C++ environment found.
  echo Please run this script from a Visual Studio Command Prompt
  echo or run "%%VSnnCOMNTOOLS%%\vsvars32.bat" first.
  goto :buildfailed
)


pushd ..\
call msbuild antlr4cpp-vs%1.vcxproj -t:rebuild -p:Configuration="Debug DLL"
call msbuild antlr4cpp-vs%1.vcxproj -t:rebuild -p:Configuration="Debug Static"
call msbuild antlr4cpp-vs%1.vcxproj -t:rebuild -p:Configuration="Release DLL"
call msbuild antlr4cpp-vs%1.vcxproj -t:rebuild -p:Configuration="Release Static"
popd

del *.noarch.%3.nupkg *.%1.%3.nupkg *.%1.%3.symbols.nupkg
call nuget pack ANTLR4.Runtime.noarch.nuspec 				-p vs=%1 -p version=%2 -p pre=-beta.2
call nuget pack ANTLR4.Runtime.shared.nuspec 	-symbols 	-p vs=%1 -p version=%2 -p pre=-beta.2
call nuget pack ANTLR4.Runtime.static.nuspec 	-symbols 	-p vs=%1 -p version=%2 -p pre=-beta.2

goto exit
:usage
echo Usage:
echo ------
echo "pack [vsvers] [version]"       // pack 2019 4.9.1
echo ------
:exit
:buildfailed
endlocal
rem echo on