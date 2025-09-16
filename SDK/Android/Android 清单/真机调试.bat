E:
cd E:\android_NDK_SDK\android-sdk-windows\android-sdk-windows-28\tools
adb kill-server
adb forward tcp:34999 localabstract:Unity-com.jinke.mergeAnimal
@echo off
echo.&echo &pause>nul
@echo on
exit 