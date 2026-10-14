# 다음 세션 프롬프트 모음

> 작성: 2026-10-14 · 프로젝트: SQLbini (Godot 4.7.2 / GDScript)
> 현재 단계: **Systems Design** — 세션 6(아트 바이블)·6a 완료: 채점기·퍼즐 정의·샌드박스 **Approved**, 나머지 8개 In Review → 6b~6d 재검토 → 세션 7
> 마지막 커밋: `1fe20f0` (채점기 재검토 APPROVED)

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

## 세션 6b — 기능 GDD 재검토 (워크벤치, 힌트, 제약 도전)

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

## 세션 6c — 진행·표현·메타 GDD 재검토 (진행, 대화, 매뉴얼, 온보딩, 기록)

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

## 세션 6d — 재검토 후 교차 일관성 확인

```
이번 세션 작업: /review-all-gdds since-last-review 를 실행해줘.
기준은 세션 5 보고서(design/gdd/gdd-cross-review-2026-10-14.md)야. 6a~6c 재검토에서
고친 문서들이 서로, 그리고 game-concept.md·design/registry/entities.yaml과 여전히 맞는지
확인하고, 충돌이 있으면 어느 문서를 고칠지 나에게 물어봐줘.
GDD 11개가 모두 Approved인지도 확인해서, 아니면 어떤 문서가 남았는지 알려줘.
끝나면 결과를 표로 요약하고 커밋할지 물어봐줘.
```

## 세션 7 — Technical Setup 게이트

```
이번 세션 작업: /gate-check technical-setup 을 실행해줘.
Concept 게이트에서 받아들인 위험(production/gate-checks/2026-10-14-concept-to-systems-design-rerun.md)이
해결됐는지도 함께 확인해줘.
시작 전에 6a~6d 재검토가 끝나 MVP GDD 11개가 모두 Approved인지 먼저 확인하고,
아니면 게이트를 돌리지 말고 남은 문서를 알려줘.
```

---

## 그 사이에 직접 해야 할 일 (Claude가 대신할 수 없음)

- **플레이테스트**: SQL을 전혀 모르는 3명 + 조금 아는 3명. 진행 방법과 판정 기준은
  `design/gdd/game-concept.md` → MVP Definition의 측정 표 참고.
  1챕터 요청 1-4/1-5/1-7/1-8은 아직 "경계값을 말해 주는" 옛 문구이니, 가능하면
  다시 쓴 뒤에 테스트하는 것이 좋습니다(퍼즐 문구 재작성은 레벨 디자인 단계에서 진행).
- 필요 없으면 `prototypes/sqlbini-web/production/` 폴더(훅이 남긴 로그) 삭제.

## 참고 위치

| 무엇 | 어디 |
|---|---|
| 세션 상태 | `production/session-state/active.md` |
| 결정 기록 | `production/session-logs/decision-log.md` |
| 컨셉 | `design/gdd/game-concept.md` |
| 시스템 목록·설계 순서 | `design/gdd/systems-index.md` |
| 공유 값(레지스트리) | `design/registry/entities.yaml` |
| 게이트 보고서 | `production/gate-checks/` |
| 프로토타입·스파이크 | `prototypes/` (`index.md`) |
