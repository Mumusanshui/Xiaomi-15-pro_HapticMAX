#!/system/bin/sh
rm -rf /data/adb/haptic_max
settings put system haptic_feedback_level 2 2>/dev/null
for p in \
  persist.vendor.audio.vibrator.aihaptic \
  vendor.aihaptic.interaction.transient_intensity \
  vendor.aihaptic.interaction.transient_sharpness \
  vendor.aihaptic.interaction.continuous_intensity \
  vendor.aihaptic.interaction.continuous_sharpness \
  vendor.aihaptic.warn.transient_intensity \
  vendor.aihaptic.warn.transient_sharpness \
  vendor.aihaptic.warn.continuous_intensity \
  vendor.aihaptic.warn.continuous_sharpness \
  vendor.aihaptic.keyboard.intensity \
  vendor.aihaptic.notification.intensity \
  vendor.aihaptic.ring.intensity \
  vendor.aihaptic.alarm.intensity \
  persist.vendor.haptic.boost_enable \
  persist.vendor.haptic.high_power_mode \
  persist.vendor.haptic.force_max_gain \
  persist.vendor.haptic.dynamic_clip_enable \
  persist.vendor.haptic.impedance_auto_adjust \
  persist.vendor.haptic.f0_auto_limit \
  persist.vendor.haptic.auto_amp_limit \
  persist.vendor.haptic.pcm_gain \
  persist.vendor.haptic.pcm_max_gain \
  persist.mihaptic.force_unlock_max \
  persist.mihaptic.short_pulse_boost \
  persist.mihaptic.long_vib_boost \
  vendor.haptic.calibrate.done \
  vendor.haptic.force_skip_cal
do resetprop --delete "$p" 2>/dev/null; done
D=$(find /sys/devices/platform/soc/9c0000.qcom,qupv3_i2c_geni_se/980000.i2c/i2c-0/0-0043/input -type d -name default 2>/dev/null | head -1)
[ -n "$D" ] && { echo 0 > "$D/f0_comp_enable" 2>/dev/null; echo 0 > "$D/redc_comp_enable" 2>/dev/null; }
exit 0
