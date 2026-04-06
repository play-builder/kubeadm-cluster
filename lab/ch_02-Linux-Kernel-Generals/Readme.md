# Ch02. Linux Kernel Generals

K8s의 모든 컴포넌트는 Linux Kernel 위에서 동작합니다.
이 챕터에서는 커널의 핵심 구조를 이해하고, K8s 노드의 필수 커널 설정을 직접 검증합니다.

## Pre-requisite
- kubeadm 기반 K8s 클러스터 (Control Plane 노드 접속)
- root 권한 (`sudo su -`)

## Lab 실행 방법
```bash
# Control Plane 노드에서
sudo su - root
git clone https://github.com/play-builder/kubeadm-cluster
cd kubeadm-cluster/lecture/ch_02-Linux-Kernel-Generals

chmod +x lab01_proc_is_not_on_disk.sh
bash lab01_proc_is_not_on_disk.sh
```

## Lab-01: /proc는 디스크에 없다 — 가상 파일시스템 증명
- `/proc` 내부 파일 크기가 전부 0인 것을 확인
- `du -sh /etc` vs `du -sh /proc` 비교로 디스크 점유 없음 증명
- `/proc/uptime`을 1초 간격으로 읽어 값이 바뀌는 것을 확인 (실시간 렌더링 증거)
```bash
bash lab01_proc_is_not_on_disk.sh
```

## Lab-02: CPU & 메모리 정보 확인
- `/proc/cpuinfo`에서 논리 CPU 수, 물리 코어, 하이퍼스레딩 확인
- `kubectl describe node`의 `cpu: 2`가 어디서 오는지 근거 확인
- `/proc/meminfo`에서 MemTotal, SwapTotal(=0, K8s 필수) 확인
```bash
bash lab02_cpu_mem_info.sh
```

## Lab-03: System Call 추적 (strace)
- `strace cat /proc/cpuinfo`로 핵심 syscall 3개 추출 (openat, read, write)
- 각 syscall이 하는 일을 하나씩 분석
- `User Space(cat) → syscall → Kernel(VFS) → 화면` 흐름을 눈으로 확인
```bash
bash lab03_trace_syscalls.sh
```

## Lab-04: Core vs Module 구분
- `lsmod | grep cgroup` → 출력 없음 = Core (커널과 한 몸)
- `lsmod | grep overlay` → 출력 있음 = Module (동적 로드)
- `mount | grep cgroup` → cgroup2 타입 확인 (K8s 1.35 cgroup v2 필수)
```bash
bash lab04_core_vs_module.sh
```

## Lab-05: K8s 필수 커널 모듈 로드
- `overlay` — 컨테이너 이미지 레이어 합성 (없으면 CreateContainerError)
- `br_netfilter` — 브릿지 트래픽 iptables 연동 (없으면 Service 통신 불가)
- `modprobe`로 로드, `lsmod`로 참조 수 및 의존성 확인, 재부팅 후 자동 로드 설정 확인
```bash
bash lab05_load_k8s_modules.sh
```

## Lab-06: K8s 필수 커널 파라미터 검증
- `ip_forward = 1` — Pod 간 크로스 노드 라우팅 허용
- `bridge-nf-call-iptables = 1` — Service DNAT (IPv4)
- `bridge-nf-call-ip6tables = 1` — Service DNAT (IPv6)
- 5가지 필수 조건 중 하나라도 누락되면 치명적 장애 발생
```bash
bash lab06_check_kernel_params.sh
```
