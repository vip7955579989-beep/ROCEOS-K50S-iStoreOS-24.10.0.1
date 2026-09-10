#!/bin/bash
# Description: OpenWrt DIY script part 2 (Device injection and customization)

# 1. 修改默认管理后台 IP 为 192.168.100.1
sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# 2. 注入 ROCEOS K50S DTS 与 DTSI
mkdir -p target/linux/rockchip/dts/rockchip
mkdir -p target/linux/rockchip/dts/rk3568
cp -f $GITHUB_WORKSPACE/patches/rk3568-roc-k50s.dts target/linux/rockchip/dts/rockchip/rk3568-roceos-k50s.dts 2>/dev/null || true
cp -f $GITHUB_WORKSPACE/patches/rk3568-roc-k50s.dtsi target/linux/rockchip/dts/rockchip/rk3568-roceos-k50s.dtsi 2>/dev/null || true
cp -f $GITHUB_WORKSPACE/patches/rk3568-roc-k50s.dts target/linux/rockchip/dts/rk3568/rk3568-roceos-k50s.dts 2>/dev/null || true
cp -f $GITHUB_WORKSPACE/patches/rk3568-roc-k50s.dtsi target/linux/rockchip/dts/rk3568/rk3568-roceos-k50s.dtsi 2>/dev/null || true

# 3. 在 target/linux/rockchip/image/armv8.mk 中注册 ROCEOS K50S 设备定义
if ! grep -q "define Device/roceos_k50s" target/linux/rockchip/image/armv8.mk; then
cat << 'DEVICE_EOF' >> target/linux/rockchip/image/armv8.mk

define Device/roceos_k50s
  DEVICE_VENDOR := ROCEOS
  DEVICE_MODEL := K50S
  SOC := rk3568
  DEVICE_DTS := rockchip/rk3568-roceos-k50s
  DEVICE_PACKAGES := kmod-r8125 kmod-nvme kmod-scsi-core kmod-ata-ahci kmod-brcmfmac brcmfmac-firmware-43455-sdio
endef
TARGET_DEVICES += roceos_k50s
DEVICE_EOF
fi

# 4. 在 02_network 中配置 ROCEOS K50S 的 5 网口精准映射
NETWORK_FILE="target/linux/rockchip/armv8/base-files/etc/board.d/02_network"
if [ -f "$NETWORK_FILE" ] && ! grep -q "roceos,k50s" "$NETWORK_FILE"; then
    sed -i '/rockchip_setup_interfaces()/a 	roceos,k50s)		ucidef_set_network_device_path eth0 "platform/3c0400000.pcie/pci0001:10/0001:10:00.0/0001:11:00.0"		ucidef_set_network_device_path eth1 "platform/3c0800000.pcie/pci0002:20/0002:20:00.0/0002:21:00.0"		ucidef_set_network_device_path eth2 "platform/3c0000000.pcie/pci0000:00/0000:00:00.0/0000:01:00.0"		ucidef_set_interfaces_lan_wan "eth0 eth1 eth2" "eth3"		;;' "$NETWORK_FILE"
fi
