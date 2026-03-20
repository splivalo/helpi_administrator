import 'package:flutter/material.dart';

export 'archive_models.dart';

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  ENUMS
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

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

enum ContractStatus { active, expired, none }

enum SessionStatus { scheduled, completed, cancelled }

enum Gender { male, female }

enum NotificationType { newOrder, contractExpiring, sessionCancelled, info }

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  MODELS
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

enum CardBrand { visa, mastercard, maestro, amex, diners, unknown }

// â”€â”€ Notification â”€â”€
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
  final int? userId; // Customer/User ID (AspNetUsers.Id) — for suspend/activate
  final int? contactId; // For backend update via PUT /api/contact-infos/{id}
  final int? ordererContactId; // For orderer update
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final double? latitude;
  final double? longitude;
  final Gender gender;
  final DateTime dateOfBirth;
  final bool isActive;
  final bool isArchived;
  final bool isSuspended;
  final String? suspensionReason;
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
    this.userId,
    this.contactId,
    this.ordererContactId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    this.city = '',
    this.latitude,
    this.longitude,
    required this.gender,
    required this.dateOfBirth,
    this.isActive = true,
    this.isArchived = false,
    this.isSuspended = false,
    this.suspensionReason,
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
  String get contactName => hasOrderer ? ordererFullName : fullName;
  String get contactPhone => hasOrderer ? (ordererPhone ?? phone) : phone;
  String get contactEmail => hasOrderer ? (ordererEmail ?? email) : email;
}

class StudentModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final double? latitude;
  final double? longitude;
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
  final bool isSuspended;
  final String? suspensionReason;
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
    this.city = '',
    this.latitude,
    this.longitude,
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
    this.isSuspended = false,
    this.suspensionReason,
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
  final String? promoCode;
  final List<int> scheduleIds;

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
    this.promoCode,
    this.scheduleIds = const [],
  });

  OrderModel copyWith({
    StudentModel? Function()? student,
    OrderStatus? status,
    List<SessionModel>? sessions,
  }) {
    return OrderModel(
      id: id,
      orderNumber: orderNumber,
      senior: senior,
      student: student != null ? student() : this.student,
      status: status ?? this.status,
      frequency: frequency,
      services: services,
      createdAt: createdAt,
      scheduledDate: scheduledDate,
      scheduledStart: scheduledStart,
      durationHours: durationHours,
      notes: notes,
      address: address,
      endDate: endDate,
      dayEntries: dayEntries,
      sessions: sessions ?? this.sessions,
      promoCode: promoCode,
      scheduleIds: scheduleIds,
    );
  }
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

// â”€â”€ Session Preview (for assign flow) â”€â”€

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
  final String participantId;
  final String participantName;
  final String participantRole; // 'senior' or 'student'
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final String? orderId;
  final List<ChatMessage> messages;

  const ChatRoom({
    required this.id,
    required this.participantId,
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

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  ADMIN NOTE
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class AdminNote {
  final int id;
  String text;
  final DateTime createdAt;
  DateTime updatedAt;

  AdminNote({
    required this.id,
    required this.text,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  bool get wasEdited => updatedAt.isAfter(createdAt);

  /// Creates an AdminNote from backend JSON.
  factory AdminNote.fromJson(Map<String, dynamic> json) {
    return AdminNote(
      id: json['id'] as int,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

//
//  ARCHIVE CHECK  API response models for archive/delete
//

/// Result of checking if an entity can be archived.
class ArchiveCheckResult {
  final bool canArchiveDirectly;
  final bool hasBlockingItems;
  final int activeAssignmentsCount;
  final int upcomingSessionsCount;
  final int activeOrdersCount;
  final String? message;

  const ArchiveCheckResult({
    required this.canArchiveDirectly,
    required this.hasBlockingItems,
    this.activeAssignmentsCount = 0,
    this.upcomingSessionsCount = 0,
    this.activeOrdersCount = 0,
    this.message,
  });

  factory ArchiveCheckResult.fromJson(Map<String, dynamic> json) {
    return ArchiveCheckResult(
      canArchiveDirectly: json['canArchiveDirectly'] as bool? ?? false,
      hasBlockingItems: json['hasBlockingItems'] as bool? ?? false,
      activeAssignmentsCount: json['activeAssignmentsCount'] as int? ?? 0,
      upcomingSessionsCount: json['upcomingSessionsCount'] as int? ?? 0,
      activeOrdersCount: json['activeOrdersCount'] as int? ?? 0,
      message: json['message'] as String?,
    );
  }

  int get totalBlockingItems =>
      activeAssignmentsCount + upcomingSessionsCount + activeOrdersCount;
}

/// Result of archive operation.
class ArchiveResult {
  final bool success;
  final String? message;
  final int terminatedAssignmentsCount;
  final int cancelledSessionsCount;
  final int cancelledOrdersCount;

  const ArchiveResult({
    required this.success,
    this.message,
    this.terminatedAssignmentsCount = 0,
    this.cancelledSessionsCount = 0,
    this.cancelledOrdersCount = 0,
  });

  factory ArchiveResult.fromJson(Map<String, dynamic> json) {
    return ArchiveResult(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      terminatedAssignmentsCount:
          json['terminatedAssignmentsCount'] as int? ?? 0,
      cancelledSessionsCount: json['cancelledSessionsCount'] as int? ?? 0,
      cancelledOrdersCount: json['cancelledOrdersCount'] as int? ?? 0,
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  DATA STORE â€” populated by DataLoader from API
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

class MockData {
  MockData._();

  static final List<SeniorModel> seniors = [];
  static final List<StudentModel> students = [];
  static final List<OrderModel> orders = [];
  static final List<ReviewModel> reviews = [];
  static final List<NotificationModel> notifications = [];
  static final List<ChatRoom> chatRooms = [];
}
