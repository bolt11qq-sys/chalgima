# Chalg'ima — O'quv kundaligi va Spaced Repetition (SRS)

**Chalg'ima** — nimani, qancha vaqt oʻqiganingizni taymer bilan hisoblab boruvchi hamda oʻqish paytida yaratilgan kartochkalarni belgilangan kunlarda takrorlab beruvchi 100% oflayn Flutter ilovasi.

Texnik topshiriq: [CHALGIMA-TZ.md](file:///C:/Users/ASUS/Desktop/chalg%27ima/CHALGIMA-TZ.md)

---

## 🎯 Asosiy imkoniyatlar

1. **Bosh sahifa (Variant D - Streak):**
   - 04:00 kun chegarasi qoidasi (kechasi oʻqilgan sessiya kechagi kunga yoziladi va streak uzilmaydi).
   - Streak bloki va hafta kunlari indikatori (oyiga 1 ta dam olish kuni streakni buzmaydi).
   - Kunlik maqsad aylanasi (CustomPainter halqa progressi).
   - Kunlik takrorlash (SRS) navbati va fanlar boʻyicha haftalik progress.
2. **Taymer va Diqqat nazorati:**
   - Erkin rejim va Pomodoro rejimi (25 daqiqa oʻqish / 5 daqiqa qisqa tanaffus / 4-siklda 15 daqiqa katta tanaffus).
   - Sessiya oldidan aniq niyat (Intention) belgilash va oldingi niyatlar taklifi.
   - Chalgʻish sanagichi: dastur orqa fonga oʻtib qaytilsa, chalgʻishlar soni va vaqti avtomatik hisoblanadi. "Chalgʻidim" tezkor tugmasi.
   - Unutilgan taymer nazorati (>4 soat ishlaganda haqiqiy vaqtni tanlash).
3. **Uch bosqichli sessiyani yakunlash oqimi:**
   - **1-qadam:** Vaqtni tasdiqlash (`−5 / +5` daqiqa) va niyat natijasi (Ha / Qisman / Yoʻq).
   - **2-qadam:** Diqqat bahosi (5 ta smaylik), faoliyat turi (oʻqish, amaliyot, loyiha, takrorlash) va "Nima oʻrgandingiz?" xulosasi.
   - **3-qadam:** Tezkor kartochkalar yaratish (`savol :: javob` formati).
4. **Takrorlash (Spaced Repetition System - SRS):**
   - Standart QA va Vaziyat (Scenario) kartochkalari.
   - Vaziyat kartochkalarida har bir variant uchun tushuntirish va xulosa beriladi.
   - "Unutdim" (1 kunga qaytadi) va "Esladim" (bosqich oshadi).
   - Qiyin kartochkalar mashqi (`difficult = 1`).
   - Sifat nazorati: 5 marta xato qilingan kartochkalar uchun qayta yozish taklifi.
5. **Life Detective (Samaradorlik tahlili):**
   - Har kuni uyqu, kayfiyat va sport koʻrsatkichlarini kiritish (15 soniya).
   - 14 kunlik maʼlumot toʻplangach korrelyatsiya xulosalarini chiqarish.
6. **Xavfsiz va 100% oflayn:**
   - Login yoʻq, barcha maʼlumotlar SQLite bazasida saqlanadi.
   - JSON formatda toʻliq zaxira nusxa olish va tiklash.
   - CSV formatida boshqa ilovalardan kartochkalarni import qilish.

---

## 🏗️ Arxitektura va Papkalar tuzilishi

```
lib/
  main.dart            // Dasturning kirish nuqtasi, mavzu va pastki navigatsiya
  theme.dart           // Nunito shrifti, Yorug' va Qorong'i mavzu, 7-bo'lim ranglari
  db/
    database.dart      // SQLite jadvallari (subjects, sessions, cards, options, stats, paths)
    seed.dart          // Dastlabki fanlar, 20+ ta namuna vaziyat va QA kartochkalar
  models/
    subject.dart       // Fan modeli
    session.dart       // O'quv sessiyasi modeli
    card.dart          // Kartochka va vaziyat variantlari modeli
    review.dart        // Takrorlash tarixi va kunlik statistika modeli
    path.dart          // O'quv yo'li (Roadmap) modeli
  store/
    app_store.dart     // Reaktiv holat boshqaruvi (ChangeNotifier)
    timer_service.dart // Taymer, pomodoro va chalg'ish hisoblagichi
  srs/
    scheduler.dart     // Spaced Repetition sof funksiyalari (04:00 chegarasi, focus score, navbat)
  screens/
    home.dart          // Variant D bosh sahifa
    timer.dart         // Taymer ekrani
    finish_1.dart      // 1-qadam: Vaqt va niyat
    finish_2.dart      // 2-qadam: Diqqat bahosi va izoh
    finish_3.dart      // 3-qadam: Kartochkalar qo'shish
    review.dart        // SRS takrorlash (QA va Scenario interaktiv kartochkalari)
    stats.dart         // Haftalik grafik, ko'rsatkichlar va Life Detective xulosalari
    subjects.dart      // Fanlar ro'yxati
    subject_edit.dart  // Fan yaratish va tahrirlash
    history.dart       // Sessiyalar tarixi
    session_edit.dart  // Qo'lda sessiya kiritish
    cards.dart         // Kartochkalar kutubxonasi, filtrlar va qidiruv
    card_edit.dart     // QA va Vaziyat kartochkalarini yaratish
    settings.dart      // Sozlamalar, SRS limitlari, JSON/CSV zaxira nusxa
    paths.dart         // O'quv yo'li (eJPT, IELTS va h.k.)
  widgets/
    ring_progress.dart // CustomPainter doiraviy progress halqasi
    streak_card.dart   // Hafta kunlari bilan sariq streak kartasi
    session_row.dart   // Sessiya ko'rinishi
    empty_state.dart   // Bo'sh ro'yxatlar uchun ko'rinish
```

---

## 🧪 Sinov (Unit Tests)

SRS algoritmik qoidalari (`04:00` chegarasi, Esladim/Unutdim bosqichlari, Focus score hisobi, navbat aralashtirish) uchun testlar yozilgan.

Ishga tushirish uchun terminalda:
```powershell
dart --enable-asserts bin/test_runner.dart
```

---

## 📱 APK Build qilish

### 1-usul: GitHub Actions orqali (Avtomatik & Bepul)
1. Ushbu loyihani GitHub reponing `main` yoki `master` tarmogʻiga yuklang (`git push`).
2. `.github/workflows/build-apk.yml` fayli avtomatik ishga tushadi.
3. Repodagi **Actions** boʻlimidan tayyor `app-release.apk` faylini yuklab oling.

### 2-usul: Kompyuteringizda (Lokal)
```powershell
flutter build apk --release
```
Tayyor APK manzili:
`build/app/outputs/flutter-apk/app-release.apk`
