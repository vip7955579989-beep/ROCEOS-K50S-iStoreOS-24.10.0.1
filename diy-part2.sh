#!/bin/bash
# Description: OpenWrt DIY script part 2 (Device injection, U-Boot mapping and customization)

# 1. 修改默认管理后台 IP 为原厂标牌的 192.168.0.254 (出厂账号: root, 密码: password)
sed -i 's/192.168.1.1/192.168.0.254/g' package/base-files/files/bin/config_generate

# 2. 注入 ROCEOS K50S DTS 与 DTSI 到编译树
mkdir -p target/linux/rockchip/dts/rockchip
mkdir -p target/linux/rockchip/dts/rk3568
mkdir -p target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/

cp -f $GITHUB_WORKSPACE/patches/rk3568-roc-k50s.dts target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/ 2>/dev/null || true
cp -f $GITHUB_WORKSPACE/patches/rk3568-roc-k50s.dtsi target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/ 2>/dev/null || true
cp -f $GITHUB_WORKSPACE/patches/rk3568-roc-k50s.dts target/linux/rockchip/dts/rockchip/ 2>/dev/null || true
cp -f $GITHUB_WORKSPACE/patches/rk3568-roc-k50s.dtsi target/linux/rockchip/dts/rockchip/ 2>/dev/null || true
cp -f $GITHUB_WORKSPACE/patches/rk3568-roc-k50s.dts target/linux/rockchip/dts/rk3568/ 2>/dev/null || true
cp -f $GITHUB_WORKSPACE/patches/rk3568-roc-k50s.dtsi target/linux/rockchip/dts/rk3568/ 2>/dev/null || true

# 3. 在 target/linux/rockchip/image/armv8.mk 中注册 ROCEOS K50S 设备定义
# 指定 UBOOT 为 k50s-rk3568，与我们提取的 k50s-rk3568-u-boot-rockchip.bin 严格对齐
if ! grep -q "define Device/roceos_k50s" target/linux/rockchip/image/armv8.mk; then
cat << 'DEVICE_EOF' >> target/linux/rockchip/image/armv8.mk

define Device/roceos_k50s
  DEVICE_VENDOR := ROCEOS
  DEVICE_MODEL := K50S
  SOC := rk3568
  UBOOT := k50s-rk3568
  DEVICE_DTS := rk3568-roc-k50s
  SUPPORTED_DEVICES := roceos,k50s roceos,roc-k50s
  DEVICE_PACKAGES := kmod-r8125 kmod-r8169 kmod-nvme kmod-scsi-core kmod-ata-ahci kmod-brcmfmac brcmfmac-firmware-43455
endef
TARGET_DEVICES += roceos_k50s
DEVICE_EOF
fi

# 4. 配置 5 网口映射 (ETH0~ETH2 为 2.5G LAN 口; ETH3~ETH4 为千兆复用 WAN/LAN 口)
for netfile in $(find target/linux/rockchip -name "02_network"); do
  if [ -f "$netfile" ] && ! grep -q "roceos,k50s" "$netfile"; then
    sed -i '/case "\$board" in/a\
roceos,k50s | roceos,roc-k50s)\
\tucidef_set_interfaces_lan_wan "eth0 eth1 eth2" "eth3 eth4"\
\t;;' "$netfile" 2>/dev/null || true
  fi
done

# 5. 调整 RootFS 分区大小为 1024MB 并启用 ext4 输出 (防止打包空间不足)
sed -i 's/CONFIG_TARGET_ROOTFS_PARTSIZE=[0-9]*/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/g' .config 2>/dev/null || true
echo "CONFIG_TARGET_ROOTFS_PARTSIZE=1024" >> .config
echo "CONFIG_TARGET_ROOTFS_EXT4FS=y" >> .config
