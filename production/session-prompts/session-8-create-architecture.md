# 세션 8 — 아키텍처 작성 (Technical Setup 시작)

> 선행 세션: 세션 7(6g 확인 + Systems Design → Technical Setup 게이트, CONCERNS 수용 → 단계 전환, 커밋 `e247dc0`)
> 사용법: **새 Claude Code 세션**(`06.Game_Studio` 폴더에서 시작)을 열고, 아래 블록 전체를 그대로 복사해 첫 메시지로 붙여 넣으세요.

```
SQLbini 프로젝트를 이어서 진행할게.
먼저 production/session-state/active.md, design/gdd/systems-index.md,
design/ideas-backlog.md를 읽고 현재 상태를 한국어로 짧게 요약해줘.
진행 규칙:
- 모든 답변과 질문(AskUserQuestion 포함)은 한국어로 해줘. 프로젝트 문서는 영어로 유지.
- 내가 게임 아이디어를 말하면 design/ideas-backlog.md에 바로 기록하고 적절한 단계에서 반영해줘.
- 범위가 늘어나는 결정은 반영 전에 일정 영향을 알려주고 나에게 물어봐줘.
- 커밋/푸시는 내가 요청할 때만 해줘.
- GDD는 모두 Approved야. 아키텍처 작업 중 GDD와 어긋나는 점을 찾으면 GDD를 바로 고치지 말고
  목록으로 모아 두었다가 나에게 물어봐줘(문구만 어긋난 것은 권고로 기록). 재검토 사이클은 만들지 마.
요약이 끝나면 아래 이번 세션 작업을 진행해줘.

이번 세션 작업 — /create-architecture 를 실행해줘.
지금 단계는 Technical Setup이야(게이트 보고서:
production/gate-checks/2026-10-15-systems-design-to-technical-setup.md, CONCERNS 수용).
그 보고서의 Technical Director 이월 항목을 아키텍처 문서와 ADR 작업 계획에 반영해줘:
1. 샌드박스 타임아웃 메커니즘 ADR — godot-sqlite에는 interrupt API가 없음.
   후보: 결과를 버리는 워커 스레드 / 별도 프로세스 / 단계 상한(step cap). SB-18로 검증 가능해야 함.
2. Windows용 godot-sqlite .dll 스파이크(4.7.2에서 동작 확인).
3. project.godot viewport 1280×720 + 4.7에서 바뀐 stretch-mode 기본값 확인, 렌더러 결정,
   64 MB 텍스처 상한을 예산으로 기록.
4. gdUnit4 설치(/test-setup)와 commands.build 설정.
5. Foundation 계층 ADR: 퍼즐 데이터 형식(Puzzle Definition), Sandbox API·lexer(tokenize) 계약,
   Playtest Log 이벤트 버스.
엔진 API는 docs/engine-reference/godot/를 먼저 확인하고, 거기 없는 4.4 이후 API는 추측하지 말고 표시해줘.
ADR은 한 번에 다 쓰지 말고, 아키텍처 문서와 ADR 작업 계획(우선순위·순서)을 먼저 보여준 뒤
어떤 ADR부터 쓸지 나에게 물어봐줘.
작업이 끝나면 첫 아키텍처 결과를 바탕으로 /estimate 재실행(MVP 일정 재추정)이 필요한지 알려줘.
```

끝나면 커밋 여부를 정한 뒤 다음 세션 문서로 넘어가세요.

## 이 세션에서 다루지 않는 것 (수용한 위험 — 별도로 처리)

- Concept 재검토: `/design-review design/gdd/game-concept.md` (새 세션, 원할 때)
- 제로-SQL 플레이테스트 날짜 정하기, 1챕터 요청 1-4/1-5/1-7/1-8 문구 재작성(레벨 디자인)
- 교차 검토 Info 이월 항목·6e 권고 → `/ux-design` 또는 구현 단계에서 처리
