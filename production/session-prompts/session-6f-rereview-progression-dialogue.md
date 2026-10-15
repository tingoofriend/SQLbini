# 세션 6f — 6e 수정 확인 재검토 (필수)

> 선행 세션: 세션 6e (커밋 `3bcd868`). Constraint Challenges·Onboarding은 APPROVED였고,
> Shift & Chapter Progression·Request & Reaction Dialogue는 NEEDS REVISION → 수정 → In Review 상태입니다.
> 현재 MVP GDD 11개 중 9개가 Approved입니다.
> 사용법: **새 Claude Code 세션**(`06.Game_Studio` 폴더에서 시작)을 열고, 아래 블록 전체를 그대로 복사해 첫 메시지로 붙여 넣으세요.
> 건너뛸 수 없습니다: 세션 7 게이트는 11개 모두 Approved여야 진행합니다.

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

이번 세션 작업: 6e 재검토(커밋 3bcd868)에서 NEEDS REVISION을 받고 수정된 GDD 2개를 독립 재검토해줘.
범위는 6e 수정분과 그 파급만이야. 각 review-log의 마지막 항목(6e)에 차단 항목과 수정 내용이 있어.
1. /design-review design/gdd/shift-and-chapter-progression.md — Unavailable(rule 7a)이 메인 요청을
   해결된 상태로 치는지: rule 4·6·10(급여 명세서 "– unavailable"), States 표(Locked 행, Per shift,
   Per chapter), PR-02·PR-04·PR-11; 시프트 첫 요청이 브리핑이 끝나야 열리는지(rule 11, States 표);
   rule 5(사이드 메시지는 브리핑이 끝난 뒤)와 Dialogue 행(브리핑 종료 신호)
2. /design-review design/gdd/request-and-reaction-dialogue.md — rule 3b(사이드 메시지·티켓은 브리핑이
   끝난 뒤, 브리핑 중에는 없음), rule 3c(브리핑 종료를 Progression에 알림 → 첫 메인 요청 열림 + 사이드
   메시지 도착), Progression 행, RD-21·RD-22; rule 2·UI Req 5의 TOO_MANY_ROWS 예외 문구
두 문서가 서로 맞는지, 그리고 onboarding-first-shift.md(rule 1: 브리핑 → "Ever used SQL?" → 1-1),
playtest-log.md(request_unavailable {source}), store-manual.md·query-workbench.md·hint-system.md
(6e에서 고친 Guided suppression window 문구)와 맞는지도 확인해줘. 이 문서들은 따로 /design-review
하지 말고 교차 확인만 해.
6e review-log에 이미 기록된 권고(RECOMMENDED), 6d 보고서의 Info(이월) 항목,
/ux-design·플레이테스트로 미룬 항목은 새 차단 항목으로 올리지 마.
결과는 각 review-log에 남겨줘. APPROVED면 systems-index와 헤더 상태를 Approved로 바꾸고
헤더 Last Updated에 6f를 남겨줘.
NEEDS REVISION이면 차단 항목을 어떻게 고칠지 나에게 물어본 뒤 고치고, 상태는 In Review로 두고
다음 새 세션에서 다시 검토하도록 active.md에 적어줘.
끝나면 active.md를 갱신하고, 결과를 표로 요약하고, GDD 11개 중 몇 개가 Approved인지 알려주고,
커밋할지 물어봐줘.
```

끝나면 커밋 여부를 정한 뒤, 11개가 모두 Approved이면 세션 7 문서로 넘어가세요.
