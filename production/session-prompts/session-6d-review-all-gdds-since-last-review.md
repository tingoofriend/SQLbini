# 세션 6d — 재검토 후 교차 일관성 확인

> 선행 세션: 세션 6a~6c, 6c-2, 6c-3 (커밋 `0b729ca`, MVP GDD 11개 모두 Approved)
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

이번 세션 작업: /review-all-gdds since-last-review 를 실행해줘.
기준은 세션 5 보고서(design/gdd/gdd-cross-review-2026-10-14.md)야. 6a~6c-3 재검토에서
고친 문서들이 서로, 그리고 game-concept.md·design/registry/entities.yaml과 여전히 맞는지
확인해줘. 충돌이 있으면 어느 문서를 고칠지 나에게 물어본 뒤 고쳐줘.

active.md의 "For 6d" 목록도 함께 처리해줘. 대부분 문구·인용·상태 표기 정리야:
1. 채점기 Interactions(Playtest Log 행): hint_counted 인용 힌트 rule 4a → 4b
2. 힌트·진행·대화·매뉴얼·온보딩의 Dependencies/Cross-References에 남은 옛 상태
   (In Review → Approved), 온보딩 양방향성 메모("Puzzle Definition must list")
3. 매뉴얼 OQ1이 삭제된 조건부 watch_out을 아직 설명함
4. 샌드박스의 tokenize 소비자 목록에 Hint System 추가
5. 제약 도전 OQ2("MVP reuses base hints") 낡음; 챌린지 모드의 에디터 초안 처리와
   UNAVAILABLE 처리가 명시되지 않음
6. Playtest Log rule 4: {mark} = 온보딩 rule 7a id, manual_* {page} = manual.<slug>,
   hint_counted는 rule 4b 인용
7. 대화의 "SQLite 텍스트 항상 표시" 예외에 TOO_MANY_ROWS 빠짐
8. 진행: UNAVAILABLE 반복 시 처리, Restart가 로그에 기록되지 않음
9. 온보딩(6c-3 권고): Run 전 Submit 엣지 케이스의 "without being shown"은 1-1.run이 아니라
   1-1.submit; 1-3이 열릴 때 매뉴얼이 이미 Open이면 1-3.manual을 Done으로 볼지;
   rule 7의 "workbench rule 15" 인용
이 중 설계 결정이 필요한 것(5의 챌린지 모드 처리, 8의 UNAVAILABLE 반복·Restart 로그,
9의 매뉴얼 Open 처리)은 한 번에 묶어서 나에게 물어봐줘. 나머지는 바로 고쳐도 돼.
고친 GDD는 문서 헤더 Last Updated에 6d를 남기고, 상태는 Approved로 유지해줘
(문구·인용 정리는 재승인 대상이 아님). 규칙이 바뀌는 수정이 생기면 그 문서는 알려줘.

GDD 11개가 모두 Approved인지도 확인해서, 아니면 어떤 문서가 남았는지 알려줘.
끝나면 active.md를 갱신하고, 결과를 표로 요약하고, 커밋할지 물어봐줘.
```

끝나면 커밋 여부를 정한 뒤 세션 7 문서로 넘어가세요.
