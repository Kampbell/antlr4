echo off
rem echo Usage:
rem echo ------
rem echo pack [vsvers] [version]       // pack 2019 4.9.1
rem echo ------
setlocal enableextensions enabledelayedexpansion
if "%1"=="" goto usage
if "%2"=="" goto usage

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
endlocal
rem echo on