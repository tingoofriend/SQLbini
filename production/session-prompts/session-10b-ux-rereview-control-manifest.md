# 세션 10b — UX 스펙 재검토 + 컨트롤 매니페스트 갱신 (Technical Setup)

> 선행 세션: 세션 10(아키텍처 재검토 CONCERNS → ADR-0007·0010 수정 후 Accepted, ADR 7개 모두 Accepted,
> `/ux-review` 워크벤치·shift-flow NEEDS REVISION → 같은 세션에서 스펙 수정, 커밋 `2d27d33`, `e0b734b`)
> 사용법: **새 Claude Code 세션**(`06.Game_Studio` 폴더에서 시작)을 열고, 아래 블록 전체를 그대로 복사해 첫 메시지로 붙여 넣으세요.
> 자동 시작: 프로젝트 폴더의 터미널에서 `tools/session/start-session.sh 10b` — 새 세션을 열고 아래 블록을 첫 메시지로 넣습니다(`--print` / `-Print`로 내용만 확인).
> 반드시 새 세션: UX 스펙 3개는 세션 10에서 수정했으므로, 같은 세션의 재검토는 무효입니다.
> Linux에서 진행 가능합니다(Windows 불필요).

```
SQLbini 프로젝트를 이어서 진행할게.
먼저 production/session-state/active.md, design/gdd/systems-index.md,
design/ideas-backlog.md, production/decision-log.md를 읽고 현재 상태를 한국어로 짧게 요약해줘.
진행 규칙:
- 모든 답변과 질문(AskUserQuestion 포함)은 한국어로 해줘. 프로젝트 문서는 영어로 유지.
- 질문할 때는 선택지마다 게임·일정에 무엇이 바뀌는지 쉬운 말로 한 줄씩 붙여줘.
- 내가 게임 아이디어를 말하면 design/ideas-backlog.md에 바로 기록하고 적절한 단계에서 반영해줘.
- 범위가 늘어나는 결정은 반영 전에 일정 영향을 알려주고 나에게 물어봐줘.
- 정한 것은 production/decision-log.md에 남기고, 내가 고른 것과 Claude가 정한 것을 구분해줘.
- 커밋/푸시는 내가 요청할 때만 해줘.
- GDD는 모두 Approved야. GDD와 어긋나는 점을 찾으면 GDD를 바로 고치지 말고
  목록으로 모아 두었다가 나에게 물어봐줘(문구만 어긋난 것은 권고로 기록). 재검토 사이클은 만들지 마.
요약이 끝나면 아래 이번 세션 작업을 진행해줘.

이번 세션 작업은 세 단계야.
1. /ux-review 를 세 번 실행해줘: design/ux/query-workbench.md, design/ux/shift-flow.md,
   design/ux/interaction-patterns.md(patterns). 세 문서 모두 세션 10에서 /ux-review 지적과 내 결정
   (에러 띠는 에디터 아래, 편집하면 채점 결과 지움, 챕터 완료 화면, 챌린지 중 Shift 버튼 비활성 +
   "Leave the dare first")으로 수정됐어. 지난 지적(active.md의 "Session Extract — /ux-review
   2026-10-16"과 세션 10 체크포인트)이 해결됐는지, 두 스펙과 IP-22(Shift 메뉴) 정의가 글자 그대로 같은지,
   design/accessibility-requirements.md와 Accepted ADR(특히 ADR-0010 신호, ADR-0007 Settings,
   ADR-0004 §4 F9)과 맞는지 확인해줘. 스펙에 남은 열린 항목(정렬 퍼즐 안내 문구 임시안, 부팅 실패 화면
   Quit만, Ctrl+Shift+S와 CodeEdit 충돌 여부, 2.0에서 두 줄 탭)도 결정이 필요하면 물어봐줘.
2. 문제없는 스펙은 상태를 Approved로 바꿀지 하나씩 물어봐줘. 문제가 있으면 고칠 내용을 먼저 보여줘
   (이 세션에서 고친 스펙은 다시 새 세션에서 검토해야 하니, 문구 수준이면 권고로만 남기는 쪽도 제안해줘).
3. /create-control-manifest 를 다시 실행해서 ADR-0007·0010(Accepted)과 세션 10의 ADR 문구 보정을 반영해줘.
끝나면 active.md를 갱신하고, 남은 Technical Setup 항목(Windows 세션 11: 스파이크 → ADR-0005 →
export·commands.build → /gate-check pre-production)을 순서대로 알려주고 커밋할지 물어봐줘.
```

끝나면 커밋 여부를 정한 뒤 세션 11 문서(`session-11-windows-spike-adr-0005.md`)로 넘어가세요.

## 이 세션에서 다루지 않는 것 (수용한 위험 — 별도로 처리)

- GDD 문구 권고 약 25건(active.md "GDD wording notes") — 묶어서 한 번에 처리할 때까지 보류
- ADR-0008(에디터: CodeEdit·IME·AccessKit), ADR-0009(카운터 띠): 해당 스토리 전까지
- Concept 재검토, 제로-SQL 플레이테스트 날짜, 1챕터 요청 1-4/1-5/1-7/1-8 문구 재작성
- 첫 푸시(GitHub CI 첫 실행) — 원할 때
