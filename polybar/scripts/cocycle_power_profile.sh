
#!/bin/sh

# 获取当前状态
PROFILE=$(powerprofilesctl get)

case "$PROFILE" in
    "balanced")
        # 如果当前是平衡模式，切换到性能模式
        powerprofilesctl set power-saver
        ;;
    "performance")
        # 如果当前是性能模式，切换到节能模式
        powerprofilesctl set balanced
        ;;
    "power-saver")
        # 如果当前是节能模式，切换到平衡模式
        powerprofilesctl set performance
        ;;
    *)
        # 默认回退到平衡模式
        powerprofilesctl set balanced
        ;;
esac

# 强制 Polybar 刷新，立即显示新的状态
# 查找 Polybar 进程并发送 USR1 信号（用于立即刷新模块）
#killall -SIGUSR1 polybar
