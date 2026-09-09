#!/system/bin/sh
MODDIR=${0%/*}
D=$(find /sys/devices/platform/soc/9c0000.qcom,qupv3_i2c_geni_se/980000.i2c/i2c-0/0-0043/input -type d -name default 2>/dev/null | head -1)
[ -n "$D" ] || exit 0
echo 1 > "$D/f0_comp_enable" 2>/dev/null
echo 1 > "$D/redc_comp_enable" 2>/dev/null
exit 0
