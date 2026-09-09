#!/system/bin/sh
# HapticMAX service: re-bind + HAL reload + props (respect user vibrate switch)
MODDIR=${0%/*}
LOG="$MODDIR/haptic_max.log"
STAGE="$MODDIR/stage"
SE=150; w=0
while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 1; w=$((w+1)); [ $w -ge $SE ] && { touch "$MODDIR/disable"; exit 0; }
done
echo "[$(date '+%F %T')] svc" >> "$LOG"
mkdir -p "$STAGE"
for f in "$MODDIR"/rtp/solid/*.bin; do
  [ -f "$f" ] || continue
  bn=$(basename "$f"); tgt="/odm/firmware/$bn"
  [ -f "$tgt" ] || continue
  ctx=$(ls -Z "$tgt" 2>/dev/null | awk '{print $1}')
  [ -z "$ctx" ] && ctx=u:object_r:vendor_file:s0
  cp -f "$f" "$STAGE/$bn"; chcon "$ctx" "$STAGE/$bn" 2>/dev/null; chmod 644 "$STAGE/$bn"
  mountpoint -q "$tgt" 2>/dev/null || mount -o ro,bind "$STAGE/$bn" "$tgt" 2>/dev/null
done
killall vendor.xiaomi.hardware.vibratorfeature.service 2>/dev/null
sleep 2
pidof vendor.xiaomi.hardware.vibratorfeature.service >/dev/null 2>&1 || start vendor.xiaomi.hardware.vibratorfeature.service 2>/dev/null
echo "hal=$(pidof vendor.xiaomi.hardware.vibratorfeature.service)" >> "$LOG"
RP=/data/adb/ksu/bin/resetprop
[ -x "$RP" ] || RP=/data/adb/magisk/magiskresetprop
[ -x "$RP" ] || RP=resetprop
command -v "$RP" >/dev/null 2>&1 && "$RP" -f "$MODDIR/system.prop"
# 不修改系统振动开关，由用户自行控制
D=$(find /sys/devices/platform/soc/9c0000.qcom,qupv3_i2c_geni_se/980000.i2c/i2c-0/0-0043/input -type d -name default 2>/dev/null | head -1)
[ -n "$D" ] || { D=$(find /sys -name f0_comp_enable 2>/dev/null | head -1); D=${D%/f0_comp_enable}; }
[ -n "$D" ] && { echo 1 > "$D/f0_comp_enable" 2>/dev/null; echo 1 > "$D/redc_comp_enable" 2>/dev/null; }
echo "[$(date '+%F %T')] done" >> "$LOG"
exit 0
