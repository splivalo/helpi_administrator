import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
//  ENUMS
// ═══════════════════════════════════════════════════════════════

enum OrderStatus { processing, active, completed, cancelled }

enum JobStatus { assigned, upcoming, completed, cancelled }

enum ServiceType { shopping, houseHelp, companionship, walk, escort, other }

enum FrequencyType { oneTime, recurring, recurringWithEnd }

enum ContractStatus { active, expired, expiring, none, deactivated }

enum Gender { male, female }

// ═══════════════════════════════════════════════════════════════
//  MODELS
// ═══════════════════════════════════════════════════════════════

class SeniorModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final bool isActive;
  final DateTime createdAt;
  final String? ordererFirstName;
  final String? ordererLastName;
  final String? ordererPhone;

  const SeniorModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    this.isActive = true,
    required this.createdAt,
    this.ordererFirstName,
    this.ordererLastName,
    this.ordererPhone,
  });

  String get fullName => '$firstName $lastName';
  bool get hasOrderer => ordererFirstName != null;
  String get ordererFullName =>
      hasOrderer ? '$ordererFirstName $ordererLastName' : '';
}

class StudentModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String bio;
  final DateTime dateOfBirth;
  final Gender gender;
  final double avgRating;
  final int totalReviews;
  final int completedJobs;
  final int cancelledJobs;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final ContractStatus contractStatus;
  final DateTime? contractStartDate;
  final DateTime? contractExpiryDate;
  final List<DayAvailability> availability;
  final double hourlyRate;
  final double sundayHourlyRate;

  const StudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.bio,
    required this.dateOfBirth,
    required this.gender,
    this.avgRating = 0.0,
    this.totalReviews = 0,
    this.completedJobs = 0,
    this.cancelledJobs = 0,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    this.contractStatus = ContractStatus.none,
    this.contractStartDate,
    this.contractExpiryDate,
    this.availability = const [],
    this.hourlyRate = 7.40,
    this.sundayHourlyRate = 11.10,
  });

  String get fullName => '$firstName $lastName';
  int get totalJobs => completedJobs + cancelledJobs;
}

class DayAvailability {
  final int dayOfWeek; // 1=Mon, 7=Sun
  final bool isEnabled;
  final TimeOfDay from;
  final TimeOfDay to;

  const DayAvailability({
    required this.dayOfWeek,
    this.isEnabled = false,
    this.from = const TimeOfDay(hour: 8, minute: 0),
    this.to = const TimeOfDay(hour: 16, minute: 0),
  });
}

class OrderModel {
  final String id;
  final String orderNumber;
  final SeniorModel senior;
  final StudentModel? student;
  final OrderStatus status;
  final FrequencyType frequency;
  final List<ServiceType> services;
  final DateTime createdAt;
  final DateTime scheduledDate;
  final TimeOfDay scheduledStart;
  final int durationHours;
  final String? notes;
  final String address;
  final DateTime? endDate;
  final List<DayEntry> dayEntries;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.senior,
    this.student,
    required this.status,
    required this.frequency,
    required this.services,
    required this.createdAt,
    required this.scheduledDate,
    required this.scheduledStart,
    required this.durationHours,
    this.notes,
    required this.address,
    this.endDate,
    this.dayEntries = const [],
  });
}

class DayEntry {
  final int dayOfWeek;
  final TimeOfDay startTime;
  final int durationHours;

  const DayEntry({
    required this.dayOfWeek,
    required this.startTime,
    required this.durationHours,
  });
}

class ReviewModel {
  final String id;
  final String seniorName;
  final String studentName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.seniorName,
    required this.studentName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });
}

class ChatRoom {
  final String id;
  final String participantName;
  final String participantRole; // 'senior' or 'student'
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final String? orderId;
  final List<ChatMessage> messages;

  const ChatRoom({
    required this.id,
    required this.participantName,
    required this.participantRole,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
    this.orderId,
    this.messages = const [],
  });

  bool get isSenior => participantRole == 'senior';
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole; // 'senior', 'student', 'admin'
  final String content;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.sentAt,
  });

  /// Convenience alias for content.
  String get text => content;

  /// Whether this message was sent by admin.
  bool get isAdmin => senderRole == 'admin';
}

// ═══════════════════════════════════════════════════════════════
//  MOCK DATA
// ═══════════════════════════════════════════════════════════════

class MockData {
  MockData._();

  // ── Seniori ──
  static final List<SeniorModel> seniors = [
    SeniorModel(
      id: 's1',
      firstName: 'Ivka',
      lastName: 'Mandić',
      email: 'ivka.mandic@email.com',
      phone: '+385 91 234 5678',
      address: 'Ilica 45, Zagreb',
      createdAt: DateTime(2026, 1, 15),
    ),
    SeniorModel(
      id: 's2',
      firstName: 'Marija',
      lastName: 'Horvat',
      email: 'marija.horvat@email.com',
      phone: '+385 92 345 6789',
      address: 'Vukovarska 12, Zagreb',
      createdAt: DateTime(2026, 1, 20),
      ordererFirstName: 'Ana',
      ordererLastName: 'Horvat',
      ordererPhone: '+385 98 765 4321',
    ),
    SeniorModel(
      id: 's3',
      firstName: 'Josip',
      lastName: 'Kovačević',
      email: 'josip.kovacevic@email.com',
      phone: '+385 91 456 7890',
      address: 'Maksimirska 100, Zagreb',
      createdAt: DateTime(2026, 2, 1),
    ),
    SeniorModel(
      id: 's4',
      firstName: 'Kata',
      lastName: 'Babić',
      email: 'kata.babic@email.com',
      phone: '+385 92 567 8901',
      address: 'Savska 25, Zagreb',
      createdAt: DateTime(2026, 2, 10),
    ),
    SeniorModel(
      id: 's5',
      firstName: 'Franjo',
      lastName: 'Jurić',
      email: 'franjo.juric@email.com',
      phone: '+385 91 678 9012',
      address: 'Heinzelova 8, Zagreb',
      isActive: false,
      createdAt: DateTime(2025, 12, 5),
    ),
  ];

  // ── Studenti ──
  static final List<StudentModel> students = [
    StudentModel(
      id: 'st1',
      firstName: 'Luka',
      lastName: 'Perić',
      email: 'luka.peric@email.com',
      phone: '+385 99 111 2222',
      address: 'Trg bana Jelačića 1, Zagreb',
      bio: 'Student medicine, 3. godina. Volim pomagati starijima.',
      dateOfBirth: DateTime(2002, 5, 14),
      gender: Gender.male,
      avgRating: 4.8,
      totalReviews: 12,
      completedJobs: 24,
      cancelledJobs: 1,
      isVerified: true,
      contractStatus: ContractStatus.active,
      contractStartDate: DateTime(2026, 3, 1),
      contractExpiryDate: DateTime(2026, 3, 31),
      createdAt: DateTime(2025, 11, 1),
      availability: const [
        DayAvailability(
          dayOfWeek: 1,
          isEnabled: true,
          from: TimeOfDay(hour: 9, minute: 0),
          to: TimeOfDay(hour: 15, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 2,
          isEnabled: true,
          from: TimeOfDay(hour: 9, minute: 0),
          to: TimeOfDay(hour: 15, minute: 0),
        ),
        DayAvailability(dayOfWeek: 3, isEnabled: false),
        DayAvailability(
          dayOfWeek: 4,
          isEnabled: true,
          from: TimeOfDay(hour: 10, minute: 0),
          to: TimeOfDay(hour: 16, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 5,
          isEnabled: true,
          from: TimeOfDay(hour: 9, minute: 0),
          to: TimeOfDay(hour: 13, minute: 0),
        ),
        DayAvailability(dayOfWeek: 6, isEnabled: false),
        DayAvailability(dayOfWeek: 7, isEnabled: false),
      ],
    ),
    StudentModel(
      id: 'st2',
      firstName: 'Ana',
      lastName: 'Matić',
      email: 'ana.matic@email.com',
      phone: '+385 99 333 4444',
      address: 'Ozaljska 55, Zagreb',
      bio: 'Studentica socijalnog rada. Iskustvo u radu sa starijima.',
      dateOfBirth: DateTime(2003, 8, 22),
      gender: Gender.female,
      avgRating: 4.6,
      totalReviews: 8,
      completedJobs: 16,
      cancelledJobs: 0,
      isVerified: true,
      contractStatus: ContractStatus.expiring,
      contractStartDate: DateTime(2026, 2, 15),
      contractExpiryDate: DateTime(2026, 3, 5),
      createdAt: DateTime(2025, 12, 15),
      availability: const [
        DayAvailability(
          dayOfWeek: 1,
          isEnabled: true,
          from: TimeOfDay(hour: 8, minute: 0),
          to: TimeOfDay(hour: 14, minute: 0),
        ),
        DayAvailability(dayOfWeek: 2, isEnabled: false),
        DayAvailability(
          dayOfWeek: 3,
          isEnabled: true,
          from: TimeOfDay(hour: 8, minute: 0),
          to: TimeOfDay(hour: 14, minute: 0),
        ),
        DayAvailability(dayOfWeek: 4, isEnabled: false),
        DayAvailability(
          dayOfWeek: 5,
          isEnabled: true,
          from: TimeOfDay(hour: 8, minute: 0),
          to: TimeOfDay(hour: 12, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 6,
          isEnabled: true,
          from: TimeOfDay(hour: 10, minute: 0),
          to: TimeOfDay(hour: 16, minute: 0),
        ),
        DayAvailability(dayOfWeek: 7, isEnabled: false),
      ],
    ),
    StudentModel(
      id: 'st3',
      firstName: 'Ivan',
      lastName: 'Šimić',
      email: 'ivan.simic@email.com',
      phone: '+385 99 555 6666',
      address: 'Dubrava 120, Zagreb',
      bio: 'Student ekonomije. Dostupan vikendom i popodne.',
      dateOfBirth: DateTime(2001, 11, 3),
      gender: Gender.male,
      avgRating: 4.2,
      totalReviews: 5,
      completedJobs: 10,
      cancelledJobs: 2,
      isVerified: true,
      contractStatus: ContractStatus.expired,
      contractStartDate: DateTime(2026, 2, 1),
      contractExpiryDate: DateTime(2026, 2, 28),
      createdAt: DateTime(2026, 1, 10),
      availability: const [
        DayAvailability(dayOfWeek: 1, isEnabled: false),
        DayAvailability(dayOfWeek: 2, isEnabled: false),
        DayAvailability(
          dayOfWeek: 3,
          isEnabled: true,
          from: TimeOfDay(hour: 14, minute: 0),
          to: TimeOfDay(hour: 20, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 4,
          isEnabled: true,
          from: TimeOfDay(hour: 14, minute: 0),
          to: TimeOfDay(hour: 20, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 5,
          isEnabled: true,
          from: TimeOfDay(hour: 14, minute: 0),
          to: TimeOfDay(hour: 20, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 6,
          isEnabled: true,
          from: TimeOfDay(hour: 9, minute: 0),
          to: TimeOfDay(hour: 18, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 7,
          isEnabled: true,
          from: TimeOfDay(hour: 9, minute: 0),
          to: TimeOfDay(hour: 18, minute: 0),
        ),
      ],
    ),
    StudentModel(
      id: 'st4',
      firstName: 'Petra',
      lastName: 'Novak',
      email: 'petra.novak@email.com',
      phone: '+385 99 777 8888',
      address: 'Črnomerec 30, Zagreb',
      bio: 'Studentica psihologije. Strpljiva i empatična.',
      dateOfBirth: DateTime(2004, 2, 10),
      gender: Gender.female,
      avgRating: 5.0,
      totalReviews: 3,
      completedJobs: 6,
      cancelledJobs: 0,
      isVerified: false,
      contractStatus: ContractStatus.none,
      createdAt: DateTime(2026, 2, 20),
      availability: const [
        DayAvailability(
          dayOfWeek: 1,
          isEnabled: true,
          from: TimeOfDay(hour: 10, minute: 0),
          to: TimeOfDay(hour: 16, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 2,
          isEnabled: true,
          from: TimeOfDay(hour: 10, minute: 0),
          to: TimeOfDay(hour: 16, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 3,
          isEnabled: true,
          from: TimeOfDay(hour: 10, minute: 0),
          to: TimeOfDay(hour: 16, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 4,
          isEnabled: true,
          from: TimeOfDay(hour: 10, minute: 0),
          to: TimeOfDay(hour: 16, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 5,
          isEnabled: true,
          from: TimeOfDay(hour: 10, minute: 0),
          to: TimeOfDay(hour: 16, minute: 0),
        ),
        DayAvailability(dayOfWeek: 6, isEnabled: false),
        DayAvailability(dayOfWeek: 7, isEnabled: false),
      ],
    ),
  ];

  // ── Narudžbe ──
  static final List<OrderModel> orders = [
    OrderModel(
      id: 'o1',
      orderNumber: '001',
      senior: seniors[0],
      student: null,
      status: OrderStatus.processing,
      frequency: FrequencyType.oneTime,
      services: [ServiceType.shopping],
      createdAt: DateTime(2026, 3, 1, 10, 30),
      scheduledDate: DateTime(2026, 3, 5),
      scheduledStart: const TimeOfDay(hour: 10, minute: 0),
      durationHours: 2,
      notes: 'Mlijeko i kruh iz Konzuma, lijekove iz ljekarne.',
      address: 'Ilica 45, Zagreb',
    ),
    OrderModel(
      id: 'o2',
      orderNumber: '002',
      senior: seniors[1],
      student: null,
      status: OrderStatus.processing,
      frequency: FrequencyType.recurring,
      services: [ServiceType.houseHelp, ServiceType.companionship],
      createdAt: DateTime(2026, 3, 1, 14, 0),
      scheduledDate: DateTime(2026, 3, 3),
      scheduledStart: const TimeOfDay(hour: 9, minute: 0),
      durationHours: 3,
      notes: 'Pomoć s čišćenjem i druženje.',
      address: 'Vukovarska 12, Zagreb',
      dayEntries: [
        const DayEntry(
          dayOfWeek: 1,
          startTime: TimeOfDay(hour: 9, minute: 0),
          durationHours: 3,
        ),
        const DayEntry(
          dayOfWeek: 4,
          startTime: TimeOfDay(hour: 9, minute: 0),
          durationHours: 3,
        ),
      ],
    ),
    OrderModel(
      id: 'o3',
      orderNumber: '003',
      senior: seniors[2],
      student: students[0],
      status: OrderStatus.active,
      frequency: FrequencyType.recurring,
      services: [ServiceType.walk, ServiceType.companionship],
      createdAt: DateTime(2026, 2, 20, 9, 0),
      scheduledDate: DateTime(2026, 2, 24),
      scheduledStart: const TimeOfDay(hour: 10, minute: 0),
      durationHours: 2,
      address: 'Maksimirska 100, Zagreb',
      dayEntries: [
        const DayEntry(
          dayOfWeek: 1,
          startTime: TimeOfDay(hour: 10, minute: 0),
          durationHours: 2,
        ),
        const DayEntry(
          dayOfWeek: 3,
          startTime: TimeOfDay(hour: 10, minute: 0),
          durationHours: 2,
        ),
        const DayEntry(
          dayOfWeek: 5,
          startTime: TimeOfDay(hour: 10, minute: 0),
          durationHours: 2,
        ),
        const DayEntry(
          dayOfWeek: 7,
          startTime: TimeOfDay(hour: 10, minute: 0),
          durationHours: 2,
        ),
      ],
    ),
    OrderModel(
      id: 'o8',
      orderNumber: '008',
      senior: seniors[0],
      student: students[0],
      status: OrderStatus.completed,
      frequency: FrequencyType.oneTime,
      services: [ServiceType.shopping],
      createdAt: DateTime(2026, 3, 2, 9, 0),
      scheduledDate: DateTime(2026, 3, 2),
      scheduledStart: const TimeOfDay(hour: 10, minute: 0),
      durationHours: 2,
      address: 'Ilica 45, Zagreb',
    ),
    OrderModel(
      id: 'o9',
      orderNumber: '009',
      senior: seniors[2],
      student: students[0],
      status: OrderStatus.cancelled,
      frequency: FrequencyType.oneTime,
      services: [ServiceType.walk],
      createdAt: DateTime(2026, 3, 1, 8, 0),
      scheduledDate: DateTime(2026, 3, 3),
      scheduledStart: const TimeOfDay(hour: 14, minute: 0),
      durationHours: 1,
      address: 'Maksimirska 100, Zagreb',
    ),
    OrderModel(
      id: 'o4',
      orderNumber: '004',
      senior: seniors[3],
      student: students[1],
      status: OrderStatus.active,
      frequency: FrequencyType.recurringWithEnd,
      services: [ServiceType.escort],
      createdAt: DateTime(2026, 2, 15, 11, 30),
      scheduledDate: DateTime(2026, 2, 18),
      scheduledStart: const TimeOfDay(hour: 8, minute: 30),
      durationHours: 4,
      notes: 'Pratnja do liječnika svaki utorak.',
      address: 'Savska 25, Zagreb',
      endDate: DateTime(2026, 4, 30),
      dayEntries: [
        const DayEntry(
          dayOfWeek: 2,
          startTime: TimeOfDay(hour: 8, minute: 30),
          durationHours: 4,
        ),
      ],
    ),
    OrderModel(
      id: 'o5',
      orderNumber: '005',
      senior: seniors[0],
      student: students[2],
      status: OrderStatus.completed,
      frequency: FrequencyType.oneTime,
      services: [ServiceType.shopping, ServiceType.houseHelp],
      createdAt: DateTime(2026, 2, 1, 8, 0),
      scheduledDate: DateTime(2026, 2, 5),
      scheduledStart: const TimeOfDay(hour: 9, minute: 0),
      durationHours: 3,
      address: 'Ilica 45, Zagreb',
    ),
    OrderModel(
      id: 'o6',
      orderNumber: '006',
      senior: seniors[1],
      student: students[0],
      status: OrderStatus.completed,
      frequency: FrequencyType.oneTime,
      services: [ServiceType.companionship],
      createdAt: DateTime(2026, 1, 25, 15, 0),
      scheduledDate: DateTime(2026, 1, 28),
      scheduledStart: const TimeOfDay(hour: 14, minute: 0),
      durationHours: 2,
      address: 'Vukovarska 12, Zagreb',
    ),
    OrderModel(
      id: 'o7',
      orderNumber: '007',
      senior: seniors[3],
      student: null,
      status: OrderStatus.cancelled,
      frequency: FrequencyType.oneTime,
      services: [ServiceType.walk],
      createdAt: DateTime(2026, 2, 10, 12, 0),
      scheduledDate: DateTime(2026, 2, 14),
      scheduledStart: const TimeOfDay(hour: 16, minute: 0),
      durationHours: 1,
      address: 'Savska 25, Zagreb',
    ),
  ];

  // ── Chat sobe ──
  static final List<ChatRoom> chatRooms = [
    ChatRoom(
      id: 'cr1',
      participantName: 'Ivka Mandić',
      participantRole: 'senior',
      lastMessage: 'Hvala na pomoći!',
      lastMessageAt: DateTime(2026, 3, 1, 16, 30),
      unreadCount: 2,
      orderId: 'o1',
      messages: [
        ChatMessage(
          id: 'm1',
          senderId: 's1',
          senderName: 'Ivka Mandić',
          senderRole: 'senior',
          content: 'Dobar dan, trebam pomoć s kupovinom.',
          sentAt: DateTime(2026, 3, 1, 15, 0),
        ),
        ChatMessage(
          id: 'm2',
          senderId: 'admin',
          senderName: 'Admin',
          senderRole: 'admin',
          content: 'Naravno, pronašli smo studenta za vas.',
          sentAt: DateTime(2026, 3, 1, 15, 30),
        ),
        ChatMessage(
          id: 'm3',
          senderId: 's1',
          senderName: 'Ivka Mandić',
          senderRole: 'senior',
          content: 'Hvala na pomoći!',
          sentAt: DateTime(2026, 3, 1, 16, 30),
        ),
      ],
    ),
    ChatRoom(
      id: 'cr2',
      participantName: 'Luka Perić',
      participantRole: 'student',
      lastMessage: 'Sutra sam dostupan od 9.',
      lastMessageAt: DateTime(2026, 3, 1, 14, 15),
      unreadCount: 0,
      messages: [
        ChatMessage(
          id: 'm4',
          senderId: 'admin',
          senderName: 'Admin',
          senderRole: 'admin',
          content: 'Luka, jesi li dostupan sutra?',
          sentAt: DateTime(2026, 3, 1, 14, 0),
        ),
        ChatMessage(
          id: 'm5',
          senderId: 'st1',
          senderName: 'Luka Perić',
          senderRole: 'student',
          content: 'Sutra sam dostupan od 9.',
          sentAt: DateTime(2026, 3, 1, 14, 15),
        ),
      ],
    ),
    ChatRoom(
      id: 'cr3',
      participantName: 'Marija Horvat',
      participantRole: 'senior',
      lastMessage: 'Trebam pomoć s narudžbom.',
      lastMessageAt: DateTime(2026, 2, 28, 10, 0),
      unreadCount: 1,
      orderId: 'o2',
      messages: [
        ChatMessage(
          id: 'm6',
          senderId: 's2',
          senderName: 'Marija Horvat',
          senderRole: 'senior',
          content: 'Trebam pomoć s narudžbom.',
          sentAt: DateTime(2026, 2, 28, 10, 0),
        ),
      ],
    ),
    ChatRoom(
      id: 'cr4',
      participantName: 'Ana Matić',
      participantRole: 'student',
      lastMessage: 'Možete li me prebaciti na drugi termin?',
      lastMessageAt: DateTime(2026, 2, 27, 18, 45),
      unreadCount: 0,
      messages: [
        ChatMessage(
          id: 'm7',
          senderId: 'st2',
          senderName: 'Ana Matić',
          senderRole: 'student',
          content: 'Možete li me prebaciti na drugi termin?',
          sentAt: DateTime(2026, 2, 27, 18, 45),
        ),
        ChatMessage(
          id: 'm8',
          senderId: 'admin',
          senderName: 'Admin',
          senderRole: 'admin',
          content: 'Naravno, javit ćemo vam novi termin.',
          sentAt: DateTime(2026, 2, 27, 19, 0),
        ),
      ],
    ),
  ];

  // ── Recenzije ──
  static final List<ReviewModel> reviews = [
    ReviewModel(
      id: 'r1',
      seniorName: 'Ivka Mandić',
      studentName: 'Luka Perić',
      rating: 5,
      comment: 'Odličan dečko, vrlo pažljiv i pouzdan.',
      createdAt: DateTime(2026, 2, 28),
    ),
    ReviewModel(
      id: 'r2',
      seniorName: 'Marija Horvat',
      studentName: 'Luka Perić',
      rating: 5,
      comment: 'Uvijek na vrijeme i veoma ljubazan.',
      createdAt: DateTime(2026, 2, 20),
    ),
    ReviewModel(
      id: 'r3',
      seniorName: 'Josip Kovačević',
      studentName: 'Ana Matić',
      rating: 4,
      comment: 'Vrlo uredna i temeljita.',
      createdAt: DateTime(2026, 2, 15),
    ),
    ReviewModel(
      id: 'r4',
      seniorName: 'Kata Babić',
      studentName: 'Ivan Šimić',
      rating: 4,
      comment: 'Dobar, ali malo kasni.',
      createdAt: DateTime(2026, 2, 10),
    ),
    ReviewModel(
      id: 'r5',
      seniorName: 'Ivka Mandić',
      studentName: 'Ivan Šimić',
      rating: 3,
      comment: null,
      createdAt: DateTime(2026, 2, 5),
    ),
  ];
}
