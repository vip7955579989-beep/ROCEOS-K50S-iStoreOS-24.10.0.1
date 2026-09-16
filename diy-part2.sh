#!/bin/bash
# =========================================================
# ROCEOS K50S (RK3568) - iStoreOS / OpenWrt diy-part2.sh
# =========================================================

# 1. 确保设备树（DTS）被多路径注入，防止内核构建阶段找不到 DTS
mkdir -p target/linux/rockchip/dts/
mkdir -p target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/
mkdir -p target/linux/rockchip/files-6.6/arch/arm64/boot/dts/rockchip/

cp -f rk3568-roc-k50s.dts target/linux/rockchip/dts/
cp -f rk3568-roc-k50s.dts target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/
cp -f rk3568-roc-k50s.dts target/linux/rockchip/files-6.6/arch/arm64/boot/dts/rockchip/

# 2. 清理 armv8.mk 中之前注入的旧定义，防止重复追加冲突
sed -i '/define Device\/roceos_roc-k50s/,/endef/d' target/linux/rockchip/image/armv8.mk
sed -i '/TARGET_DEVICES += roceos_roc-k50s/d' target/linux/rockchip/image/armv8.mk

# 3. 追加符合原生机制的设备定义（继承 Device/rk3568，不手动篡改打包流水线）
cat << 'EOF' >> target/linux/rockchip/image/armv8.mk

define Device/roceos_roc-k50s
  $(Device/rk3568)
  DEVICE_VENDOR := ROCEOS
  DEVICE_MODEL := K50S
  DEVICE_DTS := rk3568-roc-k50s
  DEVICE_PACKAGES := kmod-r8169 kmod-r8125
endef
TARGET_DEVICES += roceos_roc-k50s
EOF
