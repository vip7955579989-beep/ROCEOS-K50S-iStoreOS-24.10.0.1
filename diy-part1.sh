#!/bin/bash
# Description: OpenWrt DIY script part 1 (Add custom feeds)

# 添加 iStore 官方应用商店与其依赖源
sed -i '$a src-git istore https://github.com/linkease/istore;main' feeds.conf.default
sed -i '$a src-git nas https://github.com/linkease/nas-packages;master' feeds.conf.default
sed -i '$a src-git nas_luci https://github.com/linkease/nas-packages-luci;main' feeds.conf.default
