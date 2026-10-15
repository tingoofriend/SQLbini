# 세션 6e — 6d 규칙 변경 확인 재검토 (선택, 권장)

> 선행 세션: 세션 6d (커밋 `c5ce5a0`, 판정 CONCERNS → 모두 반영, MVP GDD 11개 모두 Approved)
> 사용법: **새 Claude Code 세션**(`06.Game_Studio` 폴더에서 시작)을 열고, 아래 블록 전체를 그대로 복사해 첫 메시지로 붙여 넣으세요.
> 건너뛰어도 됩니다: 6d 수정은 사용자 결정에 따른 작은 규칙 명시이고 상태는 Approved로 유지됐습니다. 건너뛰면 세션 7로 바로 가세요.

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

이번 세션 작업: 6d 교차 검토(design/gdd/gdd-cross-review-2026-10-15.md, 커밋 c5ce5a0)에서
규칙이 바뀐 GDD를 독립 재검토해줘. 범위는 6d 변경분과 그 파급만이야.
1. /design-review design/gdd/shift-and-chapter-progression.md — rule 7a(UNAVAILABLE → Kenji 넘기기
   제안, Unavailable 상태, 완료·별 제외, 다시 열기 가능), rule 9, rule 11(브리핑이 끝나야 첫 요청),
   rule 12a의 request_restart 기록, States 표, PR-17·PR-22
2. /design-review design/gdd/request-and-reaction-dialogue.md — rule 3c와 Briefing 상태(Day One 순서:
   브리핑 → "Ever used SQL?" → 1-1), 챌린지 모드에서 티켓 비활성(rule 3b), UNAVAILABLE 제안 큐 예외,
   TOO_MANY_ROWS(error_text 없음), RD-22
3. /design-review design/gdd/constraint-challenges.md — rule 6c(챌린지 자체 초안: 마지막 통과 쿼리로 시작,
   세션 동안 유지, 기본 초안 불변), rule 9의 UNAVAILABLE, States 표, CC-18
4. /design-review design/gdd/onboarding-first-shift.md — rule 1 순서, rule 7 Guided suppression window
   (1-3.manual Done/Dismissed·Morning 종료·코치 마크 끄기에서 닫힘; 1-3을 건너뛰어도 닫히는지),
   rule 7a 1-3.manual(매뉴얼이 이미 열려 있으면 Done), OB-24·OB-25
같은 창(window)과 규칙이 query-workbench.md(rule 6, rule 14), store-manual.md(rule 6, States, Edge Cases),
hint-system.md(Interactions: 챌린지 모드 이벤트 소유 = Constraint Challenges), playtest-log.md
(request_unavailable {source}, request_restart)와 맞는지도 확인해줘. 이 네 문서는 따로 /design-review
하지 말고 교차 확인만 해.
보고서의 Info(이월) 항목과 이미 기록된 권고(RECOMMENDED)는 새 차단 항목으로 올리지 마.
/ux-design·플레이테스트로 미룬 항목도 차단 항목이 아니야.
문맥이 70%를 넘으면 남은 문서는 다음 세션으로 넘겨줘(active.md에 기록).
결과는 각 review-log에 남겨줘. APPROVED면 상태는 Approved 그대로 두고 헤더 Last Updated에 6e를 남겨줘.
NEEDS REVISION이면 차단 항목을 어떻게 고칠지 나에게 물어본 뒤 고치고, systems-index와 헤더 상태를
In Review로 바꾸고 다음 새 세션에서 다시 검토하도록 active.md에 적어줘.
끝나면 결과를 표로 요약하고, GDD 11개 중 몇 개가 Approved인지 알려주고, 커밋할지 물어봐줘.
```

끝나면 커밋 여부를 정한 뒤 세션 7 문서로 넘어가세요.
