#!/bin/bash
# =========================================================
# ROCEOS K50S (RK3568) - iStoreOS diy-part2.sh
# =========================================================

# 1. 确保设备树（DTS 和 DTSI）覆盖注入到所有可能的直属与子目录路径
mkdir -p target/linux/rockchip/dts/
mkdir -p target/linux/rockchip/files/arch/arm64/boot/dts/
mkdir -p target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/
mkdir -p target/linux/rockchip/files-6.6/arch/arm64/boot/dts/
mkdir -p target/linux/rockchip/files-6.6/arch/arm64/boot/dts/rockchip/

cp -f "$GITHUB_WORKSPACE/patches/rk3568-roc-k50s".* target/linux/rockchip/dts/ 2>/dev/null || true
cp -f "$GITHUB_WORKSPACE/patches/rk3568-roc-k50s".* target/linux/rockchip/files/arch/arm64/boot/dts/
cp -f "$GITHUB_WORKSPACE/patches/rk3568-roc-k50s".* target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/
cp -f "$GITHUB_WORKSPACE/patches/rk3568-roc-k50s".* target/linux/rockchip/files-6.6/arch/arm64/boot/dts/
cp -f "$GITHUB_WORKSPACE/patches/rk3568-roc-k50s".* target/linux/rockchip/files-6.6/arch/arm64/boot/dts/rockchip/

# 2. 清理旧设备定义（同时清理两种名字，防止冲突）
sed -i '/define Device\/roceos_k50s/,/endef/d' target/linux/rockchip/image/armv8.mk
sed -i '/define Device\/roceos_roc-k50s/,/endef/d' target/linux/rockchip/image/armv8.mk
sed -i '/TARGET_DEVICES += roceos_k50s/d' target/linux/rockchip/image/armv8.mk
sed -i '/TARGET_DEVICES += roceos_roc-k50s/d' target/linux/rockchip/image/armv8.mk

# 3. 注入与 .config 完全一致的设备定义（继承 $(Device/rk3568)，名字对齐 roceos_k50s）
cat << 'EOF' >> target/linux/rockchip/image/armv8.mk

define Device/roceos_k50s
  $(Device/rk3568)
  DEVICE_VENDOR := ROCEOS
  DEVICE_MODEL := K50S
  DEVICE_DTS := rk3568-roc-k50s
  DEVICE_PACKAGES := kmod-r8169 kmod-r8125
endef
TARGET_DEVICES += roceos_k50s
EOF