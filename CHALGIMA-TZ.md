# Chalg'ima — texnik topshiriq (Claude Code uchun)

> Bu hujjat ilovani noldan yozish uchun yagona manba. Dizayn maketlari:
> https://claude.ai/artifact/NiQvDWcQKzBbFLm1sf6xbt (bosh sahifaning 4 varianti + 12 ekran;
> ishlatiladigan variant — **D (streak)**, canvas'da "1. Bosh sahifa (tanlangan)")

---

## 1. Ilova haqida

**Chalg'ima** — o'quv kundaligi va takrorlash ilovasi. Ikki vazifani birlashtiradi:

1. **Vaqt hisobi** — nimani, qancha vaqt o'qiganingizni taymer bilan yozadi.
2. **Takrorlash (spaced repetition)** — o'qish paytida yaratilgan kartochkalarni
   belgilangan kunlarda qaytarib beradi.

G'oyaning asosi: kartochka aynan o'qish tugagan lahzada, mavzu hali yoddaligida yaratiladi.
Shuning uchun ikkala vazifa bitta ilovada.

**Ishlash sharti:** to'liq oflayn, login yo'q, ma'lumot faqat telefonda.

---

## 2. Texnik stack

| Narsa | Tanlov |
|---|---|
| Framework | Flutter (stable), Dart 3 |
| Baza | SQLite (`sqflite` + `path`) |
| Holat | `ChangeNotifier` + `ListenableBuilder` |
| Sozlamalar | `shared_preferences` |
| Grafiklar | `fl_chart` |
| Fon taymeri | `flutter_foreground_task` (yoki shunga o'xshash foreground service) |
| Bildirishnoma | `flutter_local_notifications` |
| Package name | `uz.chalgima.app` |
| App label | `Chalg'ima` |

---

## 3. Papka tuzilishi

```
lib/
  main.dart            // app, theme, RootShell
  theme.dart
  db/database.dart  db/seed.dart
  models/ subject.dart  session.dart  card.dart  review.dart
  store/ app_store.dart      // fanlar, bugungi statistika, streak
  store/ timer_service.dart  // fon taymeri, pauza, chalg'ish sanagichi
  srs/ scheduler.dart        // takrorlash jadvali (algoritm shu yerda, UI da emas)
  screens/
    home.dart  timer.dart  finish_1.dart  finish_2.dart  finish_3.dart
    review.dart  stats.dart  subjects.dart  subject_edit.dart
    history.dart  session_edit.dart  cards.dart  card_edit.dart  settings.dart
  widgets/ ring_progress.dart  streak_card.dart  session_row.dart  empty_state.dart
```

---

## 4. Ma'lumotlar modeli (SQLite)

### subjects
`id, name, icon, color, weekly_goal_min, daily_goal_min, note, sort_order, status (active|archived), total_seconds (kesh), created_at`

### sessions
| ustun | tur | izoh |
|---|---|---|
| id | INTEGER PK | |
| subject_id | INTEGER | |
| start_at | INTEGER | unix millis |
| end_at | INTEGER | |
| net_seconds | INTEGER | sof vaqt (statistikaga shu kiradi) |
| pause_seconds | INTEGER | |
| distraction_count | INTEGER | boshqa ilovaga o'tishlar soni |
| mode | TEXT | `free` \| `pomodoro` \| `manual` |
| rating | INTEGER | 1–5, null bo'lishi mumkin |
| note | TEXT | "Nima o'rgandingiz?" |
| day_key | TEXT | `2026-09-27` — kun 04:00 da almashadi |
| confirmed | INTEGER | 0 = taymer unutilgan, keyin tuzatilgan |
| intention | TEXT | sessiya oldidan yozilgan maqsad |
| intention_done | INTEGER | 0/1/null — bajarildimi |
| kind | TEXT | `read` \| `practice` \| `project` \| `review` |
| focus_score | INTEGER | 0–100, 5.7 dagi formula bo'yicha |
| cards_created | INTEGER | shu sessiyadan tug'ilgan kartochkalar soni |

### cards
`id, subject_id, session_id (null), type (qa|cloze|scenario), question, answer, hint, stage (0–5), interval_days, next_due (day_key), last_seen, correct_count, wrong_count, streak_correct, status (active|archived), difficult (0/1), created_at`

### scenario_options
Faqat `type = scenario` kartochkalar uchun.

`id, card_id, text, is_correct (0/1), feedback, sort_order`

Har bir variantga o'z izohi (`feedback`) yoziladi: nega bu javob to'g'ri yoki nega
yetarli emas. Foydalanuvchi tanlagandan keyin aynan shu matn chiqadi.

### reviews
`id, card_id, at, result (0=unutdim, 1=esladim), stage_before, stage_after`

### day_stats (kesh, tez hisob uchun)
`day_key PK, total_seconds, goal_seconds, sessions_count, reviews_done, reviews_correct, goal_met (0/1), avg_focus, sleep_hours, mood (1–5), exercise (0/1), screen_minutes`

Oxirgi 5 ta ustun — "Life Detective" moduli uchun (5.10). Ular null bo'lishi mumkin.

### card_links
Kartochkalar va tushunchalar orasidagi bog'lanish (yengil knowledge graph).

`id, from_card_id, to_card_id, relation (uses|part_of|prerequisite|related|opposite), created_at`

### paths va path_items
O'quv yo'li: "eJPT" yoki "IELTS 7.0" kabi maqsadga olib boradigan mavzular ro'yxati.

`paths: id, name, subject_id, note, created_at`
`path_items: id, path_id, title, note, status (todo|doing|done), sort_order, done_at`

---

## 5. Biznes-mantiq qoidalari

### 5.1 Kun chegarasi
Kun **04:00** da almashadi. Soat 01:30 da tugagan sessiya kechagi `day_key` ga yoziladi.
Bu qoida streak, kunlik maqsad va takrorlash jadvali uchun ham amal qiladi.

### 5.2 Taymer
- Foreground service: ilova yopilsa ham sanaydi, bildirishnomada vaqt va pauza tugmasi.
- Pomodoro: default 25/5, har 4-siklda 15 daqiqa dam. Sozlamadan o'zgartiriladi.
- **Chalg'ish sanagichi:** ilova `paused`/`resumed` hodisalari orqali. O'qish paytida
  boshqa ilovaga o'tilgan vaqt `distraction_count` va ayiriladigan soniyalarga qo'shiladi.
  Hech qanday maxsus ruxsat talab qilinmaydi.
- **Unutilgan taymer:** davomiylik 4 soatdan oshsa yoki qurilma uzoq uxlagan bo'lsa,
  yakunlashda so'raladi: "Taymer N soat ishladi, haqiqiy vaqt qancha?" + tez variantlar.
  Bunday sessiyada `confirmed = 0`.

### 5.3 Streak
- Kun **hisoblanadi**, agar `total_seconds >= goal_seconds / 2`.
- Kun **to'liq**, agar `total_seconds >= goal_seconds`.
- Oyiga **1 ta dam olish kuni** streakni buzmaydi (sozlamadan o'zgartiriladi).
- Streak `day_stats` bo'yicha hisoblanadi, alohida hisoblagich saqlanmaydi.

### 5.4 Takrorlash algoritmi (`srs/scheduler.dart`)

| stage | interval |
|---|---|
| 0 | bugun (yangi) |
| 1 | 1 kun |
| 2 | 3 kun |
| 3 | 7 kun |
| 4 | 21 kun |
| 5 | 60 kun (o'zlashtirilgan) |

- **Esladim:** `stage + 1` (5 dan oshmaydi), `next_due = bugun + interval`.
- **Unutdim:** `stage = 1` (0 ga emas), ertaga qaytadi, `wrong_count++`.
- `wrong_count >= 3` bo'lsa `difficult = 1`.
- **Kunlik tanlov:** muddati o'tganlar → bugungilar → yangilar. Yangilar uchun chegara
  default 10 ta, umumiy chegara 20 ta (sozlamadan). Qolganlari ertaga suriladi.
- Ro'yxat **aralashtiriladi**: bir fan ketma-ket kelmasin.

### 5.5 Sessiyani yakunlash oqimi
Uch qadam, **har biri ixtiyoriy**:
1. Vaqtni tasdiqlash (`−5 / +5` tugmalari) → "Saqlash" yoki "Tafsilot qo'shish".
2. Diqqat bahosi (5 ta smaylik) + "Nima o'rgandingiz?" (tayyor boshlanishlar:
   "Tugatdim:", "Tushunmadim:", "Keyingi safar:"; ostida oxirgi 2–3 yozuv ko'rinadi).
3. Kartochkalar: tez yozuv `savol :: javob` (har qator = 1 kartochka) yoki bo'sh joy
   turi `nmap [-sV] 10.0.0.1`. "Keyinroq" tugmasi bosilsa, ertaga bosh sahifada eslatiladi.

**Qoida:** ilova hech qachon "kartochka qo'shmadingiz" deb koyimaydi. 5 daqiqadan qisqa
sessiyada faqat "Saqlash / Bekor qilish" so'raladi.

### 5.6 Vaziyat kartochkalari (scenario)

Oddiy kartochka faktni tekshiradi ("SYN skanerlash bayrog'i?"). Vaziyat kartochkasi
**qarorni** tekshiradi: "mana shunday holat, nima qilasiz?" Maqsad — junior darajadagi
"topdim" dan senior darajadagi "nimasi muhim va nega" ga o'tish.

**Tuzilishi:** matn (kontekst) → 3–4 variant → tanlov → har variant uchun izoh →
to'g'ri javobning sababi.

**Qamrab oladigan turlari (kontent yozishda shu ro'yxatga tayaniladi):**

| Turi | Savol shakli | Nimani o'rgatadi |
|---|---|---|
| Ustuvorlik | 12 ta topilma, 2 soat vaqt. Qaysi uchtasi birinchi? | vaqtni taqsimlash |
| Kuzatish | Nmap natijasi yoki log parchasi: bu yerda nima g'alati? | detallarni payqash |
| Baholash | Bu zaiflik Critical mi, High mi? Nega? | CVSS va ta'sir mantig'i |
| Muloqot | Mijoz "byudjet yo'q" deydi. Javobingiz? | texnik bo'lmagan odam bilan til topish |
| Hisobot | Texnik topilmani mijoz uchun bir jumlada yozing | yozish ko'nikmasi |
| Chegara | Bu harakat shartnoma doirasidami? | qonuniy va axloqiy chegara |

**Muhim farqlar:**
- Vaziyatda "yagona to'g'ri javob" har doim ham bo'lmaydi. Shuning uchun `is_correct`
  bilan birga **har bir variantning izohi** bo'ladi va ilova noto'g'ri tanlovda ham
  nima uchun bunday qaror qimmatga tushishini tushuntiradi.
- Takrorlash jadvali (5.4) vaziyatlarga ham **xuddi shunday** qo'llanadi, faqat
  boshlang'ich `interval` uzunroq: vaziyat faktdan ko'ra sekinroq unutiladi
  (stage 1 = 3 kun, 2 = 7, 3 = 21, 4 = 60, 5 = 120).
- Kunlik navbatda vaziyatlar soni cheklanadi (default 3 ta): ular ko'proq vaqt oladi.

**Kontent qayerdan keladi:** foydalanuvchining o'zidan. Har TryHackMe xonasi, har maqola
yoki har ish vaziyatidan keyin "bu yerda qanday qaror qabul qildim?" degan savol asosida
vaziyat yoziladi. Ilova bilan birga 20–30 ta namuna vaziyat keladi (`db/seed.dart`),
qolganini foydalanuvchi o'zi to'ldiradi.

### 5.7 Diqqat ko'rsatkichi (focus score)

Har sessiya uchun 0–100 oralig'ida hisoblanadi:

```
base        = rating * 20                     // 1–5 baho → 20–100
distraction = min(distraction_count * 6, 30)  // har chalg'ish −6, eng ko'pi −30
pause_ratio = pause_seconds / (net + pause)
pause_pen   = round(pause_ratio * 20)         // pauzada ko'p turish −20 gacha
focus_score = clamp(base - distraction - pause_pen, 0, 100)
```

Baho berilmagan sessiyada `rating = 3` deb olinadi va natija "taxminiy" deb belgilanadi.
Kunlik `avg_focus` — sessiyalarning vaqtga tortilgan o'rtachasi (uzun sessiya ko'proq
og'irlikka ega).

Statistikada vaqt bilan birga shu raqam ko'rsatiladi: "Bu hafta diqqat 72, o'tgan hafta 58".

### 5.8 Niyat (sessiya oldidan)

Taymerni boshlashdan oldin bitta qator so'raladi: "Bu sessiyada nima qilasiz?"
Bo'sh qoldirish mumkin, lekin oxirgi 3 ta niyat taklif sifatida ko'rsatiladi.

Sessiya tugagach, 1-qadamda qo'shimcha savol chiqadi: "Bajarildimi? Ha / Qisman / Yo'q".
Statistikada: "Niyatlarning 68% i bajarilgan". Bajarilmagan niyat avtomatik ravishda
keyingi sessiyaga taklif bo'lib qaytadi.

### 5.9 Bezovta qilmang rejimi

Taymer boshlanganda tizimning "Bezovta qilmang" rejimi yoqiladi, tugaganda o'chadi.
Android'da `NotificationManager.setInterruptionFilter` va
`ACCESS_NOTIFICATION_POLICY` ruxsati kerak.

Qoidalar:
- Sozlamalarda o'chirib qo'yish mumkin, default — o'chiq (birinchi marta foydalanuvchidan
  so'raladi).
- Ilova qulab tushsa ham rejim qaytarilishi shart: taymer xizmati to'xtaganda
  `onDestroy` da tiklanadi, qo'shimcha ravishda ilova har ochilganda tekshiriladi.
- Bu **bloklash emas**: qo'ng'iroq va boshqa ilovalar ishlayveradi.

### 5.10 Life Detective (o'zi haqida tadqiqot)

Kunlik bir necha ko'rsatkich yig'iladi va ular orasidagi bog'liqlik qidiriladi.

**Yig'iladigan ma'lumot:** uyqu (soat), kayfiyat (1–5), sport (ha/yo'q), ekran vaqti
(ruxsat bo'lsa avtomatik), o'qish vaqti va diqqat (avtomatik, allaqachon bor).

**Kiritish:** kechqurungi bitta bildirishnomadan, 15 soniyada. Uyqu — surgich,
kayfiyat — 5 ta smaylik, sport — bitta tugma. Hech biri majburiy emas.

**Tahlil (`analysis/insights.dart`):**
- Pearson korrelyatsiyasi ikki qator son orasida.
- Guruhlar solishtirish: hafta kunlari, kun qismlari (ertalab/kunduz/kechqurun).
- Xulosa faqat quyidagi shartlarda chiqadi: kamida **14 ta kun** ma'lumoti bor,
  `|r| >= 0.4`, va namunalar soni har guruhda kamida 5 ta. Aks holda hech narsa
  ko'rsatilmaydi.
- Har xulosa "ehtimol" tilida yoziladi: "7 soatdan kam uxlagan kunlarda diqqat
  o'rtacha 14 punktga past bo'lgan" — sabab-oqibat deb da'vo qilinmaydi.

### 5.11 Kartochka sifati bilan ishlash

- `wrong_count >= 5` bo'lsa, ilova taklif qiladi: "Bu kartochkani qayta yozing —
  savol juda keng yoki noaniq bo'lishi mumkin". Tahrirlash tugmasi darhol beriladi.
- Bitta kartochkada bir nechta fakt bo'lsa (javob 100 belgidan uzun), yozishda
  ogohlantiriladi: "Bitta kartochka — bitta fakt".
- "Qiyin" kartochkalar uchun alohida mashq rejimi: faqat ularni ketma-ket takrorlash.

### 5.12 Import va eksport

- **Import:** CSV (`savol,javob,fan`), Anki `.txt` eksporti, EngWords JSON formati.
  Dublikatlar `question` bo'yicha tekshiriladi va o'tkazib yuboriladi.
- **Eksport:** barcha ma'lumot bitta JSON faylga (zaxira nusxa), kartochkalar alohida
  CSV ga. Tiklash — o'sha JSON dan.
- **Avtomatik zaxira:** haftada bir marta ichki xotiraga, oxirgi 4 nusxa saqlanadi.

---

## 6. Ekranlar

**1-bosqich (11 ekran)**

1. **Bosh sahifa** — streak bloki (sariq, hafta belgilari), kunlik maqsad doirasi,
   "O'qishni boshlash", kunlik takrorlash vazifasi (progress bilan), fanlar bo'yicha
   haftalik maqsadlar.
2. **Takrorlash** — ikki rejim bitta ekranda:
   - *Oddiy kartochka:* savol, bosilganda javob va izoh; "Unutdim / Esladim".
   - *Vaziyat kartochkasi:* kontekst matni, 3–4 variant tugmasi. Tanlangach, tanlangan
     variantning izohi va to'g'ri javobning sababi ochiladi, keyin "Unutdim / Esladim".
   Yuqorida progress va kartochka manbasi ("18-sentabr sessiyasidan").
3. **Statistika** — Hafta/Oy/Yil, kunlik bar chart, 3 ta ko'rsatkich (kunlik o'rtacha,
   eng uzun streak, esda saqlash %), fanlar donut, matnli xulosa, ekran vaqti bloki.
4. **Fanlar** — jami vaqt va kartochkalar, faol fanlar progressi, arxiv.
5. **Fan qo'shish** — nom, izoh, haftalik/kunlik maqsad, ikonka, rang.
6. **Taymer** — rejim segmenti, katta doira, pomodoro nuqtalari, "Chalg'idim",
   Pauza va Tugatish.
7. **Yakunlash** — 3 ta qadam (yuqorida 5.5).
8. **Tarix** — kalendar, fan filtri, kunlar bo'yicha guruhlar, har sessiyada baho va
   kartochka soni.
9. **Sessiya qo'shish** — qo'lda kiritish: fan, sana, vaqt, davomiylik (tez tugmalar), baho, yozuv.
10. **Kartochkalar** — 3 ta ko'rsatkich, filtr chiplari, kartalar (bosqich nuqtalari,
    "qiyin" belgisi, keyingi takrorlash sanasi).
11. **Sozlamalar** — maqsadlar, taymer, takrorlash chegaralari (alohida: oddiy kartochka
    va vaziyat chegarasi), eslatma, mavzu, zaxira nusxa.
12. **Vaziyat qo'shish** — kontekst matni, 3–4 variant (har birida "to'g'ri" belgisi va
    izoh maydoni), umumiy tushuntirish, fan tanlash. Kartochka qo'shish ekranining
    uchinchi segmenti sifatida ochiladi.
13. **Niyat oynasi** — taymerdan oldin: bitta matn maydoni, oxirgi 3 ta niyat taklifi,
    "O'tkazib yuborish" tugmasi. Kichik bottom sheet, alohida ekran emas.
14. **Haftalik yakun** — yakshanba 20:00 da bildirishnoma orqali ochiladi: shu hafta
    necha soat va o'rtacha diqqat, o'tgan hafta bilan farqi, maqsadga yetgan fanlar,
    orqada qolganlar, eng samarali kun, keyingi haftaga maqsad qo'yish maydoni.
15. **Kunlik belgilar (Life Detective)** — uyqu, kayfiyat, sport. Bildirishnomadan
    to'g'ridan-to'g'ri ochiladi, 15 soniyalik ekran.
16. **Xulosalar** — statistikaning ichida alohida yorliq: topilgan bog'liqliklar
    ro'yxati, har biri bitta jumla va kichik grafik bilan.
17. **O'quv yo'li** — maqsad (masalan "eJPT"), mavzular ro'yxati, bajarilganlar belgisi,
    umumiy progress. Har mavzuni fan va kartochkalar bilan bog'lash mumkin.
18. **Qiyin kartochkalar mashqi** — faqat `difficult = 1` bo'lganlar, ketma-ket.
19. **Import / eksport** — sozlamalar ichida: fayl tanlash, ko'rib chiqish, tasdiqlash.

**2-bosqich:** yutuqlar, kunlik xulosa ekrani, eslatmalar daftari (barcha yozuvlar + qidiruv),
ekran vaqti statistikasi (`UsageStatsManager`, faqat foydalanuvchi ruxsat bersa),
fan tafsiloti ekrani.

**Bloklash funksiyasi qo'shilmaydi** — bu boshqa ilovaning vazifasi.

---

## 7. Dizayn tizimi

```dart
const ink    = Color(0xFF15253F);  // asosiy, tugmalar, matn
const accent = Color(0xFF2E8B68);  // yashil: bajarildi, FAB, progress
const amber  = Color(0xFFE08A0B);  // streak bloki
const bg     = Color(0xFFF2F4F6);
const grey   = Color(0xFF61708A);
const line   = Color(0xFFE4E8EC);
const red    = Color(0xFFC4453C);  // "Unutdim", qiyin kartochka
// Fan ranglari: #3E5FCC, #1F8F6B, #B4690E, #7C4DBC, #E08A0B, #C4453C
```

- Shrift: **Nunito** (dumaloq, do'stona).
- Kartochka: oq, radius 18–24, yengil soya.
- Doiraviy progress: SVG/CustomPainter, stroke 16–18, uchi yumaloq.
- Ikonkalar: ingichka chiziqli, emoji faqat baho smayliklarida.
- Qorong'i mavzu **majburiy** (kechqurun o'qish odatiy holat).

---

## 8. Bosqichlar

**1-bosqich:** baza, fanlar, taymer (fon xizmati bilan), yakunlash oqimi, kartochkalar
va takrorlash algoritmi, bosh sahifa, tarix, statistika, sozlamalar.

**2-bosqich:** niyat (5.8), diqqat ko'rsatkichi (5.7), Bezovta qilmang rejimi (5.9),
haftalik yakun ekrani, qiyin kartochkalar bilan ishlash (5.11), zaxira nusxa va
import-eksport (5.12), bosh ekran vidjeti va tez sozlamalar tugmasi.

**3-bosqich:** vaziyat kartochkalari (`scenario`) va 20–30 ta namuna kontent,
o'quv yo'llari (`paths`), kartochka bog'lanishlari (`card_links`), yutuqlar,
eslatmalar daftari, fan tafsiloti.

**4-bosqich:** Life Detective (5.10) — kunlik belgilar, ekran vaqti ruxsati,
korrelyatsiya tahlili va xulosalar ekrani.

> **Muhim qoida.** Bu ro'yxat uzun, lekin 1-bosqich **kengaymaydi**. Avval taymer,
> sessiya, kartochka va takrorlash ishlab tursin. Har bosqich alohida APK bilan
> yakunlanadi va bir hafta ishlatib ko'riladi: keyingi bosqichga o'tishdan oldin
> nima haqiqatan kerakligi aniq bo'ladi. Hammasini birdan yozishga urinish —
> loyihani tashlab yuborishning eng keng tarqalgan sababi.

---

## 9. Build (GitHub Actions)

Hamyon bilan bir xil:
`flutter create . --platforms=android --org uz.chalgima --project-name chalgima` →
`flutter pub get` → `flutter build apk --release` → artifact va Release.

Qo'shimcha: foreground service uchun manifestga `FOREGROUND_SERVICE`,
`POST_NOTIFICATIONS` (Android 13+) va service e'loni kerak. Bularni workflow emas,
paket o'zi qo'shadi; qo'lda tekshirib chiqing.

---

## 10. Qabul mezonlari

- [ ] Taymer ishlayotganda ilova yopilsa ham vaqt to'g'ri sanaladi, bildirishnoma ko'rinadi.
- [ ] Boshqa ilovaga o'tib qaytilsa, `distraction_count` oshadi va vaqt ayiriladi.
- [ ] Yakunlashda faqat "Saqlash" bosilsa ham sessiya to'liq yoziladi.
- [ ] `savol :: javob` ko'rinishida 3 qator yozilsa, 3 ta kartochka yaratiladi.
- [ ] Vaziyat kartochkasida noto'g'ri variant tanlansa ham izoh chiqadi va foydalanuvchi
      nima uchun bu qaror yomon ekanini o'qiydi.
- [ ] Kunlik navbatda vaziyatlar soni sozlamadagi chegaradan oshmaydi.
- [ ] "Esladim" bosilganda kartochka jadvalga to'g'ri suriladi, "Unutdim" da ertaga qaytadi.
- [ ] Kunlik chegara oshmaydi: 40 ta muddati o'tgan bo'lsa ham bugun 20 tasi chiqadi.
- [ ] Soat 02:00 da tugagan sessiya kechagi kunga yoziladi va streak buzilmaydi.
- [ ] 500 sessiya va 1000 kartochkada statistika 1 soniyadan tez ochiladi.
- [ ] Niyat yozilgan sessiyada yakunlashda "Bajarildimi?" so'raladi, bo'sh niyatda so'ralmaydi.
- [ ] Diqqat ko'rsatkichi 0–100 oralig'idan chiqmaydi, baho yo'q sessiyada "taxminiy" deb belgilanadi.
- [ ] "Bezovta qilmang" taymer to'xtaganda, ilova qulaganda ham o'chadi.
- [ ] 14 kundan kam ma'lumotda birorta ham xulosa ko'rsatilmaydi.
- [ ] Zaxira nusxadan tiklashdan keyin barcha kartochkalarning `next_due` sanasi saqlanadi.
- [ ] CSV import dublikatlarni qo'shmaydi.

---

## 11. Kod qoidalari

- Takrorlash algoritmi faqat `srs/scheduler.dart` da, sof funksiyalar ko'rinishida
  (`nextStage`, `nextDue`, `buildTodayQueue`) — ular uchun unit testlar yoziladi.
- Vaqt hisobi UTC millis'da saqlanadi, ko'rsatishda mahalliy vaqtga o'giriladi.
- UI matnlari o'zbekcha, kod inglizcha.
- Ekranlar bazaga to'g'ridan-to'g'ri murojaat qilmaydi, faqat `store` orqali.
- `print` o'rniga `debugPrint`; bo'sh `catch` qoldirilmaydi.
- Kartochka turlari (`qa`, `cloze`, `scenario`) bitta jadvalda saqlanadi, UI da esa
  alohida widgetlar bilan ko'rsatiladi. Yangi tur qo'shish oson bo'lishi uchun
  `CardRenderer` interfeysi orqali.
