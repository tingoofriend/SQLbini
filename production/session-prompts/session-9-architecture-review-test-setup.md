# 세션 9 — 아키텍처 독립 검토 + 테스트 환경 (Technical Setup)

> 선행 세션: 세션 8(아키텍처 문서 v1, ADR-0001·0002·0003·0004·0006 Proposed, MVP 재추정 ≈ 17주 수용)
> 사용법: **새 Claude Code 세션**(`06.Game_Studio` 폴더에서 시작)을 열고, 아래 블록 전체를 그대로 복사해 첫 메시지로 붙여 넣으세요.
> 반드시 새 세션: `/architecture-review`는 ADR을 쓴 세션에서 돌리면 무효입니다.

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
1. /architecture-review 를 실행해줘. 대상: docs/architecture/architecture.md v1과
   ADR-0001(샌드박스 타임아웃), 0002(Sandbox API·lexer), 0003(퍼즐 형식·검증기),
   0004(이벤트 버스·플레이테스트 로그), 0006(구성 루트). 모두 Proposed야.
   TR 레지스트리(docs/architecture/tr-registry.yaml)와 추적 매트릭스를 만들어줘.
   ADR-0005(플랫폼 기준)는 아직 없어 — Windows 스파이크 뒤에 쓸 예정이니 빈칸으로 표시만 해줘.
   active.md 끝의 "GDD wording notes"(ADR별 GDD 문구 권고)도 함께 확인해줘.
2. 검토 결과를 보고, 문제없는 ADR은 Accepted로 바꿀지 하나씩 물어봐줘
   (/architecture-decision accept ADR-NNNN, 0001 → 0002 → 0003 → 0004 → 0006 순서).
3. /test-setup 을 실행해줘(gdUnit4 설치, tests/unit·tests/integration, CI, 예시 테스트).
   설치 전에 받을 애드온 버전과 출처를 알려주고 물어봐줘.
   ADR-0006의 확인 항목(gdUnit4가 autoload를 추가하는지, scene_runner가 setup된 인스턴스를 받는지)을 확인해서
   ADR-0006에 결과를 적어줘.
끝나면 active.md를 갱신하고, 남은 Technical Setup 항목(Windows 스파이크 → ADR-0005 → export·commands.build,
/ux-design, /create-control-manifest, /gate-check pre-production)을 순서대로 알려주고 커밋할지 물어봐줘.
```

끝나면 커밋 여부를 정한 뒤 다음 세션 문서로 넘어가세요.

## 다음 세션 후보 (세션 10)

- **Windows PC에서**: godot-sqlite `.dll` 스파이크(4.7.2) — ADR-0001 스레드 프로브(`prototypes/sandbox-timeout-spike-2026-10-15/thread_probe.gd`, `quit_probe.gd`)도 Windows에서 재실행 → ADR-0005(viewport 1280×720·렌더러·64 MB·목표 PC) → export 프리셋·`commands.build`
- `/ux-design` (다음 게이트 필수: interaction-patterns, accessibility-requirements)

## 이 세션에서 다루지 않는 것 (수용한 위험 — 별도로 처리)

- Concept 재검토: `/design-review design/gdd/game-concept.md` (새 세션, 원할 때)
- 제로-SQL 플레이테스트 날짜 정하기, 1챕터 요청 1-4/1-5/1-7/1-8 문구 재작성(레벨 디자인)
