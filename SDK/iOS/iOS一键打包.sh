#!/bin/bash
# ==================================================
# iOS 自动打包工具链（自动筛选可用模式 + 自动签名 + 自动命名 IPA）
# ==================================================

# ---------------- 配置 ----------------
PROJECT_PATH="workspace/MyApp.xcodeproj"   # 或 .xcworkspace
SCHEME="MyApp"
CONFIGURATION="Release"
ARCHIVE_PATH="workspace/build/MyApp.xcarchive"
EXPORT_PATH="workspace/build/ipa"
TEAM_ID="YOUR_TEAM_ID"

# ---------------- 检测本地证书 ----------------
echo "检测本地证书..."
DEV_CERT=$(security find-identity -v -p codesigning | grep "iPhone Developer" | head -n1 | awk -F\" '{print $2}')
ADHOC_CERT=$(security find-identity -v -p codesigning | grep "iPhone Distribution" | head -n1 | awk -F\" '{print $2}')
APPSTORE_CERT=$(security find-identity -v -p codesigning | grep "iPhone Distribution" | head -n1 | awk -F\" '{print $2}')

# ---------------- 匹配描述文件 ----------------
echo "匹配描述文件..."
PROFILE_DIR=~/Library/MobileDevice/Provisioning\ Profiles
AVAILABLE_MODES=()

# 开发模式可用性
if [ -n "$DEV_CERT" ] && ls $PROFILE_DIR/*.mobileprovision 2>/dev/null | xargs grep -l "$DEV_CERT" >/dev/null 2>&1; then
    AVAILABLE_MODES+=("Development")
fi

# 测试模式可用性
if [ -n "$ADHOC_CERT" ] && ls $PROFILE_DIR/*.mobileprovision 2>/dev/null | xargs grep -l "$ADHOC_CERT" >/dev/null 2>&1; then
    AVAILABLE_MODES+=("AdHoc")
fi

# 正式模式可用性
if [ -n "$APPSTORE_CERT" ] && ls $PROFILE_DIR/*.mobileprovision 2>/dev/null | xargs grep -l "$APPSTORE_CERT" >/dev/null 2>&1; then
    AVAILABLE_MODES+=("AppStore")
fi

if [ ${#AVAILABLE_MODES[@]} -eq 0 ]; then
    echo "⚠️ 没有可用的证书或描述文件，无法打包"
    exit 1
fi

# ---------------- 用户选择模式 ----------------
echo "可用打包模式:"
for i in "${!AVAILABLE_MODES[@]}"; do
    echo "[$((i+1))] ${AVAILABLE_MODES[$i]}"
done
read -p "请选择模式: " CHOICE
INDEX=$((CHOICE-1))
MODE_NAME=${AVAILABLE_MODES[$INDEX]}

case $MODE_NAME in
    "Development")
        EXPORT_METHOD="development"
        SIGN_CERT="$DEV_CERT"
        ;;
    "AdHoc")
        EXPORT_METHOD="ad-hoc"
        SIGN_CERT="$ADHOC_CERT"
        ;;
    "AppStore")
        EXPORT_METHOD="app-store"
        SIGN_CERT="$APPSTORE_CERT"
        ;;
esac

# ---------------- 匹配描述文件 ----------------
PROFILE=$(ls $PROFILE_DIR/*.mobileprovision 2>/dev/null | xargs grep -l "$SIGN_CERT" | head -n1)
PROFILE_NAME=$(basename "$PROFILE" .mobileprovision)
echo "选择模式: $MODE_NAME"
echo "使用描述文件: $PROFILE_NAME"

# ---------------- 读取版本号 ----------------
INFO_PLIST="$PROJECT_PATH/Info.plist"
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFO_PLIST" 2>/dev/null)
[ -z "$VERSION" ] && VERSION="1.0"

# ---------------- 自动生成 IPA 文件名 ----------------
TIME_NOW=$(date +%Y%m%d_%H%M)
IPA_NAME="${SCHEME}_${MODE_NAME}_v${VERSION}_${TIME_NOW}.ipa"
echo "IPA 文件名: $IPA_NAME"

# ---------------- 生成 ExportOptions.plist ----------------
EXPORT_OPTIONS_PLIST="workspace/export_options.plist"
cat > $EXPORT_OPTIONS_PLIST <<EOL
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>method</key><string>$EXPORT_METHOD</string>
    <key>teamID</key><string>$TEAM_ID</string>
    <key>signingCertificate</key><string>$SIGN_CERT</string>
    <key>provisioningProfiles</key>
    <dict><key>$SCHEME</key><string>$PROFILE_NAME</string></dict>
    <key>compileBitcode</key><true/>
</dict>
</plist>
EOL

# ---------------- 清理旧构建 ----------------
rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"

# ---------------- 构建 xcarchive ----------------
if [[ "$PROJECT_PATH" == *.xcworkspace ]]; then
    xcodebuild clean -workspace "$PROJECT_PATH" -scheme "$SCHEME" -configuration "$CONFIGURATION"
    xcodebuild archive -workspace "$PROJECT_PATH" -scheme "$SCHEME" -configuration "$CONFIGURATION" -archivePath "$ARCHIVE_PATH" \
        CODE_SIGN_IDENTITY="$SIGN_CERT" PROVISIONING_PROFILE_SPECIFIER="$PROFILE_NAME"
else
    xcodebuild clean -project "$PROJECT_PATH" -scheme "$SCHEME" -configuration "$CONFIGURATION"
    xcodebuild archive -project "$PROJECT_PATH" -scheme "$SCHEME" -configuration "$CONFIGURATION" -archivePath "$ARCHIVE_PATH" \
        CODE_SIGN_IDENTITY="$SIGN_CERT" PROVISIONING_PROFILE_SPECIFIER="$PROFILE_NAME"
fi

[ $? -ne 0 ] && { echo "⚠️ 构建失败!"; exit 1; }

# ---------------- 导出 IPA ----------------
mkdir -p "$EXPORT_PATH"
xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportPath "$EXPORT_PATH" -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
    -allowProvisioningUpdates

# 重命名 IPA
mv "$EXPORT_PATH/$SCHEME.ipa" "$EXPORT_PATH/$IPA_NAME"

echo "✅ 打包完成!"
echo "IPA 路径: $EXPORT_PATH/$IPA_NAME"
