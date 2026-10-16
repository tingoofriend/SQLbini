# Standing prompt — continue from the handoff (auto)

> Used by `tools/session/auto-session.sh` / `.ps1` when `production/session-handoff.md`
> says `Next prompt: auto`. It needs no editing per session: the work comes from the
> handoff's "Next step". A session id with its own prompt file is used instead when the
> handoff names one.

```
SQLbini 프로젝트를 이어서 진행할게.
먼저 production/session-handoff.md를 읽고, production/session-state/active.md가 있으면 그것도 읽은 뒤
(없으면 다른 PC에서 이어 받은 것이니 handoff의 Carry-over를 기준으로),
design/ideas-backlog.md와 production/decision-log.md를 확인해서 현재 상태를 한국어로 짧게 요약해줘.
진행 규칙:
- 모든 답변과 질문(AskUserQuestion 포함)은 한국어로 해줘. 프로젝트 문서는 영어로 유지.
- 질문할 때는 선택지마다 게임·일정에 무엇이 바뀌는지 쉬운 말로 한 줄씩 붙여줘.
- 내가 게임 아이디어를 말하면 design/ideas-backlog.md에 바로 기록하고 적절한 단계에서 반영해줘.
- 범위가 늘어나는 결정은 반영 전에 일정 영향을 알려주고 나에게 물어봐줘.
- 정한 것은 production/decision-log.md에 남기고, 내가 고른 것과 Claude가 정한 것을 구분해줘.
- 커밋/푸시는 내가 요청할 때만 해줘.
- GDD는 모두 Approved야. GDD와 어긋나는 점을 찾으면 GDD를 바로 고치지 말고
  목록으로 모아 두었다가 나에게 물어봐줘(문구만 어긋난 것은 권고로 기록). 재검토 사이클은 만들지 마.
요약이 끝나면 handoff의 "Next step"을 진행해줘. 한 세션에 하기 너무 크면 이번 세션 범위를
먼저 제안하고 물어봐줘. 같은 세션에서 쓴 문서를 검토해야 하면 그 검토는 다음 세션으로 넘겨줘.
끝나면 active.md와 production/session-handoff.md를 갱신하고(Updated, Next prompt — 보통 auto,
Next machine, Auto-continue, Next step, Carry-over), 커밋할지 물어봐줘.
마지막 줄에 "다음 세션으로 넘어가려면 /exit 를 입력하세요"라고 알려줘.
```
