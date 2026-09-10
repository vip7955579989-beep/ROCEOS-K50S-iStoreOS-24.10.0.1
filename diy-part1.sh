#!/bin/bash
# Description: OpenWrt DIY script part 1 (Add custom feeds safely)

# 仅在不存在对应源时追加，防止 feeds update 时抛出 Duplicate feed name
grep -q "src-git istore" feeds.conf.default || echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default
grep -q "src-git nas " feeds.conf.default || echo 'src-git nas https://github.com/linkease/nas-packages;master' >> feeds.conf.default
grep -q "src-git nas_luci" feeds.conf.default || echo 'src-git nas_luci https://github.com/linkease/nas-packages-luci;main' >> feeds.conf.default
