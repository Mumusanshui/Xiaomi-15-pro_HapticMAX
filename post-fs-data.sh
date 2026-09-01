#!/system/bin/sh
# HapticMAX - post-fs-data: sysfs 极限参数（HAL 启动前）
MODDIR=${0%/*}
sleep 1

# ===== 高通马达极限参数（cs40l26 0816）=====
if [ -d "/sys/class/qcom-haptics" ]; then
  echo 0 > /sys/class/qcom-haptics/lra_thermal_protect 2>/dev/null
  echo 0 > /sys/class/qcom-haptics/lra_safety_clip 2>/dev/null
  echo 9.9 > /sys/class/qcom-haptics/lra_amplitude_max 2>/dev/null
  echo 0 > /sys/class/qcom-haptics/lra_current_limit 2>/dev/null
  echo 155 > /sys/class/qcom-haptics/lra_frequency_hz 2>/dev/null
fi

# ===== 设备节点权限 =====
chmod 0666 /dev/qcom_haptic 2>/dev/null
chown system system /dev/qcom_haptic 2>/dev/null

exit 0
