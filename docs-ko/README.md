# ClaudeCode 시스템 개발 문서

ClaudeCode 자율 소프트웨어 개발 시스템의 문서 모음입니다.  
**Triple Loop 아키텍처**와 7개 Agent 팀으로 지속적인 자율 소프트웨어 개발을 실현합니다.

---

## 빠른 탐색

| 목표 | 문서 |
|------|------|
| 5분 빠른 시작 | [빠른 시작 가이드](../docs-en/QuickStart.md) |
| 아키텍처 이해 | [아키텍처 개요](../docs-en/ArchitectureOverview.md) |
| Claude Code 설정 | [설정 가이드](../docs-en/SettingsGuide.md) (영문) |

---

## 시스템 개요

Triple Loop 아키텍처는 Claude가 Monitor → Build → Verify 3단계를 자율적으로 반복합니다:

```
┌─────────────────────────────────────────────────────┐
│         ClaudeCode 자율 개발 시스템                    │
│                                                     │
│  ┌────────────┐  ┌────────────┐  ┌──────────────┐  │
│  │Monitor 루프 │→ │ Build 루프 │→ │ Verify 루프  │  │
│  │(모니터·계획) │  │(구현·구축)  │  │(검증·확인)   │  │
│  └────────────┘  └────────────┘  └──────────────┘  │
│        ↑                                  │         │
│        └──────────────────────────────────┘         │
│                  자율 루프 계속                       │
└─────────────────────────────────────────────────────┘
```

### Claude Code 2.0 주요 기능

| 기능 | 설명 |
|------|------|
| **Checkpoints** | 모든 도구 호출 전 자동 저장; `/rewind` 또는 `Esc×2`로 복원 |
| **VS Code 확장** | 네이티브 사이드바, 인라인 diff |
| **Hooks** | 10+ 라이프사이클 이벤트 |
| **서브 Agent** | 병렬 작업 위임 |
| **MCP** | Slack/Jira/GitHub/DB 외부 연동 |
| **Agent SDK** | 커스텀 Agent 구축 |

---

## 빠른 설치

```bash
# Claude Code CLI 설치
npm install -g @anthropic-ai/claude-code

# 인증
claude auth login

# 템플릿 복사
cp -r templates/.claude /path/to/your-project/.claude

# 시작
claude
```

---

### 📁 [08_튜토리얼(Tutorials)](<../08_チュートリアル(Tutorials)/>)
단계별 실습 가이드입니다.

| 파일 | 내용 |
|------|------|
| [01_처음으로 TripleLoop 실행](<../08_チュートリアル(Tutorials)/01_初めてのTripleLoop実行(FirstTripleLoop).md>) | Triple Loop 15H 첫 번째 실행 절차 |
| [05_서브에이전트 병렬 실행](<../08_チュートリアル(Tutorials)/05_サブエージェント並列実行(SubagentParallel).md>) | 병렬 서브에이전트로 고속 개발 |

### 📁 [09_사례집(UseCases)](<../09_事例集(UseCases)/>)
실제 프로젝트 적용 사례 및 성공 패턴입니다.

| 파일 | 내용 |
|------|------|
| [03_인시던트 대응 활용 사례](<../09_事例集(UseCases)/03_インシデント対応活用事例(IncidentResponseCase).md>) | 야간 장애를 45분에 해결 |
| [04_Python_FastAPI 적용 사례](<../09_事例集(UseCases)/04_Python_FastAPI適用事例(PythonFastAPICase).md>) | 테스트 커버리지 58%→88% |

---

## 라이선스

[MIT License](../LICENSE)
