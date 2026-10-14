# 세션 2 — 기반 GDD 독립 검토 (샌드박스, 워크벤치)

> 선행 세션: 세션 1
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
요약이 끝나면 아래 이번 세션 작업을 진행해줘.

이번 세션 작업: 다음 GDD 두 개를 독립 검토해줘.
1. /design-review design/gdd/sql-execution-sandbox.md
2. /design-review design/gdd/query-workbench.md
샌드박스는 godot-sqlite 시험 결과(prototypes/sqlbini-spike-2026-10-14/SPIKE-NOTE.md 부록)를
근거로 했으니 주장과 근거가 맞는지 확인해줘. 워크벤치는 120px 픽셀 계산대 장면이 들어간
배치(rows_visible 7)가 반영됐는지 확인해줘.
끝나면 결과를 표로 요약하고 커밋할지 물어봐줘.
```

끝나면 커밋 여부를 정한 뒤 다음 세션 문서로 넘어가세요.
