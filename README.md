# ROCEOS K50S - iStoreOS 24.10 Custom Build

针对 ROCEOS K50S（瑞芯微 RK3568 芯片、3× RTL8125BG 2.5G 网卡、2× RTL8211FS 光电复用千兆网卡）专属定制的 iStoreOS 24.10（Linux 6.6 内核）全自动云端编译工程。

## 硬件特性匹配
* **SoC**: Rockchip RK3568 (4-Core Cortex-A55 @ 2.0GHz, ARM64)
* **LAN 网口**: 左起 3 个 2.5G 电口 (`eth0`, `eth1`, `eth2`)
* **WAN 网口**: 上下 2 个千兆 SFP / 电复用口 (`eth3`, `eth4`)
* **无线模块**: 正基 AP6255 双频 WiFi (2.4G+5G) + 蓝牙 4.0
* **存储支持**: M.2 NVMe SSD + 2.5寸 SATA HDD + eMMC
* **默认后台 IP**: `192.168.100.1` (账号: `root`，密码: `password`)

## 使用方法
1. 进入 GitHub 仓库页面。
2. 点击 **Actions** -> **Build iStoreOS 24.10 for ROCEOS K50S**。
3. 点击 **Run workflow** 即可全自动开始编译。
4. 编译完成后在 **Artifacts** 或 **Releases** 下载生成的固件刷机包。
