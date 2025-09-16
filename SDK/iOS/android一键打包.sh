#!/bin/bash
# ==================================
# APK Toolchain 一键工具 (Mac/Linux)
# ==================================

# 基本配置
APKTOOL="tools/apktool.jar"
ZIPALIGN="tools/zipalign"
APKSIGNER="tools/apksigner"
WORKDIR="workspace"

# 签名证书配置（如果没有会自动生成）
KEYSTORE="mykey.keystore"
ALIAS="myalias"
STOREPASS="123456"
KEYPASS="123456"

# 菜单
menu() {
    clear
    echo "=============================="
    echo "      APK 工具链菜单 (Mac)"
    echo "=============================="
    echo "[1] 反编译 APK"
    echo "[2] 回编译 APK"
    echo "[3] 签名 APK"
    echo "[4] 对齐 APK"
    echo "[5] 一键全流程"
    echo "[0] 退出"
    echo "=============================="
    read -p "请选择功能: " choice

    case $choice in
        1) decompile ;;
        2) build ;;
        3) sign ;;
        4) align ;;
        5) full ;;
        0) exit 0 ;;
        *) menu ;;
    esac
}

# 功能1: 反编译
decompile() {
    read -p "请输入要反编译的 APK 文件名 (workspace 下): " APK
    java -jar "$APKTOOL" d "$WORKDIR/$APK" -o "$WORKDIR/app_src"
    read -p "完成! 按回车返回菜单..." 
    menu
}

# 功能2: 回编译
build() {
    echo "正在回编译..."
    java -jar "$APKTOOL" b "$WORKDIR/app_src" -o "$WORKDIR/new_app_unsigned.apk"
    echo "完成! 输出: $WORKDIR/new_app_unsigned.apk"
    read -p "按回车返回菜单..." 
    menu
}

# 功能3: 签名
sign() {
    if [ ! -f "$KEYSTORE" ]; then
        echo "未找到 keystore，正在生成默认签名证书..."
        keytool -genkey -v -keystore "$KEYSTORE" -alias "$ALIAS" -keyalg RSA -keysize 2048 -validity 10000 \
            -storepass "$STOREPASS" -keypass "$KEYPASS" -dname "CN=APK,O=Toolchain,C=CN"
    fi
    read -p "请输入要签名的 APK 文件名 (workspace 下): " APK
    "$APKSIGNER" sign --ks "$KEYSTORE" --ks-pass pass:$STOREPASS --key-pass pass:$KEYPASS --ks-key-alias "$ALIAS" "$WORKDIR/$APK"
    echo "签名完成!"
    read -p "按回车返回菜单..."
    menu
}

# 功能4: 对齐
align() {
    read -p "请输入要对齐的 APK 文件名 (workspace 下): " APK
    "$ZIPALIGN" -v 4 "$WORKDIR/$APK" "$WORKDIR/aligned.apk"
    echo "对齐完成! 输出: $WORKDIR/aligned.apk"
    read -p "按回车返回菜单..."
    menu
}

# 功能5: 一键全流程
full() {
    echo "========== 一键流程 =========="
    read -p "请输入要处理的 APK 文件 (workspace 下): " APK

    echo "[1] 反编译..."
    java -jar "$APKTOOL" d "$WORKDIR/$APK" -o "$WORKDIR/app_src"

    echo "[2] 回编译..."
    java -jar "$APKTOOL" b "$WORKDIR/app_src" -o "$WORKDIR/new_app_unsigned.apk"

    echo "[3] 签名..."
    if [ ! -f "$KEYSTORE" ]; then
        keytool -genkey -v -keystore "$KEYSTORE" -alias "$ALIAS" -keyalg RSA -keysize 2048 -validity 10000 \
            -storepass "$STOREPASS" -keypass "$KEYPASS" -dname "CN=APK,O=Toolchain,C=CN"
    fi
    "$APKSIGNER" sign --ks "$KEYSTORE" --ks-pass pass:$STOREPASS --key-pass pass:$KEYPASS --ks-key-alias "$ALIAS" "$WORKDIR/new_app_unsigned.apk"

    echo "[4] 对齐..."
    "$ZIPALIGN" -v 4 "$WORKDIR/new_app_unsigned.apk" "$WORKDIR/final_app.apk"

    echo "===================================="
    echo "处理完成! 最终 APK: $WORKDIR/final_app.apk"
    read -p "按回车返回菜单..."
    menu
}

# 入口
menu
