# 조선 — 국가가 되는 법

*[English](README.md) · 한국어*

`docs/korea-focus-tree.html`, `docs/korea-research-tree.html`, `docs/korea-mod-spec.html`
세 설계 문서를 Hearts of Iron IV 1.19.2 (Operation Postern) 용 모드로 옮긴 것입니다.
브라우저로 그냥 열면 됩니다 — 중점 트리 107 노드, 장비 명명표, 태그 설계가 전부
그 안에 있고, 구현이 설계와 갈라진 자리는 아래 “설계서와 달라진 점”에 적어 뒀습니다.

## 설치

`Documents/Paradox Interactive/Hearts of Iron IV/mod/korea_chosen_mod.mod` 가
저장소의 `KoreaMod/` 폴더를 가리키게 하고 런처의 Mods 탭에서 켜면 됩니다.
`KoreaMod.zip` 은 같은 폴더를 그대로 압축한 것으로, 저장소를 클론하지 않고
설치할 때 씁니다 — 소스를 고쳤으면 이 zip도 다시 말아야 합니다.

## 무엇이 들어 있나

| | 설계서 | 구현 |
|---|---|---|
| 중점 | 107개 (은닉 1) | **105개 중점 + 2개 이벤트** — 설계서의 107 노드 중 둘은 중점이 아니라 이벤트였습니다 |
| 국민정신 | 7 | 66 (시작 7 + 중점·결정으로 얻는 59) |
| 코스메틱 태그 | 5 | 11 — 명명 6 (`KOR_jap` `KOR_chi` `KOR_usa` `KOR_csr` `KOR_sov` `KOR_ger`) + 국명 5 (`KOR_peoples_republic` `KOR_dominion` `KOR_empire` `KOR_dominion_ger` `KOR_empire_ger`) |
| 장비 명명 | 76행 × 5계열 | **678개 항목** — 연구 문서의 표 326개 + 국명 태그 5개분 사본 |
| MIO | 8 | 8 |
| 인물 | 14 | 바닐라 8인 재사용 + 신규 6인 |
| 결정 | 청구·비적·종전 7 | 15 |
| 로컬라이제이션 | 한국어·영어 | 두 벌 모두 |
| 국기 | — | 16종 — 13종은 바닐라에서 옮겨 담고, 3종은 직접 그림 ([국기](#국기) 참조) |

중점 소요일은 설계서대로 `cost` 로 떨어집니다 (35일=5, 70일=10, 105일=15, 140일=20).

이벤트는 12개입니다. 중점·결정에서 부르는 6개와, 반도에 그냥 닥치는 6개 —
1937년 7월 병참기지화, 1941년 10월 수풍 발전 개시, 1941년 12월 대일 선전성명서,
1942년 10월 조선어학회 사건, 1944년 4월 징병제, 그리고 일본이 항복하는 날
자치의회가 무너지는 이벤트입니다. 마지막 것은 `CHO_autonomous_assembly` 의 툴팁이
붉은 글씨로 약속하던 바로 그 붕괴입니다. 날짜 이벤트는
`KOR_wartime_events` 스크립트 효과 한 곳에 모여 있고 KOR·CHO 양쪽 일일
on_action 에서 부릅니다.

## 설계서의 핵심 장치가 어디에 있는지

- **관문 “아홉 중 다섯”** — `KOR_ind_regional_specialization`. 1티어 9개는 서로 선행이
  없고, 완료 수를 `KOR_ind_tier1` 변수로 세어 `custom_trigger_tooltip` 으로 노출합니다.
  최종 관문 `KOR_ind_korea_in_world` 는 1·2티어 합산 `KOR_ind_total > 8`.
- **유출률 회수** — `KOR_leak` 변수를 `KOR_supply_base_leak` 다이나믹 모디파이어가 매일
  읽습니다. 산업 중점마다 `KOR_recover_leakage` 가 5%p씩 되돌리고, 하한은 20%
  (‘세계 속의 조선’ 완료 후 10%).
- **육군을 가르는 축** — 이념이 아니라 `KOR_has_government_apparatus` 스크립트 트리거.
  제도군/유격 두 계열이 `allow_branch` 로 갈리고, 사관학교에서 합류합니다.
- **정치 5계열의 개방** — 계열 머리 넷은 1936년 1월부터 §회색으로 보이고§, 8월 25일
  일장기 말소 사건이 어느 쪽을 풀지 결정합니다. `allow_branch` 대신 `available` +
  `custom_trigger_tooltip` 을 쓴 이유는, 숨겨 버리면 첫 여덟 달 동안 트리에
  갈림길이 있다는 사실 자체가 보이지 않기 때문입니다. 진짜 은닉은 경성 계획뿐입니다.
- **은닉 분기** — `KOR_infiltrate_hq` 의 `allow_branch` 가 `KOR_uiyeoldan_done` 과
  `KOR_hq_accord_signed` 두 플래그를 동시에 요구합니다. 조건 전에는 트리에 그려지지 않습니다.
- **좌우 저울** — `KOR_scale_right` / `KOR_scale_left` 변수와 결정. BBA 세력 균형 UI를
  쓰지 않으므로 DLC 의존이 없습니다.
- **승인 게이지** — `KOR_recognition`, 기본 상한 60. `KOR_lift_recognition_cap` 은
  ‘독수리 작전’ 후 국내 진공에 성공했을 때만 호출됩니다.
- **난이도 3택 / 시작 모드** — `KoreaMod/common/game_rules/KOR_game_rules.txt`.

## 게이지가 게임을 누르는 방식

숫자를 움직일 수 있다고 해서 시스템이 되는 것은 아닙니다. 플레이하는 동안 그 숫자를
읽는 것이 있어야 시스템입니다. 유출률은 처음부터 그렇게 되어 있었고 —
`KOR_supply_base_leak` 다이나믹 모디파이어가 `KOR_leak` 을 매일 읽습니다 — 나머지
둘은 그렇지 않았습니다. 승인 게이지와 좌우 저울은 결정 창을 열 때만 읽혔고, 그
사이에는 아무 일도 하지 않는 숫자였습니다. 이제 셋 다 같은 방식으로 작동합니다.

| 게이지 | 매일 읽는 것 | 효과 |
|---|---|---|
| `KOR_leak` | `KOR_supply_base_leak` | 공장·조선소 산출 감소 |
| `KOR_recognition` | `KOR_allied_standing` | 정치력·전쟁 지지도 (0에서 0, 상한 60에서 정치력 +15%) |
| `KOR_scale_right` | `KOR_united_front_strain` | 50에서 멀어질수록 안정도 하락, 남은 절반의 열의 상승 |

파생 변수는 `KOR_refresh_gauges` 가 하루 한 번 계산하며 KOR·CHO 양쪽 일일
on_action 에서 부릅니다. 승인 게이지의 자연 감소도 여기로 옮겨, 두 태그가 같은
규칙을 따릅니다. 쓰이기만 하고 읽히지 않던 `KOR_scale_left` 도 여기서 갱신됩니다.

**이념은 압력으로 쌓입니다.** 시작 지지도는 100/0/0/0 이 아니라 중도 90 · 민주 5 ·
공산 5 입니다. `KOR_divided_movement` 가 매일 민주·공산으로 각각 0.02씩 밀고,
`KOR_governorate_police` 가 정확히 그 합만큼(0.04) 중도로 되밉니다. 경찰이 있는
동안 반도는 제자리에 서 있고, `KOR_restore_sovereignty` 가 경찰을 걷어내는 날부터
움직이기 시작합니다. 정치 트리의 갈림길이 스위치가 아니라 쌓이는 압력이 되는
지점입니다.

**병참기지는 1936년 1월 1일부터 붙습니다.** 전에는 `KOR_logistics_base` 중점을
찍어야 국민정신과 다이나믹 모디파이어가 붙었습니다. 그때까지 `KOR_setup_leakage`
는 아무도 읽지 않는 유출률을 계산하고 있었고, 산업 중점의 5%p 회수는 아직 붙지도
않은 모디파이어에서 깎이고 있었습니다. 시작 시 부여로 옮기고, 중점 쪽은
`KOR_ensure_supply_base` 로 중복 부여를 막습니다.

## 설계서와 달라진 점

1. **일본 항복 게이지 문제는 이미 없습니다.** 1.19 바닐라의 `history/states/525`,
   `527` 은 `owner = JAP` 에 `add_core_of = KOR` 만 있고 **일본 핵심주가 아닙니다.**
   설계서 §태그 설계의 가장 큰 우려는 게임이 이미 해결해 둔 상태였습니다.
2. **반도는 6개 주입니다** — 525 경기, 527 평안·황해, 1028 함경, 1029 강원,
   1030 경상, 1031 충청·전라. 여섯 모두 `owner = JAP` 에 `add_core_of = KOR` 이고
   일본 핵심주는 하나도 없습니다. 설계서가 “설치된 버전에서 직접 확인할 것”이라 한
   부분입니다. 주 단위 효과를 쓰는 곳은 실제 지리에 맞췄습니다 — 흥남·무산·아오지는
   함경(1028), 수풍·겸이포는 평안·황해(527), 조선중공업은 부산이 있는 경상(1030),
   경성방직·경인 공업지대는 경기(525), 남면북양의 목화는 충청·전라(1031)입니다.
   반도 전체를 가리켜야 하는 곳은 `is_core_of = KOR` 로 씁니다 — 주 번호를 두 번
   적지 않으려고 `KOR_seize_the_peninsula` 와 `KOR_return_peninsula_to_japan` 두
   스크립트 효과에 모아 뒀습니다.
3. **CHO 태그는 게임 규칙으로 켜고 끕니다.** 기본값은 `GOVERNORATE` 입니다 — 반도 2개
   주가 CHO로 넘어가 일본의 통합 괴뢰국이 되고, 시작 화면에서 한반도를 클릭해 바로
   플레이할 수 있습니다. 설계서의 본래 의도이자 §태그 설계의 핵심 결정입니다.
   소유권 자체는 `KoreaMod/history/states/525`, `527` 에서 선언합니다 — 국가 선택 화면은
   history 파일만 읽으므로, on_startup 에서 옮기면 선택 화면에서는 반도가 일본령이다가
   시작하는 순간 갈라져 나오고 CHO를 고를 수도 없습니다. startup 에 남은 것은 종속
   관계뿐이라 다시 그릴 지도가 없습니다.
   대신 설계서가 `가장 큰 위험`으로 꼽은 일본 AI 문제가 이 경로에 있습니다 —
   `LIBERATION` 으로 바꾸면 1936년 지도를 전혀 건드리지 않고 조선은 해방 가능
   국가로만 남습니다 (일본 AI 무영향, 대신 시작 선택 불가).

   **아직 태그 교체는 없습니다.** 설계서는 저항을 택하면 CHO→KOR로 갈아탄다고 했지만,
   지금은 코스메틱 태그만 바뀝니다. 망명 상태의 KOR이 무엇을 소유하는가를 설계서가
   정하지 않았고, HOI4에서 영토 없는 나라는 즉시 항복 처리되기 때문입니다.
4. **장비 명명 키는 접미사가 아니라 접두사입니다.** 설계서 예시는
   `infantry_equipment_1_KOR_usa` 였으나 실제 형식은 `KOR_usa_infantry_equipment_1`
   입니다 (바닐라 `GER_infantry_equipment_1` 로 확인). 접두사로 구현했습니다.

   **코스메틱 태그 슬롯은 나라당 하나뿐입니다.** 그래서 국명을 바꾸는 태그와 장비를
   명명하는 태그가 공존할 수 없고, 나중에 실행된 쪽이 앞의 것을 지웁니다. 설계서가
   국명 교체를 요구하는 두 자리 — 인민공화국과 이왕가의 재건국 — 는 국명 태그가 장비
   명명표를 함께 들고 있습니다. `KOR_peoples_republic` 은 `KOR_jap` 의 사본(노획
   일본제)이고, 이왕가는 독일 군사고문단 전후로 두 벌입니다: `KOR_dominion` ·
   `KOR_empire` 가 일본제, `KOR_dominion_ger` · `KOR_empire_ger` 가 독일제입니다.
   `KOR_name_equipment_german` 이 `YIH_yi_un_chosen` · `YIH_empire_proclaimed`
   플래그를 읽어 국명을 유지한 채 병기고만 갈아끼웁니다.
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

## 국기

CHO 태그와 코스메틱 태그 11개는 각각 국기 파일이 있어야 합니다 — 게임은
`gfx/flags/<태그>.tga` 를 찾고, 없으면 국가의 정체성이 들어갈 자리를 빈칸으로 그립니다.
이름 16개 × 세 크기(82×52, 41×26, 10×7) = 48개 파일입니다.

이 중 13개는 새로 그릴 필요가 없었습니다. 바닐라가 총독부 기(`KOR_chousen_tag_*`,
Graveyard of Empires)와 한국의 이념별 국기 4종을 이미 갖고 있어서, 이 모드의 태그가
요구하는 이름으로 옮겨 담았습니다.

| 국기 | 무엇인가 | 그림 |
|---|---|---|
| `CHO` (+이념 변형 4종), `KOR_jap` | 조선총독부 | 바닐라 `KOR_chousen_tag_*` |
| `KOR_dominion`, `KOR_dominion_ger` | 조선 자치령 | 바닐라 `KOR_chousen_tag_fascism` — 금테 팔괘, 제국에 속한 조선 |
| `KOR_ger`, `KOR_empire`, `KOR_empire_ger` | 대한제국 | 바닐라 `KOR_fascism` — 제국기의 팔괘 태극기 |
| `KOR_chi`, `KOR_usa` | 대한민국 임시정부 | 바닐라 `KOR_democratic` — 태극기 |
| `KOR_csr`, `KOR_sov` | 조선독립동맹 | **직접 그림**, `tools/make-league-flag.ps1` |
| `KOR_peoples_republic` | 조선인민공화국 | **직접 그림**, `tools/make-prk-flag.ps1` |

새로 그린 것은 둘이고, 이유는 같습니다. 바닐라에 있는 유일한 공산 계열 한국 국기가
인공기인데, 1948년 것이고 이 둘 중 어느 쪽의 조직도 아닙니다.

**조선독립동맹**(옌안, 1942)은 노선은 공산이었지만 상징은 민족이었습니다 — 휘하
조선의용군은 태극 아래에서 찍힌 사진이 남아 있습니다. 그래서 태극을 흰 원 안에 그대로
두고, 금성을 그 위가 아니라 옆에 세웠습니다. 바탕은 인공기의 주홍보다 짙게 잡아
41×26에서 둘이 같은 깃발로 보이지 않게 했고, 흰 테두리를 넓게 준 것도 의도입니다.
태극의 붉은색과 바탕의 붉은색이 둘 다 붉은색이라, 테두리가 얇으면 10×7에서 맞붙어
전체가 한 덩어리가 됩니다.

**조선인민공화국**(서울, 1945년 9월)은 실제로 태극기를 썼으므로 이것은 태극기입니다.
바꾼 것은 좌상단 하나뿐입니다. 하늘과 군주를 뜻하는 건(☰) 괘 자리를 별이 가져갑니다 —
시선이 가장 먼저 닿는 자리이고, 이 변경이 말하려는 의미가 걸린 자리이기도 합니다.
리·감·곤은 자기 자리를 지킵니다. 별은 태극의 붉은색보다 한 톤 짙게 잡아 태극의 일부로
읽히지 않게 했습니다.

둘 다 8배 크기로 그린 뒤 축소했습니다. 태극의 S자는 82×52에 직접 그리면 살아남지
못합니다. 두 스크립트는 결정적이라, 다시 돌리면 커밋된 파일이 바이트 단위로 그대로
나옵니다:

```bash
pwsh tools/make-league-flag.ps1 KoreaMod/gfx/flags
```

스크립트를 남겨 두는 이유가 이것입니다. `.tga` 는 바이너리라, 스크립트가 없으면 색도,
흰 테두리의 두께도, 별의 위치도 손댈 수 없습니다.

옮겨 담은 13개는 Paradox의 그림을 모드 폴더 안에 재배포하는 것입니다. HOI4 모드에서는
통상적인 방식이지만, 그 파일들의 정체가 무엇인지는 알고 계시는 편이 좋습니다.

**썸네일**(`KoreaMod/thumbnail.png`, 512×512, `descriptor.mod` 의 `picture=` 가 가리킴)은
`tools/make-thumbnail.ps1` 이 같은 태극과 같은 색으로 그립니다. 런처 항목과 국기가 따로
놀지 않게 하기 위해서입니다. 문장은 위쪽 2/3, 제목은 아래 1/3을 쓰고, 제목 블록은 고정
좌표가 아니라 각 줄의 실제 높이를 재서 아래로 흘립니다 — 글꼴 자체 행간이 넉넉해서
눈대중으로 잡았더니 첫 판은 제목이 아래쪽 괘를 뚫고 지나갔습니다. 제목 밑 금색 선이
5px인 것도 이유가 있습니다. 3px일 때는 런처가 목록 크기로 줄이는 순간 사라졌습니다.

`Documents/Paradox Interactive/Hearts of Iron IV/mod/` 의 `.mod` 파일로 이 저장소를
가리켜 설치하신다면, 런처에 썸네일이 뜨려면 **그 파일에도** `picture="thumbnail.png"`
줄이 있어야 합니다. `descriptor.mod` 가 담당하는 것은 zip과 Workshop 사본이지 로컬
포인터가 아닙니다.

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
├─ KoreaMod/            모드 본체 (런처가 읽는 폴더)
│  ├─ common/
│  │  ├─ national_focus/   KOR_political(60) · KOR_industry(15) · KOR_military(19) · KOR_late(11)
│  │  ├─ ideas/            KOR_ideas · KOR_focus_ideas · KOR_event_ideas
│  │  ├─ decisions/        requisition · bandits · endgame · balance + categories
│  │  ├─ scripted_triggers/ · scripted_effects/
│  │  ├─ characters/ · country_leader/ · opinion_modifiers/
│  │  ├─ dynamic_modifiers/ · game_rules/ · on_actions/
│  │  ├─ country_tags/ · countries/ · units/names_divisions/
│  │  └─ military_industrial_organization/organizations/
│  ├─ events/              KOR_timeline · KOR_politics · KOR_industry
│  ├─ gfx/flags/           국기 16종, 각각 82×52 · medium/ 41×26 · small/ 10×7
│  ├─ history/             countries/CHO · states/ (반도 6개 주) · units/KOR_1936 · units/CHO_1936
│  ├─ localisation/        korean/ · english/  (각 3파일)
│  └─ thumbnail.png        512×512, descriptor.mod 의 picture= 가 가리키는 것
├─ docs/                설계 문서 3부 (게임이 읽지 않습니다)
├─ tools/               국기·썸네일 렌더러 (이것도 게임이 읽지 않습니다)
├─ KoreaMod.zip         KoreaMod/ 를 그대로 압축한 배포본
├─ README.md            영어
└─ README.ko.md         한국어 (이 파일)
```

정치 계열만 `focus_tree` 블록 안에 있고 산업·군사·후반은 `shared_focus` 입니다.
설계서가 파일을 다섯으로 쪼갠 이유 그대로이며, 트리 하나(`korea_focus`)를 KOR과 CHO
두 태그가 공유합니다.
