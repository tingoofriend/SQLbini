# 다음 세션 프롬프트 모음

> 작성: 2026-10-14 (갱신 2026-10-15) · 프로젝트: SQLbini (Godot 4.7.2 / GDScript)
> 현재 단계: **Systems Design** — 세션 6a~6f 완료: 6f 재검토에서 Progression·Dialogue NEEDS REVISION(사이드 요청 Open 시점) → 수정 → In Review (**MVP GDD 11개 중 9개 Approved**) → 세션 7(0단계에서 두 문서 6f 수정분 확인 후 게이트)
> 마지막 커밋: `3bcd868` (6e 재검토와 수정)

> 세션별 문서(공통 프롬프트 포함, 블록 하나만 복사): `production/session-prompts/session-N-*.md`

각 세션은 **새 Claude Code 세션**에서 시작하세요(`/clear` 또는 새 터미널).
아래 프롬프트를 그대로 복사해 붙여 넣으면 됩니다. 순서대로 진행하는 것을 권장합니다.

---

## 공통 시작 프롬프트 (모든 세션의 첫 메시지로 사용)

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
```

---

## 세션 1 — 기반 GDD 독립 검토 (채점기, 퍼즐 정의)

```
이번 세션 작업: 기반 GDD 두 개를 독립 검토해줘.
1. /design-review design/gdd/hidden-data-grader.md
2. /design-review design/gdd/puzzle-definition-and-datasets.md
두 문서는 서로 계약(키 컬럼, 함정 태그, 피드백 단계)을 맺고 있으니, 한쪽을 고치면
다른 쪽도 맞는지 확인해줘. 검토 결과는 각 review-log에 남기고,
NEEDS REVISION이면 차단 항목을 고친 뒤 systems-index의 상태를 갱신해줘.
끝나면 결과를 표로 요약하고 커밋할지 물어봐줘.
```

## 세션 2 — 기반 GDD 독립 검토 (샌드박스, 워크벤치)

```
이번 세션 작업: 다음 GDD 두 개를 독립 검토해줘.
1. /design-review design/gdd/sql-execution-sandbox.md
2. /design-review design/gdd/query-workbench.md
샌드박스는 godot-sqlite 시험 결과(prototypes/sqlbini-spike-2026-10-14/SPIKE-NOTE.md 부록)를
근거로 했으니 주장과 근거가 맞는지 확인해줘. 워크벤치는 120px 픽셀 계산대 장면이 들어간
배치(rows_visible 7)가 반영됐는지 확인해줘.
끝나면 결과를 표로 요약하고 커밋할지 물어봐줘.
```

## 세션 3 — 기능 GDD 독립 검토 (힌트, 제약 도전, 진행)

```
이번 세션 작업: 다음 GDD 세 개를 독립 검토해줘.
1. /design-review design/gdd/hint-system.md
2. /design-review design/gdd/constraint-challenges.md
3. /design-review design/gdd/shift-and-chapter-progression.md
끝나면 결과를 표로 요약하고 커밋할지 물어봐줘.
```

## 세션 4 — 표현·메타 GDD 독립 검토 (대화, 매뉴얼, 온보딩, 기록)

```
이번 세션 작업: 다음 GDD 네 개를 독립 검토해줘.
1. /design-review design/gdd/request-and-reaction-dialogue.md
2. /design-review design/gdd/store-manual.md
3. /design-review design/gdd/onboarding-first-shift.md
4. /design-review design/gdd/playtest-log.md
문맥이 70%를 넘으면 남은 문서는 다음 세션으로 넘겨줘.
끝나면 결과를 표로 요약하고 커밋할지 물어봐줘.
```

## 세션 5 — GDD 전체 일관성 검토

```
이번 세션 작업: /review-all-gdds 를 실행해줘.
MVP GDD 11개와 game-concept.md, design/registry/entities.yaml 사이의
값·계약·용어가 서로 맞는지 확인하고, 충돌이 있으면 어느 문서를 고칠지 나에게 물어봐줘.
```

## 세션 6 — 아트 바이블

```
이번 세션 작업: /art-bible 을 실행해줘.
반드시 반영할 것:
- design/ideas-backlog.md #1: 분위기는 약간 aesthetic, cozy
- #2: 픽셀 아트 계산대 장면(320x30 → ×4) + 깔끔한 UI(에디터·결과 표는 꾸밈 없이 고대비)
- game-concept.md의 Visual Identity Anchor "Behind the Counter"를 더 따뜻한 톤으로 다듬기
- 각 GDD의 Visual/Audio 섹션(art-director 임시 제안)과의 일관성, contrast_min 4.5:1
끝나면 백로그 #1 상태를 applied로 바꿔줘.
```

## 세션 6a — 기반 GDD 재검토 (채점기, 퍼즐 정의, 샌드박스) — ✅ 완료 2026-10-14 (세 문서 모두 Approved)

```
이번 세션 작업: 기반 GDD 세 개를 독립 재검토해줘.
1. /design-review design/gdd/hidden-data-grader.md
2. /design-review design/gdd/puzzle-definition-and-datasets.md
3. /design-review design/gdd/sql-execution-sandbox.md
세 문서는 계약(UNAVAILABLE·build_message, TOO_MANY_ROWS, grader_row_cap, tokenize,
manual_pages·prefill_sql 필드)으로 묶여 있으니 한쪽을 고치면 다른 쪽도 맞는지 확인해줘.
이번 검토는 세션 5 교차 검토(design/gdd/gdd-cross-review-2026-10-14.md, 커밋 6b244c0)
이후의 재검토야. 각 review-log의 이전 차단 항목이 해결됐는지, 교차 검토의
"Resolution" 결정(UNAVAILABLE, manual_pages, hint_counted, Day One, 말풍선/노트 분리 등)이
문서에 맞게 들어갔는지 확인해줘. /ux-design·플레이테스트로 미룬 항목은 차단 항목이 아니야.
결과는 각 review-log에 남기고, APPROVED면 systems-index 상태를 Approved로 바꿔줘.
NEEDS REVISION이면 차단 항목을 어떻게 고칠지 나에게 물어본 뒤 고치고, 상태는 In Review로
두고 다음 새 세션에서 다시 검토하도록 active.md에 적어줘.
끝나면 결과를 표로 요약하고 커밋할지 물어봐줘.
```

## 세션 6b — 기능 GDD 재검토 (워크벤치, 힌트, 제약 도전) — ✅ 완료 2026-10-14 (워크벤치·제약 도전 Approved, 힌트 수정 → 6c-2)

```
이번 세션 작업: 다음 GDD 세 개를 독립 재검토해줘.
1. /design-review design/gdd/query-workbench.md
2. /design-review design/gdd/hint-system.md
3. /design-review design/gdd/constraint-challenges.md
힌트의 '직전과 다른 쿼리만 카운트'(rule 4a)와 챌린지 모드 규칙(힌트 숨김, 메인 요청 시계 정지,
rule 6a/6b)이 세 문서에서 같은지 확인해줘.
6a에서 채점기의 중립 메모 문구(rule 12 표)와 rule 7a(visible 재실행 오류 → SUBMIT_ERROR, 미카운트)가
바뀌었으니 워크벤치의 노트·스트립 설명이 그와 맞는지 확인해줘. 채점기 리뷰 권고대로, TOO_MANY_ROWS
스트립 고정 문구를 워크벤치의 "{grader_row_cap}+ rows — too many to compare"와 맞출지도 봐줘
(design/gdd/reviews/hidden-data-grader-review-log.md 마지막 항목).
이번 검토는 세션 5 교차 검토(design/gdd/gdd-cross-review-2026-10-14.md, 커밋 6b244c0)
이후의 재검토야. 각 review-log의 이전 차단 항목이 해결됐는지, 교차 검토의
"Resolution" 결정(UNAVAILABLE, manual_pages, hint_counted, Day One, 말풍선/노트 분리 등)이
문서에 맞게 들어갔는지 확인해줘. /ux-design·플레이테스트로 미룬 항목은 차단 항목이 아니야.
결과는 각 review-log에 남기고, APPROVED면 systems-index 상태를 Approved로 바꿔줘.
NEEDS REVISION이면 차단 항목을 어떻게 고칠지 나에게 물어본 뒤 고치고, 상태는 In Review로
두고 다음 새 세션에서 다시 검토하도록 active.md에 적어줘.
끝나면 결과를 표로 요약하고 커밋할지 물어봐줘.
```

## 세션 6c — 진행·표현·메타 GDD 재검토 (진행, 대화, 매뉴얼, 온보딩, 기록) — ✅ 완료 2026-10-15 (Playtest Log Approved, 나머지 4개 수정 → 6c-2)

```
이번 세션 작업: 다음 GDD 다섯 개를 독립 재검토해줘.
1. /design-review design/gdd/shift-and-chapter-progression.md
2. /design-review design/gdd/request-and-reaction-dialogue.md
3. /design-review design/gdd/store-manual.md
4. /design-review design/gdd/onboarding-first-shift.md
5. /design-review design/gdd/playtest-log.md
대화 문서는 6a에서 rule 2가 바뀌었어(fail.generic 음성 대사에는 컬럼 내용·순서 조언을 넣지 않고,
채점기 중립 메모에만 둠). 그게 맞게 들어갔는지 보고, 오류 표의 TOO_MANY_ROWS 행이 "visible pre-check에서만"
이라고 적혀 있는데 채점기 rule 7a 이후 determinism 실행의 truncated에서도 나니 함께 고쳐줘
(design/gdd/reviews/hidden-data-grader-review-log.md 마지막 항목).
문맥이 70%를 넘으면 남은 문서는 다음 세션으로 넘겨줘(active.md에 기록).
이번 검토는 세션 5 교차 검토(design/gdd/gdd-cross-review-2026-10-14.md, 커밋 6b244c0)
이후의 재검토야. 각 review-log의 이전 차단 항목이 해결됐는지, 교차 검토의
"Resolution" 결정(UNAVAILABLE, manual_pages, hint_counted, Day One, 말풍선/노트 분리 등)이
문서에 맞게 들어갔는지 확인해줘. /ux-design·플레이테스트로 미룬 항목은 차단 항목이 아니야.
결과는 각 review-log에 남기고, APPROVED면 systems-index 상태를 Approved로 바꿔줘.
NEEDS REVISION이면 차단 항목을 어떻게 고칠지 나에게 물어본 뒤 고치고, 상태는 In Review로
두고 다음 새 세션에서 다시 검토하도록 active.md에 적어줘.
끝나면 결과를 표로 요약하고 커밋할지 물어봐줘.
```

## 세션 6c-2 — 수정 후 재검토 (힌트, 진행, 대화, 매뉴얼, 온보딩) — ✅ 완료 2026-10-15 (4개 Approved, 온보딩 수정 → 6c-3)

```
이번 세션 작업: 6b·6c에서 NEEDS REVISION → 수정된 GDD 다섯 개를 독립 재검토해줘.
1. /design-review design/gdd/hint-system.md
2. /design-review design/gdd/shift-and-chapter-progression.md
3. /design-review design/gdd/request-and-reaction-dialogue.md
4. /design-review design/gdd/store-manual.md
5. /design-review design/gdd/onboarding-first-shift.md
각 review-log 마지막 항목의 차단 항목과 "Revised in-session" 메모를 기준으로, 고친 내용이
제대로 들어갔고 다른 문서와 맞는지 확인해줘. 특히:
- 힌트: rule 4b hint_counted(채점기 → Playtest Log 전달), tokenize 정규화, shown(p), 챌린지 모드 예외
- 진행 ↔ 워크벤치: Restart(rule 12a)를 워크벤치가 구독(워크벤치 rule 14, 엣지 케이스, QW-30)
- 진행 ↔ 대화: skip.offer / skip.accept, side kind, 대화 rule 3b, RD-21, PR-18·PR-21
- 매뉴얼: 조건부 watch_out 삭제, rule_tag + trap_rules CI 검사(rule 3a, SM-01, SM-22)
- 온보딩: rule 7a 코치마크 표(1-1.run, 1-1.submit, 1-2.schema, 1-3.manual), 1-2는 스키마 마크만
수정은 요청 범위만 다뤘으니, 전체 문서를 다시 읽되 이미 기록된 권고(RECOMMENDED)를
새 차단 항목으로 올리지는 마. /ux-design·플레이테스트로 미룬 항목도 차단 항목이 아니야.
문맥이 70%를 넘으면 남은 문서는 다음 세션으로 넘겨줘(active.md에 기록).
결과는 각 review-log에 남기고, APPROVED면 systems-index 상태와 문서 헤더를 Approved로 바꿔줘.
NEEDS REVISION이면 차단 항목을 어떻게 고칠지 나에게 물어본 뒤 고치고, 상태는 In Review로
두고 다음 새 세션에서 다시 검토하도록 active.md에 적어줘.
끝나면 결과를 표로 요약하고, GDD 11개 중 몇 개가 Approved인지 알려주고, 커밋할지 물어봐줘.
```

## 세션 6c-3 — 온보딩 재검토 — ✅ 완료 2026-10-15 (온보딩 Approved, 11개 모두 Approved)

```
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

## 세션 6d — 재검토 후 교차 일관성 확인 — ✅ 완료 2026-10-15 (CONCERNS → 모두 반영, 11개 Approved 유지)

```
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

## 세션 6e — 6d 규칙 변경 확인 재검토 — ✅ 완료 2026-10-15 (CC·Onboarding APPROVED; Progression·Dialogue NEEDS REVISION → 수정, In Review)

> 건너뛰어도 됩니다: 6d 수정은 사용자 결정에 따른 작은 규칙 명시이고 상태는 Approved로 유지됐습니다.

```
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

## 세션 6f — 6e 수정 확인 재검토 — ✅ 완료 2026-10-15 (Progression·Dialogue NEEDS REVISION → 수정, In Review)

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

## 세션 7 — 6f 수정 확인 + Technical Setup 게이트

```
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

---

## 그 사이에 직접 해야 할 일 (Claude가 대신할 수 없음)

- **플레이테스트**: SQL을 전혀 모르는 3명 + 조금 아는 3명. 진행 방법과 판정 기준은
  `design/gdd/game-concept.md` → MVP Definition의 측정 표 참고.
  1챕터 요청 1-4/1-5/1-7/1-8은 아직 "경계값을 말해 주는" 옛 문구이니, 가능하면
  다시 쓴 뒤에 테스트하는 것이 좋습니다(퍼즐 문구 재작성은 레벨 디자인 단계에서 진행).
- 필요 없으면 `prototypes/sqlbini-web/production/`, `design/gdd/production/` 폴더(세션 종료 훅이
  작업 폴더 기준으로 남긴 로그) 삭제.

## 참고 위치

| 무엇 | 어디 |
|---|---|
| 세션 상태 | `production/session-state/active.md` |
| 결정 기록 | `production/session-logs/decision-log.md` |
| 컨셉 | `design/gdd/game-concept.md` |
| 시스템 목록·설계 순서 | `design/gdd/systems-index.md` |
| 공유 값(레지스트리) | `design/registry/entities.yaml` |
| 교차 검토 보고서 | `design/gdd/gdd-cross-review-2026-10-15.md` (최신), `-2026-10-14.md` |
| 게이트 보고서 | `production/gate-checks/` |
| 프로토타입·스파이크 | `prototypes/` (`index.md`) |
