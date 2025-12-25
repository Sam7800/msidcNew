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
  static const int sessionTimeoutMinutes = 30;

  // Database
  static const String dbName = 'msidc.db';
  static const int dbVersion = 1;

  // Project categories
  static const List<String> projectCategories = [
    'Nashik Kumbhmela',
    'HAM Projects',
    'Nagpur Works',
    'NHAI Projects',
    'Other Projects',
  ];

  // Category project counts
  static const Map<String, int> categoryProjectCounts = {
    'Nashik Kumbhmela': 8,
    'HAM Projects': 2,
    'Nagpur Works': 14,
    'NHAI Projects': 4,
    'Other Projects': 6,
  };

  // Module types
  static const String moduleDPR = 'DPR';
  static const String moduleWork = 'Work';
  static const String modulePMS = 'PMS';
  static const String moduleWorkEntry = 'WorkEntry';

  // Form sections
  static const String sectionDPR = 'dpr';
  static const String sectionWork = 'work';
  static const String sectionPMS = 'pms';

  // Field counts per module
  static const int dprFieldCount = 19;
  static const int workFieldCount = 15;
  static const int pmsFieldCount = 19;
  static const int workEntryDPRFieldCount = 40;
  static const int workEntryWorkFieldCount = 20;
  static const int workEntryPMSFieldCount = 24;
  static const int totalWorkEntryFieldCount = 84;

  // Auto-save
  static const int autoSaveIntervalSeconds = 30;

  // Date formats
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String isoDateFormat = 'yyyy-MM-dd';
  static const String fullDateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Number formats
  static const String currencyFormat = '₹#,##,###.##';
  static const String percentageFormat = '##.##%';

  // Pagination
  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;

  // CSV Import
  static const List<String> supportedCSVModules = [
    'DPR',
    'Work',
    'PMS',
    'WorkEntry',
  ];

  static const int maxCSVFileSize = 10 * 1024 * 1024; // 10 MB

  // Validation
  static const int minBroadScopeWords = 50;
  static const int maxBroadScopeWords = 600;
  static const int minPasswordLength = 4;
  static const int maxProjectNameLength = 200;

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double cardElevation = 2.0;
  static const double borderRadius = 8.0;
  static const double cardBorderRadius = 12.0;

  // Grid
  static const int categoriesGridCrossAxisCount = 2;
  static const int projectsGridCrossAxisCount = 3;
  static const double gridSpacing = 16.0;
  static const double gridChildAspectRatio = 1.5;

  // Status values
  static const List<String> statusOptions = [
    'Not Started',
    'In Progress',
    'Completed',
    'On Hold',
    'Cancelled',
  ];

  // Responsible persons (from CSV analysis)
  static const List<String> responsiblePersons = [
    'Engineering',
    'Tender',
    'CE', // Chief Engineer
    'EE', // Executive Engineer
    'SE', // Superintending Engineer
    'JMD', // Joint Managing Director
    'MD', // Managing Director
    'Fin', // Finance
    'Fin Adv', // Financial Advisor
  ];

  // Post held options
  static const List<String> postHeldOptions = [
    'Managing Director',
    'Joint Managing Director',
    'Chief Engineer',
    'Superintending Engineer',
    'Executive Engineer',
    'Assistant Engineer',
    'Junior Engineer',
    'Finance Officer',
    'Accountant',
  ];

  // Contract types
  static const List<String> contractTypes = [
    'EPC',
    'Item Rate B-2',
    '% Rate B-1',
    'BOT',
  ];

  // Milestone status options
  static const List<String> milestoneStatusOptions = [
    'Not Started',
    'In Progress',
    'Completed',
    'Submitted',
    'Approved',
    'Rejected',
  ];

  // Applicability options
  static const List<String> applicabilityOptions = [
    'Not Applicable',
    'Applicable',
  ];

  // Yes/No options
  static const List<String> yesNoOptions = [
    'Yes',
    'No',
  ];

  // Import status
  static const String importStatusSuccess = 'success';
  static const String importStatusPartial = 'partial';
  static const String importStatusFailed = 'failed';

  // Audit actions
  static const String auditActionInsert = 'INSERT';
  static const String auditActionUpdate = 'UPDATE';
  static const String auditActionDelete = 'DELETE';

  // Error messages
  static const String errorGeneric = 'An error occurred. Please try again.';
  static const String errorDatabaseInit = 'Failed to initialize database.';
  static const String errorCSVImport = 'Failed to import CSV file.';
  static const String errorInvalidCredentials =
      'Invalid username or password.';
  static const String errorSessionExpired = 'Session expired. Please login again.';
  static const String errorNoData = 'No data available.';
  static const String errorInvalidDate = 'Invalid date format.';
  static const String errorInvalidAmount = 'Invalid amount.';
  static const String errorRequired = 'This field is required.';

  // Success messages
  static const String successSave = 'Data saved successfully.';
  static const String successImport = 'CSV imported successfully.';
  static const String successDelete = 'Deleted successfully.';
  static const String successLogin = 'Login successful.';

  // Confirmation messages
  static const String confirmDelete = 'Are you sure you want to delete this?';
  static const String confirmLogout = 'Are you sure you want to logout?';
  static const String confirmCancel =
      'Are you sure you want to cancel? Unsaved changes will be lost.';

  // Loading messages
  static const String loadingProjects = 'Loading projects...';
  static const String loadingData = 'Loading data...';
  static const String savingData = 'Saving data...';
  static const String importingCSV = 'Importing CSV...';

  // Tooltips
  static const String tooltipSearch = 'Search projects';
  static const String tooltipFilter = 'Filter projects';
  static const String tooltipSort = 'Sort projects';
  static const String tooltipRefresh = 'Refresh data';
  static const String tooltipExport = 'Export to CSV/Excel';
  static const String tooltipImport = 'Import from CSV';
  static const String tooltipSettings = 'Settings';
  static const String tooltipLogout = 'Logout';

  // Window configuration (Desktop)
  static const String windowTitle = 'MSIDC Project Management System';
  static const double minWindowWidth = 1024;
  static const double minWindowHeight = 768;
  static const double defaultWindowWidth = 1280;
  static const double defaultWindowHeight = 800;

  // Asset paths
  static const String assetsDataPath = 'assets/data/';

  // SharedPreferences keys
  static const String prefKeyUsername = 'username';
  static const String prefKeyIsLoggedIn = 'is_logged_in';
  static const String prefKeyLastLogin = 'last_login';
  static const String prefKeyThemeMode = 'theme_mode';

  // Route names
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeCategories = '/categories';
  static const String routeProjects = '/projects';
  static const String routeProjectDetail = '/project-detail';
  static const String routeDPR = '/dpr';
  static const String routeWork = '/work';
  static const String routeMonitoring = '/monitoring';
  static const String routeWorkEntry = '/work-entry';
  static const String routeImport = '/import';
  static const String routeSettings = '/settings';
}
