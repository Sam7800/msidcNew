/// App-wide constants for MSIDC Project Management System
class Constants {
  // App info
  static const String appName = 'MSIDC PMS';
  static const String appFullName =
      'Maharashtra State Infrastructure Development Company - Project Management System';
  static const String appVersion = '1.0.0';

  // Authentication
  static const String defaultUsername = 'admin';
  static const String defaultPassword = 'admin';

  // SharedPreferences keys
  static const String prefKeyIsLoggedIn = 'isLoggedIn';
  static const String prefKeyUsername = 'username';
  static const String prefKeyLastLogin = 'lastLogin';

  // Error messages
  static const String errorInvalidCredentials = 'Invalid username or password';

  // Tooltips
  static const String tooltipRefresh = 'Refresh data';
  static const String tooltipLogout = 'Logout';

  // Confirmation messages
  static const String confirmLogout = 'Are you sure you want to logout?';
}
