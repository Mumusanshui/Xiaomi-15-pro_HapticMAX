#!/system/bin/sh
# HapticMAX 卸载清理：恢复官方设置 + 删除模块写入的 persist 属性

# ===== 恢复系统震动设置 =====
settings put system haptic_feedback_level 2
settings put system haptic_feedback_enabled 1
settings put system keyboard_vibration_enabled 1
settings put system vibrate_on 1
settings delete system haptic_feedback_infinite_intensity 2>/dev/null
settings delete system haptic_feedback_infinite_progress 2>/dev/null
settings delete system hardware_haptic_feedback_intensity 2>/dev/null
settings delete system notification_vibration_intensity 2>/dev/null
settings delete system alarm_vibration_intensity 2>/dev/null
settings delete system ring_vibration_intensity 2>/dev/null

# ===== 清理持久模式目录 =====
rm -rf /data/adb/haptic_max

# ===== 清理 persist 属性 =====
for p in \
  persist.vendor.haptic.boost_enable \
  persist.vendor.haptic.high_power_mode \
  persist.vendor.haptic.force_max_gain \
  persist.vendor.haptic.dynamic_clip_enable \
  persist.vendor.haptic.impedance_auto_adjust \
  persist.vendor.haptic.f0_auto_limit \
  persist.mihaptic.force_unlock_max \
  persist.mihaptic.short_pulse_boost \
  persist.mihaptic.long_vib_boost \
  persist.sys.haptic_feedback_level
do
  resetprop --delete "$p" 2>/dev/null
done

exit 0
