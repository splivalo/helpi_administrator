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
      'navDashboard': 'Pregled',
      'navOrders': 'Narudžbe',
      'navStudents': 'Studenti',
      'navSeniors': 'Seniori',
      'navChat': 'Poruke',
      'navSettings': 'Jezik',

      // ── Dashboard ─────────────────────────────
      'dashboardTitle': 'Pregled',
      'totalOrders': 'Ukupno narudžbi',
      'processingOrders': 'Narudžbe u obradi',
      'activeOrders': 'Aktivne',
      'completedOrders': 'Završene',
      'totalStudents': 'Studenata',
      'activeStudents': 'Aktivni studenti',
      'totalSeniors': 'Seniora',
      'recentOrders': 'Nedavne narudžbe',
      'todaysSessions': 'Današnji termini',
      'expiringContracts': 'Ugovori koji ističu',
      'activeStudentsThisMonth': 'Aktivni studenti ovaj mjesec',
      'sessionsCount': 'termina',
      'hoursCount': 'sati',
      'viewAll': 'Prikaži sve',
      'noData': 'Nema podataka',

      // ── Narudžbe ──────────────────────────────
      'ordersTitle': 'Narudžbe',
      'allOrders': 'Sve',
      'ordersProcessing': 'U obradi',
      'ordersActive': 'Aktivne',
      'ordersCompleted': 'Završene',
      'ordersCancelled': 'Otkazane',
      'orderNumber': 'Narudžba #{number}',
      'orderDetails': 'Detalji narudžbe',
      'orderStatus': 'Status',
      'orderDate': 'Datum',
      'orderTime': 'Vrijeme',
      'orderDuration': 'Trajanje',
      'orderServices': 'Usluge',
      'orderNotes': 'Napomena',
      'orderFrequency': 'Učestalost',
      'orderSenior': 'Senior',
      'orderStudent': 'Student',
      'assignStudent': 'Dodijeli studenta',
      'reassignStudent': 'Promijeni studenta',
      'noStudentAssigned': 'Nije dodijeljen student',
      'suggestedStudents': 'Predloženi studenti',
      'assignConfirm': 'Dodijeliti {student} na ovu narudžbu?',
      'assigned': 'Dodijeljeno',
      'noOrdersFound': 'Nema pronađenih narudžbi',
      'filterByStatus': 'Filtriraj po statusu',
      'filterByDate': 'Filtriraj po datumu',
      'filterByService': 'Filtriraj po usluzi',
      'searchOrders': 'Pretraži narudžbe...',

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
      'jobAssigned': 'Dodijeljen',
      'jobCompleted': 'Završen',
      'jobUpcoming': 'Predstojeći',
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
      'studentIdNumber': 'Broj iskaznice',
      'studentRating': 'Prosječna ocjena',
      'studentTotalJobs': 'Ukupno poslova',
      'studentCompletedJobs': 'Završenih',
      'studentCancelledJobs': 'Otkazanih',
      'studentAvailability': 'Dostupnost',
      'workSummary': 'Obračun',
      'workTotalHours': 'Ukupno sati',
      'workRegularHours': 'Redovni sati',
      'workSundayHours': 'Prekovremeni',
      'workHourlyRate': 'Satnica',
      'workSundayRate': 'Nedjeljna satnica',
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
      'contractDeactivated': 'Deaktiviran',
      'uploadContract': 'Učitaj ugovor',
      'contractValidUntil': 'Vrijedi do: {date}',
      'contractExpires': 'Ističe: {date}',
      'renewContract': 'Obnovi ugovor',
      'verifiedStudent': 'Verificiran',
      'unverifiedStudent': 'Neverificiran',
      'studentDeactivated': 'Deaktiviran',
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
      'filterByRating': 'Minimalna ocjena',
      'filterByGender': 'Spol',
      'filterBySenior': 'Radio/la kod seniora',
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
      'filterAll': 'Svi',
      'filterProcessing': 'U obradi',
      'filterActive': 'Aktivni',
      'filterInactive': 'Neaktivni',
      'filterArchived': 'Arhivirani',
      'statusArchived': 'Arhiviran',
      'adminActions': 'Admin akcije',
      'assignToOrder': 'Dodijeli narudžbu',
      'matchingOrders': 'Nalozi koje može pokriti',
      'noMatchingOrders': 'Nema naloga koji odgovaraju dostupnosti.',
      'assignSuccess': 'Student dodijeljen na nalog',
      'hours': 'h',

      // ── Session Preview (assign flow) ────────
      'sessionPreviewTitle': 'Pregled sesija',
      'sessionPreviewWeeks': 'Sljedećih 8 tjedana',
      'sessionFree': 'Slobodan',
      'sessionConflict': 'Zauzet',
      'sessionSkipped': 'Preskočeno',
      'sessionRescheduled': 'Pomaknut termin',
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
      'serviceWalk': 'Šetnja',
      'serviceEscort': 'Pratnja',
      'serviceOther': 'Ostalo',

      // ── Ponavljanje ──────────────────────────
      'oneTime': 'Jednom',
      'recurring': 'Ponavljajuće',
      'recurringWithEnd': 'Do {date}',

      // ── Termini ──────────────────────────────────
      'sessionsTitle': 'Termini',
      'sessionsMonthlySubtitle': 'Prikazani termini za tekući mjesec.',
      'sessionStatusUpcoming': 'Nadolazeći',
      'sessionStatusCompleted': 'Obavljen',
      'sessionStatusCancelled': 'Otkazan',
      'sessionCancel': 'Otkaži termin',
      'sessionReschedule': 'Promijeni termin',
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
      'availableAllDays': 'Dostupan sve dane',
      'availablePartial': 'Dostupan {matched}/{total} dana',
      'availableDifferentTimes': 'Dostupan, drugi termini',
      'notAvailableForOrder': 'Nedostupan za ovu narudžbu',
      'reviewSessions': 'Pregled termina',
      'timeMismatch': 'Razlika u satima',
      'sessionReactivate': 'Vrati termin',
      'sessionReactivateConfirm':
          'Želite li vratiti ovaj termin kao nadolazeći?',

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
      'markAllRead': 'Označi sve kao pročitano',
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
    },

    'en': {
      // ── App ───────────────────────────────────
      'appName': 'Helpi Admin',
      'appTagline': 'Platform management',

      // ── Navigacija ────────────────────────────
      'navDashboard': 'Dashboard',
      'navOrders': 'Orders',
      'navStudents': 'Students',
      'navSeniors': 'Seniors',
      'navChat': 'Messages',
      'navSettings': 'Language',

      // ── Dashboard ─────────────────────────────
      'dashboardTitle': 'Dashboard',
      'totalOrders': 'Total orders',
      'processingOrders': 'Orders in processing',
      'activeOrders': 'Active',
      'completedOrders': 'Completed',
      'totalStudents': 'Students',
      'activeStudents': 'Active students',
      'totalSeniors': 'Seniors',
      'recentOrders': 'Recent orders',
      'todaysSessions': "Today's sessions",
      'expiringContracts': 'Expiring contracts',
      'activeStudentsThisMonth': 'Active students this month',
      'sessionsCount': 'sessions',
      'hoursCount': 'hours',
      'viewAll': 'View all',
      'noData': 'No data',

      // ── Narudžbe ──────────────────────────────
      'ordersTitle': 'Orders',
      'allOrders': 'All',
      'ordersProcessing': 'Processing',
      'ordersActive': 'Active',
      'ordersCompleted': 'Completed',
      'ordersCancelled': 'Cancelled',
      'orderNumber': 'Order #{number}',
      'orderDetails': 'Order details',
      'orderStatus': 'Status',
      'orderDate': 'Date',
      'orderTime': 'Time',
      'orderDuration': 'Duration',
      'orderServices': 'Services',
      'orderNotes': 'Note',
      'orderFrequency': 'Frequency',
      'orderSenior': 'Senior',
      'orderStudent': 'Student',
      'assignStudent': 'Assign student',
      'reassignStudent': 'Reassign student',
      'noStudentAssigned': 'No student assigned',
      'suggestedStudents': 'Suggested students',
      'assignConfirm': 'Assign {student} to this order?',
      'assigned': 'Assigned',
      'noOrdersFound': 'No orders found',
      'filterByStatus': 'Filter by status',
      'filterByDate': 'Filter by date',
      'filterByService': 'Filter by service',
      'searchOrders': 'Search orders...',

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
      'jobAssigned': 'Assigned',
      'jobCompleted': 'Completed',
      'jobUpcoming': 'Upcoming',
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
      'studentIdNumber': 'Student ID',
      'studentRating': 'Average rating',
      'studentTotalJobs': 'Total jobs',
      'studentCompletedJobs': 'Completed',
      'studentCancelledJobs': 'Cancelled',
      'studentAvailability': 'Availability',
      'workSummary': 'Payout',
      'workTotalHours': 'Total hours',
      'workRegularHours': 'Regular hours',
      'workSundayHours': 'Overtime',
      'workHourlyRate': 'Hourly rate',
      'workSundayRate': 'Sunday rate',
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
      'contractDeactivated': 'Deactivated',
      'uploadContract': 'Upload contract',
      'contractValidUntil': 'Valid until: {date}',
      'contractExpires': 'Expires: {date}',
      'renewContract': 'Renew contract',
      'verifiedStudent': 'Verified',
      'unverifiedStudent': 'Unverified',
      'studentDeactivated': 'Deactivated',
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
      'filterByRating': 'Minimum rating',
      'filterByGender': 'Gender',
      'filterBySenior': 'Worked with senior',
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
      'filterAll': 'All',
      'filterProcessing': 'Processing',
      'filterActive': 'Active',
      'filterInactive': 'Inactive',
      'filterArchived': 'Archived',
      'statusArchived': 'Archived',
      'adminActions': 'Admin actions',
      'assignToOrder': 'Assign order',
      'matchingOrders': 'Matching orders',
      'noMatchingOrders': 'No orders match this student\'s availability.',
      'assignSuccess': 'Student assigned to order',
      'hours': 'h',

      // ── Session Preview (assign flow) ────────
      'sessionPreviewTitle': 'Session preview',
      'sessionPreviewWeeks': 'Next 8 weeks',
      'sessionFree': 'Available',
      'sessionConflict': 'Busy',
      'sessionSkipped': 'Skipped',
      'sessionRescheduled': 'Rescheduled',
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
      'serviceWalk': 'Walk',
      'serviceEscort': 'Escort',
      'serviceOther': 'Other',

      // ── Ponavljanje ──────────────────────────
      'oneTime': 'Once',
      'recurring': 'Recurring',
      'recurringWithEnd': 'Until {date}',

      // ── Termini ──────────────────────────────────
      'sessionsTitle': 'Sessions',
      'sessionsMonthlySubtitle': 'Sessions for the current month.',
      'sessionStatusUpcoming': 'Upcoming',
      'sessionStatusCompleted': 'Completed',
      'sessionStatusCancelled': 'Cancelled',
      'sessionCancel': 'Cancel session',
      'sessionReschedule': 'Reschedule',
      'sessionSelectStudent': 'Select student',
      'sessionNewDate': 'New date',
      'sessionNewTime': 'New time',
      'sessionCancelConfirm': 'Are you sure you want to cancel this session?',
      'sessionRescheduleTitle': 'Reschedule session',
      'sessionNoStudentAssigned': 'Not assigned',
      'sessionKeepCurrentStudent': 'Keep current',
      'noStudentsForSlot': 'No students available for selected time slot',
      'availableAllDays': 'Available all days',
      'availablePartial': 'Available {matched}/{total} days',
      'availableDifferentTimes': 'Available, different schedule',
      'notAvailableForOrder': 'Not available for this order',
      'reviewSessions': 'Review sessions',
      'timeMismatch': 'Time mismatch',
      'selectTime': 'Select time',
      'sessionReactivate': 'Restore session',
      'sessionReactivateConfirm':
          'Do you want to restore this session as upcoming?',

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
      'markAllRead': 'Mark all as read',
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
  static String get navOrders => _t('navOrders');
  static String get navStudents => _t('navStudents');
  static String get navSeniors => _t('navSeniors');
  static String get navChat => _t('navChat');
  static String get navSettings => _t('navSettings');

  // ── Dashboard ──
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

  // ── Narudžbe ──
  static String get ordersTitle => _t('ordersTitle');
  static String get allOrders => _t('allOrders');
  static String get ordersProcessing => _t('ordersProcessing');
  static String get ordersActive => _t('ordersActive');
  static String get ordersCompleted => _t('ordersCompleted');
  static String get ordersCancelled => _t('ordersCancelled');
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
  static String get orderSenior => _t('orderSenior');
  static String get orderStudent => _t('orderStudent');
  static String get assignStudent => _t('assignStudent');
  static String get reassignStudent => _t('reassignStudent');
  static String get noStudentAssigned => _t('noStudentAssigned');
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
  static String get jobAssigned => _t('jobAssigned');
  static String get jobCompleted => _t('jobCompleted');
  static String get jobUpcoming => _t('jobUpcoming');
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
  static String get studentIdNumber => _t('studentIdNumber');
  static String get studentRating => _t('studentRating');
  static String get studentTotalJobs => _t('studentTotalJobs');
  static String get studentCompletedJobs => _t('studentCompletedJobs');
  static String get studentCancelledJobs => _t('studentCancelledJobs');
  static String get studentAvailability => _t('studentAvailability');
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
  static String get contractDeactivated => _t('contractDeactivated');
  static String get uploadContract => _t('uploadContract');
  static String contractValidUntil(String date) =>
      _t('contractValidUntil', params: {'date': date});
  static String contractExpires(String date) =>
      _t('contractExpires', params: {'date': date});
  static String get renewContract => _t('renewContract');
  static String get verifiedStudent => _t('verifiedStudent');
  static String get unverifiedStudent => _t('unverifiedStudent');
  static String get studentDeactivated => _t('studentDeactivated');
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
  static String get filterAll => _t('filterAll');
  static String get filterProcessing => _t('filterProcessing');
  static String get filterActive => _t('filterActive');
  static String get filterInactive => _t('filterInactive');
  static String get filterArchived => _t('filterArchived');
  static String get statusArchived => _t('statusArchived');
  static String get adminActions => _t('adminActions');
  static String get assignToOrder => _t('assignToOrder');
  static String get matchingOrders => _t('matchingOrders');
  static String get noMatchingOrders => _t('noMatchingOrders');
  static String get assignSuccess => _t('assignSuccess');
  static String get hours => _t('hours');

  // ── Session Preview ──
  static String get sessionPreviewTitle => _t('sessionPreviewTitle');
  static String get sessionPreviewWeeks => _t('sessionPreviewWeeks');
  static String get sessionFree => _t('sessionFree');
  static String get sessionConflict => _t('sessionConflict');
  static String get sessionSkipped => _t('sessionSkipped');
  static String get sessionRescheduled => _t('sessionRescheduled');
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
  static String get filterByRating => _t('filterByRating');
  static String get filterByGender => _t('filterByGender');
  static String get filterBySenior => _t('filterBySenior');
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
  static String filterResultCount(int count) =>
      _t('filterResultCount', params: {'count': '$count'});
  static String seniorResultCount(int count) =>
      _t('seniorResultCount', params: {'count': '$count'});
  static String orderResultCount(int count) =>
      _t('orderResultCount', params: {'count': '$count'});
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
  static String get serviceWalk => _t('serviceWalk');
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
  static String get sessionStatusUpcoming => _t('sessionStatusUpcoming');
  static String get sessionStatusCompleted => _t('sessionStatusCompleted');
  static String get sessionStatusCancelled => _t('sessionStatusCancelled');
  static String get sessionCancel => _t('sessionCancel');
  static String get sessionReschedule => _t('sessionReschedule');
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
  static String get sessionReactivate => _t('sessionReactivate');
  static String get sessionReactivateConfirm => _t('sessionReactivateConfirm');
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
  static String availablePartial(int matched, int total) => _t(
    'availablePartial',
    params: {'matched': matched.toString(), 'total': total.toString()},
  );
  static String get availableDifferentTimes => _t('availableDifferentTimes');
  static String get notAvailableForOrder => _t('notAvailableForOrder');
  static String get reviewSessions => _t('reviewSessions');
  static String get timeMismatch => _t('timeMismatch');
}
