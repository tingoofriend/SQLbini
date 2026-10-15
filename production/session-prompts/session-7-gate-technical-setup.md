# 세션 7 — Technical Setup 게이트

> 선행 세션: 세션 1~6, 6a~6c-3, 6d, 6e, 6f (6g 확인은 이 세션 0단계에 합침)
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

이번 세션 작업은 두 단계야.
0단계 — 6f 수정 확인(세션 6을 여기서 끝냄): Progression·Dialogue는 6f에서 문구 수정만 받고 In Review야.
전체 /design-review는 하지 말고, 각 review-log의 마지막 항목(6f)에 적힌 수정분만 확인해줘:
사이드 요청이 브리핑이 끝날 때 Open/도착하는지(Progression States 표 아래 문장·PR-03·rule 5,
Dialogue rule 2 `side` 행·rule 3b·3c·RD-22), PR-19, Progression의 Onboarding 행(답변 → 1-1 열림).
확인 기준: 규칙끼리 충돌하거나 구현이 막히는 것만 차단이고, 문구만 어긋난 것은 그 자리에서 고친 뒤 권고로 기록해.
고칠 때는 바뀐 용어를 design/gdd/ 전체에서 grep해서 남은 곳까지 같이 고쳐줘.
차단이 없으면 두 문서의 systems-index·헤더 상태를 Approved로 바꾸고(헤더 Last Updated에 6g 확인),
각 review-log에 6g 항목을 남긴 뒤 1단계로 넘어가. 차단이 있으면 고칠 방법을 나에게 물어봐줘.
1단계 — /gate-check technical-setup 을 실행해줘.
Concept 게이트에서 받아들인 위험(production/gate-checks/2026-10-14-concept-to-systems-design-rerun.md)이
해결됐는지도 함께 확인해줘.
게이트 전에 MVP GDD 11개가 모두 Approved인지 확인하고(systems-index와 각 문서 헤더),
아니면 게이트를 돌리지 말고 남은 문서를 알려줘. 6e·6f·6g 재검토 결과(각 review-log)도 반영해서 봐줘.
최신 교차 검토는 design/gdd/gdd-cross-review-2026-10-15.md(6d, CONCERNS → 모두 반영)야.
거기 남은 Info(이월) 항목과 /ux-design으로 미룬 항목은 게이트 차단 항목인지 판단만 해주고,
고칠 필요가 있으면 고치기 전에 나에게 물어봐줘.
```

끝나면 커밋 여부를 정한 뒤 다음 세션 문서로 넘어가세요.
