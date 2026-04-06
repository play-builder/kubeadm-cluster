#!/bin/bash
# ============================================================
# Lab 06: K8s 필수 커널 파라미터 검증
# ============================================================
set -e

C_TITLE="\033[1;34m"  C_SEC="\033[1;36m"  C_OK="\033[1;32m"
C_WARN="\033[1;33m"   C_ERR="\033[1;31m"  C_CMD="\033[0;37m"
C_RESET="\033[0m"

PASS=0; FAIL=0

check_param() {
    local path=$1; local desc=$2
    if [ -f "$path" ]; then
        local val=$(cat "$path")
        if [ "$val" = "1" ]; then
            echo -e "  ${C_OK}✅ $desc = $val${C_RESET}"
            PASS=$((PASS + 1))
        else
            echo -e "  ${C_ERR}❌ $desc = $val (1이어야 함!)${C_RESET}"
            FAIL=$((FAIL + 1))
        fi
    else
        echo -e "  ${C_ERR}❌ $path 없음 (br_netfilter 모듈 로드 필요)${C_RESET}"
        FAIL=$((FAIL + 1))
    fi
}

echo ""
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
echo -e "${C_TITLE}  Lab 06: K8s 필수 커널 파라미터 검증${C_RESET}"
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
echo ""
echo -e "${C_WARN}  📘 모듈 로드가 먼저, 파라미터 설정이 그 다음${C_RESET}"
echo -e "${C_WARN}     br_netfilter 없으면 /proc/sys/net/bridge/ 자체가 없음${C_RESET}"
echo ""

# ── 1 ────────────────────────────────────────────────────────
echo -e "${C_SEC}[1] 필수 커널 모듈${C_RESET}"
echo ""
for mod in overlay br_netfilter; do
    if lsmod | grep -q "^$mod"; then
        echo -e "  ${C_OK}✅ $mod 로드됨${C_RESET}"
        PASS=$((PASS + 1))
    else
        echo -e "  ${C_ERR}❌ $mod 로드 안 됨 → sudo modprobe $mod${C_RESET}"
        FAIL=$((FAIL + 1))
    fi
done
echo ""

# ── 2 ────────────────────────────────────────────────────────
echo -e "${C_SEC}[2] 필수 커널 파라미터${C_RESET}"
echo ""
echo -e "  ${C_WARN}📘 ip_forward = 1              → Pod 간 크로스 노드 라우팅${C_RESET}"
echo -e "  ${C_WARN}   bridge-nf-call-iptables = 1 → Service DNAT (IPv4)${C_RESET}"
echo -e "  ${C_WARN}   bridge-nf-call-ip6tables = 1 → Service DNAT (IPv6)${C_RESET}"
echo ""
check_param "/proc/sys/net/ipv4/ip_forward" \
    "ip_forward (Pod 간 크로스 노드 라우팅)"
check_param "/proc/sys/net/bridge/bridge-nf-call-iptables" \
    "bridge-nf-call-iptables (Service DNAT IPv4)"
check_param "/proc/sys/net/bridge/bridge-nf-call-ip6tables" \
    "bridge-nf-call-ip6tables (Service DNAT IPv6)"
echo ""

# ── 3 ────────────────────────────────────────────────────────
echo -e "${C_SEC}[3] 영구 설정 파일${C_RESET}"
echo ""
echo -e "  ${C_WARN}📘 /etc/sysctl.d/k8s.conf → 재부팅 후에도 유지${C_RESET}"
echo ""
if [ -f /etc/sysctl.d/k8s.conf ]; then
    cat /etc/sysctl.d/k8s.conf | sed 's/^/    /'
else
    echo -e "  ${C_ERR}⚠️ /etc/sysctl.d/k8s.conf 파일이 없습니다!${C_RESET}"
fi
echo ""

# ── 결과 ─────────────────────────────────────────────────────
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
echo -e "  결과: ${C_OK}✅ ${PASS}개 통과${C_RESET} / ${C_ERR}❌ ${FAIL}개 실패${C_RESET}"
if [ $FAIL -eq 0 ]; then
    echo -e "  ${C_OK}→ K8s 노드 커널 설정 정상 ✅${C_RESET}"
else
    echo -e "  ${C_ERR}→ ⚠️ 실패 항목 수정 필요!${C_RESET}"
fi
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
