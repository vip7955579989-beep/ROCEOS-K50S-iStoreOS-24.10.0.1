#!/bin/bash
# =========================================================
# ROCEOS K50S (RK3568) - iStoreOS diy-part2.sh
# =========================================================

# 0. 自动定位工作区根目录
BASE_DIR="${GITHUB_WORKSPACE:-..}"

# 1. 确保设备树被注入到所有内核检索路径
mkdir -p target/linux/rockchip/dts/
mkdir -p target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/
mkdir -p target/linux/rockchip/files-6.6/arch/arm64/boot/dts/rockchip/

if [ -d "$BASE_DIR/patches" ]; then
  cp -f "$BASE_DIR/patches/rk3568-roc-k50s".* target/linux/rockchip/dts/ 2>/dev/null || true
  cp -f "$BASE_DIR/patches/rk3568-roc-k50s".* target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/ 2>/dev/null || true
  cp -f "$BASE_DIR/patches/rk3568-roc-k50s".* target/linux/rockchip/files-6.6/arch/arm64/boot/dts/rockchip/ 2>/dev/null || true
fi

# 2. 注入 U-Boot 引导镜像
mkdir -p staging_dir/target-aarch64_generic_musl/image/
mkdir -p bin/targets/rockchip/armv8/

UBOOT_BIN=""
if [ -f "$BASE_DIR/k50s-rk3568-u-boot-rockchip.bin" ]; then
  UBOOT_BIN="$BASE_DIR/k50s-rk3568-u-boot-rockchip.bin"
elif [ -f "k50s-rk3568-u-boot-rockchip.bin" ]; then
  UBOOT_BIN="k50s-rk3568-u-boot-rockchip.bin"
fi

if [ -n "$UBOOT_BIN" ]; then
  echo "Injecting U-Boot from $UBOOT_BIN"
  cp -vf "$UBOOT_BIN" staging_dir/target-aarch64_generic_musl/image/k50s-rk3568-u-boot-rockchip.bin
  cp -vf "$UBOOT_BIN" staging_dir/target-aarch64_generic_musl/image/k50s-rk3568-u-boot.bin
  cp -vf "$UBOOT_BIN" bin/targets/rockchip/armv8/k50s-rk3568-u-boot-rockchip.bin || true
fi

# 3. 清理旧设备定义，避免重复追加
sed -i '/define Device\/roceos_k50s/,/endef/d' target/linux/rockchip/image/armv8.mk
sed -i '/define Device\/roceos_roc-k50s/,/endef/d' target/linux/rockchip/image/armv8.mk
sed -i '/TARGET_DEVICES += roceos_k50s/d' target/linux/rockchip/image/armv8.mk
sed -i '/TARGET_DEVICES += roceos_roc-k50s/d' target/linux/rockchip/image/armv8.mk

# 4. 注入与 .config 严格对齐的设备定义
cat << 'EOF' >> target/linux/rockchip/image/armv8.mk
define Device/roceos_k50s
  $(Device/rk3568)
  DEVICE_VENDOR := ROCEOS
  DEVICE_MODEL := K50S
  DEVICE_DTS := rockchip/rk3568-roc-k50s
  UBOOT_DEVICE_NAME := k50s-rk3568
  DEVICE_PACKAGES := kmod-r8125 kmod-r8169 kmod-phy-realtek kmod-usb-storage kmod-usb-storage-uas
endef
TARGET_DEVICES += roceos_k50s
EOF
