import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
//  ENUMS
// ═══════════════════════════════════════════════════════════════

enum OrderStatus { processing, active, completed, cancelled, archived }

enum JobStatus { scheduled, completed, cancelled }

enum ServiceType {
  shopping,
  houseHelp,
  companionship,
  walking,
  escort,
  other;

  /// Maps legacy/alias codes from backend to canonical enum values.
  static ServiceType fromCode(String code) => switch (code) {
    'shopping' => ServiceType.shopping,
    'house_help' || 'houseHelp' => ServiceType.houseHelp,
    'companionship' || 'socializing' => ServiceType.companionship,
    'walking' || 'walk' => ServiceType.walking,
    'escort' => ServiceType.escort,
    _ => ServiceType.other,
  };
}

enum FrequencyType { oneTime, recurring, recurringWithEnd }

enum ContractStatus { active, expired, expiring, none, deactivated }

enum SessionStatus { scheduled, completed, cancelled }

enum Gender { male, female }

enum NotificationType { newOrder, contractExpiring, sessionCancelled, info }

// ═══════════════════════════════════════════════════════════════
//  MODELS
// ═══════════════════════════════════════════════════════════════

enum CardBrand { visa, mastercard, maestro, amex, diners, unknown }

// ── Notification ──
class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });
}

class CreditCard {
  final String id;
  final String last4;
  final CardBrand brand;
  final String? holderName;
  final int expiryMonth;
  final int expiryYear;

  const CreditCard({
    required this.id,
    required this.last4,
    required this.brand,
    this.holderName,
    required this.expiryMonth,
    required this.expiryYear,
  });

  String get expiry => '${expiryMonth.toString().padLeft(2, '0')}/$expiryYear';

  bool get isExpired {
    final now = DateTime.now();
    return expiryYear < now.year ||
        (expiryYear == now.year && expiryMonth < now.month);
  }

  String get brandLabel => switch (brand) {
    CardBrand.visa => 'Visa',
    CardBrand.mastercard => 'Mastercard',
    CardBrand.maestro => 'Maestro',
    CardBrand.amex => 'Amex',
    CardBrand.diners => 'Diners',
    CardBrand.unknown => 'Kartica',
  };
}

class SeniorModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final Gender gender;
  final DateTime dateOfBirth;
  final bool isActive;
  final bool isArchived;
  final DateTime createdAt;
  final String? ordererFirstName;
  final String? ordererLastName;
  final String? ordererEmail;
  final String? ordererPhone;
  final String? ordererAddress;
  final Gender? ordererGender;
  final DateTime? ordererDateOfBirth;
  final List<CreditCard> creditCards;

  const SeniorModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
    required this.dateOfBirth,
    this.isActive = true,
    this.isArchived = false,
    required this.createdAt,
    this.ordererFirstName,
    this.ordererLastName,
    this.ordererEmail,
    this.ordererPhone,
    this.ordererAddress,
    this.ordererGender,
    this.ordererDateOfBirth,
    this.creditCards = const [],
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
  final String faculty;
  final String studentIdNumber;
  final DateTime dateOfBirth;
  final Gender gender;
  final double avgRating;
  final int totalReviews;
  final int completedJobs;
  final int cancelledJobs;
  final bool isVerified;
  final bool isActive;
  final bool isArchived;
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
    required this.faculty,
    required this.studentIdNumber,
    required this.dateOfBirth,
    required this.gender,
    this.avgRating = 0.0,
    this.totalReviews = 0,
    this.completedJobs = 0,
    this.cancelledJobs = 0,
    this.isVerified = false,
    this.isActive = true,
    this.isArchived = false,
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
  final List<SessionModel> sessions;

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
    this.sessions = const [],
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

class SessionModel {
  final String id;
  final String? orderId;
  final DateTime date;
  final int weekday;
  final TimeOfDay startTime;
  final int durationHours;
  final String? studentName;
  final SessionStatus status;
  final bool isModified;

  const SessionModel({
    required this.id,
    this.orderId,
    required this.date,
    required this.weekday,
    required this.startTime,
    required this.durationHours,
    this.studentName,
    this.status = SessionStatus.scheduled,
    this.isModified = false,
  });

  SessionModel copyWith({
    String? id,
    String? Function()? orderId,
    DateTime? date,
    int? weekday,
    TimeOfDay? startTime,
    int? durationHours,
    String? Function()? studentName,
    SessionStatus? status,
    bool? isModified,
  }) {
    return SessionModel(
      id: id ?? this.id,
      orderId: orderId != null ? orderId() : this.orderId,
      date: date ?? this.date,
      weekday: weekday ?? this.weekday,
      startTime: startTime ?? this.startTime,
      durationHours: durationHours ?? this.durationHours,
      studentName: studentName != null ? studentName() : this.studentName,
      status: status ?? this.status,
      isModified: isModified ?? this.isModified,
    );
  }
}

// ── Session Preview (for assign flow) ──

/// Conflict type for a generated session preview instance.
enum SessionConflictType { free, conflict }

/// A single generated session instance used in the assign preview flow.
/// Generated from a recurring order's dayEntries for the next N weeks.
class SessionInstancePreview {
  final DateTime date;
  final int weekday;
  final TimeOfDay startTime;
  final int durationHours;
  final SessionConflictType conflictType;
  final OrderModel? conflictingOrder;

  /// Whether admin chose to skip this conflicted session.
  bool isSkipped;

  /// Alternative start time chosen by admin (same day, different hour).
  TimeOfDay? rescheduledStart;

  /// Substitute student chosen by admin for this specific session.
  StudentModel? substituteStudent;

  SessionInstancePreview({
    required this.date,
    required this.weekday,
    required this.startTime,
    required this.durationHours,
    required this.conflictType,
    this.conflictingOrder,
    this.isSkipped = false,
    this.rescheduledStart,
    this.substituteStudent,
  });

  /// True if this session has an unresolved conflict.
  bool get hasUnresolvedConflict =>
      conflictType == SessionConflictType.conflict &&
      !isSkipped &&
      rescheduledStart == null &&
      substituteStudent == null;
}

class ReviewModel {
  final String id;
  final String? sessionId;
  final String? studentId;
  final String? seniorId;
  final String seniorName;
  final String studentName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    this.sessionId,
    this.studentId,
    this.seniorId,
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
      gender: Gender.female,
      dateOfBirth: DateTime(1948, 7, 22),
      createdAt: DateTime(2026, 1, 15),
      creditCards: [
        CreditCard(
          id: 'cc1',
          last4: '4532',
          brand: CardBrand.visa,
          holderName: 'IVKA MANDIC',
          expiryMonth: 9,
          expiryYear: 2028,
        ),
      ],
    ),
    SeniorModel(
      id: 's2',
      firstName: 'Marija',
      lastName: 'Horvat',
      email: 'marija.horvat@email.com',
      phone: '+385 92 345 6789',
      address: 'Vukovarska 12, Zagreb',
      gender: Gender.female,
      dateOfBirth: DateTime(1942, 11, 3),
      createdAt: DateTime(2026, 1, 20),
      ordererFirstName: 'Ana',
      ordererLastName: 'Horvat',
      ordererEmail: 'ana.horvat@email.com',
      ordererPhone: '+385 98 765 4321',
      ordererAddress: 'Vukovarska 12, Zagreb',
      ordererGender: Gender.female,
      ordererDateOfBirth: DateTime(1985, 3, 15),
      creditCards: [
        CreditCard(
          id: 'cc2',
          last4: '8821',
          brand: CardBrand.mastercard,
          holderName: 'ANA HORVAT',
          expiryMonth: 3,
          expiryYear: 2027,
        ),
        CreditCard(
          id: 'cc3',
          last4: '1190',
          brand: CardBrand.visa,
          holderName: 'MARIJA HORVAT',
          expiryMonth: 12,
          expiryYear: 2026,
        ),
      ],
    ),
    SeniorModel(
      id: 's3',
      firstName: 'Josip',
      lastName: 'Kovačević',
      email: 'josip.kovacevic@email.com',
      phone: '+385 91 456 7890',
      address: 'Maksimirska 100, Zagreb',
      gender: Gender.male,
      dateOfBirth: DateTime(1940, 5, 18),
      createdAt: DateTime(2026, 2, 1),
      creditCards: [
        CreditCard(
          id: 'cc4',
          last4: '7744',
          brand: CardBrand.maestro,
          holderName: 'JOSIP KOVACEVIC',
          expiryMonth: 6,
          expiryYear: 2027,
        ),
      ],
    ),
    SeniorModel(
      id: 's4',
      firstName: 'Kata',
      lastName: 'Babić',
      email: 'kata.babic@email.com',
      phone: '+385 92 567 8901',
      address: 'Savska 25, Zagreb',
      gender: Gender.female,
      dateOfBirth: DateTime(1945, 9, 12),
      createdAt: DateTime(2026, 2, 10),
    ),
    SeniorModel(
      id: 's5',
      firstName: 'Franjo',
      lastName: 'Jurić',
      email: 'franjo.juric@email.com',
      phone: '+385 91 678 9012',
      address: 'Heinzelova 8, Zagreb',
      gender: Gender.male,
      dateOfBirth: DateTime(1938, 2, 28),
      isActive: false,
      createdAt: DateTime(2025, 12, 5),
    ),
    SeniorModel(
      id: 's6',
      firstName: 'Ankica',
      lastName: 'Tomić',
      email: 'ankica.tomic@email.com',
      phone: '+385 91 789 0123',
      address: 'Draškovićeva 33, Zagreb',
      gender: Gender.female,
      dateOfBirth: DateTime(1950, 4, 10),
      createdAt: DateTime(2026, 2, 20),
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
      faculty: 'Medicinski fakultet Zagreb',
      studentIdNumber: '0036512345',
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
          from: TimeOfDay(hour: 14, minute: 0),
          to: TimeOfDay(hour: 20, minute: 0),
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
      faculty: 'Pravni fakultet Zagreb',
      studentIdNumber: '0036598765',
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
      faculty: 'Ekonomski fakultet Zagreb',
      studentIdNumber: '0036554321',
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
      faculty: 'Filozofski fakultet Zagreb',
      studentIdNumber: '0036567890',
      dateOfBirth: DateTime(2004, 2, 10),
      gender: Gender.female,
      avgRating: 5.0,
      totalReviews: 3,
      completedJobs: 6,
      cancelledJobs: 0,
      isVerified: true,
      contractStatus: ContractStatus.active,
      contractStartDate: DateTime(2026, 3, 1),
      contractExpiryDate: DateTime(2026, 6, 30),
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
    StudentModel(
      id: 'st5',
      firstName: 'Marko',
      lastName: 'Vuković',
      email: 'marko.vukovic@email.com',
      phone: '+385 99 222 3333',
      address: 'Draškovićeva 18, Zagreb',
      faculty: 'Fakultet elektrotehnike Zagreb',
      studentIdNumber: '0036511111',
      dateOfBirth: DateTime(2002, 9, 5),
      gender: Gender.male,
      avgRating: 4.5,
      totalReviews: 7,
      completedJobs: 14,
      cancelledJobs: 1,
      isVerified: true,
      contractStatus: ContractStatus.active,
      contractStartDate: DateTime(2026, 3, 1),
      contractExpiryDate: DateTime(2026, 6, 30),
      createdAt: DateTime(2025, 10, 20),
      availability: const [
        DayAvailability(
          dayOfWeek: 1,
          isEnabled: true,
          from: TimeOfDay(hour: 8, minute: 0),
          to: TimeOfDay(hour: 14, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 2,
          isEnabled: true,
          from: TimeOfDay(hour: 8, minute: 0),
          to: TimeOfDay(hour: 14, minute: 0),
        ),
        DayAvailability(dayOfWeek: 3, isEnabled: false),
        DayAvailability(
          dayOfWeek: 4,
          isEnabled: true,
          from: TimeOfDay(hour: 12, minute: 0),
          to: TimeOfDay(hour: 18, minute: 0),
        ),
        DayAvailability(dayOfWeek: 5, isEnabled: false),
        DayAvailability(
          dayOfWeek: 6,
          isEnabled: true,
          from: TimeOfDay(hour: 9, minute: 0),
          to: TimeOfDay(hour: 15, minute: 0),
        ),
        DayAvailability(dayOfWeek: 7, isEnabled: false),
      ],
    ),
    StudentModel(
      id: 'st6',
      firstName: 'Maja',
      lastName: 'Knežević',
      email: 'maja.knezevic@email.com',
      phone: '+385 99 444 5555',
      address: 'Tratinska 42, Zagreb',
      faculty: 'Farmaceutski fakultet Zagreb',
      studentIdNumber: '0036522222',
      dateOfBirth: DateTime(2003, 4, 17),
      gender: Gender.female,
      avgRating: 4.9,
      totalReviews: 10,
      completedJobs: 20,
      cancelledJobs: 0,
      isVerified: true,
      contractStatus: ContractStatus.active,
      contractStartDate: DateTime(2026, 2, 1),
      contractExpiryDate: DateTime(2026, 5, 31),
      createdAt: DateTime(2025, 11, 15),
      availability: const [
        DayAvailability(dayOfWeek: 1, isEnabled: false),
        DayAvailability(
          dayOfWeek: 2,
          isEnabled: true,
          from: TimeOfDay(hour: 9, minute: 0),
          to: TimeOfDay(hour: 15, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 3,
          isEnabled: true,
          from: TimeOfDay(hour: 9, minute: 0),
          to: TimeOfDay(hour: 15, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 4,
          isEnabled: true,
          from: TimeOfDay(hour: 9, minute: 0),
          to: TimeOfDay(hour: 15, minute: 0),
        ),
        DayAvailability(dayOfWeek: 5, isEnabled: false),
        DayAvailability(dayOfWeek: 6, isEnabled: false),
        DayAvailability(
          dayOfWeek: 7,
          isEnabled: true,
          from: TimeOfDay(hour: 10, minute: 0),
          to: TimeOfDay(hour: 16, minute: 0),
        ),
      ],
    ),
    StudentModel(
      id: 'st7',
      firstName: 'Dino',
      lastName: 'Barišić',
      email: 'dino.barisic@email.com',
      phone: '+385 99 666 7777',
      address: 'Klaićeva 5, Zagreb',
      faculty: 'Kineziološki fakultet Zagreb',
      studentIdNumber: '0036533333',
      dateOfBirth: DateTime(2001, 12, 30),
      gender: Gender.male,
      avgRating: 4.3,
      totalReviews: 6,
      completedJobs: 12,
      cancelledJobs: 1,
      isVerified: true,
      contractStatus: ContractStatus.active,
      contractStartDate: DateTime(2026, 3, 1),
      contractExpiryDate: DateTime(2026, 8, 31),
      createdAt: DateTime(2026, 1, 5),
      availability: const [
        DayAvailability(
          dayOfWeek: 1,
          isEnabled: true,
          from: TimeOfDay(hour: 14, minute: 0),
          to: TimeOfDay(hour: 20, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 2,
          isEnabled: true,
          from: TimeOfDay(hour: 14, minute: 0),
          to: TimeOfDay(hour: 20, minute: 0),
        ),
        DayAvailability(
          dayOfWeek: 3,
          isEnabled: true,
          from: TimeOfDay(hour: 14, minute: 0),
          to: TimeOfDay(hour: 20, minute: 0),
        ),
        DayAvailability(dayOfWeek: 4, isEnabled: false),
        DayAvailability(
          dayOfWeek: 5,
          isEnabled: true,
          from: TimeOfDay(hour: 14, minute: 0),
          to: TimeOfDay(hour: 20, minute: 0),
        ),
        DayAvailability(dayOfWeek: 6, isEnabled: false),
        DayAvailability(
          dayOfWeek: 7,
          isEnabled: true,
          from: TimeOfDay(hour: 8, minute: 0),
          to: TimeOfDay(hour: 14, minute: 0),
        ),
      ],
    ),
  ];

  // ── Narudžbe ──
  static final List<OrderModel> orders = [
    OrderModel(
      id: 'o1',
      orderNumber: '0001',
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
      sessions: [
        SessionModel(
          id: 'o1s1',
          date: DateTime(2026, 3, 5),
          weekday: 4,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationHours: 2,
        ),
      ],
    ),
    OrderModel(
      id: 'o2',
      orderNumber: '0002',
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
      sessions: [
        SessionModel(
          id: 'o2s1',
          date: DateTime(2026, 3, 5),
          weekday: 4,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          durationHours: 3,
        ),
        SessionModel(
          id: 'o2s2',
          date: DateTime(2026, 3, 9),
          weekday: 1,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          durationHours: 3,
        ),
        SessionModel(
          id: 'o2s3',
          date: DateTime(2026, 3, 12),
          weekday: 4,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          durationHours: 3,
        ),
        SessionModel(
          id: 'o2s4',
          date: DateTime(2026, 3, 16),
          weekday: 1,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          durationHours: 3,
        ),
      ],
    ),
    OrderModel(
      id: 'o3',
      orderNumber: '0003',
      senior: seniors[2],
      student: students[0],
      status: OrderStatus.active,
      frequency: FrequencyType.recurring,
      services: [ServiceType.walking, ServiceType.companionship],
      createdAt: DateTime(2026, 2, 20, 9, 0),
      scheduledDate: DateTime(2026, 2, 24),
      scheduledStart: const TimeOfDay(hour: 10, minute: 0),
      durationHours: 2,
      address: 'Maksimirska 100, Zagreb',
      dayEntries: [
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
      sessions: [
        SessionModel(
          id: 'o3s2',
          date: DateTime(2026, 2, 26),
          weekday: 3,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationHours: 2,
          studentName: 'Ana Kovačević',
          status: SessionStatus.completed,
        ),
        SessionModel(
          id: 'o3s3',
          date: DateTime(2026, 2, 28),
          weekday: 5,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationHours: 2,
          studentName: 'Ana Kovačević',
          status: SessionStatus.completed,
        ),
        SessionModel(
          id: 'o3s4',
          date: DateTime(2026, 3, 2),
          weekday: 7,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationHours: 2,
          studentName: 'Ana Kovačević',
          status: SessionStatus.completed,
        ),
        SessionModel(
          id: 'o3s6',
          date: DateTime(2026, 3, 5),
          weekday: 3,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationHours: 2,
          studentName: 'Ana Kovačević',
        ),
        SessionModel(
          id: 'o3s7',
          date: DateTime(2026, 3, 7),
          weekday: 5,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationHours: 2,
          studentName: 'Ana Kovačević',
        ),
        SessionModel(
          id: 'o3s8',
          date: DateTime(2026, 3, 9),
          weekday: 7,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationHours: 2,
          studentName: 'Ana Kovačević',
        ),
      ],
    ),
    OrderModel(
      id: 'o8',
      orderNumber: '0008',
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
      sessions: [
        SessionModel(
          id: 'o8s1',
          date: DateTime(2026, 3, 2),
          weekday: 1,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationHours: 2,
          studentName: 'Ana Kovačević',
          status: SessionStatus.completed,
        ),
      ],
    ),
    OrderModel(
      id: 'o9',
      orderNumber: '0009',
      senior: seniors[2],
      student: students[0],
      status: OrderStatus.cancelled,
      frequency: FrequencyType.oneTime,
      services: [ServiceType.walking],
      createdAt: DateTime(2026, 3, 1, 8, 0),
      scheduledDate: DateTime(2026, 3, 3),
      scheduledStart: const TimeOfDay(hour: 14, minute: 0),
      durationHours: 1,
      address: 'Maksimirska 100, Zagreb',
      sessions: [
        SessionModel(
          id: 'o9s1',
          date: DateTime(2026, 3, 3),
          weekday: 1,
          startTime: const TimeOfDay(hour: 14, minute: 0),
          durationHours: 1,
          studentName: 'Ana Kovačević',
          status: SessionStatus.cancelled,
        ),
      ],
    ),
    OrderModel(
      id: 'o4',
      orderNumber: '0004',
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
      sessions: [
        SessionModel(
          id: 'o4s1',
          date: DateTime(2026, 2, 18),
          weekday: 2,
          startTime: const TimeOfDay(hour: 8, minute: 30),
          durationHours: 4,
          studentName: 'Marko Jurić',
          status: SessionStatus.completed,
        ),
        SessionModel(
          id: 'o4s2',
          date: DateTime(2026, 2, 25),
          weekday: 2,
          startTime: const TimeOfDay(hour: 8, minute: 30),
          durationHours: 4,
          studentName: 'Marko Jurić',
          status: SessionStatus.completed,
        ),
        SessionModel(
          id: 'o4s3',
          date: DateTime(2026, 3, 4),
          weekday: 2,
          startTime: const TimeOfDay(hour: 8, minute: 30),
          durationHours: 4,
          studentName: 'Marko Jurić',
        ),
        SessionModel(
          id: 'o4s4',
          date: DateTime(2026, 3, 11),
          weekday: 2,
          startTime: const TimeOfDay(hour: 8, minute: 30),
          durationHours: 4,
          studentName: 'Marko Jurić',
        ),
      ],
    ),
    OrderModel(
      id: 'o5',
      orderNumber: '0005',
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
      sessions: [
        SessionModel(
          id: 'o5s1',
          date: DateTime(2026, 2, 5),
          weekday: 4,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          durationHours: 3,
          studentName: 'Petra Novak',
          status: SessionStatus.completed,
        ),
      ],
    ),
    OrderModel(
      id: 'o6',
      orderNumber: '0006',
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
      sessions: [
        SessionModel(
          id: 'o6s1',
          date: DateTime(2026, 1, 28),
          weekday: 3,
          startTime: const TimeOfDay(hour: 14, minute: 0),
          durationHours: 2,
          studentName: 'Ana Kovačević',
          status: SessionStatus.completed,
        ),
      ],
    ),
    OrderModel(
      id: 'o7',
      orderNumber: '0007',
      senior: seniors[3],
      student: null,
      status: OrderStatus.cancelled,
      frequency: FrequencyType.oneTime,
      services: [ServiceType.walking],
      createdAt: DateTime(2026, 2, 10, 12, 0),
      scheduledDate: DateTime(2026, 2, 14),
      scheduledStart: const TimeOfDay(hour: 16, minute: 0),
      durationHours: 1,
      address: 'Savska 25, Zagreb',
      sessions: [
        SessionModel(
          id: 'o7s1',
          date: DateTime(2026, 2, 14),
          weekday: 6,
          startTime: const TimeOfDay(hour: 16, minute: 0),
          durationHours: 1,
          status: SessionStatus.cancelled,
        ),
      ],
    ),
    // ── 2 nove narudžbe u obradi ──
    OrderModel(
      id: 'o10',
      orderNumber: '0010',
      senior: seniors[2],
      student: null,
      status: OrderStatus.processing,
      frequency: FrequencyType.oneTime,
      services: [ServiceType.escort, ServiceType.companionship],
      createdAt: DateTime(2026, 3, 3, 11, 0),
      scheduledDate: DateTime(2026, 3, 8),
      scheduledStart: const TimeOfDay(hour: 9, minute: 0),
      durationHours: 3,
      notes: 'Pratnja na kontrolu i druženje nakon.',
      address: 'Maksimirska 100, Zagreb',
      sessions: [
        SessionModel(
          id: 'o10s1',
          date: DateTime(2026, 3, 8),
          weekday: 7,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          durationHours: 3,
        ),
      ],
    ),
    OrderModel(
      id: 'o11',
      orderNumber: '0011',
      senior: seniors[3],
      student: null,
      status: OrderStatus.processing,
      frequency: FrequencyType.recurring,
      services: [ServiceType.houseHelp],
      createdAt: DateTime(2026, 3, 4, 8, 30),
      scheduledDate: DateTime(2026, 3, 10),
      scheduledStart: const TimeOfDay(hour: 11, minute: 0),
      durationHours: 2,
      notes: 'Pomoć s čišćenjem svaki utorak i četvrtak.',
      address: 'Savska 25, Zagreb',
      dayEntries: [
        const DayEntry(
          dayOfWeek: 2,
          startTime: TimeOfDay(hour: 11, minute: 0),
          durationHours: 2,
        ),
        const DayEntry(
          dayOfWeek: 4,
          startTime: TimeOfDay(hour: 11, minute: 0),
          durationHours: 2,
        ),
      ],
      sessions: [
        SessionModel(
          id: 'o11s0a',
          date: DateTime(2026, 2, 24),
          weekday: 2,
          startTime: const TimeOfDay(hour: 11, minute: 0),
          durationHours: 2,
        ),
        SessionModel(
          id: 'o11s0b',
          date: DateTime(2026, 3, 3),
          weekday: 2,
          startTime: const TimeOfDay(hour: 11, minute: 0),
          durationHours: 2,
        ),
        SessionModel(
          id: 'o11s1',
          date: DateTime(2026, 3, 10),
          weekday: 2,
          startTime: const TimeOfDay(hour: 11, minute: 0),
          durationHours: 2,
        ),
        SessionModel(
          id: 'o11s1b',
          date: DateTime(2026, 3, 12),
          weekday: 4,
          startTime: const TimeOfDay(hour: 11, minute: 0),
          durationHours: 2,
        ),
        SessionModel(
          id: 'o11s2',
          date: DateTime(2026, 3, 17),
          weekday: 2,
          startTime: const TimeOfDay(hour: 11, minute: 0),
          durationHours: 2,
        ),
        SessionModel(
          id: 'o11s2b',
          date: DateTime(2026, 3, 19),
          weekday: 4,
          startTime: const TimeOfDay(hour: 11, minute: 0),
          durationHours: 2,
        ),
      ],
    ),
    // ── 3 aktivne narudžbe za nove studente (sesije u ožujku) ──
    OrderModel(
      id: 'o12',
      orderNumber: '0012',
      senior: seniors[0],
      student: students[4], // Marko Vuković (st5)
      status: OrderStatus.active,
      frequency: FrequencyType.recurring,
      services: [ServiceType.shopping, ServiceType.companionship],
      createdAt: DateTime(2026, 2, 25, 10, 0),
      scheduledDate: DateTime(2026, 3, 1),
      scheduledStart: const TimeOfDay(hour: 9, minute: 0),
      durationHours: 2,
      address: 'Ilica 45, Zagreb',
      dayEntries: [
        const DayEntry(
          dayOfWeek: 1,
          startTime: TimeOfDay(hour: 9, minute: 0),
          durationHours: 2,
        ),
        const DayEntry(
          dayOfWeek: 4,
          startTime: TimeOfDay(hour: 9, minute: 0),
          durationHours: 2,
        ),
      ],
      sessions: [
        SessionModel(
          id: 'o12s1',
          date: DateTime(2026, 3, 2),
          weekday: 1,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          durationHours: 2,
          studentName: 'Marko Vuković',
          status: SessionStatus.completed,
        ),
        SessionModel(
          id: 'o12s2',
          date: DateTime(2026, 3, 5),
          weekday: 4,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          durationHours: 2,
          studentName: 'Marko Vuković',
        ),
        SessionModel(
          id: 'o12s3',
          date: DateTime(2026, 3, 9),
          weekday: 1,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          durationHours: 2,
          studentName: 'Marko Vuković',
        ),
      ],
    ),
    OrderModel(
      id: 'o13',
      orderNumber: '0013',
      senior: seniors[1],
      student: students[5], // Maja Knežević (st6)
      status: OrderStatus.active,
      frequency: FrequencyType.recurring,
      services: [ServiceType.houseHelp, ServiceType.walking],
      createdAt: DateTime(2026, 2, 20, 14, 0),
      scheduledDate: DateTime(2026, 3, 3),
      scheduledStart: const TimeOfDay(hour: 10, minute: 0),
      durationHours: 3,
      address: 'Vukovarska 12, Zagreb',
      dayEntries: [
        const DayEntry(
          dayOfWeek: 2,
          startTime: TimeOfDay(hour: 10, minute: 0),
          durationHours: 3,
        ),
        const DayEntry(
          dayOfWeek: 4,
          startTime: TimeOfDay(hour: 10, minute: 0),
          durationHours: 3,
        ),
      ],
      sessions: [
        SessionModel(
          id: 'o13s1',
          date: DateTime(2026, 3, 3),
          weekday: 2,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationHours: 3,
          studentName: 'Maja Knežević',
          status: SessionStatus.completed,
        ),
        SessionModel(
          id: 'o13s2',
          date: DateTime(2026, 3, 5),
          weekday: 4,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationHours: 3,
          studentName: 'Maja Knežević',
        ),
        SessionModel(
          id: 'o13s3',
          date: DateTime(2026, 3, 10),
          weekday: 2,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationHours: 3,
          studentName: 'Maja Knežević',
        ),
      ],
    ),
    OrderModel(
      id: 'o14',
      orderNumber: '0014',
      senior: seniors[4],
      student: students[6], // Dino Barišić (st7)
      status: OrderStatus.active,
      frequency: FrequencyType.recurringWithEnd,
      services: [ServiceType.walking, ServiceType.escort],
      createdAt: DateTime(2026, 2, 28, 16, 0),
      scheduledDate: DateTime(2026, 3, 1),
      scheduledStart: const TimeOfDay(hour: 15, minute: 0),
      durationHours: 2,
      notes: 'Šetnja i pratnja u park Maksimir.',
      address: 'Heinzelova 8, Zagreb',
      endDate: DateTime(2026, 5, 31),
      dayEntries: [
        const DayEntry(
          dayOfWeek: 1,
          startTime: TimeOfDay(hour: 15, minute: 0),
          durationHours: 2,
        ),
        const DayEntry(
          dayOfWeek: 5,
          startTime: TimeOfDay(hour: 15, minute: 0),
          durationHours: 2,
        ),
      ],
      sessions: [
        SessionModel(
          id: 'o14s1',
          date: DateTime(2026, 3, 3),
          weekday: 1,
          startTime: const TimeOfDay(hour: 15, minute: 0),
          durationHours: 2,
          studentName: 'Dino Barišić',
          status: SessionStatus.completed,
        ),
        SessionModel(
          id: 'o14s2',
          date: DateTime(2026, 3, 7),
          weekday: 5,
          startTime: const TimeOfDay(hour: 15, minute: 0),
          durationHours: 2,
          studentName: 'Dino Barišić',
        ),
        SessionModel(
          id: 'o14s3',
          date: DateTime(2026, 3, 10),
          weekday: 1,
          startTime: const TimeOfDay(hour: 15, minute: 0),
          durationHours: 2,
          studentName: 'Dino Barišić',
        ),
      ],
    ),
    // ── Lukine jednokratne narudžbe na specifične ponedjeljke ──
    OrderModel(
      id: 'o15',
      orderNumber: '0015',
      senior: seniors[0],
      student: students[0], // Luka Perić
      status: OrderStatus.active,
      frequency: FrequencyType.oneTime,
      services: [ServiceType.shopping],
      createdAt: DateTime(2026, 3, 5, 9, 0),
      scheduledDate: DateTime(2026, 3, 16), // Pon
      scheduledStart: const TimeOfDay(hour: 10, minute: 0),
      durationHours: 2,
      address: 'Ilica 45, Zagreb',
      sessions: [
        SessionModel(
          id: 'o15s1',
          date: DateTime(2026, 3, 16),
          weekday: 1,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationHours: 2,
          studentName: 'Luka Perić',
        ),
      ],
    ),
    OrderModel(
      id: 'o16',
      orderNumber: '0016',
      senior: seniors[2],
      student: students[0], // Luka Perić
      status: OrderStatus.active,
      frequency: FrequencyType.oneTime,
      services: [ServiceType.walking],
      createdAt: DateTime(2026, 3, 5, 10, 0),
      scheduledDate: DateTime(2026, 3, 30), // Pon
      scheduledStart: const TimeOfDay(hour: 10, minute: 0),
      durationHours: 2,
      address: 'Maksimirska 100, Zagreb',
      sessions: [
        SessionModel(
          id: 'o16s1',
          date: DateTime(2026, 3, 30),
          weekday: 1,
          startTime: const TimeOfDay(hour: 10, minute: 0),
          durationHours: 2,
          studentName: 'Luka Perić',
        ),
      ],
    ),
    OrderModel(
      id: 'o17',
      orderNumber: '0017',
      senior: seniors[5],
      student: students[0], // Luka Perić
      status: OrderStatus.active,
      frequency: FrequencyType.oneTime,
      services: [ServiceType.companionship],
      createdAt: DateTime(2026, 3, 5, 11, 0),
      scheduledDate: DateTime(2026, 4, 13), // Pon
      scheduledStart: const TimeOfDay(hour: 9, minute: 0),
      durationHours: 3,
      address: 'Draškovićeva 33, Zagreb',
      sessions: [
        SessionModel(
          id: 'o17s1',
          date: DateTime(2026, 4, 13),
          weekday: 1,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          durationHours: 3,
          studentName: 'Luka Perić',
        ),
      ],
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

  // ── Notifications ──
  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: 'n1',
      type: NotificationType.newOrder,
      title: 'Nova narudžba',
      body: 'Marija Horvat je kreirala novu narudžbu za kupovinu.',
      createdAt: DateTime(2026, 3, 4, 9, 15),
    ),
    NotificationModel(
      id: 'n2',
      type: NotificationType.contractExpiring,
      title: 'Ugovor ističe',
      body: 'Ugovor studenta Petra Novaka ističe za 5 dana.',
      createdAt: DateTime(2026, 3, 3, 14, 30),
    ),
    NotificationModel(
      id: 'n3',
      type: NotificationType.sessionCancelled,
      title: 'Sesija otkazana',
      body: 'Ana Matić je otkazala sesiju s Josipom Kovačevićem (05.03.).',
      createdAt: DateTime(2026, 3, 3, 10, 0),
    ),
    NotificationModel(
      id: 'n4',
      type: NotificationType.newOrder,
      title: 'Nova narudžba',
      body: 'Kata Babić je kreirala narudžbu za pomoć u kući.',
      createdAt: DateTime(2026, 3, 2, 16, 45),
    ),
    NotificationModel(
      id: 'n5',
      type: NotificationType.info,
      title: 'Sustav ažuriran',
      body: 'Helpi sustav je uspješno ažuriran na verziju 2.1.',
      createdAt: DateTime(2026, 3, 1, 8, 0),
      isRead: true,
    ),
  ];
}
