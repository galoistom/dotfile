#!/bin/sh

# 检查当前活动的配置文件
PROFILE=$(powerprofilesctl get)

# 根据配置文件输出图标和文本
case "$PROFILE" in
    "performance")
        # 性能模式：红色图标
        echo "%{F#ff0000}Perf"  
        ;;
    "balanced")
        echo "Bal"
        ;;
    "power-saver")
        echo "%{F#2ecc71}Save"
        ;;
    *)
        # 未知模式
        echo " Unknown"
        ;;
esac
