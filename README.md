# 小米15Pro震感增强-HapticMAX

针对小米 15 Pro（haotian / 0816 X 轴线性马达 / Cirrus CS40L26A）的 Magisk / KernelSU 震感增强模块。

## 兼容性

| 项目 | 说明 |
|---|---|
| 机型 | 小米 15 Pro `haotian` / `2410DPN6CC` |
| 系统 | 已验证 **HyperOS 3.0**（`OS3.0.305.0.WOBCNXM`，Android 16） |
| Root | Magisk 或 KernelSU |
| HyperOS 4 | **未实测**。若 HAL 或 `/odm/firmware` 波形路径有变，可能需重新适配 |
| 其他机型 | 请勿刷入 |

## 安装

1. 下载 `xiaomi15pro_haptic.zip`
2. 在 Magisk / KernelSU 中刷入
3. 重启手机

## 卸载

在 Magisk / KernelSU 中移除模块并重启。  
模块只对 `/odm/firmware/*_P_RTP.bin` 做覆盖挂载（bind mount），**不写入分区**，卸载后即恢复原厂波形。`uninstall.sh` 会清理相关属性。

## 效果说明（相对 v1.0）

v1.0 部分配置写在了 15 Pro 上并不存在的路径上（如 `/sys/class/qcom-haptics`），因此体感提升有限。v1.1+ 按真机诊断重做：

| 场景 | 说明 |
|---|---|
| 桌面点击 / 重按 | 按 155Hz 谐振重做 RTP，更实 |
| 后台滑动卡片 | 保留原厂长度，增加能量 |
| 返回手势 / 上划后台 | 增强 `162` / `163` / `72` 专用波形 |
| 音量键 | 增强 `6` 波形 |
| 后台卡片下滑锁定 | 增强 `216` 波形 |
| 键盘打字 | 系统链路不读本模块 RTP，**无法通过本模块增强** |

主要手段：

1. 修正无效路径，改为 Cirrus CS40L26A 真实节点  
2. 打开 AIHaptic 总开关并调高交互相关参数  
3. 按 155Hz 合成 / 放大 RTP 波形  
4. bind mount 前 `chcon` 为 `vendor_file`，避免 HAL 因 SELinux 读失败而回退原厂  
5. 打开 CS40L26 的 F0 / Redc 驱动补偿  

## 注意

- 仅面向小米 15 Pro（haotian）
- 已验证 HyperOS 3.0；HyperOS 4 未实测，升级后请自行确认
- 波形幅度已接近满幅，长时间高频震动会发热，属正常现象
- 删除模块重启即可回退；刷入前建议备份
- 震动强度受马达行程与 HAL 限制，软件无法无限加大

## License

MIT
