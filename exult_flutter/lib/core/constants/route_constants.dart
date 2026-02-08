/// Route names and paths for the application
class RouteConstants {
  // Public routes
  static const String home = '/';
  static const String pricing = '/pricing';
  static const String howItWorks = '/how-it-works';
  static const String contact = '/contact';

  // Auth routes
  static const String signIn = '/signin';
  static const String signUp = '/signup';

  // Protected routes (require authentication)
  static const String books = '/books';
  static const String bookDetail = '/books/:id';
  static const String profile = '/profile';
  static const String loans = '/loans';
  static const String subscribe = '/subscribe';

  // Admin routes (require admin role)
  static const String admin = '/admin';
  static const String adminSubscribers = '/admin/subscribers';
  static const String adminBooks = '/admin/books';
  static const String adminFinancials = '/admin/financials';

  // Helper methods
  static String bookDetailPath(String bookId) => '/books/$bookId';
}
