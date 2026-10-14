# 다음 세션 프롬프트 모음

> 작성: 2026-10-14 · 프로젝트: SQLbini (Godot 4.7.2 / GDScript)
> 현재 단계: **Systems Design** — MVP GDD 11개 작성 완료(모두 "Designed", 독립 검토 대기)
> 마지막 커밋: `693b34f` (origin/main에 푸시됨)

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

## 세션 7 — Technical Setup 게이트

```
이번 세션 작업: /gate-check technical-setup 을 실행해줘.
Concept 게이트에서 받아들인 위험(production/gate-checks/2026-10-14-concept-to-systems-design-rerun.md)이
해결됐는지도 함께 확인해줘.
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
