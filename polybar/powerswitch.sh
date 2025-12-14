#!/bin/bash

# 获取当前电源模式
get_current_mode() {
    powerprofilesctl get
}

# 设置电源模式
set_power_mode() {
    powerprofilesctl set "$1"
}

# 循环切换模式
toggle_power_mode() {
    CURRENT_MODE=$(get_current_mode)
    case "$CURRENT_MODE" in
        performance)
            set_power_mode balanced
            ;;
        balanced)
            set_power_mode power-saver
            ;;
        power-saver)
            set_power_mode performance
            ;;
        *)
            # 默认设置为 balanced，以防出现未知状态
            set_power_mode balanced
            ;;
    esac
}

# 输出到 Polybar
output_polybar() {
    CURRENT_MODE=$(get_current_mode)
    ICON=""
    TOOLTIP=""

    case "$CURRENT_MODE" in
        performance)
            ICON="⚡" # ⚡ 或  (性能图标)
            TOOLTIP="性能模式"
            ;;
        balanced)
            ICON="" # ⚖️ 或  (均衡图标)
            TOOLTIP="均衡模式"
            ;;
        power-saver)
            ICON="parrow-alt" # sp (省电图标)
            TOOLTIP="省电模式"
            ;;
        *)
            ICON="question-circle"
            TOOLTIP="未知电源模式"
            ;;
    esac

    echo "$ICON $TOOLTIP"
}

# 主逻辑
case "$1" in
    toggle)
        toggle_power_mode
        ;;
    set_performance)
        set_power_mode performance
        ;;
    set_balanced)
        set_power_mode balanced
        ;;
    set_power_saver)
        set_power_mode power-saver
        ;;
    *)
        # 默认是输出当前状态
        ;;
esac

output_polybar
