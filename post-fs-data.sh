#!/system/bin/sh
# HapticMAX post-fs-data — bind RTP BEFORE vibrator HAL starts
# 热加载强、重启弱：多半是 HAL 先缓存了原厂波形
MODDIR=${0%/*}
LOG="$MODDIR/haptic_max.log"
STAGE="$MODDIR/stage"
mkdir -p "$STAGE"
echo "[$(date '+%F %T')] post-fs-data" >> "$LOG"

for f in "$MODDIR"/rtp/solid/*.bin; do
  [ -f "$f" ] || continue
  bn=$(basename "$f")
  tgt="/odm/firmware/$bn"
  [ -f "$tgt" ] || continue
  ctx=$(ls -Z "$tgt" 2>/dev/null | awk '{print $1}')
  [ -z "$ctx" ] && ctx=u:object_r:vendor_file:s0
  cp -f "$f" "$STAGE/$bn"
  chcon "$ctx" "$STAGE/$bn" 2>/dev/null
  chmod 644 "$STAGE/$bn"
  if mount -o ro,bind "$STAGE/$bn" "$tgt" 2>/dev/null; then
    echo "pfd bind $bn" >> "$LOG"
  else
    echo "pfd bind FAIL $bn" >> "$LOG"
  fi
done

D=$(find /sys/devices/platform/soc/9c0000.qcom,qupv3_i2c_geni_se/980000.i2c/i2c-0/0-0043/input -type d -name default 2>/dev/null | head -1)
[ -n "$D" ] && { echo 1 > "$D/f0_comp_enable" 2>/dev/null; echo 1 > "$D/redc_comp_enable" 2>/dev/null; }

exit 0
