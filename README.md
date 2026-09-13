# ROCEOS K50S - iStoreOS 24.10 Custom Build

针对 ROCEOS K50S（瑞芯微 RK3568 芯片、3× RTL8125BG 2.5G 电口、2× RTL8211FS 千兆 SFP 双层光口）专属定制的 iStoreOS 24.10（Linux 6.6 内核）全自动云端编译工程。

## 硬件特性匹配

- **SoC**: Rockchip RK3568 (4-Core Cortex-A55 @ 2.0GHz, ARM64)
- **LAN 网口**: 左起 3 个 2.5G 电口 (ETH0, ETH1, ETH2)
- **SFP 光口**: 上下堆叠 2 个千兆 SFP 光口 (上层 ETH3, 下层 ETH4)
- **调试接口**: RJ45 Console 串口 (UART2 @ 1500000)
- **无线模块**: 正基 AP6255 双频 WiFi (2.4G+5G) + 蓝牙 4.0
- **存储支持**: 板载 eMMC + TF卡槽 + 2.5寸 SATA
- **出厂默认 IP**: 192.168.0.254 (账号: root , 密码: password)

## 使用方法

1. 进入 GitHub 仓库页面。
2. 点击 *Actions* -> *Build iStoreOS 24.10 for ROCEOS K50S*。
3. 点击 *Run workflow* 即可全自动开始编译。
4. 编译完成后在 *Artifacts* 或 *Releases* 下载生成的固件刷机包。
