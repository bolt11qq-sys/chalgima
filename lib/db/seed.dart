import 'package:sqflite/sqflite.dart';
import '../srs/scheduler.dart';

class SeedData {
  static Future<void> seed(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final today = SrsScheduler.getDayKey();

    // 1. Fanlar
    await db.rawInsert('''
      INSERT INTO subjects (id, name, icon, color, weekly_goal_min, daily_goal_min, note, sort_order, status, total_seconds, created_at)
      VALUES 
      (1, 'Kiberxavfsizlik & Pentest', 'security', '#3E5FCC', 600, 90, 'eJPT v2 va TryHackMe xonalari', 1, 'active', 32400, ?),
      (2, 'Ingliz tili (IELTS / C1)', 'language', '#1F8F6B', 420, 60, 'Vocabulary va Writing Task 2', 2, 'active', 24600, ?),
      (3, 'Backend & Algoritmlar', 'code', '#B4690E', 360, 50, 'PostgreSQL, Go va tizim arxitekturasi', 3, 'active', 18000, ?),
      (4, 'Tarmoqlar (CCNA / TCP/IP)', 'hub', '#7C4DBC', 240, 40, 'Wireshark va Subnetting amaliyoti', 4, 'active', 14400, ?)
    ''', [now, now, now, now]);

    // Yordamchi funksiya: Scenario kartochka va variantlarini kiritish
    Future<void> insertScenario({
      required int subjectId,
      required String question,
      required String answer,
      required String hint,
      required int stage,
      required int intervalDays,
      required String nextDue,
      required List<Map<String, dynamic>> options,
    }) async {
      final cardId = await db.insert('cards', {
        'subject_id': subjectId,
        'type': 'scenario',
        'question': question,
        'answer': answer,
        'hint': hint,
        'stage': stage,
        'interval_days': intervalDays,
        'next_due': nextDue,
        'correct_count': 1,
        'wrong_count': 0,
        'streak_correct': 1,
        'status': 'active',
        'difficult': 0,
        'created_at': now,
      });

      int order = 1;
      for (final opt in options) {
        await db.insert('scenario_options', {
          'card_id': cardId,
          'text': opt['text'],
          'is_correct': opt['is_correct'] ? 1 : 0,
          'feedback': opt['feedback'],
          'sort_order': order++,
        });
      }
    }

    // Yordamchi funksiya: QA kartochka kiritish
    Future<void> insertQA({
      required int subjectId,
      required String question,
      required String answer,
      String? hint,
      int stage = 0,
      int intervalDays = 0,
      String? nextDue,
    }) async {
      await db.insert('cards', {
        'subject_id': subjectId,
        'type': 'qa',
        'question': question,
        'answer': answer,
        'hint': hint,
        'stage': stage,
        'interval_days': intervalDays,
        'next_due': nextDue ?? today,
        'correct_count': stage > 0 ? 1 : 0,
        'wrong_count': 0,
        'streak_correct': stage > 0 ? 1 : 0,
        'status': 'active',
        'difficult': 0,
        'created_at': now,
      });
    }

    // 2. Namuna vaziyat kartochkalari (5.6 bo'lim talablari bo'yicha)

    // Scenario 1: Ustuvorlik
    await insertScenario(
      subjectId: 1,
      question: 'Vaziyat (Ustuvorlik): Pentestda 12 ta zaiflik topdingiz. Mijozga hisobot topshirishga 2 soat qoldi. Qaysi uchtasini birinchi tekshirib tasdiqlaysiz?',
      answer: 'RCE, SQL Injection va Maxfiy IDOR',
      hint: 'Biznesga bevosita ta\'sir qiluvchi Critical xavflar',
      stage: 2,
      intervalDays: 7,
      nextDue: today,
      options: [
        {
          'text': 'SSL eskirgan shifr, Clickjacking va Server versiyasi oshkorligi',
          'is_correct': false,
          'feedback': 'Bu zaifliklar Low/Info darajada. Qisqa vaqt ichida ularga chalgʻish mijoz infratuzilmasiga jiddiy xavf soladigan narsalarni chetda qoldiradi.',
        },
        {
          'text': 'RCE (Remote Code Execution), SQL Injection va Maxfiy IDOR',
          'is_correct': true,
          'feedback': 'Aynan toʻgʻri! RCE serverni toʻliq egallash, SQLi maʼlumotlar bazasini oʻgʻirlash xavfini tugʻdiradi. Critical topilmalar birinchi tasdiqlanishi shart.',
        },
        {
          'text': 'Barcha 12 tasini yuzaki koʻrib chiqib, barchasini birdan yozish',
          'is_correct': false,
          'feedback': 'Vaqt yetmaydi, natijada isbotlanmagan (false positive) maʼlumotlar hisobotga kirib qolib, nufuzingizga putur yetadi.',
        },
      ],
    );

    // Scenario 2: Kuzatish
    await insertScenario(
      subjectId: 1,
      question: 'Vaziyat (Kuzatish): Nmap skanerida quyidagi natija chiqdi: Port 80/tcp OPEN (Apache 2.4.49), Port 22/tcp FILTERED. Nimaga eʼtibor qaratasiz?',
      answer: 'Apache 2.4.49 dagi mashhur Path Traversal / RCE (CVE-2021-41773)',
      hint: 'Apache versiyasi va maʼlum CVE xavfi',
      stage: 1,
      intervalDays: 3,
      nextDue: today,
      options: [
        {
          'text': 'SSH porti yopiqligi sababli darhol SSH brute-force qilish',
          'is_correct': false,
          'feedback': 'Port FILTERED (firewall bilan toʻsilgan), brute force qilish foydasiz va vaqtni yoʻqotadi.',
        },
        {
          'text': 'Apache 2.4.49 dagi mashhur Path Traversal (CVE-2021-41773) zaifligini tekshirish',
          'is_correct': true,
          'feedback': 'Ajoyib kuzatuvchanlik! Apache 2.4.49 versiyasi mashhur kritik 0-day Path Traversal va RCE ga ega boʻlib, darhol tekshirilishi kerak.',
        },
        {
          'text': 'Web sayt dizayni eskiligini mijozga bildirish',
          'is_correct': false,
          'feedback': 'Dizayn texnik xavfsizlik pentestining birlamchi maqsadi emas.',
        },
      ],
    );

    // Scenario 3: Muloqot
    await insertScenario(
      subjectId: 1,
      question: 'Vaziyat (Muloqot): Katta zaiflik haqida bildirdingiz, ammo mijoz rahbari: "Bizga bu muhim emas, byudjet yoʻq" dedi. Qanday javob berasiz?',
      answer: 'Texnik atamalarsiz biznes riski va moliyaviy zararni tushuntirish',
      hint: 'Biznes tilida gapirish va xatarni rasmiylashtirish',
      stage: 1,
      intervalDays: 3,
      nextDue: today,
      options: [
        {
          'text': '"Siz xavfsizlikni tushunmas ekansiz" deb bahslashish',
          'is_correct': false,
          'feedback': 'Mijoz bilan ziddiyat hamkorlikni toʻxtatadi va xavf baribir yechimsiz qoladi.',
        },
        {
          'text': 'Xavfni biznes tili va ehtimoliy jarima/yoʻqotish summasi orqali koʻrsatib, yozma tasdiq olish',
          'is_correct': true,
          'feedback': 'Mukammal! Rahbarlar texnik jargondan koʻra pul va obroʻ yoʻqotilishini tezroq tushunishadi. Rasmiy javobgarlikni qayd etish professional yondashuvdir.',
        },
        {
          'text': 'Hech narsa demasdan indamay ketish',
          'is_correct': false,
          'feedback': 'Keyinchalik tizim buzilsa, birinchi navbatda pentester masʼuliyatsizlikda ayblanishi mumkin.',
        },
      ],
    );

    // Scenario 4: Baholash
    await insertScenario(
      subjectId: 1,
      question: 'Vaziyat (Baholash): Ichki admin paneldagi zaiflik faqat lokal tarmoqdan (VPN orqali) ishlaydi va parolni talab qiladi. U Critical boʻladimi yoki Medium?',
      answer: 'Medium yoki High (CVSS: Attack Vector Adjacent/Network with High Privileges)',
      hint: 'CVSS parametrlari: talab qilinadigan ruxsatlar va hujum vektori',
      stage: 0,
      intervalDays: 0,
      nextDue: today,
      options: [
        {
          'text': 'Critical, chunki baribir admin huquqiga taalluqli',
          'is_correct': false,
          'feedback': 'Critical zaifliklar odatda autentifikatsiyasiz va masofadan (Internetdan) amalga oshirilishi shart.',
        },
        {
          'text': 'Medium/High, chunki hujumchi avval ichki tarmoqqa kirishi va admin autentifikatsiyasiga ega boʻlishi kerak',
          'is_correct': true,
          'feedback': 'Toʻgʻri baho! Zaiflik xavfli boʻlsa-da, hujum uchun koʻplab shartlar bajarilishi talab qilinadi, shuning uchun CVSS skori pasayadi.',
        },
      ],
    );

    // Scenario 5: Chegara (Scope)
    await insertScenario(
      subjectId: 1,
      question: 'Vaziyat (Chegara): Shartnomada faqat `api.kompaniya.uz` koʻrsatilgan. Siz `dev-api.kompaniya.uz` da ochiq database topdingiz. Nima qilasiz?',
      answer: 'Tegmasdan, darhol mijozga scope tashqarisidagi jiddiy xavf sifatida yozma xabar berish',
      hint: 'Pentest huquqiy chegarasi (RoE - Rules of Engagement)',
      stage: 1,
      intervalDays: 3,
      nextDue: today,
      options: [
        {
          'text': 'Darhol unga ham kirib maʼlumotlarni koʻchirib olish va hisobotga kiritish',
          'is_correct': false,
          'feedback': 'Noqonuniy harakat! Shartnomadan tashqari tizimga kirish jinoyat kodeksi boʻyicha javobgarlikka sabab boʻlishi mumkin.',
        },
        {
          'text': 'Tegmasdan, skopdan tashqaridagi xatar sifatida mijoz kontaktiga xabar berish va ruxsat soʻrash',
          'is_correct': true,
          'feedback': 'Toʻgʻri etika! Xavfni koʻrib koʻrmaslikka olmaysiz, ammo qonuniy doirani buzmasdan xabardor qilasiz.',
        },
      ],
    );

    // Scenario 6: Backend & Kesh
    await insertScenario(
      subjectId: 3,
      question: 'Vaziyat (Kesh & DB): Yuqori yuklamali API da har daqiqada 100 000 ta bir xil mahsulot maʼlumoti soʻralmoqda. PostgreSQL CPU si 99% ga yetdi. Eng toʻgʻri birinchi qadam?',
      answer: 'Redis kesh (TTL bilan) va query indekslarini tekshirish',
      hint: 'Oʻqish yuklamasini bazadan uzoqlashtirish',
      stage: 0,
      intervalDays: 0,
      nextDue: today,
      options: [
        {
          'text': 'Server apparat taʼminotini (RAM/CPU) darhol 4 barobar kattalashtirish (Vertical scaling)',
          'is_correct': false,
          'feedback': 'Qimmat va vaqtinchalik chora. Arxivdagi tizimli muammoni hal qilmaydi.',
        },
        {
          'text': 'Tez-tez soʻraladigan maʼlumotni Redis keshga olish va mos indekslarni qoʻshish',
          'is_correct': true,
          'feedback': 'Aynan toʻgʻri arxitektura! 95%+ soʻrovlar xotiradagi (Redis) keshdan qaytadi, baza CPU si darhol 10% dan pastga tushadi.',
        },
      ],
    );

    // 3. Namunaviy QA kartochkalari (Ingliz tili, Tarmoqlar, Backend, Kiberxavfsizlik)
    await insertQA(
      subjectId: 2,
      question: 'IELTS Writing: "exacerbate" soʻzining maʼnosi va sinonimi nima?',
      answer: 'Vaziyatni yanada ogʻirlashtirish / chuqurlashtirish (worsen, aggravate). Misol: "Traffic congestion exacerbates air pollution."',
      hint: 'Muammoni battar qilish feʼli',
      stage: 1,
      intervalDays: 1,
      nextDue: today,
    );

    await insertQA(
      subjectId: 2,
      question: 'Collocation: "qiyin qaror qabul qilmoq" ingliz tilida qanday ifodalanadi?',
      answer: '"Make a tough decision" yoki "take a difficult decision"',
      hint: 'Feʼl tanlovi: do emas, make',
      stage: 2,
      intervalDays: 3,
      nextDue: today,
    );

    await insertQA(
      subjectId: 2,
      question: 'IELTS Academic: "Ubiquitous" soʻzining maʼnosi nima?',
      answer: 'Hamma joyda uchraydigan, keng tarqalgan (omnipresent, widespread). Misol: "Smartphones have become ubiquitous."',
      hint: 'Har qadamda bor narsa',
      stage: 0,
      intervalDays: 0,
      nextDue: today,
    );

    await insertQA(
      subjectId: 4,
      question: 'TCP ning 3 bosqichli ulanishi (Three-way handshake) bayroqlari tartibi qanday?',
      answer: '1. SYN (mijoz) -> 2. SYN-ACK (server) -> 3. ACK (mijoz)',
      hint: 'Sinxronizatsiya va tasdiqlash bayroqlari',
      stage: 3,
      intervalDays: 7,
      nextDue: today,
    );

    await insertQA(
      subjectId: 4,
      question: 'CIDR: /24 subnet maskida nechta foydalaniladigan (usable) host manzili boʻladi?',
      answer: '254 ta (Jami 256 ta - 1 ta tarmoq manzili - 1 ta broadcast manzili = 254).',
      hint: '2^(32-24) - 2',
      stage: 1,
      intervalDays: 1,
      nextDue: today,
    );

    await insertQA(
      subjectId: 3,
      question: 'PostgreSQL da B-Tree indeksi qachon ishlamay qoladi?',
      answer: 'Ustun ustida funksiya bajarilganda (masalan WHERE LOWER(email) = ...) yoki ustun tipi mos kelmaganida (implicit cast).',
      hint: 'Funksiya ichiga olingan ustunlar',
      stage: 2,
      intervalDays: 3,
      nextDue: today,
    );

    await insertQA(
      subjectId: 3,
      question: 'Idempotentlik nima va qaysi HTTP metodlari idempotent hisoblanadi?',
      answer: 'Bir necha marta takrorlanganda ham tizim holatini faqat bitta marta oʻzgartiruvchi operatsiya. GET, PUT, DELETE - idempotent. POST - idempotent emas.',
      hint: 'Koʻp marta yuborilsa ham natija bir xilligi',
      stage: 0,
      intervalDays: 0,
      nextDue: today,
    );

    await insertQA(
      subjectId: 1,
      question: 'SQL Injection: "Tautology" asosidagi hujumga oddiy misol keltiring.',
      answer: '\' OR 1=1 --\nBu ifoda doimo rost (TRUE) boʻlgani sababli autentifikatsiyani aylanib oʻtish imkonini beradi.',
      hint: 'Har doim haqiqiy boʻlgan tenglik',
      stage: 2,
      intervalDays: 3,
      nextDue: today,
    );

    // 4. Bugungi kun statistikasi boshlang'ich ma'lumoti
    await db.insert('day_stats', {
      'day_key': today,
      'total_seconds': 3600, // 1 soat o'qilgan
      'goal_seconds': 5400,  // 1.5 soat maqsad
      'sessions_count': 2,
      'reviews_done': 5,
      'reviews_correct': 4,
      'goal_met': 0,
      'avg_focus': 78,
      'sleep_hours': 7.5,
      'mood': 4,
      'exercise': 1,
      'screen_minutes': 140,
    });

    // Kechagi kunlar statistikasi (Streak hisobi ishlashi uchun)
    final dayMinus1 = SrsScheduler.addDaysToKey(today, -1);
    final dayMinus2 = SrsScheduler.addDaysToKey(today, -2);
    final dayMinus3 = SrsScheduler.addDaysToKey(today, -3);

    await db.insert('day_stats', {
      'day_key': dayMinus1,
      'total_seconds': 5800,
      'goal_seconds': 5400,
      'sessions_count': 3,
      'reviews_done': 12,
      'reviews_correct': 11,
      'goal_met': 1,
      'avg_focus': 82,
      'sleep_hours': 8.0,
      'mood': 5,
      'exercise': 1,
      'screen_minutes': 180,
    });

    await db.insert('day_stats', {
      'day_key': dayMinus2,
      'total_seconds': 4200,
      'goal_seconds': 5400,
      'sessions_count': 2,
      'reviews_done': 8,
      'reviews_correct': 7,
      'goal_met': 1, // >= goal/2 (5.3 bo'yicha)
      'avg_focus': 74,
      'sleep_hours': 6.5,
      'mood': 3,
      'exercise': 0,
      'screen_minutes': 210,
    });

    await db.insert('day_stats', {
      'day_key': dayMinus3,
      'total_seconds': 6100,
      'goal_seconds': 5400,
      'sessions_count': 3,
      'reviews_done': 10,
      'reviews_correct': 9,
      'goal_met': 1,
      'avg_focus': 88,
      'sleep_hours': 7.5,
      'mood': 4,
      'exercise': 1,
      'screen_minutes': 160,
    });

    // 5. Namuna o'quv yo'li (Learning Path - 17-ekran talabi)
    final pathId = await db.insert('paths', {
      'name': 'eJPT v2 Sertifikatsiyasi',
      'subject_id': 1,
      'note': 'Junior Penetration Tester imtihoniga tayyorgarlik rejam',
      'created_at': now,
    });

    await db.insert('path_items', {
      'path_id': pathId,
      'title': 'TCP/IP, Wireshark va tarmoq xizmatlari tahlili',
      'note': 'Protokollar tahlili va port skanerlash',
      'status': 'done',
      'sort_order': 1,
      'done_at': now,
    });

    await db.insert('path_items', {
      'path_id': pathId,
      'title': 'Nmap skanerlash taktikasi va NSE skriptlari',
      'note': 'Host discovery va xizmatlarni aniqlash',
      'status': 'doing',
      'sort_order': 2,
    });

    await db.insert('path_items', {
      'path_id': pathId,
      'title': 'Web ilovalar zaifliklari (OWASP Top 10)',
      'note': 'SQLi, XSS, IDOR amaliyoti',
      'status': 'todo',
      'sort_order': 3,
    });
  }
}
