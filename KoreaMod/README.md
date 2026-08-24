# 조선 — 국가가 되는 법 / Chosŏn — How to Become a Nation

`korea-focus-tree.html`, `korea-research-tree.html`, `korea-mod-spec.html` 세 설계 문서를
Hearts of Iron IV 1.19.2 (Operation Postern) 용 모드로 옮긴 것입니다.

설치: `Documents/Paradox Interactive/Hearts of Iron IV/mod/korea_chosen_mod.mod` 가
이 폴더를 가리키도록 이미 생성되어 있습니다. 런처의 Mods 탭에서 켜면 됩니다.

## 무엇이 들어 있나

| | 설계서 | 구현 |
|---|---|---|
| 중점 | 107개 (은닉 1) | **105개 중점 + 2개 이벤트** — 설계서의 107 노드 중 둘은 중점이 아니라 이벤트였습니다 |
| 국민정신 | 7 | 66 (시작 7 + 중점·결정으로 얻는 59) |
| 코스메틱 태그 | 5 | 6 (`KOR_jap` `KOR_chi` `KOR_usa` `KOR_csr` `KOR_sov` `KOR_ger`) |
| 장비 명명 | 76행 × 5계열 | **326개 항목** (연구 문서의 표를 그대로 이식) |
| MIO | 8 | 8 |
| 인물 | 14 | 바닐라 8인 재사용 + 신규 6인 |
| 결정 | 청구·비적·종전 7 | 15 |
| 로컬라이제이션 | 한국어·영어 | 두 벌 모두 |

중점 소요일은 설계서대로 `cost` 로 떨어집니다 (35일=5, 70일=10, 105일=15, 140일=20).

## 설계서의 핵심 장치가 어디에 있는지

- **관문 “아홉 중 다섯”** — `KOR_ind_regional_specialization`. 1티어 9개는 서로 선행이
  없고, 완료 수를 `KOR_ind_tier1` 변수로 세어 `custom_trigger_tooltip` 으로 노출합니다.
  최종 관문 `KOR_ind_korea_in_world` 는 1·2티어 합산 `KOR_ind_total > 8`.
- **유출률 회수** — `KOR_leak` 변수를 `KOR_supply_base_leak` 다이나믹 모디파이어가 매일
  읽습니다. 산업 중점마다 `KOR_recover_leakage` 가 5%p씩 되돌리고, 하한은 20%
  (‘세계 속의 조선’ 완료 후 10%).
- **육군을 가르는 축** — 이념이 아니라 `KOR_has_government_apparatus` 스크립트 트리거.
  제도군/유격 두 계열이 `allow_branch` 로 갈리고, 사관학교에서 합류합니다.
- **은닉 분기** — `KOR_infiltrate_hq` 의 `allow_branch` 가 `KOR_uiyeoldan_done` 과
  `KOR_hq_accord_signed` 두 플래그를 동시에 요구합니다. 조건 전에는 트리에 그려지지 않습니다.
- **좌우 저울** — `KOR_scale_right` / `KOR_scale_left` 변수와 결정. BBA 세력 균형 UI를
  쓰지 않으므로 DLC 의존이 없습니다.
- **승인 게이지** — `KOR_recognition`, 기본 상한 60. `KOR_lift_recognition_cap` 은
  ‘독수리 작전’ 후 국내 진공에 성공했을 때만 호출됩니다.
- **난이도 3택 / 시작 모드** — `common/game_rules/KOR_game_rules.txt`.

## 설계서와 달라진 점

1. **일본 항복 게이지 문제는 이미 없습니다.** 1.19 바닐라의 `history/states/525`,
   `527` 은 `owner = JAP` 에 `add_core_of = KOR` 만 있고 **일본 핵심주가 아닙니다.**
   설계서 §태그 설계의 가장 큰 우려는 게임이 이미 해결해 둔 상태였습니다.
2. **반도는 2개 주입니다** — 525 (경기), 527 (평안·황해). 설계서가 “설치된 버전에서
   직접 확인할 것”이라 한 부분이며, 확인 결과 둘뿐입니다.
3. **CHO 태그는 게임 규칙으로 켜고 끕니다.** 기본값은 `GOVERNORATE` 입니다 — 반도 2개
   주가 CHO로 넘어가 일본의 통합 괴뢰국이 되고, 시작 화면에서 한반도를 클릭해 바로
   플레이할 수 있습니다. 설계서의 본래 의도이자 §태그 설계의 핵심 결정입니다.
   대신 설계서가 `가장 큰 위험`으로 꼽은 일본 AI 문제가 이 경로에 있습니다 —
   `LIBERATION` 으로 바꾸면 1936년 지도를 전혀 건드리지 않고 조선은 해방 가능
   국가로만 남습니다 (일본 AI 무영향, 대신 시작 선택 불가).

   **아직 태그 교체는 없습니다.** 설계서는 저항을 택하면 CHO→KOR로 갈아탄다고 했지만,
   지금은 코스메틱 태그만 바뀝니다. 망명 상태의 KOR이 무엇을 소유하는가를 설계서가
   정하지 않았고, HOI4에서 영토 없는 나라는 즉시 항복 처리되기 때문입니다.
4. **장비 명명 키는 접미사가 아니라 접두사입니다.** 설계서 예시는
   `infantry_equipment_1_KOR_usa` 였으나 실제 형식은 `KOR_usa_infantry_equipment_1`
   입니다 (바닐라 `GER_infantry_equipment_1` 로 확인). 접두사로 구현했습니다.
5. **사단 편제 제한은 우회할 필요가 없었습니다.** 1.19에 `set_division_template_cap`
   효과가 있어 그대로 씁니다 (시작 3 → 신흥무관학교 8 → 사관학교 해제, 인민공화국 12).
   다만 ‘조선군사령부 거부권’ 쪽은 설계서대로 극단적 페널티로 구현했습니다 — 사단 편성
   자체를 금지하는 modifier는 여전히 없습니다.
6. **`economy_minister` 슬롯은 이 버전에 없습니다.** 박흥식은 `captain_of_industry`
   특성을 가진 정치 고문입니다.
7. **명명표 중 함선 행은 빠졌습니다.** 수송선·구축함·잠수함 이름은 장비 로컬라이제이션이
   아니라 함명 목록(`common/units/names_ships`)에서 오기 때문입니다.
8. **전차 행의 부수 차량 이름은 차체만 옮겼습니다.** ‘하고 · 케누 · 코히’ 같은 행에서
   자주포·구축전차·대공전차 변형은 생략했습니다.

## 확인된 것과 확인되지 않은 것

정적 검증은 끝냈습니다 — 중괄호 균형, 중점 선행/배타/상대좌표 참조 106개, 국민정신
참조, 스크립트 효과·트리거 호출, GFX 아이콘 이름, 모디파이어 이름(바닐라 사용례 대조),
그리고 두 언어의 로컬라이제이션 키 전수. 남은 미해결 참조는 없습니다.

**게임을 실제로 띄워 보지는 않았습니다.** 런타임에서만 드러나는 것들 — 중점 트리
레이아웃이 겹치는지, AI가 분기를 제대로 타는지, `GOVERNORATE` 모드에서 일본의 중일전쟁
수행이 무너지는지 — 은 직접 켜서 봐야 합니다. 설계서가 관전 모드 10회를 요구한 것이
바로 그 부분입니다.

첫 확인 순서를 추천하자면:

```bash
"C:/Program Files (x86)/Steam/steamapps/common/Hearts of Iron IV/hoi4.exe" -debug
```

`-debug` 로 켜면 `Documents/Paradox Interactive/Hearts of Iron IV/logs/error.log` 에
스크립트 오류가 쌓입니다. 콘솔에서 `tag KOR` 로 갈아타 트리를 먼저 보세요.

## 파일 구조

```
KoreaMod/
├─ common/
│  ├─ national_focus/   KOR_political(60) · KOR_industry(15) · KOR_military(19) · KOR_late(11)
│  ├─ ideas/            KOR_ideas · KOR_focus_ideas · KOR_event_ideas
│  ├─ decisions/        requisition · bandits · endgame · balance + categories
│  ├─ scripted_triggers/ · scripted_effects/
│  ├─ characters/ · country_leader/ · opinion_modifiers/
│  ├─ dynamic_modifiers/ · game_rules/ · on_actions/
│  ├─ country_tags/ · countries/ · units/names_divisions/
│  └─ military_industrial_organization/organizations/
├─ events/              KOR_triggers · KOR_politics · KOR_industry
├─ history/             countries/CHO · units/KOR_1936 · units/CHO_1936
└─ localisation/        korean/ · english/  (각 3파일)
```

정치 계열만 `focus_tree` 블록 안에 있고 산업·군사·후반은 `shared_focus` 입니다.
설계서가 파일을 다섯으로 쪼갠 이유 그대로이며, 트리 하나(`korea_focus`)를 KOR과 CHO
두 태그가 공유합니다.
