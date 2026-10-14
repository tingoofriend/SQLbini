# 세션 6b — 기능 GDD 재검토 (워크벤치, 힌트, 제약 도전)

> 선행 세션: 세션 6a
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

이번 세션 작업: 다음 GDD 세 개를 독립 재검토해줘.
1. /design-review design/gdd/query-workbench.md
2. /design-review design/gdd/hint-system.md
3. /design-review design/gdd/constraint-challenges.md
힌트의 '직전과 다른 쿼리만 카운트'(rule 4a)와 챌린지 모드 규칙(힌트 숨김, 메인 요청 시계 정지,
rule 6a/6b)이 세 문서에서 같은지 확인해줘.
이번 검토는 세션 5 교차 검토(design/gdd/gdd-cross-review-2026-10-14.md, 커밋 6b244c0)
이후의 재검토야. 각 review-log의 이전 차단 항목이 해결됐는지, 교차 검토의
"Resolution" 결정(UNAVAILABLE, manual_pages, hint_counted, Day One, 말풍선/노트 분리 등)이
문서에 맞게 들어갔는지 확인해줘. /ux-design·플레이테스트로 미룬 항목은 차단 항목이 아니야.
결과는 각 review-log에 남기고, APPROVED면 systems-index 상태를 Approved로 바꿔줘.
NEEDS REVISION이면 차단 항목을 어떻게 고칠지 나에게 물어본 뒤 고치고, 상태는 In Review로
두고 다음 새 세션에서 다시 검토하도록 active.md에 적어줘.
끝나면 결과를 표로 요약하고 커밋할지 물어봐줘.
```

끝나면 커밋 여부를 정한 뒤 다음 세션 문서로 넘어가세요.
