#!/bin/bash
# Description: OpenWrt DIY script part 2 (Device injection and customization)

# 1. 修改默认管理后台 IP 为 192.168.100.1
sed -i 's/192.168.1.1/192.168.100.1/g' package/base-files/files/bin/config_generate

# 2. 注入 ROCEOS K50S DTS 与 DTSI
mkdir -p target/linux/rockchip/dts/rockchip
mkdir -p target/linux/rockchip/dts/rk3568

cp -f $GITHUB_WORKSPACE/patches/rk3568-roc-k50s.dts target/linux/rockchip/dts/rockchip/ 2>/dev/null || true
cp -f $GITHUB_WORKSPACE/patches/rk3568-roc-k50s.dtsi target/linux/rockchip/dts/rockchip/ 2>/dev/null || true
cp -f $GITHUB_WORKSPACE/patches/rk3568-roc-k50s.dts target/linux/rockchip/dts/rk3568/ 2>/dev/null || true
cp -f $GITHUB_WORKSPACE/patches/rk3568-roc-k50s.dtsi target/linux/rockchip/dts/rk3568/ 2>/dev/null || true

# 3. 在 target/linux/rockchip/image/armv8.mk 中注册 ROCEOS K50S 设备定义 (仅保留实际存在的 rk3568-roc-k50s)
if ! grep -q "define Device/roceos_k50s" target/linux/rockchip/image/armv8.mk; then
cat << 'DEVICE_EOF' >> target/linux/rockchip/image/armv8.mk

define Device/roceos_k50s
  DEVICE_VENDOR := ROCEOS
  DEVICE_MODEL := K50S
  SOC := rk3568
  DEVICE_DTS := rockchip/rk3568-roc-k50s
  DEVICE_PACKAGES := kmod-r8125 kmod-nvme kmod-scsi-core kmod-ata-ahci kmod-brcmfmac brcmfmac-firmware-43455
endef
TARGET_DEVICES += roceos_k50s
DEVICE_EOF
fi

# 4. 配置 5 网口映射 (LAN: 3x 2.5G 电口 eth0~eth2; WAN: 2x 千兆复用口 eth3~eth4)
for netfile in $(find target/linux/rockchip -name "02_network"); do
  if [ -f "$netfile" ] && ! grep -q "roceos,k50s" "$netfile"; then
    sed -i '/case "\$board" in/a\
roceos,k50s)\
\tucidef_set_interfaces_lan_wan "eth0 eth1 eth2" "eth3 eth4"\
\t;;' "$netfile" 2>/dev/null || true
  fi
done
