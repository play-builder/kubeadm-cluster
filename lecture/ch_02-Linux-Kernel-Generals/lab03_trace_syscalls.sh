#!/bin/bash
# ============================================================
# Lab 03: strace — System Call 추적
# ============================================================
# User Space(cat) → syscall → Kernel(VFS) → 화면
# ============================================================
set -e

C_TITLE="\033[1;34m"  C_SEC="\033[1;36m"  C_OK="\033[1;32m"
C_WARN="\033[1;33m"   C_CMD="\033[0;37m"  C_RESET="\033[0m"

if ! command -v strace &>/dev/null; then
    echo -e "${C_WARN}strace 설치 중...${C_RESET}"
    apt-get install -y strace > /dev/null 2>&1
fi

echo ""
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
echo -e "${C_TITLE}  Lab 03: System Call 추적 (strace)${C_RESET}"
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
echo ""
echo -e "${C_WARN}  📘 프로그램(User) → System Call → Kernel → 화면${C_RESET}"
echo -e "${C_WARN}     이 한 줄이 Linux의 핵심 동작 원리${C_RESET}"
echo ""

# ── 1 ────────────────────────────────────────────────────────
echo -e "${C_SEC}[1] cat /proc/cpuinfo → 핵심 System Call 3개 추출${C_RESET}"
echo ""
echo -e "  ${C_WARN}📘 ENOENT(No such file)는 정상 탐색 노이즈 → 무시${C_RESET}"
echo -e "  ${C_WARN}   핵심은 openat, read, write 딱 3개${C_RESET}"
echo ""
strace cat /proc/cpuinfo 2>&1 | grep -E "^(openat|read|write)" | head -6
echo ""

# ── 2 ────────────────────────────────────────────────────────
echo -e "${C_SEC}[2] 하나씩 분석${C_RESET}"
echo ""

echo -e "  ${C_WARN}📘 openat(\"/proc/cpuinfo\") = 3   ← 파일 열기${C_RESET}"
echo ""
echo -e "  ${C_OK}첫째, openat.${C_RESET}"
echo -e "  ${C_CMD}cat이 커널에게 \"/proc/cpuinfo 열어줘\"라고 요청.${C_RESET}"
echo -e "  ${C_CMD}커널이 3이라는 파일 디스크립터를 돌려줌.${C_RESET}"
echo -e "  ${C_CMD}\"이제부터 이 파일은 3번 통로야.\"${C_RESET}"
echo ""

echo -e "  ${C_WARN}📘 read(3, ...) = 2360             ← 커널이 RAM에서 렌더링${C_RESET}"
echo ""
echo -e "  ${C_OK}둘째, read.${C_RESET}"
echo -e "  ${C_CMD}cat이 \"3번 통로 데이터 읽어줘\"라고 요청.${C_RESET}"
echo -e "  ${C_CMD}커널이 디스크로 가지 않고 RAM 상태를 읽어 텍스트로 렌더링.${C_RESET}"
echo -e "  ${C_CMD}2360 = 커널이 실시간으로 만들어준 바이트 크기.${C_RESET}"
echo ""

echo -e "  ${C_WARN}📘 write(1, ...) = 2360            ← 화면(fd=1)에 출력${C_RESET}"
echo -e "  ${C_WARN}   read(3, ...)  = 0               ← EOF${C_RESET}"
echo ""
echo -e "  ${C_OK}셋째, write.${C_RESET}"
echo -e "  ${C_CMD}\"이 2360바이트를 1번 통로(모니터 화면)에 출력해줘!\"${C_RESET}"
echo -e "  ${C_CMD}마지막 read 반환값 0 = \"더 이상 데이터 없음(EOF)\".${C_RESET}"
echo ""

echo -e "  ${C_OK}정리: 열고(open) → 읽어서(read) → 화면에 쓴다(write)${C_RESET}"
echo -e "  ${C_CMD}cat 명령어 하나가 커널과의 시스템 콜을 통해 완성됩니다.${C_RESET}"
echo ""

# ── 3 ────────────────────────────────────────────────────────
echo -e "${C_SEC}[3] syscall 호출 통계${C_RESET}"
echo ""
strace -c cat /proc/cpuinfo > /dev/null 2>&1 || true
strace -c cat /proc/cpuinfo 2>&1 | tail -20
echo ""
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
echo -e "${C_OK}  Lab 03 완료 ✅${C_RESET}"
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
