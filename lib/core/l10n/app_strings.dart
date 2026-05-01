/// Gemini Hybrid i18n — centralizirani stringovi za Helpi Admin.
///
/// Svaki tekst koji se prikazuje korisniku MORA ići kroz ovu klasu.
class AppStrings {
  AppStrings._();

  // ─── Trenutni jezik ─────────────────────────────────────────────
  static String _currentLocale = 'hr';

  static String get currentLocale => _currentLocale;

  static void setLocale(String locale) {
    if (_localizedValues.containsKey(locale)) {
      _currentLocale = locale;
    }
  }

  // ─── Lokalizirane vrijednosti ───────────────────────────────────
  static final Map<String, Map<String, String>> _localizedValues = {
    'hr': {
      // ── App ───────────────────────────────────

      // ── Navigacija ────────────────────────────
      'navDashboard': 'Analitika',
      'navStudents': 'Studenti',
      'navSeniors': 'Seniori',
      'navChat': 'Poruke',
      'navCoupons': 'Kuponi',
      'navSettings': 'Postavke',
      'navMore': 'Više',

      // ── Postavke ──────────────────────────────
      'settingsTitle': 'Postavke',
      'settingsPricing': 'Cijena',
      'settingsRestrictions': 'Ograničenja',
      'settingsCancelRules': 'Otkazivanje sesije',
      'settingsAvailabilityRules': 'Promjena dostupnosti',
      'studentCancelEnabled': 'Student može otkazati',
      'availabilityChangeEnabled': 'Student može mijenjati dostupnost',
      'availabilityChangeCutoff': 'Student',
      'settingsOperational': 'Logistika',
      'settingsStudentRates': 'Satnica',
      'settingsEarnings': 'Troškovi',
      'settingsLanguage': 'Jezik',
      'langHr': 'Hrvatski',
      'langEn': 'Engleski',
      'settingsTheme': 'Tema',
      'settingsPreferences': 'Preferencije',
      'settingsConfiguration': 'Konfiguracija',
      'themeLight': 'Svijetla',
      'themeDark': 'Tamna',
      'themeSystem': 'Sistemska',
      'weekdayRate': 'Radni dan',
      'sundayRate': 'Neradni dan',
      'studentHourlyRate': 'Radni dan',
      'studentSundayRate': 'Neradni dan',
      'studentCancelCutoff': 'Student',
      'seniorCancelCutoff': 'Senior',
      'travelBuffer': 'Putovanje',
      'paymentTiming': 'Naplata',
      'vatPercentage': 'PDV (%)',
      'intermediaryPercentage': 'Posrednik',
      'settingsSaved': 'Postavke uspješno spremljene',
      'settingsSaveFailed': 'Spremanje postavki nije uspjelo',
      'settingsLoadFailed': 'Učitavanje postavki nije uspjelo',

      // ── Sponzorstvo ──
      'settingsSponsor': 'Sponzorstvo',
      'sponsorLogoUrl': 'URL logotipa',
      'sponsorDarkLogoUrl': 'URL logotipa (opcionalno)',
      'sponsorLabel': 'Tekst oznake',
      'sponsorActive': 'Sponzor vidljiv',
      'sponsorName': 'Naziv sponzora',
      'sponsorSaved': 'Sponzor uspješno spremljen',
      'sponsorSaveFailed': 'Spremanje sponzora nije uspjelo',
      'sponsorLoadFailed': 'Učitavanje sponzora nije uspjelo',
      'sponsorDarkLogoHint':
          'Opcionalno – ako je prazno, koristi se glavni logo',
      'sponsorChooseLogo': 'Odaberi logo',
      'sponsorChooseDarkLogo': 'Odaberi logo',
      'sponsorUploading': 'Učitavanje...',
      'sponsorUploadFailed': 'Upload logotipa nije uspio',
      'sponsorNoLogo': 'Nema logotipa',
      'sponsorDeleteLogoTitle': 'Obriši logotip',
      'sponsorDeleteLogoMsg':
          'Deaktiviraj sponzora prije brisanja glavnog loga.',
      'sponsorDeleteLogoConfirm': 'Želiš li obrisati ovaj logotip?',
      'sponsorDeleteFailed': 'Brisanje logotipa nije uspjelo',

      // ── Kuponi ────────────────────────────
      'couponsTitle': 'Kuponi',
      'couponNew': 'Novi kupon',
      'couponCode': 'Kod',
      'couponName': 'Naziv',
      'couponDescription': 'Opis',
      'couponType': 'Tip',
      'couponValue': 'Vrijednost',
      'couponCombinable': 'Može se kombinirati',
      'couponCity': 'Grad',
      'couponCityAll': 'Svi gradovi',
      'couponValidFrom': 'Vrijedi od',
      'couponValidUntil': 'Vrijedi do',
      'couponActive': 'Aktivan',
      'couponInactive': 'Neaktivan',
      'couponExpired': 'Istekao',
      'couponAssignments': 'Dodjele',
      'couponAssignSenior': 'Dodijeli kupon',
      'couponNoAssignments': 'Nema dodjela',
      'couponSaved': 'Kupon spremljen',
      'couponSaveFailed': 'Spremanje kupona nije uspjelo',
      'couponDeleted': 'Kupon obrisan',
      'couponDeleteFailed': 'Brisanje kupona nije uspjelo',
      'couponDeleteConfirm': 'Obrisati kupon?',
      'couponNoCoupons': 'Nema kupona',
      'couponTypeMonthlyHours': 'Mjesečno (sati)',
      'couponTypeWeeklyHours': 'Tjedno (sati)',
      'couponTypeOneTimeHours': 'Jednokratno (sati)',
      'couponRemainingHours': 'Preostalo sati',
      'couponAssignedBy': 'Dodijelio',
      'couponSelfRedeemed': 'Unio senior',
      'couponRedeemTitle': 'Aktiviraj kupon',
      'couponRedeemHint': 'Unesite kod kupona',
      'couponRedeemed': 'Kupon aktiviran',
      'couponRedeemFailed': 'Aktivacija kupona nije uspjela',
      'couponDeactivated': 'Kupon deaktiviran',
      'couponDeactivateFailed': 'Deaktivacija kupona nije uspjela',
      'couponNotFound': 'Kupon nije pronađen',
      'couponAlreadyActive': 'Kupon je već aktivan',
      'couponNotYetValid': 'Kupon još nije valjan',
      'couponExclusiveConflict': 'Ne može se kombinirati s postojećim kuponom',
      'couponActiveCoupons': 'Aktivni kuponi',
      'couponNone': 'Nema aktivnih kupona',
      'couponCodeCopied': 'Kod kupona kopiran',
      'couponCopyCode': 'Kopiraj kod',

      // ── Analitika ─────────────────────────────
      'dashboardTitle': 'Analitika',
      'analyticsLast7Days': 'Zadnjih 7 dana',
      'analyticsThisMonth': 'Ovaj mjesec',
      'analyticsLastMonth': 'Prošli mjesec',
      'analyticsCustomRange': 'Prilagođeno',
      'analyticsOrders': 'Narudžbe',
      'analyticsRevenue': 'Prihod',
      'analyticsActiveSeniors': 'Aktivni seniori',
      'analyticsCompare': 'Usporedi s prethodnim periodom',
      'analyticsNoData': 'Nema podataka za odabrani period',
      'analyticsCurrent': 'Trenutno',
      'analyticsPrevious': 'Prethodno',
      'analyticsEarnings': 'Zarada',
      'analyticsCompareShort': 'Usporedi prethodno',
      'analyticsExportDate': 'Datum',
      'analyticsExportStripeFee': 'Stripe naknada',
      'analyticsExportStudentPay': 'Isplata studentu',
      'analyticsExportStudentService': 'Studentski servis (18%)',
      'analyticsExportGrossRevenue': 'Prihod (bruto)',
      'analyticsExportSummarySheet': 'Usporedba',
      'analyticsExportMetric': 'Metrika',
      'analyticsExportCurrentPeriod': 'Trenutni period',
      'analyticsExportPreviousPeriod': 'Prethodni period',
      'analyticsExportChange': 'Promjena (%)',
      'analyticsExportTotal': 'Ukupno',

      // ── Narudžbe ──────────────────────────────
      'cancelOrderConfirmTitle': 'Otkaži narudžbu',
      'cancelOrderConfirmMsg':
          'Jeste li sigurni da želite otkazati ovu narudžbu? Svi nadolazeći termini će biti otkazani.',
      'cancelOrderBtn': 'Otkaži narudžbu',
      'editOrderTitle': 'Uredi narudžbu',
      'editOrderSuccess': 'Narudžba uspješno ažurirana',
      'orderNumber': 'Narudžba #{number}',
      'orderDetails': 'Detalji narudžbe',
      'orderDate': 'Datum',
      'orderServices': 'Usluge',
      'orderNotes': 'Napomena',
      'orderFrequency': 'Učestalost',
      'orderStudent': 'Student',
      'assignStudent': 'Dodijeli studenta',
      'reassignStudent': 'Promijeni studenta',
      'noStudentAssigned': 'Nije dodijeljen student',
      'pendingAcceptanceBanner': '{count} narudžbi čeka potvrdu studenta',
      'pendingAcceptanceTitle': 'Čekaju potvrdu',
      'pendingAcceptanceSenior': 'Senior',
      'pendingAcceptanceStudent': 'Student',
      'pendingAcceptanceTime': 'Čeka',
      'pendingAcceptanceEmpty': 'Nema narudžbi koje čekaju potvrdu.',
      'pendingAcceptanceMinutes': '{min} min',
      'pendingAcceptanceHours': '{h}h {min}min',
      'pendingAcceptanceDays': '{d}d {h}h',
      'studentAwaitingAcceptance': 'Čeka potvrdu studenta',
      'awaitingAcceptanceMulti': 'Čekaju potvrdu',
      'pendingStudentLabel': 'Dodijeljeni student',
      'suggestedStudents': 'Predloženi studenti',
      'assignConfirm': 'Dodijeliti {student} na ovu narudžbu?',
      'noOrdersFound': 'Nema pronađenih narudžbi',

      // ── Kreiranje narudžbe ────────────────────
      'createOrder': 'Nova narudžba',
      'addOrder': 'Dodaj narudžbu',
      'createOrderSuccess': 'Narudžba uspješno kreirana.',
      'selectSenior': 'Odaberi seniora',
      'selectSeniorHint': 'Pretraži seniore...',
      'scheduledDate': 'Datum',
      'scheduledTime': 'Vrijeme početka',
      'durationHoursLabel': 'Trajanje (sati)',
      'selectServices': 'Usluge',
      'orderNotesHint': 'Napomena (opcionalno)',
      'selectAtLeastOneService': 'Odaberite barem jednu uslugu.',
      'seniorRequired': 'Odaberite seniora.',
      'dateRequired': 'Odaberite datum.',
      'addDay': 'Dodaj dan',
      'selectDay': 'Odaberi dan',
      'hasEndDate': 'Do određenog datuma',

      // ── Statusi narudžbi ──────────────────────
      'statusProcessing': 'U obradi',
      'statusActive': 'Aktivna',
      'statusCompleted': 'Završena',
      'statusCancelled': 'Otkazana',

      // ── Statusi termina (job) ─────────────────

      // ── Studenti ──────────────────────────────
      'studentsTitle': 'Studenti',
      'studentFirstName': 'Ime',
      'studentLastName': 'Prezime',
      'studentEmail': 'Email',
      'studentPhone': 'Telefon',
      'studentAddress': 'Adresa',
      'studentFaculty': 'Fakultet',
      'studentRating': 'Prosječna ocjena',
      'studentCompletedJobs': 'Završenih',
      'studentReviewCount': 'recenzija',
      'studentCancelledJobs': 'Otkazanih',
      'studentAvailability': 'Dostupnost',
      'noAvailability': 'Nema unesene dostupnosti.',
      'workSummary': 'Obračun',
      'workTotalHours': 'Ukupno sati',
      'workRegularHours': 'Redovni sati',
      'workSundayHours': 'Prekovremeni',
      'workHourlyRate': 'Satnica',
      'workSundayRate': 'Povećana satnica',
      'workEstimatedPayout': 'Procjena isplate',
      'workNoOrders': 'Nema poslova u odabranom razdoblju.',
      'workContractPeriod': 'Ugovoreno razdoblje',
      'workCustomPeriod': 'Prilagođeno razdoblje',
      'workFrom': 'Od',
      'workTo': 'Do',
      'studentContractStart': 'Početak ugovora',
      'contractStatus': 'Status ugovora',
      'contractActive': 'Aktivan',
      'contractExpired': 'Istekao',
      'contractNone': 'Neaktivan',
      'searchStudents': 'Pretraži studente...',
      'noStudentsFound': 'Nema pronađenih studenata',
      'studentReviews': 'Ocjene studenta',
      'allStudents': 'Svi',
      'sortBy': 'Sortiraj',
      'sortAZ': 'A → Ž',
      'sortZA': 'Ž → A',
      'sortNewest': 'Najnoviji',
      'sortOldest': 'Najstariji',
      'sortRatingHigh': 'Ocjena ↓',
      'sortRatingLow': 'Ocjena ↑',

      // ── Napredni filteri studenata ────────────
      'advancedFilters': 'Napredni filteri',
      'filterByActivity': 'Aktivnost u periodu',
      'filterDidNotWork': 'Nije radio/la',
      'filterWorked': 'Radio/la',
      'filterPeriodThisMonth': 'Ovaj mjesec',
      'filterPeriodLastMonth': 'Prošli mjesec',
      'filterPeriodCustom': 'Prilagođeno',
      'filterPeriodFrom': 'Od datuma',
      'filterPeriodTo': 'Do datuma',
      'filterAvailHint': 'Dan + sat se kombiniraju',
      'filterMinJobs': 'Min. završenih poslova',
      'filterByAvailability': 'Dostupnost',
      'filterByDay': 'Dan u tjednu',
      'filterByTimeFrom': 'Dostupan od',
      'filterByTimeTo': 'Dostupan do',
      'excludeBusy': 'Isključi zauzete',
      'filterByRating': 'Minimalna ocjena',
      'filterByGender': 'Spol',
      'filterByFaculty': 'Fakultet',
      'anyFaculty': 'Bilo koji fakultet',
      'filterByCity': 'Grad',
      'anyCity': 'Svi gradovi',
      'filterBySenior': 'Radio/la kod seniora',
      'knownStudents': 'Poznati',
      'filterApply': 'Primijeni',
      'filterReset': 'Poništi sve',
      'filterActiveCount': '{count} aktivnih filtera',
      'dayMon': 'Pon',
      'dayTue': 'Uto',
      'dayWed': 'Sri',
      'dayThu': 'Čet',
      'dayFri': 'Pet',
      'daySat': 'Sub',
      'daySun': 'Ned',
      'anyGender': 'Bilo koji',
      'anyContract': 'Svi',
      'anySenior': 'Bilo koji',
      'filterResultCount': '{count} studenata',
      'seniorResultCount': '{count} seniora',

      // ── Detalji studenta ──────────────────────
      'studentPersonalData': 'Osobni podaci',
      'studentDateOfBirth': 'Datum rođenja',
      'studentGender': 'Spol',
      'genderMale': 'Muški',
      'genderFemale': 'Ženski',
      'studentTotalRatings': 'Ukupno ocjena',
      'studentContractTitle': 'Ugovor',
      'studentContractStatus': 'Status ugovora',
      'studentContractExpiry': 'Ističe',
      'studentUploadContract': 'Učitaj ugovor',
      'contractUploadSuccess': 'Ugovor uspješno učitan.',
      'contractSelectPeriod': 'Odaberi period ugovora',
      'contractNumber': 'Broj ugovora',
      'contractDelete': 'Obriši ugovor',
      'contractDeleteTitle': 'Brisanje ugovora',
      'contractDeleteConfirm':
          'Jeste li sigurni da želite obrisati ugovor? Datoteka će biti obrisana s Google Drivea.',
      'contractDeleteSuccess': 'Ugovor uspješno obrisan.',
      'contractLoading': 'Učitavanje ugovora...',
      'contractDeleting': 'Brisanje ugovora...',
      'studentNotAvailableMale': 'Nedostupan',
      'studentNotAvailableFemale': 'Nedostupna',
      'studentAssignedOrders': 'Dodijeljene narudžbe',
      'studentArchive': 'Arhiviraj',
      'studentUnarchive': 'Vrati iz arhive',
      'archiveConfirmTitle': 'Arhiviraj',
      'archiveConfirmMsg':
          'Jeste li sigurni da želite arhivirati? Arhivirani profil neće biti vidljiv na listi.',
      'unarchiveConfirmTitle': 'Vrati iz arhive',
      'unarchiveConfirmMsg':
          'Jeste li sigurni da želite vratiti profil iz arhive?',
      'archiveBlockedTitle': 'Upozorenje pri arhiviranju',
      'archiveWarningOrders':
          'Arhiviranjem korisnika otkazat će se {count} {orders}. Želite li nastaviti?',
      'archiveWarningAssignments':
          'Arhiviranjem studenta otkazat će se {count} {assignments}. Želite li nastaviti?',
      'archiveSuccess': 'Uspješno arhivirano',
      'unarchiveSuccess': 'Uspješno vraćeno iz arhive',
      'suspendWarningTitle': 'Upozorenje pri suspenziji',
      'suspendWarningMsg':
          'Korisnik ima aktivnih narudžbi koje će biti automatski otkazane. Želite li nastaviti?',
      'suspendWarningStudentMsg':
          'Student ima aktivne narudžbe s kojih će biti uklonjen. Narudžbe će se vratiti na status "U obradi" dok se ne pronađe zamjena. Želite li nastaviti?',
      'filterAll': 'Svi',
      'filterProcessing': 'U obradi',
      'seniorFilterActive': 'Aktivan',
      'seniorFilterInactive': 'Neaktivan',
      'filterArchived': 'Arhiviran',
      'statusArchived': 'Arhiviran',
      'adminActions': 'Admin akcije',
      'adminNotes': 'Bilješke',
      'adminNotesEmpty': 'Nema bilješki',
      'adminNoteAdd': 'Dodaj bilješku',
      'adminNoteEdit': 'Uredi bilješku',
      'adminNoteSave': 'Spremi',
      'adminNoteCancel': 'Odustani',
      'adminNoNotes': 'Nema zabilješki za ovog studenta.',
      'adminNoteDelete': 'Obriši bilješku',
      'adminNoteDeleteConfirm':
          'Jeste li sigurni da želite obrisati ovu bilješku?',
      'adminNotePlaceholder': 'Unesite bilješku...',
      'adminNoteEdited': 'uređeno',
      'assignShort': 'Dodijeli',
      'assignSuccess': 'Student dodijeljen na nalog',
      'allSchedulesCovered': 'Svi termini već imaju dodijeljenog studenta',
      'hours': 'h',

      // ── Session Preview (assign flow) ────────
      'sessionPreviewTitle': 'Pregled sesija',
      'sessionPreviewWeeks': 'Sljedećih 8 tjedana',
      'sessionFree': 'Slobodan',
      'sessionConflict': 'Zauzet',
      'sessionSkipped': 'Preskočeno',
      'sessionRescheduled': 'Pomaknut termin',
      'sessionRescheduledShort': 'Pomaknut',
      'sessionSubstitute': 'Zamjena',
      'skipSession': 'Preskoči',
      'changeTime': 'Pomakni',
      'findSubstitute': 'Zamjena',
      'undoSkip': 'Vrati',
      'confirmAssign': 'Potvrdi dodjelu',
      'unresolvedConflicts': 'Još imate neriješenih konflikata',
      'conflictWith': 'Konflikt s',
      'selectNewTime': 'Odaberi novi termin',
      'selectSubstitute': 'Odaberi zamjenu',
      'noSubstitutesAvailable': 'Nema dostupnih zamjena za ovaj termin',
      'noAlternativeSlots': 'Nema dostupnih alternativnih termina',
      'sessionCountChip': '{count} sesija',

      // ── Raspored sekcija ──────────────────────
      'editLayout': 'Uredi raspored',
      'sectionLayoutTitle': 'Raspored sekcija',
      'sectionLayoutHint': 'Povuci za promjenu redoslijeda',
      'resetDefault': 'Reset',

      // ── Detalji seniora ───────────────────────
      'seniorOrdererTitle': 'Naručitelj usluga',
      'seniorServiceUser': 'Korisnik usluga',
      'seniorOrdererFirstName': 'Ime',
      'seniorOrdererLastName': 'Prezime',
      'seniorOrdererEmail': 'Email',
      'seniorOrdererName': 'Ime naručitelja',
      'seniorOrdererPhone': 'Telefon',
      'seniorOrdererAddress': 'Adresa',
      'seniorOrdererGender': 'Spol',
      'seniorOrdererDob': 'Datum rođenja',
      'addSeniorTitle': 'Novi senior',
      'addSeniorSuccess': 'Senior uspješno dodan',
      'editSeniorTitle': 'Uredi seniora',
      'editSeniorSuccess': 'Podaci uspješno ažurirani',
      'editStudentTitle': 'Uredi studenta',
      'editStudentSuccess': 'Podaci studenta uspješno ažurirani',
      'addSeniorHasOrderer': 'Ima naručitelja',
      'fieldRequired': 'Obavezno polje',
      'selectDate': 'Odaberi datum',
      'selectGender': 'Odaberi spol',
      'seniorCreditCards': 'Kartice za plaćanje',
      'seniorNoCards': 'Nema spremljenih kartica',
      'cardExpiry': 'Ističe',
      'cardExpired': 'Istekla',

      // ── Chat detalji ──────────────────────────
      'chatSelectConversation': 'Odaberite razgovor',
      'chatNoMessages': 'Nema poruka',
      'chatInputHint': 'Upiši poruku...',
      'chatSearchHint': 'Pretraži korisnike...',
      'chatNoConversationYet': 'Još nema razgovora',

      // ── Seniori ───────────────────────────────
      'seniorsTitle': 'Seniori',
      'seniorFirstName': 'Ime',
      'seniorLastName': 'Prezime',
      'seniorEmail': 'Email',
      'seniorPhone': 'Telefon',
      'seniorAddress': 'Adresa',
      'seniorReviews': 'Ocjene seniora',
      'seniorNoReviews': 'Nema ocjena',
      'seniorOrders': 'Narudžbe seniora',
      'searchSeniors': 'Pretraži seniore...',
      'noSeniorsFound': 'Nema pronađenih seniora',

      // ── Chat ──────────────────────────────────
      'chatTitle': 'Poruke',

      // ── Usluge ────────────────────────────────
      'serviceShopping': 'Kupovina',
      'serviceHouseHelp': 'Pomoć u kući',
      'serviceCompanionship': 'Društvo',
      'serviceWalking': 'Šetnja',
      'serviceEscort': 'Pratnja',
      'serviceOther': 'Ostalo',

      // ── Ponavljanje ──────────────────────────
      'oneTime': 'Jednom',
      'recurring': 'Ponavljajuće',
      'recurringWithEnd': 'Do {date}',

      // ── Termini ──────────────────────────────────
      'sessionsTitle': 'Termini',
      'sessionsTitleSingular': 'Termin',
      'sessionsMonthlySubtitle': 'Prikazani termini za {month} {year}.',
      'sessionsPlannedSubtitle': 'Čeka se dodjela studenta.',
      'sessionsCancelledSubtitle': 'Narudžba je otkazana.',
      'sessionStatusPlanned': 'Planirano',
      'sessionStatusScheduled': 'Nadolazeći',
      'sessionStatusActive': 'Aktivan',
      'sessionStatusCompleted': 'Završen',
      'sessionStatusCancelled': 'Otkazan',
      'sessionCancel': 'Otkaži termin',
      'sessionCancelShort': 'Otkaži',
      'sessionReschedule': 'Promijeni termin',
      'sessionRescheduleShort': 'Promijeni',
      'sessionSelectStudent': 'Odaberi studenta',
      'sessionNewDate': 'Novi datum',
      'sessionNewTime': 'Novo vrijeme',
      'sessionCancelConfirm':
          'Jeste li sigurni da želite otkazati ovaj termin?',
      'sessionRescheduleTitle': 'Promjena termina',
      'sessionKeepCurrentStudent': 'Zadrži trenutnog',
      'noStudentsForSlot': 'Nema dostupnih studenata za odabrani termin',
      'selectTime': 'Odaberi vrijeme',
      'timePickerHour': 'Sat',
      'timePickerMinute': 'Min',
      'availableAllDays': 'Dostupan sve dane',
      'availableAllDaysShort': 'Dostupan',
      'availableDifferentTimes': 'Djelomično dostupan',
      'availableDifferentTimesShort': 'Djelomično',
      'reviewSessions': 'Pregled termina',
      'reviewShort': 'Pregled',
      'timeMismatch': 'Razlika u satima',
      'unavailableDay': 'Nedostupan taj dan',
      'sessionReactivate': 'Vrati termin',
      'sessionModified': 'Izmijenjeno',
      'seniorSessionConflict':
          'Senior već ima drugi termin na {date} koji se preklapa s {time}.',

      // ── Općenito ──────────────────────────────
      'loading': 'Učitavanje...',
      'error': 'Greška',
      'retry': 'Pokušaj ponovo',
      'cancel': 'Odustani',
      'confirm': 'Potvrdi',
      'ok': 'U redu',
      'save': 'Spremi',
      'saving': 'Spremam...',
      'delete': 'Obriši',
      'edit': 'Uredi',
      'yesterday': 'Jučer',
      'emailCopied': 'Email kopiran',
      'copyEmail': 'Kopiraj email',
      'callPhone': 'Nazovi',

      // ── Notifications ──
      'notifications': 'Obavijesti',
      'noNotifications': 'Nema novih obavijesti',
      'archiveNotifications': 'Arhiviraj',
      'notifArchiveFailed': 'Arhiviranje nije uspjelo',
      'notifArchiveEmpty': 'Nema pročitanih obavijesti za arhiviranje',
      'notifArchiving': 'Arhiviranje...',
      'justNow': 'Upravo sad',
      'minutesAgo': 'min prije',
      'hoursAgo': 'h prije',
      'daysAgo': 'd prije',

      // ── Auth ──────────────────────────────────
      'email': 'E-mail adresa',
      'password': 'Lozinka',
      'loginButton': 'Prijavi se',
      'logout': 'Odjava',
      'forgotPassword': 'Zaboravljena lozinka?',
      'loginError': 'Greška pri prijavi',
      'invalidCredentials': 'Neispravni podaci za prijavu',
      'forgotPasswordTitle': 'Zaboravljena lozinka',
      'forgotPasswordSubtitle': 'Unesite email adresu za slanje koda',
      'sendResetCode': 'Pošalji kod',
      'resetCode': 'Kod za resetiranje',
      'newPassword': 'Nova lozinka',
      'confirmNewPassword': 'Potvrdite novu lozinku',
      'resetPasswordButton': 'Resetiraj lozinku',
      'resetPasswordSuccess': 'Lozinka uspješno promijenjena',
      'setPasswordLabel': 'Postavi lozinku',
      'setPasswordHint': 'Ostavi prazno ako ne želiš mijenjati',
      'codeSent': 'Kod je poslan na vaš email',
      'backToLogin': 'Povratak na prijavu',

      // ── Profil / Postavke ─────────────────────

      // ── Dani ──────────────────────────────────
      'dayMonFull': 'Ponedjeljak',
      'dayTueFull': 'Utorak',
      'dayWedFull': 'Srijeda',
      'dayThuFull': 'Četvrtak',
      'dayFriFull': 'Petak',
      'daySatFull': 'Subota',
      'daySunFull': 'Nedjelja',

      // ── Mjeseci ───────────────────────────────
      'monthJan': 'Siječanj',
      'monthFeb': 'Veljača',
      'monthMar': 'Ožujak',
      'monthApr': 'Travanj',
      'monthMay': 'Svibanj',
      'monthJun': 'Lipanj',
      'monthJul': 'Srpanj',
      'monthAug': 'Kolovoz',
      'monthSep': 'Rujan',
      'monthOct': 'Listopad',
      'monthNov': 'Studeni',
      'monthDec': 'Prosinac',

      // ── Parametrizirani ───────────────────────

      // ── Suspenzija ──
      'suspend': 'Suspendiraj',
      'activate': 'Aktiviraj',
      'suspended': 'Suspendiran',
      'suspensionReason': 'Razlog suspenzije',
      'suspensionReasonHint': 'Unesite razlog suspenzije...',
      'suspensionHistory': 'Povijest suspenzija',
      'suspendConfirmTitle': 'Potvrda suspenzije',
      'suspendConfirmMsg':
          'Jeste li sigurni da želite suspendirati korisnika {name}?',
      'activateConfirmTitle': 'Potvrda aktivacije',
      'activateConfirmMsg':
          'Jeste li sigurni da želite aktivirati korisnika {name}?',
      'suspensionSuccess': 'Korisnik uspješno suspendiran',
      'activationSuccess': 'Korisnik uspješno aktiviran',
      'suspensionFailed': 'Suspenzija nije uspjela',
      'activationFailed': 'Aktivacija nije uspjela',
      'suspensionReasonRequired': 'Razlog suspenzije je obavezan',
      'actionSuspended': 'Suspendiran',
      'actionActivated': 'Aktiviran',
      'noSuspensionHistory': 'Nema povijesti suspenzija',

      // ── Export ────────────────────────────────
      'exportToExcel': 'Izvezi u Excel',
      'exportSuccess': 'Podaci uspješno izvezeni',
      'studentCreatedAt': 'Datum registracije',

      // ── Server nedostupan ─────────────────────────
      'serverUnavailableTitle': 'Server nedostupan',
      'serverUnavailableMessage':
          'Nije moguće spojiti se na server. Provjerite je li backend pokrenut.',
      'serverUnavailableRetrying': 'Pokušavam ponovo...',
      'serverUnavailableRetry': 'Pokušaj ponovo',
    },

    'en': {
      // ── App ───────────────────────────────────

      // ── Navigacija ────────────────────────────
      'navDashboard': 'Analytics',
      'navStudents': 'Students',
      'navSeniors': 'Seniors',
      'navChat': 'Messages',
      'navCoupons': 'Coupons',
      'navSettings': 'Settings',
      'navMore': 'More',

      // ── Settings ──────────────────────────────
      'settingsTitle': 'Settings',
      'settingsPricing': 'Pricing',
      'settingsRestrictions': 'Restrictions',
      'settingsCancelRules': 'Session cancellation',
      'settingsAvailabilityRules': 'Availability change',
      'studentCancelEnabled': 'Student can cancel',
      'availabilityChangeEnabled': 'Student can change availability',
      'availabilityChangeCutoff': 'Student',
      'settingsOperational': 'Logistics',
      'settingsStudentRates': 'Rates',
      'settingsEarnings': 'Costs',
      'settingsLanguage': 'Language',
      'langHr': 'Croatian',
      'langEn': 'English',
      'settingsTheme': 'Theme',
      'settingsPreferences': 'Preferences',
      'settingsConfiguration': 'Configuration',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'themeSystem': 'System',
      'weekdayRate': 'Weekday',
      'sundayRate': 'Non-working day',
      'studentHourlyRate': 'Weekday',
      'studentSundayRate': 'Non-working day',
      'studentCancelCutoff': 'Student',
      'seniorCancelCutoff': 'Senior',
      'travelBuffer': 'Travel',
      'paymentTiming': 'Payment',
      'vatPercentage': 'VAT (%)',
      'intermediaryPercentage': 'Intermediary',
      'settingsSaved': 'Settings saved successfully',
      'settingsSaveFailed': 'Failed to save settings',
      'settingsLoadFailed': 'Failed to load settings',

      // ── Sponsor ──
      'settingsSponsor': 'Sponsorship',
      'sponsorLogoUrl': 'Logo URL',
      'sponsorDarkLogoUrl': 'Logo URL (optional)',
      'sponsorLabel': 'Label text',
      'sponsorActive': 'Sponsor visible',
      'sponsorName': 'Sponsor name',
      'sponsorSaved': 'Sponsor saved successfully',
      'sponsorSaveFailed': 'Failed to save sponsor',
      'sponsorLoadFailed': 'Failed to load sponsor',
      'sponsorDarkLogoHint': 'Optional – if empty, main logo is used',
      'sponsorChooseLogo': 'Choose logo',
      'sponsorChooseDarkLogo': 'Choose logo',
      'sponsorUploading': 'Uploading...',
      'sponsorUploadFailed': 'Logo upload failed',
      'sponsorNoLogo': 'No logo',
      'sponsorDeleteLogoTitle': 'Delete logo',
      'sponsorDeleteLogoMsg':
          'Deactivate sponsor before deleting the main logo.',
      'sponsorDeleteLogoConfirm': 'Do you want to delete this logo?',
      'sponsorDeleteFailed': 'Failed to delete logo',

      // ── Coupons ────────────────────────────
      'couponsTitle': 'Coupons',
      'couponNew': 'New coupon',
      'couponCode': 'Code',
      'couponName': 'Name',
      'couponDescription': 'Description',
      'couponType': 'Type',
      'couponValue': 'Value',
      'couponCombinable': 'Can be combined',
      'couponCity': 'City',
      'couponCityAll': 'All cities',
      'couponValidFrom': 'Valid from',
      'couponValidUntil': 'Valid until',
      'couponActive': 'Active',
      'couponInactive': 'Inactive',
      'couponExpired': 'Expired',
      'couponAssignments': 'Assignments',
      'couponAssignSenior': 'Assign coupon',
      'couponNoAssignments': 'No assignments',
      'couponSaved': 'Coupon saved',
      'couponSaveFailed': 'Failed to save coupon',
      'couponDeleted': 'Coupon deleted',
      'couponDeleteFailed': 'Failed to delete coupon',
      'couponDeleteConfirm': 'Delete coupon?',
      'couponNoCoupons': 'No coupons',
      'couponTypeMonthlyHours': 'Monthly (hours)',
      'couponTypeWeeklyHours': 'Weekly (hours)',
      'couponTypeOneTimeHours': 'One-time (hours)',
      'couponRemainingHours': 'Remaining hours',
      'couponAssignedBy': 'Assigned by',
      'couponSelfRedeemed': 'Self-redeemed',
      'couponRedeemTitle': 'Activate coupon',
      'couponRedeemHint': 'Enter coupon code',
      'couponRedeemed': 'Coupon activated',
      'couponRedeemFailed': 'Coupon activation failed',
      'couponDeactivated': 'Coupon deactivated',
      'couponDeactivateFailed': 'Coupon deactivation failed',
      'couponNotFound': 'Coupon not found',
      'couponAlreadyActive': 'Coupon is already active',
      'couponNotYetValid': 'Coupon is not yet valid',
      'couponExclusiveConflict': 'Cannot combine with existing coupon',
      'couponActiveCoupons': 'Active coupons',
      'couponNone': 'No active coupons',
      'couponCodeCopied': 'Coupon code copied',
      'couponCopyCode': 'Copy code',

      // ── Analitika ─────────────────────────────
      'dashboardTitle': 'Analytics',
      'analyticsLast7Days': 'Last 7 days',
      'analyticsThisMonth': 'This month',
      'analyticsLastMonth': 'Last month',
      'analyticsCustomRange': 'Custom range',
      'analyticsOrders': 'Orders',
      'analyticsRevenue': 'Revenue',
      'analyticsActiveSeniors': 'Active seniors',
      'analyticsCompare': 'Compare with previous period',
      'analyticsNoData': 'No data for selected period',
      'analyticsCurrent': 'Current',
      'analyticsPrevious': 'Previous',
      'analyticsEarnings': 'Earnings',
      'analyticsCompareShort': 'Compare previous',
      'analyticsExportDate': 'Date',
      'analyticsExportStripeFee': 'Stripe fee',
      'analyticsExportStudentPay': 'Student pay',
      'analyticsExportStudentService': 'Student service (18%)',
      'analyticsExportGrossRevenue': 'Revenue (gross)',
      'analyticsExportSummarySheet': 'Comparison',
      'analyticsExportMetric': 'Metric',
      'analyticsExportCurrentPeriod': 'Current period',
      'analyticsExportPreviousPeriod': 'Previous period',
      'analyticsExportChange': 'Change (%)',
      'analyticsExportTotal': 'Total',

      // ── Narudžbe ──────────────────────────────
      'cancelOrderConfirmTitle': 'Cancel order',
      'cancelOrderConfirmMsg':
          'Are you sure you want to cancel this order? All upcoming sessions will be cancelled.',
      'cancelOrderBtn': 'Cancel order',
      'editOrderTitle': 'Edit order',
      'editOrderSuccess': 'Order updated successfully',
      'orderNumber': 'Order #{number}',
      'orderDetails': 'Order details',
      'orderDate': 'Date',
      'orderServices': 'Services',
      'orderNotes': 'Note',
      'orderFrequency': 'Frequency',
      'orderStudent': 'Student',
      'assignStudent': 'Assign student',
      'reassignStudent': 'Reassign student',
      'noStudentAssigned': 'No student assigned',
      'pendingAcceptanceBanner': '{count} orders awaiting student confirmation',
      'pendingAcceptanceTitle': 'Awaiting confirmation',
      'pendingAcceptanceSenior': 'Senior',
      'pendingAcceptanceStudent': 'Student',
      'pendingAcceptanceTime': 'Waiting',
      'pendingAcceptanceEmpty': 'No orders awaiting confirmation.',
      'pendingAcceptanceMinutes': '{min} min',
      'pendingAcceptanceHours': '{h}h {min}min',
      'pendingAcceptanceDays': '{d}d {h}h',
      'studentAwaitingAcceptance': 'Awaiting student confirmation',
      'awaitingAcceptanceMulti': 'Awaiting confirmation',
      'pendingStudentLabel': 'Assigned student',
      'suggestedStudents': 'Suggested students',
      'assignConfirm': 'Assign {student} to this order?',
      'noOrdersFound': 'No orders found',

      // ── Kreiranje narudžbe ────────────────────
      'createOrder': 'New order',
      'addOrder': 'Add order',
      'createOrderSuccess': 'Order created successfully.',
      'selectSenior': 'Select senior',
      'selectSeniorHint': 'Search seniors...',
      'scheduledDate': 'Date',
      'scheduledTime': 'Start time',
      'durationHoursLabel': 'Duration (hours)',
      'selectServices': 'Services',
      'orderNotesHint': 'Note (optional)',
      'selectAtLeastOneService': 'Select at least one service.',
      'seniorRequired': 'Please select a senior.',
      'dateRequired': 'Please select a date.',
      'addDay': 'Add day',
      'selectDay': 'Select day',
      'hasEndDate': 'Until specific date',

      // ── Statusi narudžbi ──────────────────────
      'statusProcessing': 'Processing',
      'statusActive': 'Active',
      'statusCompleted': 'Completed',
      'statusCancelled': 'Cancelled',

      // ── Statusi termina (job) ─────────────────

      // ── Studenti ──────────────────────────────
      'studentsTitle': 'Students',
      'studentFirstName': 'First name',
      'studentLastName': 'Last name',
      'studentEmail': 'Email',
      'studentPhone': 'Phone',
      'studentAddress': 'Address',
      'studentFaculty': 'Faculty',
      'studentRating': 'Average rating',
      'studentCompletedJobs': 'Completed',
      'studentReviewCount': 'reviews',
      'studentCancelledJobs': 'Cancelled',
      'studentAvailability': 'Availability',
      'noAvailability': 'No availability set.',
      'workSummary': 'Payout',
      'workTotalHours': 'Total hours',
      'workRegularHours': 'Regular hours',
      'workSundayHours': 'Overtime',
      'workHourlyRate': 'Hourly rate',
      'workSundayRate': 'Overtime rate',
      'workEstimatedPayout': 'Estimated payout',
      'workNoOrders': 'No jobs in selected period.',
      'workContractPeriod': 'Contract period',
      'workCustomPeriod': 'Custom period',
      'workFrom': 'From',
      'workTo': 'To',
      'studentContractStart': 'Contract start',
      'contractStatus': 'Contract status',
      'contractActive': 'Active',
      'contractExpired': 'Expired',
      'contractNone': 'Inactive',
      'searchStudents': 'Search students...',
      'noStudentsFound': 'No students found',
      'studentReviews': 'Student reviews',
      'allStudents': 'All',
      'sortBy': 'Sort',
      'sortAZ': 'A → Z',
      'sortZA': 'Z → A',
      'sortNewest': 'Newest',
      'sortOldest': 'Oldest',
      'sortRatingHigh': 'Rating ↓',
      'sortRatingLow': 'Rating ↑',

      // ── Advanced student filters ──────────────
      'advancedFilters': 'Advanced filters',
      'filterByActivity': 'Activity in period',
      'filterDidNotWork': 'Did not work',
      'filterWorked': 'Worked',
      'filterPeriodThisMonth': 'This month',
      'filterPeriodLastMonth': 'Last month',
      'filterPeriodCustom': 'Custom',
      'filterPeriodFrom': 'From date',
      'filterPeriodTo': 'To date',
      'filterAvailHint': 'Day + hour are combined',
      'filterMinJobs': 'Min. completed jobs',
      'filterByAvailability': 'Availability',
      'filterByDay': 'Day of week',
      'filterByTimeFrom': 'Available from',
      'filterByTimeTo': 'Available to',
      'excludeBusy': 'Exclude busy',
      'filterByRating': 'Minimum rating',
      'filterByGender': 'Gender',
      'filterByFaculty': 'Faculty',
      'anyFaculty': 'Any faculty',
      'filterByCity': 'City',
      'anyCity': 'All cities',
      'filterBySenior': 'Worked with senior',
      'knownStudents': 'Known',
      'filterApply': 'Apply',
      'filterReset': 'Reset all',
      'filterActiveCount': '{count} active filters',
      'dayMon': 'Mon',
      'dayTue': 'Tue',
      'dayWed': 'Wed',
      'dayThu': 'Thu',
      'dayFri': 'Fri',
      'daySat': 'Sat',
      'daySun': 'Sun',
      'anyGender': 'Any',
      'anyContract': 'All',
      'anySenior': 'Any',
      'filterResultCount': '{count} students',
      'seniorResultCount': '{count} seniors',

      // ── Detalji studenta ──────────────────────
      'studentPersonalData': 'Personal data',
      'studentDateOfBirth': 'Date of birth',
      'studentGender': 'Gender',
      'genderMale': 'Male',
      'genderFemale': 'Female',
      'studentTotalRatings': 'Total ratings',
      'studentContractTitle': 'Contract',
      'studentContractStatus': 'Contract status',
      'studentContractExpiry': 'Expires',
      'studentUploadContract': 'Upload contract',
      'contractUploadSuccess': 'Contract uploaded successfully.',
      'contractSelectPeriod': 'Select contract period',
      'contractNumber': 'Contract number',
      'contractDelete': 'Delete contract',
      'contractDeleteTitle': 'Delete contract',
      'contractDeleteConfirm':
          'Are you sure you want to delete this contract? The file will be removed from Google Drive.',
      'contractDeleteSuccess': 'Contract deleted successfully.',
      'contractLoading': 'Loading contract...',
      'contractDeleting': 'Deleting contract...',
      'studentNotAvailableMale': 'Not available',
      'studentNotAvailableFemale': 'Not available',
      'studentAssignedOrders': 'Assigned orders',
      'studentArchive': 'Archive',
      'studentUnarchive': 'Restore from archive',
      'archiveConfirmTitle': 'Archive',
      'archiveConfirmMsg':
          'Are you sure you want to archive? Archived profile will not be visible on the list.',
      'unarchiveConfirmTitle': 'Restore from archive',
      'unarchiveConfirmMsg':
          'Are you sure you want to restore this profile from the archive?',
      'archiveBlockedTitle': 'Archive warning',
      'archiveWarningOrders':
          'Archiving will cancel {count} {orders}. Continue?',
      'archiveWarningAssignments':
          'Archiving will cancel {count} {assignments}. Continue?',
      'archiveSuccess': 'Successfully archived',
      'unarchiveSuccess': 'Successfully restored from archive',
      'suspendWarningTitle': 'Suspension warning',
      'suspendWarningMsg':
          'This user has active orders that will be automatically cancelled. Continue?',
      'suspendWarningStudentMsg':
          'Student has active orders from which they will be removed. Orders will return to "Processing" status until a replacement is found. Continue?',
      'filterAll': 'All',
      'filterProcessing': 'Processing',
      'seniorFilterActive': 'Active',
      'seniorFilterInactive': 'Inactive',
      'filterArchived': 'Archived',
      'statusArchived': 'Archived',
      'adminActions': 'Admin actions',
      'adminNotes': 'Notes',
      'adminNotesEmpty': 'No notes',
      'adminNoteAdd': 'Add note',
      'adminNoteEdit': 'Edit note',
      'adminNoteSave': 'Save',
      'adminNoteCancel': 'Cancel',
      'adminNoNotes': 'No notes for this student.',
      'adminNoteDelete': 'Delete note',
      'adminNoteDeleteConfirm': 'Are you sure you want to delete this note?',
      'adminNotePlaceholder': 'Enter note...',
      'adminNoteEdited': 'edited',
      'assignShort': 'Assign',
      'assignSuccess': 'Student assigned to order',
      'allSchedulesCovered': 'All schedules already have a student assigned',
      'hours': 'h',

      // ── Session Preview (assign flow) ────────
      'sessionPreviewTitle': 'Session preview',
      'sessionPreviewWeeks': 'Next 8 weeks',
      'sessionFree': 'Available',
      'sessionConflict': 'Busy',
      'sessionSkipped': 'Skipped',
      'sessionRescheduled': 'Rescheduled',
      'sessionRescheduledShort': 'Rescheduled',
      'sessionSubstitute': 'Substitute',
      'skipSession': 'Skip',
      'changeTime': 'Reschedule',
      'findSubstitute': 'Substitute',
      'undoSkip': 'Undo',
      'confirmAssign': 'Confirm assignment',
      'unresolvedConflicts': 'You still have unresolved conflicts',
      'conflictWith': 'Conflict with',
      'selectNewTime': 'Select new time',
      'selectSubstitute': 'Select substitute',
      'noSubstitutesAvailable': 'No substitutes available for this slot',
      'noAlternativeSlots': 'No alternative time slots available',
      'sessionCountChip': '{count} sessions',

      // ── Raspored sekcija ──────────────────────
      'editLayout': 'Edit layout',
      'sectionLayoutTitle': 'Section layout',
      'sectionLayoutHint': 'Drag to change order',
      'resetDefault': 'Reset',

      // ── Detalji seniora ───────────────────────
      'seniorOrdererTitle': 'Service orderer',
      'seniorServiceUser': 'Service user',
      'seniorOrdererFirstName': 'First name',
      'seniorOrdererLastName': 'Last name',
      'seniorOrdererEmail': 'Email',
      'seniorOrdererName': 'Orderer name',
      'seniorOrdererPhone': 'Phone',
      'seniorOrdererAddress': 'Address',
      'seniorOrdererGender': 'Gender',
      'seniorOrdererDob': 'Date of birth',
      'addSeniorTitle': 'New senior',
      'addSeniorSuccess': 'Senior added successfully',
      'editSeniorTitle': 'Edit senior',
      'editSeniorSuccess': 'Data updated successfully',
      'editStudentTitle': 'Edit student',
      'editStudentSuccess': 'Student data updated successfully',
      'addSeniorHasOrderer': 'Has orderer',
      'fieldRequired': 'Required field',
      'selectDate': 'Select date',
      'selectGender': 'Select gender',
      'seniorCreditCards': 'Payment cards',
      'seniorNoCards': 'No saved cards',
      'cardExpiry': 'Expires',
      'cardExpired': 'Expired',

      // ── Chat detalji ──────────────────────────
      'chatSelectConversation': 'Select a conversation',
      'chatNoMessages': 'No messages',
      'chatInputHint': 'Type a message...',
      'chatSearchHint': 'Search users...',
      'chatNoConversationYet': 'No conversation yet',

      // ── Seniori ───────────────────────────────
      'seniorsTitle': 'Seniors',
      'seniorFirstName': 'First name',
      'seniorLastName': 'Last name',
      'seniorEmail': 'Email',
      'seniorPhone': 'Phone',
      'seniorAddress': 'Address',
      'seniorReviews': 'Senior reviews',
      'seniorNoReviews': 'No reviews',
      'seniorOrders': 'Senior orders',
      'searchSeniors': 'Search seniors...',
      'noSeniorsFound': 'No seniors found',

      // ── Chat ──────────────────────────────────
      'chatTitle': 'Messages',

      // ── Usluge ────────────────────────────────
      'serviceShopping': 'Shopping',
      'serviceHouseHelp': 'Home help',
      'serviceCompanionship': 'Companionship',
      'serviceWalking': 'Walking',
      'serviceEscort': 'Escort',
      'serviceOther': 'Other',

      // ── Ponavljanje ──────────────────────────
      'oneTime': 'Once',
      'recurring': 'Recurring',
      'recurringWithEnd': 'Until {date}',

      // ── Termini ──────────────────────────────────
      'sessionsTitle': 'Sessions',
      'sessionsTitleSingular': 'Session',
      'sessionsMonthlySubtitle': 'Showing sessions for {month} {year}.',
      'sessionsPlannedSubtitle': 'Awaiting student assignment.',
      'sessionsCancelledSubtitle': 'Order has been cancelled.',
      'sessionStatusPlanned': 'Planned',
      'sessionStatusScheduled': 'Scheduled',
      'sessionStatusActive': 'Active',
      'sessionStatusCompleted': 'Completed',
      'sessionStatusCancelled': 'Cancelled',
      'sessionCancel': 'Cancel session',
      'sessionCancelShort': 'Cancel',
      'sessionReschedule': 'Reschedule',
      'sessionRescheduleShort': 'Reschedule',
      'sessionSelectStudent': 'Select student',
      'sessionNewDate': 'New date',
      'sessionNewTime': 'New time',
      'sessionCancelConfirm': 'Are you sure you want to cancel this session?',
      'sessionRescheduleTitle': 'Reschedule session',
      'sessionKeepCurrentStudent': 'Keep current',
      'noStudentsForSlot': 'No students available for selected time slot',
      'availableAllDays': 'Available all days',
      'availableAllDaysShort': 'Available',
      'availableDifferentTimes': 'Partially available',
      'availableDifferentTimesShort': 'Partial',
      'reviewSessions': 'Review sessions',
      'reviewShort': 'Review',
      'timeMismatch': 'Time mismatch',
      'unavailableDay': 'Unavailable this day',
      'selectTime': 'Select time',
      'timePickerHour': 'Hour',
      'timePickerMinute': 'Min',
      'sessionReactivate': 'Restore session',
      'sessionModified': 'Modified',
      'seniorSessionConflict':
          'Senior already has another session on {date} that overlaps with {time}.',

      // ── Općenito ──────────────────────────────
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Try again',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'ok': 'OK',
      'save': 'Save',
      'saving': 'Saving...',
      'delete': 'Delete',
      'edit': 'Edit',
      'yesterday': 'Yesterday',
      'emailCopied': 'Email copied',
      'copyEmail': 'Copy email',
      'callPhone': 'Call',

      // ── Notifications ──
      'notifications': 'Notifications',
      'noNotifications': 'No new notifications',
      'archiveNotifications': 'Archive',
      'notifArchiveFailed': 'Archive failed',
      'notifArchiveEmpty': 'No read notifications to archive',
      'notifArchiving': 'Archiving...',
      'justNow': 'Just now',
      'minutesAgo': 'min ago',
      'hoursAgo': 'h ago',
      'daysAgo': 'd ago',

      // ── Auth ──────────────────────────────────
      'email': 'Email address',
      'password': 'Password',
      'loginButton': 'Sign in',
      'logout': 'Log out',
      'forgotPassword': 'Forgot password?',
      'loginError': 'Login error',
      'invalidCredentials': 'Invalid credentials',
      'forgotPasswordTitle': 'Forgot password',
      'forgotPasswordSubtitle': 'Enter your email to receive a reset code',
      'sendResetCode': 'Send code',
      'resetCode': 'Reset code',
      'newPassword': 'New password',
      'confirmNewPassword': 'Confirm new password',
      'resetPasswordButton': 'Reset password',
      'resetPasswordSuccess': 'Password changed successfully',
      'setPasswordLabel': 'Set password',
      'setPasswordHint': 'Leave empty to keep current',
      'codeSent': 'Code sent to your email',
      'backToLogin': 'Back to login',

      // ── Profil / Postavke ─────────────────────

      // ── Dani ──────────────────────────────────
      'dayMonFull': 'Monday',
      'dayTueFull': 'Tuesday',
      'dayWedFull': 'Wednesday',
      'dayThuFull': 'Thursday',
      'dayFriFull': 'Friday',
      'daySatFull': 'Saturday',
      'daySunFull': 'Sunday',

      // ── Mjeseci ───────────────────────────────
      'monthJan': 'January',
      'monthFeb': 'February',
      'monthMar': 'March',
      'monthApr': 'April',
      'monthMay': 'May',
      'monthJun': 'June',
      'monthJul': 'July',
      'monthAug': 'August',
      'monthSep': 'September',
      'monthOct': 'October',
      'monthNov': 'November',
      'monthDec': 'December',

      // ── Parametrizirani ───────────────────────

      // ── Suspension ──
      'suspend': 'Suspend',
      'activate': 'Activate',
      'suspended': 'Suspended',
      'suspensionReason': 'Suspension reason',
      'suspensionReasonHint': 'Enter suspension reason...',
      'suspensionHistory': 'Suspension history',
      'suspendConfirmTitle': 'Confirm suspension',
      'suspendConfirmMsg': 'Are you sure you want to suspend user {name}?',
      'activateConfirmTitle': 'Confirm activation',
      'activateConfirmMsg': 'Are you sure you want to activate user {name}?',
      'suspensionSuccess': 'User suspended successfully',
      'activationSuccess': 'User activated successfully',
      'suspensionFailed': 'Suspension failed',
      'activationFailed': 'Activation failed',
      'suspensionReasonRequired': 'Suspension reason is required',
      'actionSuspended': 'Suspended',
      'actionActivated': 'Activated',
      'noSuspensionHistory': 'No suspension history',

      // ── Export ────────────────────────────────
      'exportToExcel': 'Export to Excel',
      'exportSuccess': 'Data exported successfully',
      'studentCreatedAt': 'Registration date',

      // ── Server Unavailable ────────────────────────
      'serverUnavailableTitle': 'Server Unavailable',
      'serverUnavailableMessage':
          'Unable to connect to server. Please check if the backend is running.',
      'serverUnavailableRetrying': 'Retrying...',
      'serverUnavailableRetry': 'Retry',
    },
  };

  // ─── Interni getter s parametrima ───────────────────────────────
  static String _t(String key, {Map<String, String>? params}) {
    String value = _localizedValues[_currentLocale]?[key] ?? key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }
    return value;
  }

  // ─── HR plural helpers ──────────────────────────────────────────
  static String _pluralNarudzba(int n) {
    final lastTwo = n % 100;
    final lastOne = n % 10;
    if (lastOne == 1 && lastTwo != 11) return 'narudžba';
    if (lastOne >= 2 && lastOne <= 4 && (lastTwo < 12 || lastTwo > 14)) {
      return 'narudžbe';
    }
    return 'narudžbi';
  }

  static String _pluralDodjela(int n) {
    final lastTwo = n % 100;
    final lastOne = n % 10;
    if (lastOne == 1 && lastTwo != 11) return 'dodjela';
    if (lastOne >= 2 && lastOne <= 4 && (lastTwo < 12 || lastTwo > 14)) {
      return 'dodjele';
    }
    return 'dodjela';
  }

  // ═══════════════════════════════════════════════════════════════
  //  STATIC GETTERS
  // ═══════════════════════════════════════════════════════════════

  // ── App ──

  // ── Navigacija ──
  static String get navDashboard => _t('navDashboard');
  static String get navStudents => _t('navStudents');
  static String get navSeniors => _t('navSeniors');
  static String get navChat => _t('navChat');
  static String get navCoupons => _t('navCoupons');
  static String get navSettings => _t('navSettings');
  static String get navMore => _t('navMore');

  // ── Analitika ──
  static String get dashboardTitle => _t('dashboardTitle');
  static String get analyticsLast7Days => _t('analyticsLast7Days');
  static String get analyticsThisMonth => _t('analyticsThisMonth');
  static String get analyticsLastMonth => _t('analyticsLastMonth');
  static String get analyticsCustomRange => _t('analyticsCustomRange');
  static String get analyticsOrders => _t('analyticsOrders');
  static String get analyticsRevenue => _t('analyticsRevenue');
  static String get analyticsActiveSeniors => _t('analyticsActiveSeniors');
  static String get analyticsCompare => _t('analyticsCompare');
  static String get analyticsNoData => _t('analyticsNoData');
  static String get analyticsCurrent => _t('analyticsCurrent');
  static String get analyticsPrevious => _t('analyticsPrevious');
  static String get analyticsEarnings => _t('analyticsEarnings');
  static String get analyticsCompareShort => _t('analyticsCompareShort');
  static String get analyticsExportDate => _t('analyticsExportDate');
  static String get analyticsExportStripeFee => _t('analyticsExportStripeFee');
  static String get analyticsExportStudentPay =>
      _t('analyticsExportStudentPay');
  static String get analyticsExportStudentService =>
      _t('analyticsExportStudentService');
  static String get analyticsExportGrossRevenue =>
      _t('analyticsExportGrossRevenue');
  static String get analyticsExportSummarySheet =>
      _t('analyticsExportSummarySheet');
  static String get analyticsExportMetric => _t('analyticsExportMetric');
  static String get analyticsExportCurrentPeriod =>
      _t('analyticsExportCurrentPeriod');
  static String get analyticsExportPreviousPeriod =>
      _t('analyticsExportPreviousPeriod');
  static String get analyticsExportChange => _t('analyticsExportChange');
  static String get analyticsExportTotal => _t('analyticsExportTotal');

  // ── Narudžbe ──
  static String get cancelOrderConfirmTitle => _t('cancelOrderConfirmTitle');
  static String get cancelOrderConfirmMsg => _t('cancelOrderConfirmMsg');
  static String get cancelOrderBtn => _t('cancelOrderBtn');
  static String get editOrderTitle => _t('editOrderTitle');
  static String get editOrderSuccess => _t('editOrderSuccess');
  static String orderNumber(String number) =>
      _t('orderNumber', params: {'number': number});
  static String get orderDetails => _t('orderDetails');
  static String get orderDate => _t('orderDate');
  static String get orderServices => _t('orderServices');
  static String get orderNotes => _t('orderNotes');
  static String get orderFrequency => _t('orderFrequency');
  static String get orderStudent => _t('orderStudent');
  static String get assignStudent => _t('assignStudent');
  static String get reassignStudent => _t('reassignStudent');
  static String get noStudentAssigned => _t('noStudentAssigned');
  static String pendingAcceptanceBanner(int count) =>
      _t('pendingAcceptanceBanner', params: {'count': '$count'});
  static String get pendingAcceptanceTitle => _t('pendingAcceptanceTitle');
  static String get pendingAcceptanceSenior => _t('pendingAcceptanceSenior');
  static String get pendingAcceptanceStudent => _t('pendingAcceptanceStudent');
  static String get pendingAcceptanceTime => _t('pendingAcceptanceTime');
  static String get pendingAcceptanceEmpty => _t('pendingAcceptanceEmpty');
  static String pendingAcceptanceMinutes(int min) =>
      _t('pendingAcceptanceMinutes', params: {'min': '$min'});
  static String pendingAcceptanceHours(int h, int min) =>
      _t('pendingAcceptanceHours', params: {'h': '$h', 'min': '$min'});
  static String pendingAcceptanceDays(int d, int h) =>
      _t('pendingAcceptanceDays', params: {'d': '$d', 'h': '$h'});
  static String get studentAwaitingAcceptance =>
      _t('studentAwaitingAcceptance');
  static String get awaitingAcceptanceMulti => _t('awaitingAcceptanceMulti');
  static String get pendingStudentLabel => _t('pendingStudentLabel');
  static String get suggestedStudents => _t('suggestedStudents');
  static String assignConfirm(String student) =>
      _t('assignConfirm', params: {'student': student});
  static String get noOrdersFound => _t('noOrdersFound');

  // ── Kreiranje narudžbe ──
  static String get createOrder => _t('createOrder');
  static String get addOrder => _t('addOrder');
  static String get createOrderSuccess => _t('createOrderSuccess');
  static String get selectSenior => _t('selectSenior');
  static String get selectSeniorHint => _t('selectSeniorHint');
  static String get scheduledDate => _t('scheduledDate');
  static String get scheduledTime => _t('scheduledTime');
  static String get durationHoursLabel => _t('durationHoursLabel');
  static String get selectServices => _t('selectServices');
  static String get orderNotesHint => _t('orderNotesHint');
  static String get selectAtLeastOneService => _t('selectAtLeastOneService');
  static String get seniorRequired => _t('seniorRequired');
  static String get dateRequired => _t('dateRequired');
  static String get addDay => _t('addDay');
  static String get selectDay => _t('selectDay');
  static String get hasEndDate => _t('hasEndDate');

  // ── Statusi ──
  static String get statusProcessing => _t('statusProcessing');
  static String get statusActive => _t('statusActive');
  static String get statusCompleted => _t('statusCompleted');
  static String get statusCancelled => _t('statusCancelled');

  // ── Job statusi ──

  // ── Studenti ──
  static String get studentsTitle => _t('studentsTitle');
  static String get studentFirstName => _t('studentFirstName');
  static String get studentLastName => _t('studentLastName');
  static String get studentEmail => _t('studentEmail');
  static String get studentPhone => _t('studentPhone');
  static String get studentAddress => _t('studentAddress');
  static String get studentFaculty => _t('studentFaculty');
  static String get studentRating => _t('studentRating');
  static String get studentCompletedJobs => _t('studentCompletedJobs');
  static String get studentReviewCount => _t('studentReviewCount');
  static String get studentCancelledJobs => _t('studentCancelledJobs');
  static String get studentAvailability => _t('studentAvailability');
  static String get noAvailability => _t('noAvailability');
  static String get workSummary => _t('workSummary');
  static String get workTotalHours => _t('workTotalHours');
  static String get workRegularHours => _t('workRegularHours');
  static String get workSundayHours => _t('workSundayHours');
  static String get workHourlyRate => _t('workHourlyRate');
  static String get workSundayRate => _t('workSundayRate');
  static String get workEstimatedPayout => _t('workEstimatedPayout');
  static String get workNoOrders => _t('workNoOrders');
  static String get workContractPeriod => _t('workContractPeriod');
  static String get workCustomPeriod => _t('workCustomPeriod');
  static String get workFrom => _t('workFrom');
  static String get workTo => _t('workTo');
  static String get studentContractStart => _t('studentContractStart');
  static String get contractStatus => _t('contractStatus');
  static String get contractActive => _t('contractActive');
  static String get contractExpired => _t('contractExpired');
  static String get contractNone => _t('contractNone');
  static String get searchStudents => _t('searchStudents');
  static String get noStudentsFound => _t('noStudentsFound');
  static String get studentReviews => _t('studentReviews');
  static String get allStudents => _t('allStudents');
  static String get sortBy => _t('sortBy');
  static String get sortAZ => _t('sortAZ');
  static String get sortZA => _t('sortZA');
  static String get sortNewest => _t('sortNewest');
  static String get sortOldest => _t('sortOldest');
  static String get sortRatingHigh => _t('sortRatingHigh');
  static String get sortRatingLow => _t('sortRatingLow');

  // ── Detalji studenta ──
  static String get studentPersonalData => _t('studentPersonalData');
  static String get studentDateOfBirth => _t('studentDateOfBirth');
  static String get studentGender => _t('studentGender');
  static String get genderMale => _t('genderMale');
  static String get genderFemale => _t('genderFemale');
  static String get studentTotalRatings => _t('studentTotalRatings');
  static String get studentContractTitle => _t('studentContractTitle');
  static String get studentContractStatus => _t('studentContractStatus');
  static String get studentContractExpiry => _t('studentContractExpiry');
  static String get studentUploadContract => _t('studentUploadContract');
  static String get contractUploadSuccess => _t('contractUploadSuccess');
  static String get contractSelectPeriod => _t('contractSelectPeriod');
  static String get contractNumber => _t('contractNumber');
  static String get contractDelete => _t('contractDelete');
  static String get contractDeleteTitle => _t('contractDeleteTitle');
  static String get contractDeleteConfirm => _t('contractDeleteConfirm');
  static String get contractDeleteSuccess => _t('contractDeleteSuccess');
  static String get contractLoading => _t('contractLoading');
  static String get contractDeleting => _t('contractDeleting');
  static String get studentAssignedOrders => _t('studentAssignedOrders');
  static String get studentArchive => _t('studentArchive');
  static String get studentUnarchive => _t('studentUnarchive');
  static String get archiveConfirmTitle => _t('archiveConfirmTitle');
  static String get archiveConfirmMsg => _t('archiveConfirmMsg');
  static String get unarchiveConfirmTitle => _t('unarchiveConfirmTitle');
  static String get unarchiveConfirmMsg => _t('unarchiveConfirmMsg');
  static String get archiveBlockedTitle => _t('archiveBlockedTitle');
  static String archiveWarningOrders(int count) {
    final orders = _currentLocale == 'hr'
        ? _pluralNarudzba(count)
        : (count == 1 ? 'order' : 'orders');
    return _t(
      'archiveWarningOrders',
      params: {'count': '$count', 'orders': orders},
    );
  }

  static String archiveWarningAssignments(int count) {
    final assignments = _currentLocale == 'hr'
        ? _pluralDodjela(count)
        : (count == 1 ? 'assignment' : 'assignments');
    return _t(
      'archiveWarningAssignments',
      params: {'count': '$count', 'assignments': assignments},
    );
  }

  static String get archiveSuccess => _t('archiveSuccess');
  static String get unarchiveSuccess => _t('unarchiveSuccess');
  static String get suspendWarningTitle => _t('suspendWarningTitle');
  static String get suspendWarningMsg => _t('suspendWarningMsg');
  static String get suspendWarningStudentMsg => _t('suspendWarningStudentMsg');
  static String get filterAll => _t('filterAll');
  static String get filterProcessing => _t('filterProcessing');
  static String get filterArchived => _t('filterArchived');
  static String get seniorFilterActive => _t('seniorFilterActive');
  static String get seniorFilterInactive => _t('seniorFilterInactive');
  static String get statusArchived => _t('statusArchived');
  static String get adminActions => _t('adminActions');
  static String get adminNotes => _t('adminNotes');
  static String get adminNotesEmpty => _t('adminNotesEmpty');
  static String get adminNoteAdd => _t('adminNoteAdd');
  static String get adminNoteEdit => _t('adminNoteEdit');
  static String get adminNoteSave => _t('adminNoteSave');
  static String get adminNoteCancel => _t('adminNoteCancel');
  static String get adminNoNotes => _t('adminNoNotes');
  static String get adminNoteDelete => _t('adminNoteDelete');
  static String get adminNoteDeleteConfirm => _t('adminNoteDeleteConfirm');
  static String get adminNotePlaceholder => _t('adminNotePlaceholder');
  static String get adminNoteEdited => _t('adminNoteEdited');
  static String get assignShort => _t('assignShort');
  static String get assignSuccess => _t('assignSuccess');
  static String get allSchedulesCovered => _t('allSchedulesCovered');
  static String get hours => _t('hours');

  // ── Session Preview ──
  static String get sessionPreviewTitle => _t('sessionPreviewTitle');
  static String get sessionPreviewWeeks => _t('sessionPreviewWeeks');
  static String get sessionFree => _t('sessionFree');
  static String get sessionConflict => _t('sessionConflict');
  static String get sessionSkipped => _t('sessionSkipped');
  static String get sessionRescheduled => _t('sessionRescheduled');
  static String get sessionRescheduledShort => _t('sessionRescheduledShort');
  static String get sessionSubstitute => _t('sessionSubstitute');
  static String get skipSession => _t('skipSession');
  static String get changeTime => _t('changeTime');
  static String get findSubstitute => _t('findSubstitute');
  static String get undoSkip => _t('undoSkip');
  static String get confirmAssign => _t('confirmAssign');
  static String get unresolvedConflicts => _t('unresolvedConflicts');
  static String get conflictWith => _t('conflictWith');
  static String get selectNewTime => _t('selectNewTime');
  static String get selectSubstitute => _t('selectSubstitute');
  static String sessionCountChip(int count) =>
      _t('sessionCountChip', params: {'count': count.toString()});
  static String get noSubstitutesAvailable => _t('noSubstitutesAvailable');
  static String get noAlternativeSlots => _t('noAlternativeSlots');

  // ── Raspored sekcija ──
  static String get editLayout => _t('editLayout');
  static String get sectionLayoutTitle => _t('sectionLayoutTitle');
  static String get sectionLayoutHint => _t('sectionLayoutHint');
  static String get resetDefault => _t('resetDefault');

  // ── Napredni filteri ──
  static String get advancedFilters => _t('advancedFilters');
  static String get filterByActivity => _t('filterByActivity');
  static String get filterDidNotWork => _t('filterDidNotWork');
  static String get filterWorked => _t('filterWorked');
  static String get filterPeriodThisMonth => _t('filterPeriodThisMonth');
  static String get filterPeriodLastMonth => _t('filterPeriodLastMonth');
  static String get filterPeriodCustom => _t('filterPeriodCustom');
  static String get filterPeriodFrom => _t('filterPeriodFrom');
  static String get filterPeriodTo => _t('filterPeriodTo');
  static String get filterAvailHint => _t('filterAvailHint');
  static String get filterMinJobs => _t('filterMinJobs');
  static String get filterByAvailability => _t('filterByAvailability');
  static String get filterByDay => _t('filterByDay');
  static String get filterByTimeFrom => _t('filterByTimeFrom');
  static String get filterByTimeTo => _t('filterByTimeTo');
  static String get excludeBusy => _t('excludeBusy');
  static String get filterByRating => _t('filterByRating');
  static String get filterByGender => _t('filterByGender');
  static String get filterByFaculty => _t('filterByFaculty');
  static String get anyFaculty => _t('anyFaculty');
  static String get filterByCity => _t('filterByCity');
  static String get anyCity => _t('anyCity');
  static String get filterBySenior => _t('filterBySenior');
  static String get knownStudents => _t('knownStudents');
  static String get filterApply => _t('filterApply');
  static String get filterReset => _t('filterReset');
  static String filterActiveCount(int count) =>
      _t('filterActiveCount', params: {'count': '$count'});
  static String get dayMon => _t('dayMon');
  static String get dayTue => _t('dayTue');
  static String get dayWed => _t('dayWed');
  static String get dayThu => _t('dayThu');
  static String get dayFri => _t('dayFri');
  static String get daySat => _t('daySat');
  static String get daySun => _t('daySun');
  static String get anyGender => _t('anyGender');
  static String get anyContract => _t('anyContract');
  static String get anySenior => _t('anySenior');
  static String filterResultCount(int count) {
    if (_currentLocale == 'hr') {
      if (count == 1) return '1 student';
      if (count >= 2 && count <= 4) return '$count studenta';
      return '$count studenata';
    }
    return _t('filterResultCount', params: {'count': '$count'});
  }

  static String seniorResultCount(int count) {
    if (_currentLocale == 'hr') {
      if (count == 1) return '1 senior';
      return '$count seniora';
    }
    return _t('seniorResultCount', params: {'count': '$count'});
  }

  // ── Detalji seniora ──
  static String get seniorFirstName => _t('seniorFirstName');
  static String get seniorLastName => _t('seniorLastName');
  static String get seniorOrdererTitle => _t('seniorOrdererTitle');
  static String get seniorServiceUser => _t('seniorServiceUser');
  static String get seniorOrdererFirstName => _t('seniorOrdererFirstName');
  static String get seniorOrdererLastName => _t('seniorOrdererLastName');
  static String get seniorOrdererEmail => _t('seniorOrdererEmail');
  static String get seniorOrdererName => _t('seniorOrdererName');
  static String get seniorOrdererPhone => _t('seniorOrdererPhone');
  static String get seniorOrdererAddress => _t('seniorOrdererAddress');
  static String get seniorOrdererGender => _t('seniorOrdererGender');
  static String get seniorOrdererDob => _t('seniorOrdererDob');
  static String get addSeniorTitle => _t('addSeniorTitle');
  static String get addSeniorSuccess => _t('addSeniorSuccess');
  static String get editSeniorTitle => _t('editSeniorTitle');
  static String get editSeniorSuccess => _t('editSeniorSuccess');
  static String get editStudentTitle => _t('editStudentTitle');
  static String get editStudentSuccess => _t('editStudentSuccess');
  static String get addSeniorHasOrderer => _t('addSeniorHasOrderer');
  static String get fieldRequired => _t('fieldRequired');
  static String get selectDate => _t('selectDate');
  static String get selectGender => _t('selectGender');
  static String get seniorCreditCards => _t('seniorCreditCards');
  static String get seniorNoCards => _t('seniorNoCards');
  static String get cardExpiry => _t('cardExpiry');
  static String get cardExpired => _t('cardExpired');

  // ── Chat detalji ──
  static String get chatSelectConversation => _t('chatSelectConversation');
  static String get chatNoMessages => _t('chatNoMessages');
  static String get chatInputHint => _t('chatInputHint');
  static String get chatSearchHint => _t('chatSearchHint');
  static String get chatNoConversationYet => _t('chatNoConversationYet');

  // ── Seniori ──
  static String get seniorsTitle => _t('seniorsTitle');
  static String get seniorEmail => _t('seniorEmail');
  static String get seniorPhone => _t('seniorPhone');
  static String get seniorAddress => _t('seniorAddress');
  static String get seniorReviews => _t('seniorReviews');
  static String get seniorNoReviews => _t('seniorNoReviews');
  static String get seniorOrders => _t('seniorOrders');
  static String get searchSeniors => _t('searchSeniors');
  static String get noSeniorsFound => _t('noSeniorsFound');

  // ── Chat ──
  static String get chatTitle => _t('chatTitle');

  // ── Usluge ──
  static String get serviceShopping => _t('serviceShopping');
  static String get serviceHouseHelp => _t('serviceHouseHelp');
  static String get serviceCompanionship => _t('serviceCompanionship');
  static String get serviceWalking => _t('serviceWalking');
  static String get serviceEscort => _t('serviceEscort');
  static String get serviceOther => _t('serviceOther');

  // ── Ponavljanje ──
  static String get oneTime => _t('oneTime');
  static String get recurring => _t('recurring');
  static String recurringWithEnd(String date) =>
      _t('recurringWithEnd', params: {'date': date});

  // ── Općenito ──
  static String get loading => _t('loading');
  static String get error => _t('error');
  static String get retry => _t('retry');
  static String get cancel => _t('cancel');
  static String get confirm => _t('confirm');
  static String get ok => _t('ok');
  static String get save => _t('save');
  static String get saving => _t('saving');
  static String get delete => _t('delete');
  static String get edit => _t('edit');
  static String get yesterday => _t('yesterday');

  // ── Auth ──
  static String get email => _t('email');
  static String get password => _t('password');
  static String get loginButton => _t('loginButton');
  static String get logout => _t('logout');
  static String get forgotPassword => _t('forgotPassword');
  static String get loginError => _t('loginError');
  static String get invalidCredentials => _t('invalidCredentials');
  static String get forgotPasswordTitle => _t('forgotPasswordTitle');
  static String get forgotPasswordSubtitle => _t('forgotPasswordSubtitle');
  static String get sendResetCode => _t('sendResetCode');
  static String get resetCode => _t('resetCode');
  static String get newPassword => _t('newPassword');
  static String get confirmNewPassword => _t('confirmNewPassword');
  static String get resetPasswordButton => _t('resetPasswordButton');
  static String get resetPasswordSuccess => _t('resetPasswordSuccess');
  static String get setPasswordLabel => _t('setPasswordLabel');
  static String get setPasswordHint => _t('setPasswordHint');
  static String get codeSent => _t('codeSent');
  static String get backToLogin => _t('backToLogin');

  // ── Profil / Postavke ──

  // ── Dani ──

  static String get dayMonFull => _t('dayMonFull');
  static String get dayTueFull => _t('dayTueFull');
  static String get dayWedFull => _t('dayWedFull');
  static String get dayThuFull => _t('dayThuFull');
  static String get dayFriFull => _t('dayFriFull');
  static String get daySatFull => _t('daySatFull');
  static String get daySunFull => _t('daySunFull');

  // ── Parametrizirani ──

  // ── Termini ──
  static String get sessionsTitle => _t('sessionsTitle');
  static String get sessionsTitleSingular => _t('sessionsTitleSingular');
  static String sessionsMonthlySubtitle(String month, int year) =>
      _t('sessionsMonthlySubtitle', params: {'month': month, 'year': '$year'});
  static String monthName(int month) {
    const keys = [
      '',
      'monthJan',
      'monthFeb',
      'monthMar',
      'monthApr',
      'monthMay',
      'monthJun',
      'monthJul',
      'monthAug',
      'monthSep',
      'monthOct',
      'monthNov',
      'monthDec',
    ];
    return _t(keys[month.clamp(1, 12)]);
  }

  static String get sessionsPlannedSubtitle => _t('sessionsPlannedSubtitle');
  static String get sessionsCancelledSubtitle =>
      _t('sessionsCancelledSubtitle');
  static String get sessionStatusPlanned => _t('sessionStatusPlanned');
  static String get sessionStatusScheduled => _t('sessionStatusScheduled');
  static String get sessionStatusActive => _t('sessionStatusActive');
  static String get sessionStatusCompleted => _t('sessionStatusCompleted');
  static String get sessionStatusCancelled => _t('sessionStatusCancelled');
  static String get sessionCancel => _t('sessionCancel');
  static String get sessionCancelShort => _t('sessionCancelShort');
  static String get sessionReschedule => _t('sessionReschedule');
  static String get sessionRescheduleShort => _t('sessionRescheduleShort');
  static String get sessionSelectStudent => _t('sessionSelectStudent');
  static String get sessionNewDate => _t('sessionNewDate');
  static String get sessionNewTime => _t('sessionNewTime');
  static String get sessionCancelConfirm => _t('sessionCancelConfirm');
  static String get sessionRescheduleTitle => _t('sessionRescheduleTitle');
  static String get sessionKeepCurrentStudent =>
      _t('sessionKeepCurrentStudent');
  static String get noStudentsForSlot => _t('noStudentsForSlot');
  static String get selectTime => _t('selectTime');
  static String get timePickerHour => _t('timePickerHour');
  static String get timePickerMinute => _t('timePickerMinute');
  static String get sessionReactivate => _t('sessionReactivate');
  static String get sessionModified => _t('sessionModified');
  static String seniorSessionConflict(String date, String time) =>
      _t('seniorSessionConflict', params: {'date': date, 'time': time});
  static String get emailCopied => _t('emailCopied');
  static String get copyEmail => _t('copyEmail');
  static String get callPhone => _t('callPhone');
  static String get notifications => _t('notifications');
  static String get noNotifications => _t('noNotifications');
  static String get archiveNotifications => _t('archiveNotifications');
  static String get notifArchiveFailed => _t('notifArchiveFailed');
  static String get notifArchiveEmpty => _t('notifArchiveEmpty');
  static String get notifArchiving => _t('notifArchiving');
  static String get justNow => _t('justNow');
  static String get minutesAgo => _t('minutesAgo');
  static String get hoursAgo => _t('hoursAgo');
  static String get daysAgo => _t('daysAgo');
  static String get availableAllDays => _t('availableAllDays');
  static String get availableAllDaysShort => _t('availableAllDaysShort');
  static String get availableDifferentTimes => _t('availableDifferentTimes');
  static String get availableDifferentTimesShort =>
      _t('availableDifferentTimesShort');
  static String get reviewSessions => _t('reviewSessions');
  static String get reviewShort => _t('reviewShort');
  static String get timeMismatch => _t('timeMismatch');
  static String get unavailableDay => _t('unavailableDay');

  // ── Suspenzija ──
  static String get suspend => _t('suspend');
  static String get activate => _t('activate');
  static String get suspended => _t('suspended');
  static String get suspensionReason => _t('suspensionReason');
  static String get suspensionReasonHint => _t('suspensionReasonHint');
  static String get suspensionHistory => _t('suspensionHistory');
  static String get suspendConfirmTitle => _t('suspendConfirmTitle');
  static String suspendConfirmMsg(String name) =>
      _t('suspendConfirmMsg', params: {'name': name});
  static String get activateConfirmTitle => _t('activateConfirmTitle');
  static String activateConfirmMsg(String name) =>
      _t('activateConfirmMsg', params: {'name': name});
  static String get suspensionSuccess => _t('suspensionSuccess');
  static String get activationSuccess => _t('activationSuccess');
  static String get suspensionFailed => _t('suspensionFailed');
  static String get activationFailed => _t('activationFailed');
  static String get suspensionReasonRequired => _t('suspensionReasonRequired');
  static String get actionSuspended => _t('actionSuspended');
  static String get actionActivated => _t('actionActivated');
  static String get noSuspensionHistory => _t('noSuspensionHistory');

  // ── Export ──
  static String get exportToExcel => _t('exportToExcel');
  static String get exportSuccess => _t('exportSuccess');
  static String get studentCreatedAt => _t('studentCreatedAt');

  // ── Server nedostupan ──
  static String get serverUnavailableTitle => _t('serverUnavailableTitle');
  static String get serverUnavailableMessage => _t('serverUnavailableMessage');
  static String get serverUnavailableRetrying =>
      _t('serverUnavailableRetrying');
  static String get serverUnavailableRetry => _t('serverUnavailableRetry');

  // ── Postavke ──
  static String get settingsTitle => _t('settingsTitle');
  static String get settingsPricing => _t('settingsPricing');
  static String get settingsRestrictions => _t('settingsRestrictions');
  static String get settingsCancelRules => _t('settingsCancelRules');
  static String get settingsAvailabilityRules =>
      _t('settingsAvailabilityRules');
  static String get studentCancelEnabled => _t('studentCancelEnabled');
  static String get availabilityChangeEnabled =>
      _t('availabilityChangeEnabled');
  static String get availabilityChangeCutoff => _t('availabilityChangeCutoff');
  static String get settingsOperational => _t('settingsOperational');
  static String get settingsStudentRates => _t('settingsStudentRates');
  static String get settingsEarnings => _t('settingsEarnings');
  static String get settingsLanguage => _t('settingsLanguage');
  static String get langHr => _t('langHr');
  static String get langEn => _t('langEn');
  static String get settingsTheme => _t('settingsTheme');
  static String get settingsPreferences => _t('settingsPreferences');
  static String get settingsConfiguration => _t('settingsConfiguration');
  static String get themeLight => _t('themeLight');
  static String get themeDark => _t('themeDark');
  static String get themeSystem => _t('themeSystem');
  static String get weekdayRate => _t('weekdayRate');
  static String get sundayRate => _t('sundayRate');
  static String get studentCancelCutoff => _t('studentCancelCutoff');
  static String get seniorCancelCutoff => _t('seniorCancelCutoff');
  static String get travelBuffer => _t('travelBuffer');
  static String get paymentTiming => _t('paymentTiming');
  static String get vatPercentage => _t('vatPercentage');
  static String get intermediaryPercentage => _t('intermediaryPercentage');
  static String get studentHourlyRate => _t('studentHourlyRate');
  static String get studentSundayRate => _t('studentSundayRate');
  static String get settingsSaved => _t('settingsSaved');
  static String get settingsSaveFailed => _t('settingsSaveFailed');
  static String get settingsLoadFailed => _t('settingsLoadFailed');

  // ── Sponzorstvo ──
  static String get settingsSponsor => _t('settingsSponsor');
  static String get sponsorLogoUrl => _t('sponsorLogoUrl');
  static String get sponsorDarkLogoUrl => _t('sponsorDarkLogoUrl');
  static String get sponsorLabel => _t('sponsorLabel');
  static String get sponsorActive => _t('sponsorActive');
  static String get sponsorName => _t('sponsorName');
  static String get sponsorSaved => _t('sponsorSaved');
  static String get sponsorSaveFailed => _t('sponsorSaveFailed');
  static String get sponsorLoadFailed => _t('sponsorLoadFailed');
  static String get sponsorDarkLogoHint => _t('sponsorDarkLogoHint');
  static String get sponsorChooseLogo => _t('sponsorChooseLogo');
  static String get sponsorChooseDarkLogo => _t('sponsorChooseDarkLogo');
  static String get sponsorUploading => _t('sponsorUploading');
  static String get sponsorUploadFailed => _t('sponsorUploadFailed');
  static String get sponsorNoLogo => _t('sponsorNoLogo');
  static String get sponsorDeleteLogoTitle => _t('sponsorDeleteLogoTitle');
  static String get sponsorDeleteLogoMsg => _t('sponsorDeleteLogoMsg');
  static String get sponsorDeleteLogoConfirm => _t('sponsorDeleteLogoConfirm');
  static String get sponsorDeleteFailed => _t('sponsorDeleteFailed');

  // ── Kuponi ──
  static String get couponsTitle => _t('couponsTitle');
  static String get couponNew => _t('couponNew');
  static String get couponCode => _t('couponCode');
  static String get couponName => _t('couponName');
  static String get couponDescription => _t('couponDescription');
  static String get couponType => _t('couponType');
  static String get couponValue => _t('couponValue');
  static String get couponCombinable => _t('couponCombinable');
  static String get couponCity => _t('couponCity');
  static String get couponCityAll => _t('couponCityAll');
  static String get couponValidFrom => _t('couponValidFrom');
  static String get couponValidUntil => _t('couponValidUntil');
  static String get couponActive => _t('couponActive');
  static String get couponInactive => _t('couponInactive');
  static String get couponExpired => _t('couponExpired');
  static String get couponAssignments => _t('couponAssignments');
  static String get couponAssignSenior => _t('couponAssignSenior');
  static String get couponNoAssignments => _t('couponNoAssignments');
  static String get couponSaved => _t('couponSaved');
  static String get couponSaveFailed => _t('couponSaveFailed');
  static String get couponDeleted => _t('couponDeleted');
  static String get couponDeleteFailed => _t('couponDeleteFailed');
  static String get couponDeleteConfirm => _t('couponDeleteConfirm');
  static String get couponNoCoupons => _t('couponNoCoupons');
  static String get couponTypeMonthlyHours => _t('couponTypeMonthlyHours');
  static String get couponTypeWeeklyHours => _t('couponTypeWeeklyHours');
  static String get couponTypeOneTimeHours => _t('couponTypeOneTimeHours');
  static String get couponRemainingHours => _t('couponRemainingHours');
  static String get couponAssignedBy => _t('couponAssignedBy');
  static String get couponSelfRedeemed => _t('couponSelfRedeemed');
  static String get couponRedeemTitle => _t('couponRedeemTitle');
  static String get couponRedeemHint => _t('couponRedeemHint');
  static String get couponRedeemed => _t('couponRedeemed');
  static String get couponRedeemFailed => _t('couponRedeemFailed');
  static String get couponDeactivated => _t('couponDeactivated');
  static String get couponDeactivateFailed => _t('couponDeactivateFailed');
  static String get couponNotFound => _t('couponNotFound');
  static String get couponAlreadyActive => _t('couponAlreadyActive');
  static String get couponNotYetValid => _t('couponNotYetValid');
  static String get couponExclusiveConflict => _t('couponExclusiveConflict');
  static String get couponActiveCoupons => _t('couponActiveCoupons');
  static String get couponNone => _t('couponNone');
  static String get couponCodeCopied => _t('couponCodeCopied');
  static String get couponCopyCode => _t('couponCopyCode');
}
