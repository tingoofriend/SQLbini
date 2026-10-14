# 세션 6c-3 — 온보딩 재검토

> ✅ 완료 2026-10-15 (커밋 `0b729ca`): 온보딩 Approved, MVP GDD 11개 모두 Approved → 세션 6d

> 선행 세션: 세션 6c-2 (커밋 `f6e1f0a`)
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

이번 세션 작업: 6c-2에서 NEEDS REVISION → 수정된 온보딩 GDD를 독립 재검토해줘.
/design-review design/gdd/onboarding-first-shift.md
review-log 마지막 항목의 차단 항목과 "Revised in-session" 메모를 기준으로 확인해줘. 특히:
- 코치마크 완료 조건이 자기 퍼즐 안에서만 성립하는지(rule 7a 범위 문단, rule 8, States)
- 예외는 1-1에서 Run 전에 Submit한 경우(1-1.run Done) 하나뿐인지
- 매뉴얼 엣지 케이스 분리(1-1/1-2에서 열면 아무것도 Done 아님, 1-3에서 마크 전에 열면 Done)와 OB-11·OB-13
- 마크 id가 Playtest Log의 mark_shown/done/dismissed {mark}와 맞는지
전체 문서를 다시 읽되 이미 기록된 권고(RECOMMENDED)를 새 차단 항목으로 올리지는 마.
/ux-design·플레이테스트로 미룬 항목도 차단 항목이 아니야.
결과는 review-log에 남기고, APPROVED면 systems-index 상태와 문서 헤더를 Approved로 바꿔줘.
NEEDS REVISION이면 차단 항목을 어떻게 고칠지 나에게 물어본 뒤 고치고, 상태는 In Review로
두고 다음 새 세션에서 다시 검토하도록 active.md에 적어줘.
끝나면 결과를 요약하고, GDD 11개 중 몇 개가 Approved인지 알려주고, 커밋할지 물어봐줘.
```

끝나면 커밋 여부를 정한 뒤 세션 6d로 넘어가세요(11개 모두 Approved일 때).
