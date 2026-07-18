#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] 删除 BBR 配置..."
rm -f /etc/sysctl.d/999-net-bbr-fq.conf

echo "[2/4] 恢复 /etc/sysctl.conf ..."
LATEST=$(ls -t /etc/sysctl.conf.bak.* 2>/dev/null | head -1 || true)
if [ -n "$LATEST" ]; then
    cp -af "$LATEST" /etc/sysctl.conf
    echo "已恢复: $LATEST"
else
    echo "没有找到备份，跳过"
fi

echo "[3/4] 恢复 /etc/sysctl.d 配置..."
find /etc/sysctl.d -maxdepth 1 -name "*.bak.*" | while read -r f; do
    mv "$f" "${f%.bak.*}"
    echo "恢复: ${f%.bak.*}"
done

echo "[4/4] 重新加载 sysctl..."
sysctl --system

echo
echo "===== 当前状态 ====="
sysctl net.ipv4.tcp_congestion_control
sysctl net.core.default_qdisc
echo "===================="
