import 'package:helpi_admin/core/models/admin_models.dart';

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
      'appName': 'Helpi Admin',
      'appTagline': 'Upravljanje platformom',

      // ── Navigacija ────────────────────────────
      'navDashboard': 'Analitika',
      'navStudents': 'Studenti',
      'navSeniors': 'Seniori',
      'navChat': 'Poruke',
      'navSettings': 'Jezik',

      // ── Analitika ─────────────────────────────
      'dashboardTitle': 'Analitika',
      'totalOrders': 'Ukupno narudžbi',
      'processingOrders': 'Seniori u obradi',
      'activeOrders': 'Aktivne',
      'completedOrders': 'Završene',
      'totalStudents': 'Studenata',
      'activeStudents': 'Aktivni studenti',
      'totalSeniors': 'Seniora',
      'recentOrders': 'Nedavne narudžbe',
      'todaysSessions': 'Današnji termini',
      'expiringContracts': 'Istekli ugovori',
      'activeStudentsThisMonth': 'Aktivni studenti ovaj mjesec',
      'sessionsCount': 'termina',
      'hoursCount': 'sati',
      'viewAll': 'Prikaži sve',
      'noData': 'Nema podataka',
      'noProcessingOrders': 'Nema seniora u obradi',
      'noActiveStudentsMonth': 'Nema aktivnih studenata',
      'noExpiringContracts': 'Nema isteklih ugovora',
      'analyticsLast7Days': 'Zadnjih 7 dana',
      'analyticsThisMonth': 'Ovaj mjesec',
      'analyticsLastMonth': 'Prošli mjesec',
      'analyticsCustomRange': 'Prilagođeno',
      'analyticsOrders': 'Narudžbe',
      'analyticsRevenue': 'Prihod',
      'analyticsActiveSeniors': 'Aktivni seniori',
      'analyticsCompare': 'Usporedi s prethodnim periodom',
      'analyticsPrevPeriod': 'vs prethodni period',
      'analyticsNoChange': 'Bez promjene',
      'analyticsTotal': 'Ukupno: {value}',
      'analyticsNoData': 'Nema podataka za odabrani period',
      'analyticsCurrent': 'Trenutno',
      'analyticsPrevious': 'Prethodno',
      'analyticsEarnings': 'Zarada',
      'analyticsCompareShort': 'Usporedi prethodno',
      'analyticsEarningsShort': 'Zarada',
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
      'ordersProcessing': 'U obradi',
      'cancelOrderConfirmTitle': 'Otkaži narudžbu',
      'cancelOrderConfirmMsg':
          'Jeste li sigurni da želite otkazati ovu narudžbu? Svi nadolazeći termini će biti otkazani.',
      'cancelOrderBtn': 'Otkaži narudžbu',
      'archiveOrderBlockedTitle': 'Nije moguće arhivirati',
      'archiveOrderBlockedMsg':
          'Narudžba mora biti otkazana ili završena prije arhiviranja.',
      'editOrderTitle': 'Uredi narudžbu',
      'editOrderSuccess': 'Narudžba uspješno ažurirana',
      'orderNumber': 'Narudžba #{number}',
      'orderDetails': 'Detalji narudžbe',
      'orderStatus': 'Status',
      'orderDate': 'Datum',
      'orderTime': 'Vrijeme',
      'orderDuration': 'Trajanje',
      'orderServices': 'Usluge',
      'orderNotes': 'Napomena',
      'orderFrequency': 'Učestalost',
      'orderSchedule': 'Raspored',
      'orderSenior': 'Senior',
      'orderStudent': 'Student',
      'assignStudent': 'Dodijeli studenta',
      'reassignStudent': 'Promijeni studenta',
      'noStudentAssigned': 'Nije dodijeljen student',
      'sessionsNoStudent': 'Dodijeli studenta za upravljanje terminima.',
      'suggestedStudents': 'Predloženi studenti',
      'assignConfirm': 'Dodijeliti {student} na ovu narudžbu?',
      'assigned': 'Dodijeljeno',
      'noOrdersFound': 'Nema pronađenih narudžbi',
      'filterByStatus': 'Filtriraj po statusu',
      'filterByDate': 'Filtriraj po datumu',
      'filterByService': 'Filtriraj po usluzi',
      'searchOrders': 'Pretraži narudžbe...',

      // ── Promo kod ─────────────────────────────
      'promoCode': 'Promo kod',
      'promoCodeHint': 'Unesite promo kod...',
      'promoCodeApply': 'Primijeni promo kod',

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
      'endDateLabel': 'Krajnji datum',
      'hasEndDate': 'Do određenog datuma',

      // ── Statusi narudžbi ──────────────────────
      'statusProcessing': 'U obradi',
      'statusActive': 'Aktivna',
      'statusCompleted': 'Završena',
      'statusCancelled': 'Otkazana',

      // ── Statusi termina (job) ─────────────────
      'jobScheduled': 'Zakazan',
      'jobCompleted': 'Završen',
      'jobCancelled': 'Otkazan',

      // ── Studenti ──────────────────────────────
      'studentsTitle': 'Studenti',
      'studentDetails': 'Detalji studenta',
      'studentFirstName': 'Ime',
      'studentLastName': 'Prezime',
      'studentName': 'Ime i prezime',
      'studentEmail': 'Email',
      'studentPhone': 'Telefon',
      'studentAddress': 'Adresa',
      'studentFaculty': 'Fakultet',
      'studentRating': 'Prosječna ocjena',
      'studentTotalJobs': 'Ukupno poslova',
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
      'workPickDates': 'Odaberi datume',
      'workFrom': 'Od',
      'workTo': 'Do',
      'studentContractStart': 'Početak ugovora',
      'studentContract': 'Ugovor',
      'contractStatus': 'Status ugovora',
      'contractActive': 'Aktivan',
      'contractExpired': 'Istekao',
      'contractExpiring': 'Ističe uskoro',
      'contractNone': 'Nema ugovora',
      'uploadContract': 'Učitaj ugovor',
      'contractValidUntil': 'Vrijedi do: {date}',
      'contractExpires': 'Ističe: {date}',
      'renewContract': 'Obnovi ugovor',
      'verifiedStudent': 'Verificiran',
      'unverifiedStudent': 'Neverificiran',
      'verifyStudent': 'Verificiraj',
      'searchStudents': 'Pretraži studente...',
      'noStudentsFound': 'Nema pronađenih studenata',
      'studentOrders': 'Narudžbe studenta',
      'studentReviews': 'Ocjene studenta',
      'allStudents': 'Svi',
      'activeStudentsFilter': 'Aktivni',
      'inactiveStudents': 'Neaktivni',
      'contractExpiringFilter': 'Ističe ugovor',
      'sortBy': 'Sortiraj',
      'sortAZ': 'A → Ž',
      'sortZA': 'Ž → A',
      'sortNewest': 'Najnoviji',
      'sortOldest': 'Najstariji',
      'sortNewestF': 'Najnovije',
      'sortOldestF': 'Najstarije',
      'sortRatingHigh': 'Ocjena ↓',
      'sortRatingLow': 'Ocjena ↑',

      // ── Napredni filteri studenata ────────────
      'advancedFilters': 'Napredni filteri',
      'filterByActivity': 'Aktivnost u periodu',
      'filterWorkedThisMonth': 'Radio/la ovaj mjesec',
      'filterDidNotWork': 'Nije radio/la',
      'filterWorked': 'Radio/la',
      'filterPeriodThisMonth': 'Ovaj mjesec',
      'filterPeriodLastMonth': 'Prošli mjesec',
      'filterPeriodLast60Days': 'Zadnjih 60 dana',
      'filterPeriodCustom': 'Prilagođeno',
      'filterPeriodFrom': 'Od datuma',
      'filterPeriodTo': 'Do datuma',
      'filterAvailHint': 'Dan + sat se kombiniraju (AND)',
      'filterMinJobs': 'Min. završenih poslova',
      'filterMaxJobs': 'Max. završenih poslova',
      'filterByContract': 'Status ugovora',
      'filterByAvailability': 'Dostupnost',
      'filterByDay': 'Dan u tjednu',
      'filterByTimeFrom': 'Dostupan od',
      'filterByTimeTo': 'Dostupan do',
      'excludeBusy': 'Isključi zauzete',
      'workedWithSenior': 'Radio kod ovog seniora ({count}x)',
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
      'anyContract': 'Bilo koji',
      'anySenior': 'Bilo koji',
      'filterResultCount': '{count} studenata',
      'seniorResultCount': '{count} seniora',
      'orderResultCount': '{count} narudžbi',
      'thisMonthShort': 'ovaj mj.',

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
      'studentRenewContract': 'Obnovi ugovor',
      'contractUploadSuccess': 'Ugovor uspješno učitan.',
      'contractRenewSuccess': 'Ugovor uspješno obnovljen.',
      'contractSelectPeriod': 'Odaberi period ugovora',
      'contractFileSelected': 'Odabran: {name}',
      'contractNoFileSelected': 'Nije odabran dokument.',
      'contractNumber': 'Broj ugovora',
      'contractDelete': 'Obriši ugovor',
      'contractDeleteTitle': 'Brisanje ugovora',
      'contractDeleteConfirm':
          'Jeste li sigurni da želite obrisati ugovor? Datoteka će biti obrisana s Google Drivea.',
      'contractDeleteSuccess': 'Ugovor uspješno obrisan.',
      'contractLoading': 'Učitavanje ugovora...',
      'contractDeleting': 'Brisanje ugovora...',
      'studentNotAvailable': 'Nedostupan',
      'studentNotAvailableMale': 'Nedostupan',
      'studentNotAvailableFemale': 'Nedostupna',
      'studentAssignedOrders': 'Dodijeljene narudžbe',
      'studentRemoveVerification': 'Ukloni verifikaciju',
      'studentVerify': 'Verificiraj',
      'studentArchive': 'Arhiviraj',
      'studentUnarchive': 'Vrati iz arhive',
      'archiveConfirmTitle': 'Arhiviraj',
      'archiveConfirmMsg':
          'Jeste li sigurni da želite arhivirati? Arhivirani profil neće biti vidljiv na listi.',
      'unarchiveConfirmTitle': 'Vrati iz arhive',
      'unarchiveConfirmMsg':
          'Jeste li sigurni da želite vratiti profil iz arhive?',
      'archiveBlockedTitle': 'Nije moguće arhivirati',
      'archiveBlockedMsg':
          'Nije moguće arhivirati jer ima aktivnih narudžbi. Prvo otkazite ili prebacite narudžbe.',
      'archiveForceWarning':
          'Arhiviranjem će se automatski otkazati sve narudžbe i dodjele.',
      'archiveSuccess': 'Uspješno arhivirano',
      'unarchiveSuccess': 'Uspješno vraćeno iz arhive',
      'suspendWarningTitle': 'Upozorenje: aktivne narudžbe',
      'suspendWarningMsg':
          'Korisnik ima aktivnih narudžbi koje će biti automatski otkazane. Jeste li sigurni da želite nastaviti sa suspenzijom?',
      'suspendWarningStudentMsg':
          'Student ima aktivne narudžbe s kojih će biti uklonjen. Narudžbe će se vratiti na status "Na čekanju" dok se ne pronađe zamjena. Jeste li sigurni?',
      'filterAll': 'Svi',
      'filterProcessing': 'U obradi',
      'filterActive': 'Aktivni',
      'filterInactive': 'Neaktivni',
      'seniorFilterActive': 'Aktivan',
      'seniorFilterInactive': 'Neaktivan',
      'filterArchived': 'Arhiviran',
      'statusArchived': 'Arhiviran',
      'adminActions': 'Admin akcije',
      'adminNotes': 'Bilješke',
      'adminNotesEmpty': 'Nema bilješki.',
      'adminNoteAdd': 'Dodaj bilješku',
      'adminNoteEdit': 'Uredi bilješku',
      'adminNoteSave': 'Spremi',
      'adminNoteCancel': 'Odustani',
      'adminNoteDelete': 'Obriši bilješku',
      'adminNoteDeleteConfirm':
          'Jeste li sigurni da želite obrisati ovu bilješku?',
      'adminNotePlaceholder': 'Unesite bilješku...',
      'adminNoteEdited': 'uređeno',
      'assignShort': 'Dodijeli',
      'assignSuccess': 'Student dodijeljen na nalog',
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
      'oneTimeOrder': 'Jednokratna',
      'recurringOrder': 'Ponavljajuća',

      // ── Raspored sekcija ──────────────────────
      'editLayout': 'Uredi raspored',
      'sectionLayoutTitle': 'Raspored sekcija',
      'sectionLayoutHint': 'Povuci za promjenu redoslijeda',
      'resetDefault': 'Reset',

      // ── Detalji seniora ───────────────────────
      'seniorPersonalData': 'Osobni podaci',
      'seniorOrdererTitle': 'Naručitelj usluga',
      'seniorServiceUser': 'Korisnik usluga',
      'seniorOrdererInfo': 'Naručitelj',
      'seniorOrdererFirstName': 'Ime',
      'seniorOrdererLastName': 'Prezime',
      'seniorOrdererEmail': 'Email',
      'seniorOrdererName': 'Ime naručitelja',
      'seniorOrdererPhone': 'Telefon',
      'seniorOrdererAddress': 'Adresa',
      'seniorOrdererGender': 'Spol',
      'seniorOrdererDob': 'Datum rođenja',
      'seniorOrdererRelation': 'Odnos',
      'seniorNotes': 'Napomena',
      'addSeniorTitle': 'Novi senior',
      'addSeniorSuccess': 'Senior uspješno dodan',
      'editSeniorTitle': 'Uredi seniora',
      'editSeniorSuccess': 'Podaci uspješno ažurirani',
      'addSeniorHasOrderer': 'Ima naručitelja',
      'fieldRequired': 'Obavezno polje',
      'selectDate': 'Odaberi datum',
      'selectGender': 'Odaberi spol',
      'seniorOrderCount': '{count} narudžbi',
      'seniorCreditCards': 'Kartice za plaćanje',
      'seniorNoCards': 'Nema spremljenih kartica',
      'cardExpiry': 'Ističe',
      'cardExpired': 'Istekla',

      // ── Chat detalji ──────────────────────────
      'chatSelectConversation': 'Odaberite razgovor',
      'chatSeniorTag': 'Senior',
      'chatStudentTag': 'Student',
      'chatNoMessages': 'Nema poruka',
      'chatInputHint': 'Upiši poruku...',

      // ── Seniori ───────────────────────────────
      'seniorsTitle': 'Seniori',
      'seniorDetails': 'Detalji seniora',
      'seniorFirstName': 'Ime',
      'seniorLastName': 'Prezime',
      'seniorName': 'Ime i prezime',
      'seniorEmail': 'Email',
      'seniorPhone': 'Telefon',
      'seniorAddress': 'Adresa',
      'seniorReviews': 'Ocjene seniora',
      'seniorNoReviews': 'Nema ocjena',
      'seniorOrders': 'Narudžbe seniora',
      'seniorTotalOrders': 'Ukupno narudžbi',
      'seniorActiveOrders': 'Aktivnih',
      'searchSeniors': 'Pretraži seniore...',
      'noSeniorsFound': 'Nema pronađenih seniora',
      'allSeniors': 'Svi',
      'activeSeniors': 'Aktivni',
      'inactiveSeniors': 'Neaktivni',
      'ordererInfo': 'Naručitelj',
      'seniorInfo': 'Korisnik usluge',

      // ── Chat ──────────────────────────────────
      'chatTitle': 'Poruke',
      'chatRooms': 'Chat sobe',
      'chatWithSenior': 'Chat sa seniorom',
      'chatWithStudent': 'Chat sa studentom',
      'typeMessage': 'Upiši poruku...',
      'sendMessage': 'Pošalji',
      'noMessages': 'Nema poruka',
      'noChatRooms': 'Nema chat soba',
      'searchChats': 'Pretraži poruke...',

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
      'sessionsMonthlySubtitle': 'Prikazani termini za tekući mjesec.',
      'sessionsPlannedSubtitle': 'Čeka se dodjela studenta.',
      'sessionsCancelledSubtitle': 'Narudžba je otkazana.',
      'sessionStatusPlanned': 'Planirano',
      'sessionStatusScheduled': 'Nadolazeći',
      'sessionStatusCompleted': 'Obavljen',
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
      'sessionNoStudentAssigned': 'Nije dodijeljen',
      'sessionKeepCurrentStudent': 'Zadrži trenutnog',
      'noStudentsForSlot': 'Nema dostupnih studenata za odabrani termin',
      'selectTime': 'Odaberi vrijeme',
      'timePickerHour': 'Sat',
      'timePickerMinute': 'Min',
      'availableAllDays': 'Dostupan sve dane',
      'availableAllDaysShort': 'Dostupan',
      'availablePartial': 'Dostupan {matched}/{total} dana',
      'availableDifferentTimes': 'Djelomično dostupan',
      'availableDifferentTimesShort': 'Djelomično',
      'notAvailableForOrder': 'Nedostupan za ovu narudžbu',
      'reviewSessions': 'Pregled termina',
      'reviewShort': 'Pregled',
      'timeMismatch': 'Razlika u satima',
      'unavailableDay': 'Nedostupan taj dan',
      'sessionReactivate': 'Vrati termin',
      'sessionReactivateConfirm':
          'Želite li vratiti ovaj termin kao nadolazeći?',
      'studentUnavailableForSession':
          'Student nije dostupan za ovaj termin. Promijenite studenta ili termin.',
      'sessionModified': 'Izmijenjeno',
      'seniorSessionConflict':
          'Senior već ima drugi termin na {date} koji se preklapa s {time}.',

      // ── Općenito ──────────────────────────────
      'loading': 'Učitavanje...',
      'error': 'Greška',
      'retry': 'Pokušaj ponovo',
      'cancel': 'Odustani',
      'confirm': 'Potvrdi',
      'save': 'Spremi',
      'back': 'Natrag',
      'next': 'Dalje',
      'close': 'Zatvori',
      'search': 'Pretraži',
      'noResults': 'Nema rezultata',
      'ok': 'U redu',
      'delete': 'Obriši',
      'edit': 'Uredi',
      'add': 'Dodaj',
      'actions': 'Akcije',
      'details': 'Detalji',
      'total': 'Ukupno',
      'today': 'Danas',
      'yesterday': 'Jučer',
      'thisWeek': 'Ovaj tjedan',
      'thisMonth': 'Ovaj mjesec',
      'emailCopied': 'Email kopiran',
      'copyEmail': 'Kopiraj email',
      'callPhone': 'Nazovi',
      'phoneCopied': 'Telefon kopiran',

      // ── Notifications ──
      'notifications': 'Obavijesti',
      'noNotifications': 'Nema novih obavijesti',
      'markAllRead': 'Sve pročitano',
      'justNow': 'Upravo sad',
      'minutesAgo': 'min prije',
      'hoursAgo': 'h prije',
      'daysAgo': 'd prije',

      // ── Auth ──────────────────────────────────
      'login': 'Prijava',
      'email': 'E-mail adresa',
      'password': 'Lozinka',
      'loginButton': 'Prijavi se',
      'loginTitle': 'Helpi Admin',
      'loginSubtitle': 'Prijavite se za upravljanje platformom',
      'logout': 'Odjava',
      'forgotPassword': 'Zaboravljena lozinka?',
      'loggingIn': 'Prijava u tijeku...',
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
      'codeSent': 'Kod je poslan na vaš email',
      'enterEmail': 'Unesite email adresu',
      'sending': 'Slanje...',
      'resetting': 'Resetiranje...',
      'backToLogin': 'Povratak na prijavu',

      // ── Profil / Postavke ─────────────────────
      'settings': 'Postavke',
      'language': 'Jezik',
      'profile': 'Moj profil',

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
      'deleteConfirm': 'Obriši {item}?',
      'itemCount': '{count} stavki',
      'ratingValue': '{rating}/5',
      'hoursFormat': '{hours}h',
      'priceFormat': '{price} €',
      'pricePerHour': '{price} €/sat',
      'activeStudentsMonth': 'Aktivni studenti — {monthYear}',

      // ── Suspenzija ──
      'suspend': 'Suspendiraj',
      'activate': 'Aktiviraj',
      'suspended': 'Suspendiran',
      'suspendUser': 'Suspendiraj korisnika',
      'activateUser': 'Aktiviraj korisnika',
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
      'suspendedAt': 'Suspendiran dana',
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
      'appName': 'Helpi Admin',
      'appTagline': 'Platform management',

      // ── Navigacija ────────────────────────────
      'navDashboard': 'Analytics',
      'navStudents': 'Students',
      'navSeniors': 'Seniors',
      'navChat': 'Messages',
      'navSettings': 'Language',

      // ── Analitika ─────────────────────────────
      'dashboardTitle': 'Analytics',
      'totalOrders': 'Total orders',
      'processingOrders': 'Seniors in processing',
      'activeOrders': 'Active',
      'completedOrders': 'Completed',
      'totalStudents': 'Students',
      'activeStudents': 'Active students',
      'totalSeniors': 'Seniors',
      'recentOrders': 'Recent orders',
      'todaysSessions': "Today's sessions",
      'expiringContracts': 'Expired contracts',
      'activeStudentsThisMonth': 'Active students this month',
      'sessionsCount': 'sessions',
      'hoursCount': 'hours',
      'viewAll': 'View all',
      'noData': 'No data',
      'noProcessingOrders': 'No seniors in processing',
      'noActiveStudentsMonth': 'No active students',
      'noExpiringContracts': 'No expiring contracts',
      'analyticsLast7Days': 'Last 7 days',
      'analyticsThisMonth': 'This month',
      'analyticsLastMonth': 'Last month',
      'analyticsCustomRange': 'Custom range',
      'analyticsOrders': 'Orders',
      'analyticsRevenue': 'Revenue',
      'analyticsActiveSeniors': 'Active seniors',
      'analyticsCompare': 'Compare with previous period',
      'analyticsPrevPeriod': 'vs previous period',
      'analyticsNoChange': 'No change',
      'analyticsTotal': 'Total: {value}',
      'analyticsNoData': 'No data for selected period',
      'analyticsCurrent': 'Current',
      'analyticsPrevious': 'Previous',
      'analyticsEarnings': 'Earnings',
      'analyticsCompareShort': 'Compare previous',
      'analyticsEarningsShort': 'Earnings',
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
      'ordersProcessing': 'Processing',
      'cancelOrderConfirmTitle': 'Cancel order',
      'cancelOrderConfirmMsg':
          'Are you sure you want to cancel this order? All upcoming sessions will be cancelled.',
      'cancelOrderBtn': 'Cancel order',
      'archiveOrderBlockedTitle': 'Cannot archive',
      'archiveOrderBlockedMsg':
          'Order must be cancelled or completed before archiving.',
      'editOrderTitle': 'Edit order',
      'editOrderSuccess': 'Order updated successfully',
      'orderNumber': 'Order #{number}',
      'orderDetails': 'Order details',
      'orderStatus': 'Status',
      'orderDate': 'Date',
      'orderTime': 'Time',
      'orderDuration': 'Duration',
      'orderServices': 'Services',
      'orderNotes': 'Note',
      'orderFrequency': 'Frequency',
      'orderSchedule': 'Schedule',
      'orderSenior': 'Senior',
      'orderStudent': 'Student',
      'assignStudent': 'Assign student',
      'reassignStudent': 'Reassign student',
      'noStudentAssigned': 'No student assigned',
      'sessionsNoStudent': 'Assign a student to manage sessions.',
      'suggestedStudents': 'Suggested students',
      'assignConfirm': 'Assign {student} to this order?',
      'assigned': 'Assigned',
      'noOrdersFound': 'No orders found',
      'filterByStatus': 'Filter by status',
      'filterByDate': 'Filter by date',
      'filterByService': 'Filter by service',
      'searchOrders': 'Search orders...',

      // ── Promo kod ─────────────────────────────
      'promoCode': 'Promo code',
      'promoCodeHint': 'Enter promo code...',
      'promoCodeApply': 'Apply promo code',

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
      'endDateLabel': 'End date',
      'hasEndDate': 'Until specific date',

      // ── Statusi narudžbi ──────────────────────
      'statusProcessing': 'Processing',
      'statusActive': 'Active',
      'statusCompleted': 'Completed',
      'statusCancelled': 'Cancelled',

      // ── Statusi termina (job) ─────────────────
      'jobScheduled': 'Scheduled',
      'jobCompleted': 'Completed',
      'jobCancelled': 'Cancelled',

      // ── Studenti ──────────────────────────────
      'studentsTitle': 'Students',
      'studentDetails': 'Student details',
      'studentFirstName': 'First name',
      'studentLastName': 'Last name',
      'studentName': 'Full name',
      'studentEmail': 'Email',
      'studentPhone': 'Phone',
      'studentAddress': 'Address',
      'studentFaculty': 'Faculty',
      'studentRating': 'Average rating',
      'studentTotalJobs': 'Total jobs',
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
      'workPickDates': 'Pick dates',
      'workFrom': 'From',
      'workTo': 'To',
      'studentContractStart': 'Contract start',
      'studentContract': 'Contract',
      'contractStatus': 'Contract status',
      'contractActive': 'Active',
      'contractExpired': 'Expired',
      'contractExpiring': 'Expiring soon',
      'contractNone': 'No contract',
      'uploadContract': 'Upload contract',
      'contractValidUntil': 'Valid until: {date}',
      'contractExpires': 'Expires: {date}',
      'renewContract': 'Renew contract',
      'verifiedStudent': 'Verified',
      'unverifiedStudent': 'Unverified',
      'verifyStudent': 'Verify',
      'searchStudents': 'Search students...',
      'noStudentsFound': 'No students found',
      'studentOrders': 'Student orders',
      'studentReviews': 'Student reviews',
      'allStudents': 'All',
      'activeStudentsFilter': 'Active',
      'inactiveStudents': 'Inactive',
      'contractExpiringFilter': 'Contract expiring',
      'sortBy': 'Sort',
      'sortAZ': 'A → Z',
      'sortZA': 'Z → A',
      'sortNewest': 'Newest',
      'sortOldest': 'Oldest',
      'sortNewestF': 'Newest',
      'sortOldestF': 'Oldest',
      'sortRatingHigh': 'Rating ↓',
      'sortRatingLow': 'Rating ↑',

      // ── Advanced student filters ──────────────
      'advancedFilters': 'Advanced filters',
      'filterByActivity': 'Activity in period',
      'filterWorkedThisMonth': 'Worked this month',
      'filterDidNotWork': 'Did not work',
      'filterWorked': 'Worked',
      'filterPeriodThisMonth': 'This month',
      'filterPeriodLastMonth': 'Last month',
      'filterPeriodLast60Days': 'Last 60 days',
      'filterPeriodCustom': 'Custom',
      'filterPeriodFrom': 'From date',
      'filterPeriodTo': 'To date',
      'filterAvailHint': 'Day + hour are combined (AND)',
      'filterMinJobs': 'Min. completed jobs',
      'filterMaxJobs': 'Max. completed jobs',
      'filterByContract': 'Contract status',
      'filterByAvailability': 'Availability',
      'filterByDay': 'Day of week',
      'filterByTimeFrom': 'Available from',
      'filterByTimeTo': 'Available to',
      'excludeBusy': 'Exclude busy',
      'workedWithSenior': 'Worked with this senior ({count}x)',
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
      'anyContract': 'Any',
      'anySenior': 'Any',
      'filterResultCount': '{count} students',
      'seniorResultCount': '{count} seniors',
      'orderResultCount': '{count} orders',
      'thisMonthShort': 'this mo.',

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
      'studentRenewContract': 'Renew contract',
      'contractUploadSuccess': 'Contract uploaded successfully.',
      'contractRenewSuccess': 'Contract renewed successfully.',
      'contractSelectPeriod': 'Select contract period',
      'contractFileSelected': 'Selected: {name}',
      'contractNoFileSelected': 'No document selected.',
      'contractNumber': 'Contract number',
      'contractDelete': 'Delete contract',
      'contractDeleteTitle': 'Delete contract',
      'contractDeleteConfirm':
          'Are you sure you want to delete this contract? The file will be removed from Google Drive.',
      'contractDeleteSuccess': 'Contract deleted successfully.',
      'contractLoading': 'Loading contract...',
      'contractDeleting': 'Deleting contract...',
      'studentNotAvailable': 'Not available',
      'studentNotAvailableMale': 'Not available',
      'studentNotAvailableFemale': 'Not available',
      'studentAssignedOrders': 'Assigned orders',
      'studentRemoveVerification': 'Remove verification',
      'studentVerify': 'Verify',
      'studentArchive': 'Archive',
      'studentUnarchive': 'Restore from archive',
      'archiveConfirmTitle': 'Archive',
      'archiveConfirmMsg':
          'Are you sure you want to archive? Archived profile will not be visible on the list.',
      'unarchiveConfirmTitle': 'Restore from archive',
      'unarchiveConfirmMsg':
          'Are you sure you want to restore this profile from the archive?',
      'archiveBlockedTitle': 'Cannot archive',
      'archiveBlockedMsg':
          'Cannot archive because there are active orders. Cancel or reassign orders first.',
      'archiveForceWarning':
          'Archiving will automatically cancel all orders and assignments.',
      'archiveSuccess': 'Successfully archived',
      'unarchiveSuccess': 'Successfully restored from archive',
      'suspendWarningTitle': 'Warning: active orders',
      'suspendWarningMsg':
          'This user has active orders that will be automatically cancelled. Are you sure you want to proceed with suspension?',
      'suspendWarningStudentMsg':
          'Student has active orders from which they will be removed. Orders will return to "Pending" status until a replacement is found. Are you sure?',
      'filterAll': 'All',
      'filterProcessing': 'Processing',
      'filterActive': 'Active',
      'filterInactive': 'Inactive',
      'seniorFilterActive': 'Active',
      'seniorFilterInactive': 'Inactive',
      'filterArchived': 'Archived',
      'statusArchived': 'Archived',
      'adminActions': 'Admin actions',
      'adminNotes': 'Notes',
      'adminNotesEmpty': 'No notes.',
      'adminNoteAdd': 'Add note',
      'adminNoteEdit': 'Edit note',
      'adminNoteSave': 'Save',
      'adminNoteCancel': 'Cancel',
      'adminNoteDelete': 'Delete note',
      'adminNoteDeleteConfirm': 'Are you sure you want to delete this note?',
      'adminNotePlaceholder': 'Enter note...',
      'adminNoteEdited': 'edited',
      'assignShort': 'Assign',
      'assignSuccess': 'Student assigned to order',
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
      'oneTimeOrder': 'One-time',
      'recurringOrder': 'Recurring',

      // ── Raspored sekcija ──────────────────────
      'editLayout': 'Edit layout',
      'sectionLayoutTitle': 'Section layout',
      'sectionLayoutHint': 'Drag to change order',
      'resetDefault': 'Reset',

      // ── Detalji seniora ───────────────────────
      'seniorPersonalData': 'Personal data',
      'seniorOrdererTitle': 'Service orderer',
      'seniorServiceUser': 'Service user',
      'seniorOrdererInfo': 'Orderer',
      'seniorOrdererFirstName': 'First name',
      'seniorOrdererLastName': 'Last name',
      'seniorOrdererEmail': 'Email',
      'seniorOrdererName': 'Orderer name',
      'seniorOrdererPhone': 'Phone',
      'seniorOrdererAddress': 'Address',
      'seniorOrdererGender': 'Gender',
      'seniorOrdererDob': 'Date of birth',
      'seniorOrdererRelation': 'Relation',
      'seniorNotes': 'Notes',
      'addSeniorTitle': 'New senior',
      'addSeniorSuccess': 'Senior added successfully',
      'editSeniorTitle': 'Edit senior',
      'editSeniorSuccess': 'Data updated successfully',
      'addSeniorHasOrderer': 'Has orderer',
      'fieldRequired': 'Required field',
      'selectDate': 'Select date',
      'selectGender': 'Select gender',
      'seniorOrderCount': '{count} orders',
      'seniorCreditCards': 'Payment cards',
      'seniorNoCards': 'No saved cards',
      'cardExpiry': 'Expires',
      'cardExpired': 'Expired',

      // ── Chat detalji ──────────────────────────
      'chatSelectConversation': 'Select a conversation',
      'chatSeniorTag': 'Senior',
      'chatStudentTag': 'Student',
      'chatNoMessages': 'No messages',
      'chatInputHint': 'Type a message...',

      // ── Seniori ───────────────────────────────
      'seniorsTitle': 'Seniors',
      'seniorDetails': 'Senior details',
      'seniorFirstName': 'First name',
      'seniorLastName': 'Last name',
      'seniorName': 'Full name',
      'seniorEmail': 'Email',
      'seniorPhone': 'Phone',
      'seniorAddress': 'Address',
      'seniorReviews': 'Senior reviews',
      'seniorNoReviews': 'No reviews',
      'seniorOrders': 'Senior orders',
      'seniorTotalOrders': 'Total orders',
      'seniorActiveOrders': 'Active',
      'searchSeniors': 'Search seniors...',
      'noSeniorsFound': 'No seniors found',
      'allSeniors': 'All',
      'activeSeniors': 'Active',
      'inactiveSeniors': 'Inactive',
      'ordererInfo': 'Orderer',
      'seniorInfo': 'Service user',

      // ── Chat ──────────────────────────────────
      'chatTitle': 'Messages',
      'chatRooms': 'Chat rooms',
      'chatWithSenior': 'Chat with senior',
      'chatWithStudent': 'Chat with student',
      'typeMessage': 'Type a message...',
      'sendMessage': 'Send',
      'noMessages': 'No messages',
      'noChatRooms': 'No chat rooms',
      'searchChats': 'Search messages...',

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
      'sessionsMonthlySubtitle': 'Sessions for the current month.',
      'sessionsPlannedSubtitle': 'Awaiting student assignment.',
      'sessionsCancelledSubtitle': 'Order has been cancelled.',
      'sessionStatusPlanned': 'Planned',
      'sessionStatusScheduled': 'Scheduled',
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
      'sessionNoStudentAssigned': 'Not assigned',
      'sessionKeepCurrentStudent': 'Keep current',
      'noStudentsForSlot': 'No students available for selected time slot',
      'availableAllDays': 'Available all days',
      'availableAllDaysShort': 'Available',
      'availablePartial': 'Available {matched}/{total} days',
      'availableDifferentTimes': 'Partially available',
      'availableDifferentTimesShort': 'Partial',
      'notAvailableForOrder': 'Not available for this order',
      'reviewSessions': 'Review sessions',
      'reviewShort': 'Review',
      'timeMismatch': 'Time mismatch',
      'unavailableDay': 'Unavailable this day',
      'selectTime': 'Select time',
      'timePickerHour': 'Hour',
      'timePickerMinute': 'Min',
      'sessionReactivate': 'Restore session',
      'sessionReactivateConfirm':
          'Do you want to restore this session as upcoming?',
      'studentUnavailableForSession':
          'Student is not available for this session. Change the student or reschedule.',
      'sessionModified': 'Modified',
      'seniorSessionConflict':
          'Senior already has another session on {date} that overlaps with {time}.',

      // ── Općenito ──────────────────────────────
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Try again',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'back': 'Back',
      'next': 'Next',
      'close': 'Close',
      'search': 'Search',
      'noResults': 'No results',
      'ok': 'OK',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'actions': 'Actions',
      'details': 'Details',
      'total': 'Total',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'thisWeek': 'This week',
      'thisMonth': 'This month',
      'emailCopied': 'Email copied',
      'copyEmail': 'Copy email',
      'callPhone': 'Call',
      'phoneCopied': 'Phone copied',

      // ── Notifications ──
      'notifications': 'Notifications',
      'noNotifications': 'No new notifications',
      'markAllRead': 'All read',
      'justNow': 'Just now',
      'minutesAgo': 'min ago',
      'hoursAgo': 'h ago',
      'daysAgo': 'd ago',

      // ── Auth ──────────────────────────────────
      'login': 'Login',
      'email': 'Email address',
      'password': 'Password',
      'loginButton': 'Sign in',
      'loginTitle': 'Helpi Admin',
      'loginSubtitle': 'Sign in to manage the platform',
      'logout': 'Log out',
      'forgotPassword': 'Forgot password?',
      'loggingIn': 'Signing in...',
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
      'codeSent': 'Code sent to your email',
      'enterEmail': 'Enter email address',
      'sending': 'Sending...',
      'resetting': 'Resetting...',
      'backToLogin': 'Back to login',

      // ── Profil / Postavke ─────────────────────
      'settings': 'Settings',
      'language': 'Language',
      'profile': 'My profile',

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
      'deleteConfirm': 'Delete {item}?',
      'itemCount': '{count} items',
      'ratingValue': '{rating}/5',
      'hoursFormat': '{hours}h',
      'priceFormat': '€{price}',
      'pricePerHour': '€{price}/hour',
      'activeStudentsMonth': 'Active students — {monthYear}',

      // ── Suspension ──
      'suspend': 'Suspend',
      'activate': 'Activate',
      'suspended': 'Suspended',
      'suspendUser': 'Suspend user',
      'activateUser': 'Activate user',
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
      'suspendedAt': 'Suspended on',
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

  // ═══════════════════════════════════════════════════════════════
  //  STATIC GETTERS
  // ═══════════════════════════════════════════════════════════════

  // ── App ──
  static String get appName => _t('appName');
  static String get appTagline => _t('appTagline');

  // ── Navigacija ──
  static String get navDashboard => _t('navDashboard');
  static String get navStudents => _t('navStudents');
  static String get navSeniors => _t('navSeniors');
  static String get navChat => _t('navChat');
  static String get navSettings => _t('navSettings');

  // ── Analitika ──
  static String get dashboardTitle => _t('dashboardTitle');
  static String get totalOrders => _t('totalOrders');
  static String get processingOrders => _t('processingOrders');
  static String get activeOrders => _t('activeOrders');
  static String get completedOrders => _t('completedOrders');
  static String get totalStudents => _t('totalStudents');
  static String get activeStudents => _t('activeStudents');
  static String get totalSeniors => _t('totalSeniors');
  static String get recentOrders => _t('recentOrders');
  static String get todaysSessions => _t('todaysSessions');
  static String get expiringContracts => _t('expiringContracts');
  static String get activeStudentsThisMonth => _t('activeStudentsThisMonth');
  static String get sessionsCount => _t('sessionsCount');
  static String get hoursCount => _t('hoursCount');
  static String get viewAll => _t('viewAll');
  static String get noData => _t('noData');
  static String get noProcessingOrders => _t('noProcessingOrders');
  static String get noActiveStudentsMonth => _t('noActiveStudentsMonth');
  static String get noExpiringContracts => _t('noExpiringContracts');
  static String get analyticsLast7Days => _t('analyticsLast7Days');
  static String get analyticsThisMonth => _t('analyticsThisMonth');
  static String get analyticsLastMonth => _t('analyticsLastMonth');
  static String get analyticsCustomRange => _t('analyticsCustomRange');
  static String get analyticsOrders => _t('analyticsOrders');
  static String get analyticsRevenue => _t('analyticsRevenue');
  static String get analyticsActiveSeniors => _t('analyticsActiveSeniors');
  static String get analyticsCompare => _t('analyticsCompare');
  static String get analyticsPrevPeriod => _t('analyticsPrevPeriod');
  static String get analyticsNoChange => _t('analyticsNoChange');
  static String analyticsTotal(String value) =>
      _t('analyticsTotal', params: {'value': value});
  static String get analyticsNoData => _t('analyticsNoData');
  static String get analyticsCurrent => _t('analyticsCurrent');
  static String get analyticsPrevious => _t('analyticsPrevious');
  static String get analyticsEarnings => _t('analyticsEarnings');
  static String get analyticsCompareShort => _t('analyticsCompareShort');
  static String get analyticsEarningsShort => _t('analyticsEarningsShort');
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
  static String get ordersProcessing => _t('ordersProcessing');
  static String get cancelOrderConfirmTitle => _t('cancelOrderConfirmTitle');
  static String get cancelOrderConfirmMsg => _t('cancelOrderConfirmMsg');
  static String get cancelOrderBtn => _t('cancelOrderBtn');
  static String get archiveOrderBlockedTitle => _t('archiveOrderBlockedTitle');
  static String get archiveOrderBlockedMsg => _t('archiveOrderBlockedMsg');
  static String get editOrderTitle => _t('editOrderTitle');
  static String get editOrderSuccess => _t('editOrderSuccess');
  static String orderNumber(String number) =>
      _t('orderNumber', params: {'number': number});
  static String get orderDetails => _t('orderDetails');
  static String get orderStatus => _t('orderStatus');
  static String get orderDate => _t('orderDate');
  static String get orderTime => _t('orderTime');
  static String get orderDuration => _t('orderDuration');
  static String get orderServices => _t('orderServices');
  static String get orderNotes => _t('orderNotes');
  static String get orderFrequency => _t('orderFrequency');
  static String get orderSchedule => _t('orderSchedule');
  static String get promoCode => _t('promoCode');
  static String get promoCodeHint => _t('promoCodeHint');
  static String get promoCodeApply => _t('promoCodeApply');
  static String get orderSenior => _t('orderSenior');
  static String get orderStudent => _t('orderStudent');
  static String get assignStudent => _t('assignStudent');
  static String get reassignStudent => _t('reassignStudent');
  static String get noStudentAssigned => _t('noStudentAssigned');
  static String get sessionsNoStudent => _t('sessionsNoStudent');
  static String get suggestedStudents => _t('suggestedStudents');
  static String assignConfirm(String student) =>
      _t('assignConfirm', params: {'student': student});
  static String get assigned => _t('assigned');
  static String get noOrdersFound => _t('noOrdersFound');
  static String get filterByStatus => _t('filterByStatus');
  static String get filterByDate => _t('filterByDate');
  static String get filterByService => _t('filterByService');
  static String get searchOrders => _t('searchOrders');

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
  static String get endDateLabel => _t('endDateLabel');
  static String get hasEndDate => _t('hasEndDate');

  // ── Statusi ──
  static String get statusProcessing => _t('statusProcessing');
  static String get statusActive => _t('statusActive');
  static String get statusCompleted => _t('statusCompleted');
  static String get statusCancelled => _t('statusCancelled');

  // ── Job statusi ──
  static String get jobScheduled => _t('jobScheduled');
  static String get jobCompleted => _t('jobCompleted');
  static String get jobCancelled => _t('jobCancelled');

  // ── Studenti ──
  static String get studentsTitle => _t('studentsTitle');
  static String get studentDetails => _t('studentDetails');
  static String get studentFirstName => _t('studentFirstName');
  static String get studentLastName => _t('studentLastName');
  static String get studentName => _t('studentName');
  static String get studentEmail => _t('studentEmail');
  static String get studentPhone => _t('studentPhone');
  static String get studentAddress => _t('studentAddress');
  static String get studentFaculty => _t('studentFaculty');
  static String get studentRating => _t('studentRating');
  static String get studentTotalJobs => _t('studentTotalJobs');
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
  static String get workPickDates => _t('workPickDates');
  static String get workFrom => _t('workFrom');
  static String get workTo => _t('workTo');
  static String get studentContractStart => _t('studentContractStart');
  static String get studentContract => _t('studentContract');
  static String get contractStatus => _t('contractStatus');
  static String get contractActive => _t('contractActive');
  static String get contractExpired => _t('contractExpired');
  static String get contractExpiring => _t('contractExpiring');
  static String get contractNone => _t('contractNone');
  static String get uploadContract => _t('uploadContract');
  static String contractValidUntil(String date) =>
      _t('contractValidUntil', params: {'date': date});
  static String contractExpires(String date) =>
      _t('contractExpires', params: {'date': date});
  static String get renewContract => _t('renewContract');
  static String get verifiedStudent => _t('verifiedStudent');
  static String get unverifiedStudent => _t('unverifiedStudent');
  static String get verifyStudent => _t('verifyStudent');
  static String get searchStudents => _t('searchStudents');
  static String get noStudentsFound => _t('noStudentsFound');
  static String get studentOrders => _t('studentOrders');
  static String get studentReviews => _t('studentReviews');
  static String get allStudents => _t('allStudents');
  static String get activeStudentsFilter => _t('activeStudentsFilter');
  static String get inactiveStudents => _t('inactiveStudents');
  static String get contractExpiringFilter => _t('contractExpiringFilter');
  static String get sortBy => _t('sortBy');
  static String get sortAZ => _t('sortAZ');
  static String get sortZA => _t('sortZA');
  static String get sortNewest => _t('sortNewest');
  static String get sortOldest => _t('sortOldest');
  static String get sortNewestF => _t('sortNewestF');
  static String get sortOldestF => _t('sortOldestF');
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
  static String get studentRenewContract => _t('studentRenewContract');
  static String get contractUploadSuccess => _t('contractUploadSuccess');
  static String get contractRenewSuccess => _t('contractRenewSuccess');
  static String get contractSelectPeriod => _t('contractSelectPeriod');
  static String contractFileSelected(String name) =>
      _t('contractFileSelected', params: {'name': name});
  static String get contractNoFileSelected => _t('contractNoFileSelected');
  static String get contractNumber => _t('contractNumber');
  static String get contractDelete => _t('contractDelete');
  static String get contractDeleteTitle => _t('contractDeleteTitle');
  static String get contractDeleteConfirm => _t('contractDeleteConfirm');
  static String get contractDeleteSuccess => _t('contractDeleteSuccess');
  static String get contractLoading => _t('contractLoading');
  static String get contractDeleting => _t('contractDeleting');
  static String get studentNotAvailable => _t('studentNotAvailable');
  static String studentNotAvailableGendered(Gender gender) =>
      gender == Gender.female
      ? _t('studentNotAvailableFemale')
      : _t('studentNotAvailableMale');
  static String get studentAssignedOrders => _t('studentAssignedOrders');
  static String get studentRemoveVerification =>
      _t('studentRemoveVerification');
  static String get studentVerify => _t('studentVerify');
  static String get studentArchive => _t('studentArchive');
  static String get studentUnarchive => _t('studentUnarchive');
  static String get archiveConfirmTitle => _t('archiveConfirmTitle');
  static String get archiveConfirmMsg => _t('archiveConfirmMsg');
  static String get unarchiveConfirmTitle => _t('unarchiveConfirmTitle');
  static String get unarchiveConfirmMsg => _t('unarchiveConfirmMsg');
  static String get archiveBlockedTitle => _t('archiveBlockedTitle');
  static String get archiveBlockedMsg => _t('archiveBlockedMsg');
  static String get archiveForceWarning => _t('archiveForceWarning');
  static String get archiveSuccess => _t('archiveSuccess');
  static String get unarchiveSuccess => _t('unarchiveSuccess');
  static String get suspendWarningTitle => _t('suspendWarningTitle');
  static String get suspendWarningMsg => _t('suspendWarningMsg');
  static String get suspendWarningStudentMsg => _t('suspendWarningStudentMsg');
  static String get filterAll => _t('filterAll');
  static String get filterProcessing => _t('filterProcessing');
  static String get filterActive => _t('filterActive');
  static String get filterInactive => _t('filterInactive');
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
  static String get adminNoteDelete => _t('adminNoteDelete');
  static String get adminNoteDeleteConfirm => _t('adminNoteDeleteConfirm');
  static String get adminNotePlaceholder => _t('adminNotePlaceholder');
  static String get adminNoteEdited => _t('adminNoteEdited');
  static String get assignShort => _t('assignShort');
  static String get assignSuccess => _t('assignSuccess');
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
  static String get oneTimeOrder => _t('oneTimeOrder');
  static String get recurringOrder => _t('recurringOrder');

  // ── Raspored sekcija ──
  static String get editLayout => _t('editLayout');
  static String get sectionLayoutTitle => _t('sectionLayoutTitle');
  static String get sectionLayoutHint => _t('sectionLayoutHint');
  static String get resetDefault => _t('resetDefault');

  // ── Napredni filteri ──
  static String get advancedFilters => _t('advancedFilters');
  static String get filterByActivity => _t('filterByActivity');
  static String get filterWorkedThisMonth => _t('filterWorkedThisMonth');
  static String get filterDidNotWork => _t('filterDidNotWork');
  static String get filterWorked => _t('filterWorked');
  static String get filterPeriodThisMonth => _t('filterPeriodThisMonth');
  static String get filterPeriodLastMonth => _t('filterPeriodLastMonth');
  static String get filterPeriodLast60Days => _t('filterPeriodLast60Days');
  static String get filterPeriodCustom => _t('filterPeriodCustom');
  static String get filterPeriodFrom => _t('filterPeriodFrom');
  static String get filterPeriodTo => _t('filterPeriodTo');
  static String get filterAvailHint => _t('filterAvailHint');
  static String get filterMinJobs => _t('filterMinJobs');
  static String get filterMaxJobs => _t('filterMaxJobs');
  static String get filterByContract => _t('filterByContract');
  static String get filterByAvailability => _t('filterByAvailability');
  static String get filterByDay => _t('filterByDay');
  static String get filterByTimeFrom => _t('filterByTimeFrom');
  static String get filterByTimeTo => _t('filterByTimeTo');
  static String get excludeBusy => _t('excludeBusy');
  static String workedWithSenior(int count) =>
      _t('workedWithSenior', params: {'count': '$count'});
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

  static String orderResultCount(int count) {
    if (_currentLocale == 'hr') {
      if (count == 1) return '1 narudžba';
      if (count >= 2 && count <= 4) return '$count narudžbe';
      return '$count narudžbi';
    }
    return _t('orderResultCount', params: {'count': '$count'});
  }

  static String get thisMonthShort => _t('thisMonthShort');

  // ── Detalji seniora ──
  static String get seniorPersonalData => _t('seniorPersonalData');
  static String get seniorFirstName => _t('seniorFirstName');
  static String get seniorLastName => _t('seniorLastName');
  static String get seniorOrdererTitle => _t('seniorOrdererTitle');
  static String get seniorServiceUser => _t('seniorServiceUser');
  static String get seniorOrdererInfo => _t('seniorOrdererInfo');
  static String get seniorOrdererFirstName => _t('seniorOrdererFirstName');
  static String get seniorOrdererLastName => _t('seniorOrdererLastName');
  static String get seniorOrdererEmail => _t('seniorOrdererEmail');
  static String get seniorOrdererName => _t('seniorOrdererName');
  static String get seniorOrdererPhone => _t('seniorOrdererPhone');
  static String get seniorOrdererAddress => _t('seniorOrdererAddress');
  static String get seniorOrdererGender => _t('seniorOrdererGender');
  static String get seniorOrdererDob => _t('seniorOrdererDob');
  static String get seniorOrdererRelation => _t('seniorOrdererRelation');
  static String get seniorNotes => _t('seniorNotes');
  static String get addSeniorTitle => _t('addSeniorTitle');
  static String get addSeniorSuccess => _t('addSeniorSuccess');
  static String get editSeniorTitle => _t('editSeniorTitle');
  static String get editSeniorSuccess => _t('editSeniorSuccess');
  static String get addSeniorHasOrderer => _t('addSeniorHasOrderer');
  static String get fieldRequired => _t('fieldRequired');
  static String get selectDate => _t('selectDate');
  static String get selectGender => _t('selectGender');
  static String get seniorCreditCards => _t('seniorCreditCards');
  static String get seniorNoCards => _t('seniorNoCards');
  static String get cardExpiry => _t('cardExpiry');
  static String get cardExpired => _t('cardExpired');
  static String seniorOrderCount(int count) {
    final locale = _currentLocale;
    if (locale == 'hr') {
      final mod10 = count % 10;
      final mod100 = count % 100;
      if (mod10 == 1 && mod100 != 11) return '$count narudžba';
      if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
        return '$count narudžbe';
      }
      return '$count narudžbi';
    }
    return count == 1 ? '$count order' : '$count orders';
  }

  // ── Chat detalji ──
  static String get chatSelectConversation => _t('chatSelectConversation');
  static String get chatSeniorTag => _t('chatSeniorTag');
  static String get chatStudentTag => _t('chatStudentTag');
  static String get chatNoMessages => _t('chatNoMessages');
  static String get chatInputHint => _t('chatInputHint');

  // ── Seniori ──
  static String get seniorsTitle => _t('seniorsTitle');
  static String get seniorDetails => _t('seniorDetails');
  static String get seniorName => _t('seniorName');
  static String get seniorEmail => _t('seniorEmail');
  static String get seniorPhone => _t('seniorPhone');
  static String get seniorAddress => _t('seniorAddress');
  static String get seniorReviews => _t('seniorReviews');
  static String get seniorNoReviews => _t('seniorNoReviews');
  static String get seniorOrders => _t('seniorOrders');
  static String get seniorTotalOrders => _t('seniorTotalOrders');
  static String get seniorActiveOrders => _t('seniorActiveOrders');
  static String get searchSeniors => _t('searchSeniors');
  static String get noSeniorsFound => _t('noSeniorsFound');
  static String get allSeniors => _t('allSeniors');
  static String get activeSeniors => _t('activeSeniors');
  static String get inactiveSeniors => _t('inactiveSeniors');
  static String get ordererInfo => _t('ordererInfo');
  static String get seniorInfo => _t('seniorInfo');

  // ── Chat ──
  static String get chatTitle => _t('chatTitle');
  static String get chatRooms => _t('chatRooms');
  static String get chatWithSenior => _t('chatWithSenior');
  static String get chatWithStudent => _t('chatWithStudent');
  static String get typeMessage => _t('typeMessage');
  static String get sendMessage => _t('sendMessage');
  static String get noMessages => _t('noMessages');
  static String get noChatRooms => _t('noChatRooms');
  static String get searchChats => _t('searchChats');

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
  static String get save => _t('save');
  static String get back => _t('back');
  static String get next => _t('next');
  static String get close => _t('close');
  static String get search => _t('search');
  static String get noResults => _t('noResults');
  static String get ok => _t('ok');
  static String get delete => _t('delete');
  static String get edit => _t('edit');
  static String get add => _t('add');
  static String get actions => _t('actions');
  static String get details => _t('details');
  static String get total => _t('total');
  static String get today => _t('today');
  static String get yesterday => _t('yesterday');
  static String get thisWeek => _t('thisWeek');
  static String get thisMonth => _t('thisMonth');

  // ── Auth ──
  static String get login => _t('login');
  static String get email => _t('email');
  static String get password => _t('password');
  static String get loginButton => _t('loginButton');
  static String get loginTitle => _t('loginTitle');
  static String get loginSubtitle => _t('loginSubtitle');
  static String get logout => _t('logout');
  static String get forgotPassword => _t('forgotPassword');
  static String get loggingIn => _t('loggingIn');
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
  static String get codeSent => _t('codeSent');
  static String get enterEmail => _t('enterEmail');
  static String get sending => _t('sending');
  static String get resetting => _t('resetting');
  static String get backToLogin => _t('backToLogin');

  // ── Profil / Postavke ──
  static String get settings => _t('settings');
  static String get language => _t('language');
  static String get profile => _t('profile');

  // ── Dani ──

  static String get dayMonFull => _t('dayMonFull');
  static String get dayTueFull => _t('dayTueFull');
  static String get dayWedFull => _t('dayWedFull');
  static String get dayThuFull => _t('dayThuFull');
  static String get dayFriFull => _t('dayFriFull');
  static String get daySatFull => _t('daySatFull');
  static String get daySunFull => _t('daySunFull');

  // ── Mjeseci ──
  static const _monthKeys = [
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

  /// Returns localized month name (1-based: 1 = January/Siječanj).
  static String monthName(int month) => _t(_monthKeys[month - 1]);

  // ── Parametrizirani ──
  static String deleteConfirm(String item) =>
      _t('deleteConfirm', params: {'item': item});
  static String itemCount(String count) =>
      _t('itemCount', params: {'count': count});
  static String ratingValue(String rating) =>
      _t('ratingValue', params: {'rating': rating});
  static String hoursFormat(String hours) =>
      _t('hoursFormat', params: {'hours': hours});
  static String priceFormat(String price) =>
      _t('priceFormat', params: {'price': price});
  static String pricePerHour(String price) =>
      _t('pricePerHour', params: {'price': price});
  static String activeStudentsMonth(String monthYear) =>
      _t('activeStudentsMonth', params: {'monthYear': monthYear});

  // ── Termini ──
  static String get sessionsTitle => _t('sessionsTitle');
  static String get sessionsMonthlySubtitle => _t('sessionsMonthlySubtitle');
  static String get sessionsPlannedSubtitle => _t('sessionsPlannedSubtitle');
  static String get sessionsCancelledSubtitle =>
      _t('sessionsCancelledSubtitle');
  static String get sessionStatusPlanned => _t('sessionStatusPlanned');
  static String get sessionStatusScheduled => _t('sessionStatusScheduled');
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
  static String get sessionNoStudentAssigned => _t('sessionNoStudentAssigned');
  static String get sessionKeepCurrentStudent =>
      _t('sessionKeepCurrentStudent');
  static String get noStudentsForSlot => _t('noStudentsForSlot');
  static String get selectTime => _t('selectTime');
  static String get timePickerHour => _t('timePickerHour');
  static String get timePickerMinute => _t('timePickerMinute');
  static String get sessionReactivate => _t('sessionReactivate');
  static String get sessionReactivateConfirm => _t('sessionReactivateConfirm');
  static String get studentUnavailableForSession =>
      _t('studentUnavailableForSession');
  static String get sessionModified => _t('sessionModified');
  static String seniorSessionConflict(String date, String time) =>
      _t('seniorSessionConflict', params: {'date': date, 'time': time});
  static String get emailCopied => _t('emailCopied');
  static String get copyEmail => _t('copyEmail');
  static String get callPhone => _t('callPhone');
  static String get phoneCopied => _t('phoneCopied');
  static String get notifications => _t('notifications');
  static String get noNotifications => _t('noNotifications');
  static String get markAllRead => _t('markAllRead');
  static String get justNow => _t('justNow');
  static String get minutesAgo => _t('minutesAgo');
  static String get hoursAgo => _t('hoursAgo');
  static String get daysAgo => _t('daysAgo');
  static String get availableAllDays => _t('availableAllDays');
  static String get availableAllDaysShort => _t('availableAllDaysShort');
  static String availablePartial(int matched, int total) => _t(
    'availablePartial',
    params: {'matched': matched.toString(), 'total': total.toString()},
  );
  static String get availableDifferentTimes => _t('availableDifferentTimes');
  static String get availableDifferentTimesShort =>
      _t('availableDifferentTimesShort');
  static String get notAvailableForOrder => _t('notAvailableForOrder');
  static String get reviewSessions => _t('reviewSessions');
  static String get reviewShort => _t('reviewShort');
  static String get timeMismatch => _t('timeMismatch');
  static String get unavailableDay => _t('unavailableDay');

  // ── Suspenzija ──
  static String get suspend => _t('suspend');
  static String get activate => _t('activate');
  static String get suspended => _t('suspended');
  static String get suspendUser => _t('suspendUser');
  static String get activateUser => _t('activateUser');
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
  static String get suspendedAt => _t('suspendedAt');
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
}
