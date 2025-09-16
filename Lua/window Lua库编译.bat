@echo off
setlocal enabledelayedexpansion

rem 设置项目和输出目录
set "PROJECT_DIR=%cd%"
set "BUILD_DIR=%PROJECT_DIR%\build"
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

echo ============================
echo 请选择要构建的 Lua 库平台:
echo 1) Windows DLL
echo 2) macOS dylib
echo 3) iOS static lib (.a)
echo 4) Android SO
echo 5) 全部构建
echo ============================
set /p choice="输入编号 (1-5): "

set /p zip_choice="是否压缩成 ZIP 文件？(y/n): "
set "DO_ZIP=false"
if /i "%zip_choice%"=="y" set "DO_ZIP=true"

rem ----------------------------
rem 构建 Windows DLL
rem ----------------------------
if "%choice%"=="1" goto build_windows
if "%choice%"=="5" goto build_windows

rem ----------------------------
rem 构建 macOS dylib
rem ----------------------------
if "%choice%"=="2" goto build_mac
if "%choice%"=="5" goto build_mac

rem ----------------------------
rem 构建 iOS 静态库
rem ----------------------------
if "%choice%"=="3" goto build_ios
if "%choice%"=="5" goto build_ios

rem ----------------------------
rem 构建 Android SO
rem ----------------------------
if "%choice%"=="4" goto build_android
if "%choice%"=="5" goto build_android

echo 无效选择
goto end

rem ============================
:build_windows
echo 构建 Windows DLL...
if not exist "%BUILD_DIR%\windows" mkdir "%BUILD_DIR%\windows"

gcc -O2 -shared -o "%BUILD_DIR%\windows\lua.dll" ^
"Lua\lapi.c" "Lua\lcode.c" "Lua\ldebug.c" "Lua\ldo.c" "Lua\lfunc.c" "Lua\lgc.c" ^
"Lua\llex.c" "Lua\lmem.c" "Lua\lobject.c" "Lua\lopcodes.c" "Lua\lparser.c" ^
"Lua\lstate.c" "Lua\lstring.c" "Lua\ltable.c" "Lua\ltm.c" "Lua\lundump.c" ^
"Lua\lvm.c" "Lua\lzio.c" "Lua\lauxlib.c" "Lua\lbaselib.c" "Lua\linit.c" ^
"Lua\liolib.c" "Lua\lmathlib.c" "Lua\loslib.c" "Lua\ltablib.c" "Lua\lstrlib.c" ^
"Lua\lutf8lib.c" "Lua\loadlib.c" -Wl,--out-implib,"%BUILD_DIR%\windows\lua.lib"

if "%DO_ZIP%"=="true" goto zip_windows
echo Windows DLL 构建完成 (未压缩)
goto end_windows

:zip_windows
powershell -Command "Compress-Archive -Path '%BUILD_DIR%\windows\lua.dll','%BUILD_DIR%\windows\lua.lib' -DestinationPath '%BUILD_DIR%\windows\LuaWindows.zip' -Force"
echo Windows DLL 已打包成 ZIP

:end_windows

rem ============================
:build_mac
echo 构建 macOS dylib...
if not exist "%BUILD_DIR%\mac" mkdir "%BUILD_DIR%\mac"

clang -O2 -dynamiclib -o "%BUILD_DIR%\mac\liblua.dylib" ^
"Lua\lapi.c" "Lua\lcode.c" "Lua\ldebug.c" "Lua\ldo.c" "Lua\lfunc.c" "Lua\lgc.c" ^
"Lua\llex.c" "Lua\lmem.c" "Lua\lobject.c" "Lua\lopcodes.c" "Lua\lparser.c" ^
"Lua\lstate.c" "Lua\lstring.c" "Lua\ltable.c" "Lua\ltm.c" "Lua\lundump.c" ^
"Lua\lvm.c" "Lua\lzio.c" "Lua\lauxlib.c" "Lua\lbaselib.c" "Lua\linit.c" ^
"Lua\liolib.c" "Lua\lmathlib.c" "Lua\loslib.c" "Lua\ltablib.c" "Lua\lstrlib.c" ^
"Lua\lutf8lib.c" "Lua\loadlib.c"

if "%DO_ZIP%"=="true" goto zip_mac
echo macOS dylib 构建完成 (未压缩)
goto end_mac

:zip_mac
powershell -Command "Compress-Archive -Path '%BUILD_DIR%\mac\liblua.dylib' -DestinationPath '%BUILD_DIR%\mac\LuaMac.zip' -Force"
echo macOS dylib 已打包成 ZIP

:end_mac

rem ============================
:build_ios
echo 构建 iOS 静态库 (.a)...
if not exist "%BUILD_DIR%\ios" mkdir "%BUILD_DIR%\ios"

xcrun --sdk iphoneos clang -arch arm64 -c ^
"Lua\lapi.c" "Lua\lcode.c" "Lua\ldebug.c" "Lua\ldo.c" "Lua\lfunc.c" "Lua\lgc.c" ^
"Lua\llex.c" "Lua\lmem.c" "Lua\lobject.c" "Lua\lopcodes.c" "Lua\lparser.c" ^
"Lua\lstate.c" "Lua\lstring.c" "Lua\ltable.c" "Lua\ltm.c" "Lua\lundump.c" ^
"Lua\lvm.c" "Lua\lzio.c" "Lua\lauxlib.c" "Lua\lbaselib.c" "Lua\linit.c" ^
"Lua\liolib.c" "Lua\lmathlib.c" "Lua\loslib.c" "Lua\ltablib.c" "Lua\lstrlib.c" ^
"Lua\lutf8lib.c" "Lua\loadlib.c" -o "%BUILD_DIR%\ios\"

cd "%BUILD_DIR%\ios"
ar rcs liblua.a *.o
cd "%PROJECT_DIR%"

if "%DO_ZIP%"=="true" goto zip_ios
echo iOS 静态库构建完成 (未压缩)
goto end_ios

:zip_ios
powershell -Command "Compress-Archive -Path '%BUILD_DIR%\ios\liblua.a' -DestinationPath '%BUILD_DIR%\ios\LuaIOS.zip' -Force"
echo iOS 静态库 已打包成 ZIP

:end_ios

rem ============================
:build_android
echo 构建 Android SO...
if not exist "%BUILD_DIR%\android" mkdir "%BUILD_DIR%\android"

rem 设置 NDK 路径
set "NDK=C:\Android\android-ndk-r25b"
"%NDK%\toolchains\llvm\prebuilt\windows-x86_64\bin\clang.exe" --target=aarch64-linux-android21 -fPIC -O2 -shared -o "%BUILD_DIR%\android\liblua.so" ^
"Lua\lapi.c" "Lua\lcode.c" "Lua\ldebug.c" "Lua\ldo.c" "Lua\lfunc.c" "Lua\lgc.c" ^
"Lua\llex.c" "Lua\lmem.c" "Lua\lobject.c" "Lua\lopcodes.c" "Lua\lparser.c" ^
"Lua\lstate.c" "Lua\lstring.c" "Lua\ltable.c" "Lua\ltm.c" "Lua\lundump.c" ^
"Lua\lvm.c" "Lua\lzio.c" "Lua\lauxlib.c" "Lua\lbaselib.c" "Lua\linit.c" ^
"Lua\liolib.c" "Lua\lmathlib.c" "Lua\loslib.c" "Lua\ltablib.c" "Lua\lstrlib.c" ^
"Lua\lutf8lib.c" "Lua\loadlib.c"

if "%DO_ZIP%"=="true" goto zip_android
echo Android SO 构建完成 (未压缩)
goto end_android

:zip_android
powershell -Command "Compress-Archive -Path '%BUILD_DIR%\android\liblua.so' -DestinationPath '%BUILD_DIR%\android\LuaAndroid.zip' -Force"
echo Android SO 已打包成 ZIP

:end_android

:end
echo 构建完成，输出目录: %BUILD_DIR%
pause
endlocal
