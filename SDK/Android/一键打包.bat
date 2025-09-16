@echo off
title APK Toolchain 一键工具
color 0a
setlocal enabledelayedexpansion

rem ========= 基本配置 =========
rem Apktool 的路径
set APKTOOL=tools\apktool.jar
rem zipalign 工具路径
set ZIPALIGN=tools\zipalign.exe
rem apksigner 工具路径
set APKSIGNER=tools\apksigner.exe
rem 工作目录，用来放待处理 APK、反编译输出等
set WORKDIR=workspace

rem ========= 签名证书配置 =========
rem 如果没有 keystore，本脚本会自动生成
set KEYSTORE=mykey.keystore
set ALIAS=myalias
set STOREPASS=123456
set KEYPASS=123456

rem ========= 菜单界面 =========
:menu
cls
echo ==============================
echo       APK 工具链菜单
echo ==============================
echo [1] 反编译 APK
echo [2] 回编译 APK
echo [3] 签名 APK
echo [4] 对齐 APK
echo [5] 一键全流程
echo [0] 退出
echo ==============================
set /p choice=请选择功能： 

rem 根据用户输入跳转到不同的功能
if "%choice%"=="1" goto decompile
if "%choice%"=="2" goto build
if "%choice%"=="3" goto sign
if "%choice%"=="4" goto align
if "%choice%"=="5" goto full
if "%choice%"=="0" exit
goto menu

rem ========= 功能1：反编译 =========
:decompile
cls
set /p APK=请输入要反编译的 APK 文件路径（放在 workspace 下）： 
rem 用 apktool 反编译 APK，输出到 workspace/app_src
java -jar %APKTOOL% d "%WORKDIR%\%APK%" -o "%WORKDIR%\app_src"
pause
goto menu

rem ========= 功能2：回编译 =========
:build
cls
echo 正在回编译...
rem 用 apktool 回编译，生成未签名 APK
java -jar %APKTOOL% b "%WORKDIR%\app_src" -o "%WORKDIR%\new_app_unsigned.apk"
echo 完成，输出: %WORKDIR%\new_app_unsigned.apk
pause
goto menu

rem ========= 功能3：签名 =========
:sign
cls
rem 如果不存在签名证书，则自动创建一个
if not exist %KEYSTORE% (
    echo 正在生成默认签名证书...
    keytool -genkey -v -keystore %KEYSTORE% -alias %ALIAS% -keyalg RSA -keysize 2048 -validity 10000 -storepass %STOREPASS% -keypass %KEYPASS% -dname "CN=APK,O=Toolchain,C=CN"
)
set /p APK=请输入要签名的 APK 文件名（workspace 下）： 
rem 使用 apksigner 对 APK 进行签名
%APKSIGNER% sign --ks %KEYSTORE% --ks-pass pass:%STOREPASS% --key-pass pass:%KEYPASS% --ks-key-alias %ALIAS% "%WORKDIR%\%APK%"
echo 签名完成！
pause
goto menu

rem ========= 功能4：对齐 =========
:align
cls
set /p APK=请输入要对齐的 APK 文件名（workspace 下）： 
rem 使用 zipalign 优化 APK，生成 aligned.apk
%ZIPALIGN% -v 4 "%WORKDIR%\%APK%" "%WORKDIR%\aligned.apk"
echo 对齐完成！输出: %WORKDIR%\aligned.apk
pause
goto menu

rem ========= 功能5：一键全流程 =========
:full
cls
echo ========== 一键流程 ==========
set /p APK=请输入要处理的 APK 文件（workspace 下）： 

rem Step 1: 反编译
echo [1] 反编译...
java -jar %APKTOOL% d "%WORKDIR%\%APK%" -o "%WORKDIR%\app_src"

rem Step 2: 回编译
echo [2] 回编译...
java -jar %APKTOOL% b "%WORKDIR%\app_src" -o "%WORKDIR%\new_app_unsigned.apk"

rem Step 3: 签名
echo [3] 签名...
if not exist %KEYSTORE% (
    keytool -genkey -v -keystore %KEYSTORE% -alias %ALIAS% -keyalg RSA -keysize 2048 -validity 10000 -storepass %STOREPASS% -keypass %KEYPASS% -dname "CN=APK,O=Toolchain,C=CN"
)
%APKSIGNER% sign --ks %KEYSTORE% --ks-pass pass:%STOREPASS% --key-pass pass:%KEYPASS% --ks-key-alias %ALIAS% "%WORKDIR%\new_app_unsigned.apk"

rem Step 4: 对齐
echo [4] 对齐...
%ZIPALIGN% -v 4 "%WORKDIR%\new_app_unsigned.apk" "%WORKDIR%\final_app.apk"

echo ====================================
echo 处理完成！最终 APK: %WORKDIR%\final_app.apk
pause
goto menu
