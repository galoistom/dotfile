#!/bin/sh

# 检查当前活动的配置文件
PROFILE=$(powerprofilesctl get)

# 根据配置文件输出图标和文本
case "$PROFILE" in
    "performance")
        # 性能模式：红色图标
        echo "Perf"  
        ;;
    "balanced")
        # 平衡模式：绿色图标 (通常是默认)
        echo "%{F#99ccff}Bal"
        ;;
    "power-saver")
        # 节能模式：蓝色图标
        echo "%{F#2ecc71}Save"
        ;;
    *)
        # 未知模式
        echo " Unknown"
        ;;
esac
