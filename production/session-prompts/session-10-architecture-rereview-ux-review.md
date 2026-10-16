# 세션 10 — 아키텍처 재검토 + ADR-0007·0010 승인 + UX 스펙 검토 (Technical Setup)

> 선행 세션: 세션 9(아키텍처 검토 FAIL → ADR 수정 후 0001·0002·0003·0004·0006 Accepted, gdUnit4 테스트 환경,
> 접근성 요구사항·상호작용 패턴·워크벤치/shift-flow UX 스펙, 컨트롤 매니페스트, ADR-0007·0010 Proposed, 렌더러 스파이크(Linux))
> 사용법: **새 Claude Code 세션**(`06.Game_Studio` 폴더에서 시작)을 열고, 아래 블록 전체를 그대로 복사해 첫 메시지로 붙여 넣으세요.
> 반드시 새 세션: ADR-0007·0010과 UX 스펙은 세션 9에서 작성했으므로, 같은 세션의 검토는 무효입니다.
> Linux에서 진행 가능합니다(Windows 불필요).

```
SQLbini 프로젝트를 이어서 진행할게.
먼저 production/session-state/active.md, design/gdd/systems-index.md,
design/ideas-backlog.md, production/decision-log.md를 읽고 현재 상태를 한국어로 짧게 요약해줘.
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

이번 세션 작업은 세 단계야.
1. /architecture-review 를 실행해줘. 대상: docs/architecture/architecture.md와
   ADR-0001·0002·0003·0004·0006(Accepted, 세션 9에서 수정 후 승인 — 수정이 맞는지도 확인)과
   ADR-0007(설정값·문자열 테이블·세션 설정), ADR-0010(게임플레이 시그널 계약) — 둘 다 Proposed.
   기존 TR 레지스트리(docs/architecture/tr-registry.yaml, 60개)의 ID는 유지하고,
   requirements-traceability.md를 갱신해줘. ADR-0005(플랫폼 기준)는 아직 없어 — Windows 스파이크 뒤라 빈칸으로 표시만.
   직전 보고서 docs/architecture/architecture-review-2026-10-15.md의 지적(C1~C7, 엔진 권고)이 해결됐는지도 확인해줘.
   active.md의 "GDD wording notes"(ADR별 GDD 문구 권고)도 함께 확인해줘.
2. 검토 결과를 보고, 문제없는 ADR은 Accepted로 바꿀지 하나씩 물어봐줘
   (/architecture-decision accept ADR-NNNN, 0007 → 0010 순서). 문제가 있으면 고칠 내용을 먼저 보여줘.
3. /ux-review 를 두 번 실행해줘: design/ux/query-workbench.md, design/ux/shift-flow.md.
   design/accessibility-requirements.md, design/ux/interaction-patterns.md와의 일치도 확인해줘.
끝나면 active.md를 갱신하고, 남은 Technical Setup 항목(Windows 스파이크 → ADR-0005 → export·commands.build,
/gate-check pre-production)을 순서대로 알려주고 커밋할지 물어봐줘.
```

끝나면 커밋 여부를 정한 뒤 다음 세션 문서로 넘어가세요.

## 다음 세션 후보 (세션 11 — Windows PC)

- godot-sqlite v4.9 Windows `.dll` 스파이크(4.7.2): SB-01…12 상당 확인, ADR-0001 스레드 프로브
  (`prototypes/sandbox-timeout-spike-2026-10-15/thread_probe.gd`, `quit_probe.gd`) 재실행, PL-07(강제 종료 후 로그 보존)
- 렌더러 스파이크 Windows 측정: `prototypes/renderer-spike-2026-10-16/` (Forward+ = D3D12, Compatibility)
- 목표 PC 정하기(AQ-03) → 쿼리 1회 비용 p95 측정, 최악 제출 시간 `submit_worst` 재확인
- ADR-0005 작성(viewport 1280×720·stretch·min_size, 렌더러, 64 MB, 목표 PC) → `project.godot` 반영
- export 프리셋(Linux·Windows, release/playtest/dev 태그, JSON include filter) + `/settings`로 `commands.build`
- 그 뒤 `/gate-check pre-production`

## 이 세션에서 다루지 않는 것 (수용한 위험 — 별도로 처리)

- ADR-0008(에디터: CodeEdit·IME·AccessKit — IME 확인 실험 필요), ADR-0009(카운터 띠 렌더링): 해당 스토리 전까지
- Concept 재검토, 제로-SQL 플레이테스트 날짜, 1챕터 요청 1-4/1-5/1-7/1-8 문구 재작성
- 첫 푸시(GitHub CI 첫 실행) — 원할 때
