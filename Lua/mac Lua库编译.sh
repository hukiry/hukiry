#!/bin/bash
set -e

PROJECT_DIR=$(pwd)
BUILD_DIR=$PROJECT_DIR/build
mkdir -p $BUILD_DIR

echo "请选择要构建的 Lua 库平台："
echo "1) Windows DLL"
echo "2) macOS dylib"
echo "3) iOS static lib (.a)"
echo "4) Android SO"
echo "5) 全部构建"
read -p "输入编号 (1-5): " choice

read -p "是否压缩成 ZIP 文件？(y/n): " zip_choice
if [[ "$zip_choice" == "y" || "$zip_choice" == "Y" ]]; then
    DO_ZIP=true
else
    DO_ZIP=false
fi

build_windows() {
    echo "构建 Windows DLL..."
    mkdir -p $BUILD_DIR/windows
    gcc -O2 -shared -o $BUILD_DIR/windows/lua.dll \
        Lua/lapi.c Lua/lcode.c Lua/ldebug.c Lua/ldo.c Lua/lfunc.c Lua/lgc.c \
        Lua/llex.c Lua/lmem.c Lua/lobject.c Lua/lopcodes.c Lua/lparser.c \
        Lua/lstate.c Lua/lstring.c Lua/ltable.c Lua/ltm.c Lua/lundump.c \
        Lua/lvm.c Lua/lzio.c Lua/lauxlib.c Lua/lbaselib.c Lua/linit.c \
        Lua/liolib.c Lua/lmathlib.c Lua/loslib.c Lua/ltablib.c Lua/lstrlib.c \
        Lua/lutf8lib.c Lua/loadlib.c -Wl,--out-implib,$BUILD_DIR/windows/lua.lib

    if $DO_ZIP; then
        cd $BUILD_DIR/windows
        zip LuaWindows.zip lua.dll lua.lib
        cd $PROJECT_DIR
        echo "Windows DLL 打包完成 (ZIP)"
    else
        echo "Windows DLL 构建完成 (未压缩)"
    fi
}

build_mac() {
    echo "构建 macOS dylib..."
    mkdir -p $BUILD_DIR/mac
    clang -O2 -dynamiclib -o $BUILD_DIR/mac/liblua.dylib \
        Lua/lapi.c Lua/lcode.c Lua/ldebug.c Lua/ldo.c Lua/lfunc.c Lua/lgc.c \
        Lua/llex.c Lua/lmem.c Lua/lobject.c Lua/lopcodes.c Lua/lparser.c \
        Lua/lstate.c Lua/lstring.c Lua/ltable.c Lua/ltm.c Lua/lundump.c \
        Lua/lvm.c Lua/lzio.c Lua/lauxlib.c Lua/lbaselib.c Lua/linit.c \
        Lua/liolib.c Lua/lmathlib.c Lua/loslib.c Lua/ltablib.c Lua/lstrlib.c \
        Lua/lutf8lib.c Lua/loadlib.c

    if $DO_ZIP; then
        cd $BUILD_DIR/mac
        zip LuaMac.zip liblua.dylib
        cd $PROJECT_DIR
        echo "macOS dylib 打包完成 (ZIP)"
    else
        echo "macOS dylib 构建完成 (未压缩)"
    fi
}

build_ios() {
    echo "构建 iOS 静态库 (.a)..."
    mkdir -p $BUILD_DIR/ios
    xcrun --sdk iphoneos clang -arch arm64 -c \
        Lua/lapi.c Lua/lcode.c Lua/ldebug.c Lua/ldo.c Lua/lfunc.c Lua/lgc.c \
        Lua/llex.c Lua/lmem.c Lua/lobject.c Lua/lopcodes.c Lua/lparser.c \
        Lua/lstate.c Lua/lstring.c Lua/ltable.c Lua/ltm.c Lua/lundump.c \
        Lua/lvm.c Lua/lzio.c Lua/lauxlib.c Lua/lbaselib.c Lua/linit.c \
        Lua/liolib.c Lua/lmathlib.c Lua/loslib.c Lua/ltablib.c Lua/lstrlib.c \
        Lua/lutf8lib.c Lua/loadlib.c
    cd $BUILD_DIR/ios
    ar rcs liblua.a *.o

    if $DO_ZIP; then
        zip LuaIOS.zip liblua.a
        cd $PROJECT_DIR
        echo "iOS 静态库打包完成 (ZIP)"
    else
        cd $PROJECT_DIR
        echo "iOS 静态库构建完成 (未压缩)"
    fi
}

build_android() {
    echo "构建 Android SO..."
    mkdir -p $BUILD_DIR/android
    $NDK/toolchains/llvm/prebuilt/darwin-x86_64/bin/clang \
        --target=aarch64-linux-android21 -fPIC -O2 -shared \
        -o $BUILD_DIR/android/liblua.so \
        Lua/lapi.c Lua/lcode.c Lua/ldebug.c Lua/ldo.c Lua/lfunc.c Lua/lgc.c \
        Lua/llex.c Lua/lmem.c Lua/lobject.c Lua/lopcodes.c Lua/lparser.c \
        Lua/lstate.c Lua/lstring.c Lua/ltable.c Lua/ltm.c Lua/lundump.c \
        Lua/lvm.c Lua/lzio.c Lua/lauxlib.c Lua/lbaselib.c Lua/linit.c \
        Lua/liolib.c Lua/lmathlib.c Lua/loslib.c Lua/ltablib.c Lua/lstrlib.c \
        Lua/lutf8lib.c Lua/loadlib.c

    if $DO_ZIP; then
        cd $BUILD_DIR/android
        zip LuaAndroid.zip liblua.so
        cd $PROJECT_DIR
        echo "Android SO 打包完成 (ZIP)"
    else
        echo "Android SO 构建完成 (未压缩)"
    fi
}

case $choice in
    1) build_windows ;;
    2) build_mac ;;
    3) build_ios ;;
    4) build_android ;;
    5) build_windows; build_mac; build_ios; build_android ;;
    *) echo "无效选择"; exit 1 ;;
esac

echo "Lua 库构建完成，输出目录: $BUILD_DIR"
