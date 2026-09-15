#!/bin/bash
# Description: OpenWrt DIY script part 2 (Configuration modification)

# 1. 统一管理后台 IP 为 192.168.0.254
sed -i 's/192.168.100.1/192.168.0.254/g' package/base-files/files/bin/config_generate || true
sed -i 's/192.168.1.1/192.168.0.254/g' package/base-files/files/bin/config_generate || true

# 2. 设备树注入到 rockchip 专用目录
mkdir -p target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/
cp -f patches/rk3568-roc-k50s.dts target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/ || true
cp -f patches/rk3568-roc-k50s.dtsi target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/ || true

# 3. U-Boot 多别名容错注入
mkdir -p staging_dir/target-aarch64_generic_musl/image/
mkdir -p bin/targets/rockchip/armv8/
if [ -f k50s-rk3568-u-boot-rockchip.bin ]; then
    cp -f k50s-rk3568-u-boot-rockchip.bin staging_dir/target-aarch64_generic_musl/image/k50s-rk3568-u-boot-rockchip.bin || true
    cp -f k50s-rk3568-u-boot-rockchip.bin staging_dir/target-aarch64_generic_musl/image/k50s-rk3568-u-boot.bin || true
    cp -f k50s-rk3568-u-boot-rockchip.bin staging_dir/target-aarch64_generic_musl/image/k50s-rk3568-boot.bin || true
fi

# 4. 修复 Missing Build/boot-combine 并注册 Device/roceos_k50s 板型定义
IMAGE_MAKEFILE="target/linux/rockchip/image/Makefile"
ARMV8_MAKEFILE="target/linux/rockchip/image/armv8.mk"

# 在 image/Makefile 中兜底补齐缺失的 Build/boot-combine 定义
if [ -f "$IMAGE_MAKEFILE" ]; then
    if ! grep -q "define Build/boot-combine" "$IMAGE_MAKEFILE"; then
        sed -i '1i define Build/boot-combine\n\t@true\nendef\n' "$IMAGE_MAKEFILE"
    fi
fi

# 在 armv8.mk 中注入标准设备定义
if [ -f "$ARMV8_MAKEFILE" ]; then
    # 若存在先前的 roceos_k50s 定义，先移除旧块防止重复追加
    sed -i '/define Device\/roceos_k50s/,/TARGET_DEVICES += roceos_k50s/d' "$ARMV8_MAKEFILE"

    cat << 'EOF' >> "$ARMV8_MAKEFILE"

define Device/roceos_k50s
  DEVICE_VENDOR := ROCEOS
  DEVICE_MODEL := K50S
  SOC := rk3568
  DEVICE_DTS := rockchip/rk3568-roc-k50s
  UBOOT_DEVICE_NAME := k50s-rk3568
  IMAGE/sysupgrade.img.gz := boot-common | boot-script | pine64-img | gzip | append-metadata
  DEVICE_PACKAGES := kmod-r8125 kmod-r8169 kmod-phy-realtek kmod-usb-storage kmod-usb-storage-uas
endef
TARGET_DEVICES += roceos_k50s
EOF
fi
