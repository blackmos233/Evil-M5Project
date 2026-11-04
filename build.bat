@echo off
chcp 65001 >nul
echo ========================================================
echo       Evil-Cardputer 固件自动编译与一键打包脚本
echo ========================================================

set PROJECT_DIR=%~dp0
cd /d "%PROJECT_DIR%"

echo [1/3] 正在启动 PlatformIO 进行增量/全量编译...
pio run
if %ERRORLEVEL% neq 0 (
    echo [错误] 固件编译失败，请检查上方报错信息。
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2/3] 正在导出独立应用固件...
if not exist "binaries" mkdir "binaries"
copy /y ".pio\build\cardputer-cn\firmware.bin" "binaries\Evil-Cardputer-v1-5-7-CN.bin" >nul

echo.
echo [3/3] 正在合成 0x0 起始的完整合流镜像包...
python -m esptool --chip esp32s3 merge_bin -o "binaries\Evil-Cardputer-v1-5-7-CN-merged.bin" 0x0 ".pio\build\cardputer-cn\bootloader.bin" 0x8000 ".pio\build\cardputer-cn\partitions.bin" 0x10000 ".pio\build\cardputer-cn\firmware.bin"

echo.
echo ========================================================
echo [成功] 固件构建与导出完成！产物位于 binaries\ 目录：
echo   - binaries\Evil-Cardputer-v1-5-7-CN.bin        (M5Launcher / OTA 0x10000)
echo   - binaries\Evil-Cardputer-v1-5-7-CN-merged.bin (esptool 直刷 0x0)
echo ========================================================
pause
