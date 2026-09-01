# HapticMAX

小米 15 Pro（0816 X轴线性马达）全局震感增强模块。

## 生效参数

经完整实测，真正对振动强度起作用的参数仅以下几项，本模块已全部拉满：

- `vendor.haptic.force_skip_cal=1` — 跳过马达校准，满功率运行（核心）
- `persist.vendor.haptic.force_max_gain=9.9` — 硬件增益上限（核心）
- `persist.vendor.haptic.high_power_mode=1` — 高功率模式
- `persist.vendor.haptic.boost_enable=1` — 增益增强
- `persist.sys.haptic_feedback_level=5` — 系统触感级别

## 已验证无效的参数

以下参数经实测对振动**无任何影响**，修改不会带来变化：

- AIHaptic 系列（transient/continuous intensity、sharpness）
- `Hapticsconfig.xml` 中的 PWL 参数与 `pulse_intensity`
- `pcm_gain` / `pcm_max_gain`
- RTP bin / ACDB pcm 波形文件

因此本版为**精简验证版**：仅保留生效的属性配置，移除已证明无效的波形文件与切换脚本，刷机包体积约 5KB。

## 安装

1. 下载 `xiaomi15pro_haptic.zip`
2. 通过 Magisk / KernelSU 刷入
3. 重启手机生效

## 卸载

在 Magisk / KernelSU 中移除模块，重启即恢复官方振动。

## 注意

`system.prop` 为经过验证的完整原始配置——请勿随意删除其中的注释或参数，否则可能导致增强失效（实测精简后会明显减弱）。
