# 세션 11 — Windows 스파이크 + ADR-0005 + export 설정 (Technical Setup 마무리)

> 선행 세션: 세션 10b(UX 스펙 재검토 → 세 스펙 NEEDS REVISION → 수정, 컨트롤 매니페스트 갱신 2026-10-17)
> 사용법: **Windows PC**에서 저장소를 받고(`git pull`), Godot 4.7.2와 Claude Code를 준비한 뒤
> 자동 연속 진행: `pwsh tools\session\auto-session.ps1` (session-handoff.md를 읽어 이 세션부터 시작하고, /exit 후 다음 세션을 자동으로 엶).
> 이 세션만 시작: 프로젝트 폴더의 터미널에서 `pwsh tools\session\start-session.ps1 11` (PowerShell 7.3+) — 새 세션을 열고 아래 블록을 첫 메시지로 넣습니다(`--print` / `-Print`로 내용만 확인).
> **새 Claude Code 세션**(`06.Game_Studio` 폴더에서 시작)에 아래 블록 전체를 첫 메시지로 붙여 넣으세요.
> 준비물: Godot 4.7.2 Windows 실행 파일, godot-sqlite v4.9 Windows 바이너리(`.dll`), 목표 PC 후보 정보(CPU·GPU·RAM).

```
SQLbini 프로젝트를 이어서 진행할게. 이번 세션은 Windows PC에서 해.
먼저 production/session-handoff.md(이 PC에는 active.md가 없으니 Carry-over가 기준), production/decision-log.md,
docs/architecture/architecture-review-2026-10-16.md, docs/architecture/requirements-traceability.md를 읽고
현재 상태를 한국어로 짧게 요약해줘.
진행 규칙:
- 모든 답변과 질문(AskUserQuestion 포함)은 한국어로 해줘. 프로젝트 문서는 영어로 유지.
- 질문할 때는 선택지마다 게임·일정에 무엇이 바뀌는지 쉬운 말로 한 줄씩 붙여줘.
- 내가 게임 아이디어를 말하면 design/ideas-backlog.md에 바로 기록하고 적절한 단계에서 반영해줘.
- 범위가 늘어나는 결정은 반영 전에 일정 영향을 알려주고 나에게 물어봐줘.
- 정한 것은 production/decision-log.md에 남기고, 내가 고른 것과 Claude가 정한 것을 구분해줘.
- 커밋/푸시는 내가 요청할 때만 해줘.
- GDD는 모두 Approved야. GDD와 어긋나는 점을 찾으면 GDD를 바로 고치지 말고
  목록으로 모아 두었다가 나에게 물어봐줘(문구만 어긋난 것은 권고로 기록). 재검토 사이클은 만들지 마.
요약이 끝나면 아래 이번 세션 작업을 진행해줘.

이번 세션 작업은 0단계 + 네 단계야.
0. UX 스펙 가벼운 확인(세션 10b에서 고친 부분만): design/ux/query-workbench.md,
   design/ux/shift-flow.md, design/ux/interaction-patterns.md의 "Revision 2026-10-17" /
   Last Updated에 적힌 수정이 10b 지적(session-handoff.md Carry-over의 "/ux-review 2026-10-17")을
   해결했는지만 확인해줘. 전체 재검토는 하지 마. 문제없으면 스펙마다 Approved로 바꿀지 물어봐줘.
   Windows에서 Ctrl+Shift+S·Ctrl+Enter가 OS에 잡히지 않는지도
   prototypes/codeedit-shortcut-probe-2026-10-17/로 한 번 돌려봐줘.
1. Windows 스파이크 (prototypes/ 아래, 결과는 README로):
   - godot-sqlite v4.9 Windows .dll이 Godot 4.7.2에서 로드되는지, SB-01…12 상당 동작 확인
   - ADR-0001 스레드 프로브 재실행(prototypes/sandbox-timeout-spike-2026-10-15/thread_probe.gd, quit_probe.gd)
   - PL-07(강제 종료 후 플레이테스트 로그 보존)
   - 렌더러 스파이크 Windows 측정(prototypes/renderer-spike-2026-10-16/: Forward+ = D3D12, Compatibility)
   - 내보낸(export) 빌드에서 문자 수 세기 확인: "é"=1, 가족 ZWJ 이모지=1
     (ADR-0007 Risks — include_text_server_data 결정용)
2. 목표 PC를 정하고(AQ-03) 쿼리 1회 비용 p95, 최악 제출 시간 submit_worst를 재확인해줘.
   결정이 필요한 것은 선택지와 일정 영향을 붙여서 물어봐줘.
3. /architecture-decision 으로 ADR-0005(플랫폼·화면·성능 기준)를 써줘:
   viewport 1280×720·stretch·min_size, 렌더러, 텍스처 64 MB·draw call 기준, 목표 PC,
   include_text_server_data, build id 출처(TR-playtest-007), export include filter(JSON).
   그다음 project.godot 반영, export 프리셋(Linux·Windows, release/playtest/dev 기능 태그),
   /settings 로 commands.build 설정. ADR-0005 승인은 하나씩 물어봐줘.
4. /architecture-review 로 ADR-0005 반영 후 커버리지를 확인하고(새 세션이 아니면 coverage 모드만),
   준비가 되면 /gate-check pre-production 을 실행해줘.
끝나면 active.md(이 PC에서 새로 만들어도 됨)와 production/session-handoff.md를 갱신하고
(Updated, Next prompt — 보통 auto, Next machine, Auto-continue, Next step, Carry-over), 커밋할지 물어봐줘.
마지막 줄에 "다음 세션으로 넘어가려면 /exit 를 입력하세요"라고 알려줘.
```

## 참고

- ADR-0005가 채워야 할 빈칸: TR-sandbox-009, TR-grader-005, TR-platform-001, TR-platform-002,
  TR-playtest-007, TR-workbench-004(ADR-0008과 함께) — `docs/architecture/requirements-traceability.md`
- 세션 10 엔진 지적 중 ADR-0005 몫: E4(내보낸 빌드의 ICU 데이터), FocusListener 초기값 데스크톱 확인(E6)
- `project.godot`에 viewport 1280×720이 아직 없음(카운터 띠가 ×4.44로 그려짐) — 띠 작업 전에 반영

## 이 세션에서 다루지 않는 것

- ADR-0008(에디터: CodeEdit·IME·AccessKit — IME 확인 실험 필요), ADR-0009(카운터 띠)
- GDD 문구 권고 묶음 처리, Concept 재검토, 제로-SQL 플레이테스트 날짜
