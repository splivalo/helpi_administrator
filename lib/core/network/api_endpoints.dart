class ApiEndpoints {
  ApiEndpoints._();

  // Base
  static const String baseUrl =
      'http://localhost:5142';

  // Auth
  static const String login = '/api/auth/login';
  static const String registerAdmin = '/api/auth/register/admin';
  static const String registerCustomer = '/api/auth/register/customer';
  static const String changePassword = '/api/auth/change-password';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password-code';

  // Dashboard
  static const String dashboardAdmin = '/api/dashboard/admin';

  // Orders
  static const String orders = '/api/orders';
  static String orderById(int id) => '/api/orders/$id';
  static String cancelOrder(int id) => '/api/orders/$id/cancel';

  // Sessions (JobInstances)
  static const String sessions = '/api/sessions';
  static String sessionById(int id) => '/api/sessions/$id';
  static String sessionsByOrder(int orderId) => '/api/sessions/order/$orderId';
  static String cancelSession(int id) => '/api/sessions/$id/cancel';
  static String reactivateSession(int id) => '/api/sessions/$id/reactivate';
  static String manageSession(int id) => '/api/sessions/$id/manage';

  // Students
  static const String students = '/api/students';
  static String studentById(int id) => '/api/students/$id';

  // Seniors
  static const String seniors = '/api/seniors';
  static String seniorById(int id) => '/api/seniors/$id';

  // Customers
  static const String customers = '/api/customers';
  static String customerById(int id) => '/api/customers/$id';

  // Contact Info
  static const String contactInfos = '/api/contact-infos';

  // Student Contracts
  static const String studentContracts = '/api/student-contracts';
  static String contractsByStudent(int studentId) =>
      '/api/student-contracts/student/$studentId';

  // Student Services
  static String servicesByStudent(int studentId) =>
      '/api/student-services/student/$studentId';

  // Services
  static const String services = '/api/services';

  // Student Availability
  static String availabilityByStudent(int studentId) =>
      '/api/student-availability-slots/student/$studentId';

  // Schedule Assignments
  static const String scheduleAssignments = '/api/schedule-assignments';
  static const String adminAssign = '/api/schedule-assignments/admin-assign';

  // Reviews
  static const String reviews = '/api/reviews';
  static String reviewsBySenior(int seniorId) =>
      '/api/reviews/senior/$seniorId';
  static String reviewsByStudent(int studentId) =>
      '/api/reviews/student/$studentId';

  // Promo Codes
  static const String promoCodes = '/api/promo-codes';
  static String promoCodeById(int id) => '/api/promo-codes/$id';
  static const String promoCodeValidate = '/api/promo-codes/validate';
  static const String promoCodeApply = '/api/promo-codes/apply';

  // Pricing
  static const String pricingConfigurations = '/api/PricingConfiguration';

  // Notifications
  static String notificationsByUser(int userId) =>
      '/api/HNotifications/user/$userId';
  static String notificationsUnreadByUser(int userId) =>
      '/api/HNotifications/user/$userId/unread';
  static String notificationsUnreadCount(int userId) =>
      '/api/HNotifications/user/$userId/unread-count';
  static String notificationMarkRead(int id) =>
      '/api/HNotifications/$id/mark-read';
  static String notificationMarkAllRead(int userId) =>
      '/api/HNotifications/user/$userId/mark-all-read';

  // Cities
  static const String cities = '/api/cities';

  // Faculties
  static const String faculties = '/api/faculties';

  // Invoices
  static const String invoices = '/api/invoices';

  // Suspensions
  static String suspensionStatus(int userId) =>
      '/api/suspensions/users/$userId';
  static String suspendUser(int userId) =>
      '/api/suspensions/users/$userId/suspend';
  static String activateUser(int userId) =>
      '/api/suspensions/users/$userId/activate';

  // Archive Check (Students, Seniors, Orders)
  static String studentArchiveCheck(int id) =>
      '/api/students/$id/archive-check';
  static String studentArchive(int id) => '/api/students/$id/archive';
  static String studentUnarchive(int id) => '/api/students/$id/unarchive';
  static String seniorArchiveCheck(int id) => '/api/seniors/$id/archive-check';
  static String seniorArchive(int id) => '/api/seniors/$id/archive';
  static String orderArchiveCheck(int id) => '/api/orders/$id/archive-check';
  static String orderArchive(int id) => '/api/orders/$id/archive';

  // Contract Delete Check
  static String contractDeleteCheck(int id) =>
      '/api/student-contracts/$id/delete-check';
  static String contractDeleteWithCheck(int id) =>
      '/api/student-contracts/$id/with-check';

  // Admin Notes
  static String adminNotes(String entityType, int entityId) =>
      '/api/admin-notes/$entityType/$entityId';
  static String adminNoteById(int id) => '/api/admin-notes/$id';
}
