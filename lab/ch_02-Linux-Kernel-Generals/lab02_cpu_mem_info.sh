#!/bin/bash
# ============================================================
# Lab 02: /proc/cpuinfo & /proc/meminfo — K8s 노드 정보
# ============================================================

set -e

C_TITLE="\033[1;34m"
C_SEC="\033[1;36m"
C_OK="\033[1;32m"
C_WARN="\033[1;33m"
C_ERR="\033[1;31m"
C_CMD="\033[0;37m"
C_RESET="\033[0m"

echo ""
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
echo -e "${C_TITLE}  Lab 02: CPU & 메모리 정보 확인${C_RESET}"
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
echo ""

# ── 1. CPU 정보 ──────────────────────────────────────────────
echo -e "${C_SEC}[1] /proc/cpuinfo — 핵심 항목${C_RESET}"
echo ""
grep -E '^(processor|model name|cpu cores|siblings)' /proc/cpuinfo | head -8
echo ""

LOGICAL=$(grep -c '^processor' /proc/cpuinfo)
CORES=$(grep -m1 'cpu cores' /proc/cpuinfo | awk '{print $NF}')
SIBLINGS=$(grep -m1 'siblings' /proc/cpuinfo | awk '{print $NF}')

echo -e "  ${C_WARN}해석:${C_RESET}"
echo -e "  ${C_OK}논리 CPU: ${LOGICAL}개${C_RESET} (= kubectl describe node의 cpu: ${LOGICAL})"
echo -e "  ${C_CMD}물리 코어: ${CORES}개 × 하이퍼스레딩 = siblings ${SIBLINGS}${C_RESET}"
if grep -q 'hypervisor' /proc/cpuinfo; then
    echo -e "  ${C_OK}flags에 'hypervisor' 있음 → VM(EC2) 위에서 동작 중${C_RESET}"
fi
echo ""

# ── 2. 메모리 정보 ───────────────────────────────────────────
echo -e "${C_SEC}[2] /proc/meminfo — 핵심 항목${C_RESET}"
echo ""
grep -E '^(MemTotal|MemAvailable|MemFree|SwapTotal)' /proc/meminfo
echo ""

MEM_TOTAL_KB=$(grep '^MemTotal' /proc/meminfo | awk '{print $2}')
MEM_TOTAL_GIB=$(echo "scale=2; $MEM_TOTAL_KB / 1024 / 1024" | bc)
SWAP=$(grep '^SwapTotal' /proc/meminfo | awk '{print $2}')

echo -e "  ${C_WARN}해석:${C_RESET}"
echo -e "  ${C_CMD}MemTotal: ${MEM_TOTAL_GIB} GiB (4GB에서 커널 예약분 차감)${C_RESET}"
if [ "$SWAP" = "0" ]; then
    echo -e "  ${C_OK}SwapTotal: 0 ← swap off 확인 (K8s 필수) ✅${C_RESET}"
else
    echo -e "  ${C_ERR}SwapTotal: ${SWAP} kB ← ⚠️ swap이 켜져 있음! swapoff -a 필요${C_RESET}"
fi
echo -e "  ${C_CMD}MemFree ≠ MemAvailable: kubelet은 MemAvailable 기준으로 eviction 판단${C_RESET}"
echo ""
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
echo -e "${C_OK}  Lab 02 완료 ✅${C_RESET}"
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
