#!/system/bin/sh
# HapticMAX - 用 bind mount 直接挂载，不依赖 KSU/Hybrid Mount 的挂载系统
MODDIR=${0%/*}
LOG="$MODDIR/haptic_max.log"
echo "[$(date '+%F %T')] haptic_max service started" > "$LOG"

# ===== 系统启动超时自禁保护（防卡米）=====
SE=150; wsec=0
while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 1; wsec=$((wsec+1))
  [ $wsec -ge $SE ] && { touch "$MODDIR/disable"; exit 0; }
done

# ===== 读取当前风格 =====
MODE=$(cat /data/adb/haptic_max/mode 2>/dev/null || echo solid)
SRC="$MODDIR/webroot/assets/styles/$MODE"
[ -d "$SRC" ] || SRC="$MODDIR/webroot/assets/styles/solid"

# ===== bind mount 配置文件 =====
for f in \
  vendor/etc/Hapticsconfig.xml \
  vendor/etc/HapticsPolicy.xml \
  vendor/etc/aac_richtap.config \
  vendor/persist/haptics/user_cal.cfg \
  odm/etc/init/vendor.xiaomi.hardware.vibratorfeature.service.rc \
; do
  [ -f "$SRC/$f" ] && mount -o ro,bind "$SRC/$f" "/$f" 2>/dev/null
done

# ===== bind mount pcm 波形文件 =====
PCM_SRC="$SRC/vendor/etc/acdbdata/haptics_data"
if [ -d "$PCM_SRC" ]; then
  for f in "$PCM_SRC"/*.pcm; do
    [ -f "$f" ] && mount -o ro,bind "$f" "/vendor/etc/acdbdata/haptics_data/$(basename $f)" 2>/dev/null
  done
fi

# ===== bind mount bin 波形文件 =====
BIN_SRC="$SRC/odm/firmware"
if [ -d "$BIN_SRC" ]; then
  for f in "$BIN_SRC"/*.bin; do
    [ -f "$f" ] && mount -o ro,bind "$f" "/odm/firmware/$(basename $f)" 2>/dev/null
  done
fi

echo "[$(date '+%F %T')] bind mount applied mode=$MODE" >> "$LOG"

# ===== 应用系统属性增强 =====
sleep 2
RP=/data/adb/ksu/bin/resetprop
[ ! -x "$RP" ] && RP=resetprop
if command -v "$RP" >/dev/null 2>&1; then
  "$RP" -f "$MODDIR/system.prop"
fi

# ===== 系统设置层面拉满震动强度 =====
settings put system haptic_feedback_level 5
settings put system vibrate_on 1
settings put system haptic_feedback_enabled 1
settings put system keyboard_vibration_enabled 1

# ===== 直接写驱动节点（0816 谐振 155Hz）=====
[ -f /sys/class/qcom-haptics/lra_frequency_hz ] && echo 155 > /sys/class/qcom-haptics/lra_frequency_hz 2>/dev/null

# ===== 校准标记 =====
setprop vendor.haptic.calibrate.done 1
setprop vendor.haptic.force_skip_cal 1

echo "[$(date '+%F %T')] props+settings+freq applied" >> "$LOG"

# ===== AIHaptic 属性守护 =====
(
RP2=/data/adb/ksu/bin/resetprop
[ ! -x "$RP2" ] && RP2=resetprop
MODE=$(cat /data/adb/haptic_max/mode 2>/dev/null || echo solid)
case "$MODE" in
  crisp) AI_INT=900; AI_SHP=800 ;;
  *)     AI_INT=900; AI_SHP=600 ;;
esac
i=0
while [ $i -lt 6 ]; do
  "$RP2" vendor.aihaptic.interaction.transient_intensity $AI_INT
  "$RP2" vendor.aihaptic.interaction.transient_sharpness $AI_SHP
  "$RP2" vendor.aihaptic.interaction.continuous_intensity $AI_INT
  "$RP2" vendor.aihaptic.interaction.continuous_sharpness $AI_SHP
  "$RP2" vendor.aihaptic.warn.transient_intensity $AI_INT
  "$RP2" vendor.aihaptic.warn.transient_sharpness $AI_SHP
  "$RP2" vendor.aihaptic.warn.continuous_intensity $AI_INT
  "$RP2" vendor.aihaptic.warn.continuous_sharpness $AI_SHP
  i=$((i+1)); sleep 10
done
echo "[$(date '+%F %T')] aihaptic guard done" >> "$LOG"
) &

exit 0
