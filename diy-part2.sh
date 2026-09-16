#!/bin/bash
# =========================================================
# ROCEOS K50S (RK3568) - iStoreOS diy-part2.sh (合并优化版)
# =========================================================

# 0. 自动定位工作区根目录
BASE_DIR="${GITHUB_WORKSPACE:-..}"

# 1. 调整 uhttpd 端口，防止与 iStoreOS/Nginx 默认 80/443 端口冲突
sed -i "s/:80/:81/g" package/network/services/uhttpd/files/uhttpd.config 2>/dev/null || true
sed -i "s/:443/:4443/g" package/network/services/uhttpd/files/uhttpd.config 2>/dev/null || true

# 2. 注入网络与系统初始化配置（来自 configfiles/etc）
if [ -d "$BASE_DIR/configfiles/etc" ]; then
    mkdir -p package/base-files/files/etc/
    cp -rf "$BASE_DIR/configfiles/etc/"* package/base-files/files/etc/
fi

# 3. 追加内核配置（开启 PSI 监控与 KPROBES，iStore 商店和 Docker 必须）
mkdir -p target/linux/rockchip/armv8/
echo "CONFIG_PSI=y" >> target/linux/rockchip/armv8/config-6.6
echo "CONFIG_KPROBES=y" >> target/linux/rockchip/armv8/config-6.6

# 4. 确保 K50S 设备树注入到内核检索路径（RK3568 专用）
mkdir -p target/linux/rockchip/dts/
mkdir -p target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/
mkdir -p target/linux/rockchip/files-6.6/arch/arm64/boot/dts/rockchip/

if [ -d "$BASE_DIR/patches" ]; then
    cp -f "$BASE_DIR/patches/rk3568-roc-k50s".* target/linux/rockchip/dts/ 2>/dev/null || true
    cp -f "$BASE_DIR/patches/rk3568-roc-k50s".* target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/ 2>/dev/null || true
    cp -f "$BASE_DIR/patches/rk3568-roc-k50s".* target/linux/rockchip/files-6.6/arch/arm64/boot/dts/rockchip/ 2>/dev/null || true
fi

# 5. 注入专用 U-Boot 引导镜像
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

# 6. 清理旧设备定义，避免重复追加导致编译冲突
sed -i '/define Device\/roceos_k50s/,/endef/d' target/linux/rockchip/image/armv8.mk
sed -i '/define Device\/roceos_roc-k50s/,/endef/d' target/linux/rockchip/image/armv8.mk
sed -i '/TARGET_DEVICES += roceos_k50s/d' target/linux/rockchip/image/armv8.mk
sed -i '/TARGET_DEVICES += roceos_roc-k50s/d' target/linux/rockchip/image/armv8.mk

# 7. 写入 K50S 镜像打包目标（关联专用设备树与驱动）
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

# 8. 拉取 iStoreOS 核心设置与可选插件
git clone --depth=1 -b main https://github.com/xiaomeng9597/istoreos-settings package/default-settings 2>/dev/null || true
git clone --depth=1 https://github.com/sirpdboy/luci-app-eqosplus package/luci-app-eqosplus 2>/dev/null || true
