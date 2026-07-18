#!/bin/bash
#
# BBR + FQ 调优状态检查脚本
# Author: XiaoDian / ChatGPT
# Date: 2025-09-22
#

set -e

echo "===== BBR + FQ 状态检查 ====="

# 默认网卡
default_iface=$(ip route show default | awk '{print $5}' | head -n1)
echo "默认网卡: $default_iface"

# TCP 拥塞控制算法
echo -n "TCP 拥塞控制算法: "
sysctl -n net.ipv4.tcp_congestion_control

# 默认队列调度器
echo -n "默认队列调度器(qdisc): "
sysctl -n net.core.default_qdisc

# 网卡 qdisc 状态
if command -v tc >/dev/null 2>&1; then
    echo "网卡 $default_iface qdisc 状态:"
    tc qdisc show dev "$default_iface" || echo "无法获取 qdisc 状态"
else
    echo "tc 命令不存在，无法显示网卡 qdisc 状态"
fi

# 缓冲区参数
echo -n "net.core.rmem_max: "; sysctl -n net.core.rmem_max
echo -n "net.core.wmem_max: "; sysctl -n net.core.wmem_max
echo -n "net.ipv4.tcp_rmem: "; sysctl -n net.ipv4.tcp_rmem
echo -n "net.ipv4.tcp_wmem: "; sysctl -n net.ipv4.tcp_wmem

# 检查 BBR 模块是否加载
echo -n "BBR 模块状态: "
if lsmod | grep -q '^tcp_bbr'; then
    echo "已加载"
else
    echo "未加载"
fi

echo "===== 检查完成 ====="
