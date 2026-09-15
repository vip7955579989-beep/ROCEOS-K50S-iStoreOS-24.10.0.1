#!/bin/bash
# Description: OpenWrt DIY script part 2 (After Update feeds)

# 1. 修改默认管理后台 IP 为 192.168.0.254
sed -i 's/192.168.100.1/192.168.0.254/g' package/base-files/files/bin/config_generate || true
sed -i 's/192.168.1.1/192.168.0.254/g' package/base-files/files/bin/config_generate || true

# 2. 注入 DTS 设备树（严格仅放入 rockchip 厂商目录）
echo "Copying DTS files..."
mkdir -p target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/
cp -f $GITHUB_WORKSPACE/patches/rk3568-roc-k50s.* target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/

# 3. 预先注入 U-Boot 引导固件（适配各种打包命名的别名）
mkdir -p staging_dir/target-aarch64_generic_musl/image/
if [ -f "$GITHUB_WORKSPACE/k50s-rk3568-u-boot-rockchip.bin" ]; then
    cp -f "$GITHUB_WORKSPACE/k50s-rk3568-u-boot-rockchip.bin" staging_dir/target-aarch64_generic_musl/image/k50s-rk3568-u-boot-rockchip.bin
    cp -f "$GITHUB_WORKSPACE/k50s-rk3568-u-boot-rockchip.bin" staging_dir/target-aarch64_generic_musl/image/k50s-rk3568-u-boot.bin
    cp -f "$GITHUB_WORKSPACE/k50s-rk3568-u-boot-rockchip.bin" staging_dir/target-aarch64_generic_musl/image/k50s-rk3568-boot.bin
fi

# 4. 在 armv8.mk 中添加 ROCEOS K50S 设备定义与必备驱动
if ! grep -q "Device/roceos_k50s" target/linux/rockchip/image/armv8.mk; then
cat >> target/linux/rockchip/image/armv8.mk << 'EOF'

define Device/roceos_k50s
  DEVICE_VENDOR := ROCEOS
  DEVICE_MODEL := K50S
  SOC := rk3568
  DEVICE_DTS := rockchip/rk3568-roc-k50s
  UBOOT := k50s-rk3568
  IMAGE/sysupgrade.img.gz := boot-common | boot-combine | check-size | gzip | append-metadata
  DEVICE_PACKAGES := kmod-r8125 kmod-r8169 kmod-phy-realtek kmod-usb-storage kmod-usb-storage-uas
endef
TARGET_DEVICES += roceos_k50s
EOF
fi
