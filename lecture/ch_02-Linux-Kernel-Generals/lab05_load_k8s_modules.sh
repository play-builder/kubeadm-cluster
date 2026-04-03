#!/bin/bash
# ============================================================
# Lab 04: Core vs Module 구분
# ============================================================
set -e

C_TITLE="\033[1;34m"  C_SEC="\033[1;36m"  C_OK="\033[1;32m"
C_WARN="\033[1;33m"   C_CMD="\033[0;37m"  C_RESET="\033[0m"

echo ""
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
echo -e "${C_TITLE}  Lab 04: Core vs Module 구분${C_RESET}"
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
echo ""
echo -e "${C_WARN}  📘 Core   = 커널과 한 몸 (떼어낼 수 없음)${C_RESET}"
echo -e "${C_WARN}     Module = 필요할 때 붙이고 떼는 확장${C_RESET}"
echo -e "${C_WARN}     구분법: lsmod에 나타나면 Module, 안 나타나면 Core${C_RESET}"
echo ""

# ── 1 ────────────────────────────────────────────────────────
echo -e "${C_SEC}[1] 현재 커널 버전${C_RESET}"
echo -e "  ${C_OK}$(cat /proc/sys/kernel/osrelease)${C_RESET}"
echo ""

# ── 2 ────────────────────────────────────────────────────────
echo -e "${C_SEC}[2] Core 확인: cgroup${C_RESET}"
echo ""
echo -e "  ${C_WARN}📘 cgroup은 Core → lsmod에 안 나옴${C_RESET}"
echo ""
RESULT=$(lsmod | grep cgroup || true)
if [ -z "$RESULT" ]; then
    echo -e "  ${C_CMD}lsmod | grep cgroup → ${C_WARN}(출력 없음)${C_RESET}"
    echo -e "  ${C_OK}→ Core이므로 정상. 커널 바이너리에 내장.${C_RESET}"
fi
echo ""

# ── 3 ────────────────────────────────────────────────────────
echo -e "${C_SEC}[3] Core이지만 filesystem으로 노출됨${C_RESET}"
echo ""
echo -e "  ${C_WARN}📘 lsmod에는 안 나오지만 mount로 확인 가능${C_RESET}"
echo -e "  ${C_WARN}   cgroup2 = cgroup v2 활성화 (K8s 1.35 필수)${C_RESET}"
echo ""
mount | grep cgroup
echo ""
echo -e "  ${C_OK}→ cgroup2 타입 마운트 확인 = v2 활성화 ✅${C_RESET}"
echo ""

# ── 4 ────────────────────────────────────────────────────────
echo -e "${C_SEC}[4] Module 확인: overlay${C_RESET}"
echo ""
echo -e "  ${C_WARN}📘 overlay는 Module → lsmod에 나타남${C_RESET}"
echo ""
lsmod | grep overlay || echo -e "  ${C_WARN}(아직 로드되지 않음 — modprobe overlay 필요)${C_RESET}"
echo ""

# ── 정리 ─────────────────────────────────────────────────────
echo -e "${C_SEC}[정리]${C_RESET}"
echo -e "  ${C_OK}Core${C_RESET}:   lsmod ✕, 커널과 한 몸 ${C_CMD}(cgroup, Namespace, Scheduler)${C_RESET}"
echo -e "  ${C_OK}Module${C_RESET}: lsmod ✔, 동적 로드     ${C_CMD}(overlay, br_netfilter)${C_RESET}"
echo ""
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
echo -e "${C_OK}  Lab 04 완료 ✅${C_RESET}"
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
