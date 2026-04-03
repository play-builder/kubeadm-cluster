#!/bin/bash
# ============================================================
# Lab 01: /proc — 가상 파일시스템 증명
# ============================================================

set -e

# ── 색상 정의 ────────────────────────────────────────────────
C_TITLE="\033[1;34m"    # 파랑 볼드 (타이틀)
C_SEC="\033[1;36m"      # 시안 볼드 (섹션 헤더)
C_OK="\033[1;32m"       # 초록 볼드 (성공/핵심)
C_WARN="\033[1;33m"     # 노랑 (설명/화살표)
C_CMD="\033[0;37m"      # 밝은 회색 (명령어 출력)
C_RESET="\033[0m"       # 리셋

echo ""
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
echo -e "${C_TITLE}  Lab 01: /proc — 가상 파일시스템 증명${C_RESET}"
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
echo ""

# ── 1. /proc 내부 구조 확인 ──────────────────────────────────
echo -e "${C_SEC}[1] /proc 내부 구조 (파일 크기가 전부 0인 것에 주목)${C_RESET}"
echo ""
ls -altr /proc | head -15
echo ""

# ── 2. 디스크 점유 비교 ─────────────────────────────────────
echo -e "${C_SEC}[2] /etc (디스크에 실제 존재) vs /proc (가상)${C_RESET}"
echo ""
echo -ne "  /etc  용량: ${C_OK}"; du -sh /etc 2>/dev/null | awk '{print $1}'; echo -ne "${C_RESET}"
echo -ne "  /proc 용량: ${C_OK}"; du -sh /proc 2>/dev/null | awk '{print $1}'; echo -ne "${C_RESET}"
echo ""
echo -e "  ${C_WARN}→ /proc는 0 Byte. 디스크에 없고 커널이 RAM에서 실시간 생성합니다.${C_RESET}"
echo ""

# ── 3. 실시간 렌더링 증명 ────────────────────────────────────
echo -e "${C_SEC}[3] /proc/uptime — 읽을 때마다 값이 바뀜 (실시간 렌더링 증거)${C_RESET}"
echo ""
echo -ne "  1차: ${C_CMD}"; cat /proc/uptime; echo -ne "${C_RESET}"
sleep 1
echo -ne "  2차: ${C_CMD}"; cat /proc/uptime; echo -ne "${C_RESET}"
echo ""
echo -e "  ${C_WARN}→ 1초 사이에 값이 변함. 저장된 파일이 아니라 실시간 생성입니다.${C_RESET}"
echo ""
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
echo -e "${C_OK}  Lab 01 완료 ✅${C_RESET}"
echo -e "${C_TITLE}═══════════════════════════════════════════════════${C_RESET}"
