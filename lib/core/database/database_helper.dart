import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import '../services/logger_service.dart';

/// DatabaseHelper - Singleton class for SQLite database management
///
/// Manages:
/// - Database initialization and versioning
/// - Table creation and migrations
/// - Foreign key constraints
/// - Triggers for auto-updates and audit logging
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final LoggerService _logger = LoggerService.instance;

  DatabaseHelper._init();

  /// Get database instance (creates if not exists)
  Future<Database> get database async {
    if (_database != null) {
      await _logger.database('GET', 'Returning existing database instance');
      return _database!;
    }
    await _logger.database('GET', 'Initializing new database instance');
    _database = await _initDB('msidc.db');
    await _logger.database('GET', 'Database instance created successfully');
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB(String filePath) async {
    try {
      await _logger.database('INIT', 'Starting database initialization for: $filePath');

      // Initialize FFI for desktop platforms
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        await _logger.database('INIT', 'Initializing SQLite FFI for desktop platform');
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      await _logger.database('INIT', 'Database path: $path');

      final db = await openDatabase(
        path,
        version: 4,
        onCreate: _createDB,
        onConfigure: _onConfigure,
        onUpgrade: _upgradeDB,
      );

      await _logger.database('INIT', 'Database opened successfully at version ${await db.getVersion()}');
      return db;
    } catch (e, stackTrace) {
      await _logger.database('INIT', 'Failed to initialize database', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Enable foreign keys
  Future<void> _onConfigure(Database db) async {
    await _logger.database('CONFIGURE', 'Enabling foreign key constraints');
    await db.execute('PRAGMA foreign_keys = ON');
    await _logger.database('CONFIGURE', 'Foreign key constraints enabled');
  }

  /// Handle database upgrades
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await _logger.database('UPGRADE', 'Upgrading database from v$oldVersion to v$newVersion');

    if (oldVersion < 2) {
      await _migrateV1ToV2(db);
    }

    if (oldVersion < 3) {
      await _migrateV2ToV3(db);
    }

    if (oldVersion < 4) {
      await _migrateV3ToV4(db);
    }

    await _logger.database('UPGRADE', 'Database upgrade completed successfully');
  }

  /// Migrate from version 1 to version 2
  /// - Creates categories table
  /// - Migrates projects table from category (TEXT) to category_id (INTEGER FK)
  Future<void> _migrateV1ToV2(Database db) async {
    await _logger.database('MIGRATION', 'Starting v1→v2 migration');

    try {
      // Step 1: Create categories table
      await _logger.database('MIGRATION', 'Creating categories table');
      await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          description TEXT,
          color_hex TEXT DEFAULT '#0061FF',
          icon_name TEXT DEFAULT 'folder',
          display_order INTEGER DEFAULT 0,
          is_active INTEGER DEFAULT 1,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      await db.execute(
          'CREATE INDEX idx_categories_name ON categories(name)');
      await db.execute(
          'CREATE INDEX idx_categories_display_order ON categories(display_order)');
      await db.execute(
          'CREATE INDEX idx_categories_active ON categories(is_active)');

      // Create trigger for categories table
      await db.execute('''
        CREATE TRIGGER update_categories_timestamp
        AFTER UPDATE ON categories
        BEGIN
          UPDATE categories SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
        END
      ''');

      // Step 2: Insert default 5 categories
      await _logger.database('MIGRATION', 'Inserting default categories');
      final categoryInserts = [
        "INSERT INTO categories (name, description, color_hex, icon_name, display_order) VALUES ('Nashik Kumbhmela', '8 projects for Nashik Kumbhmela development', '#0061FF', 'festival', 1)",
        "INSERT INTO categories (name, description, color_hex, icon_name, display_order) VALUES ('HAM Projects', '2 HAM (Hybrid Annuity Model) projects', '#00E676', 'handshake', 2)",
        "INSERT INTO categories (name, description, color_hex, icon_name, display_order) VALUES ('Nagpur Works', '14 infrastructure projects in Nagpur region', '#FF1744', 'apartment', 3)",
        "INSERT INTO categories (name, description, color_hex, icon_name, display_order) VALUES ('NHAI Projects', '4 National Highway Authority projects', '#FF9100', 'route', 4)",
        "INSERT INTO categories (name, description, color_hex, icon_name, display_order) VALUES ('Other Projects', '6 miscellaneous infrastructure projects', '#9C27B0', 'business', 5)",
      ];

      for (final insert in categoryInserts) {
        await db.execute(insert);
      }

      // Step 3: Create new projects table with category_id
      await _logger.database('MIGRATION', 'Creating new projects table structure');
      await db.execute('''
        CREATE TABLE projects_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sr_no INTEGER NOT NULL,
          name TEXT NOT NULL,
          category_id INTEGER NOT NULL,
          broad_scope TEXT,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          UNIQUE(sr_no),
          FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT ON UPDATE CASCADE
        )
      ''');

      // Step 4: Migrate data from old projects table to new one
      await _logger.database('MIGRATION', 'Migrating existing projects data');
      await db.execute('''
        INSERT INTO projects_new (id, sr_no, name, category_id, broad_scope, created_at, updated_at)
        SELECT
          p.id,
          p.sr_no,
          p.name,
          c.id AS category_id,
          p.broad_scope,
          p.created_at,
          p.updated_at
        FROM projects p
        INNER JOIN categories c ON p.category = c.name
      ''');

      // Step 5: Drop old projects table
      await _logger.database('MIGRATION', 'Dropping old projects table');
      await db.execute('DROP TABLE projects');

      // Step 6: Rename new table to projects
      await _logger.database('MIGRATION', 'Renaming projects_new to projects');
      await db.execute('ALTER TABLE projects_new RENAME TO projects');

      // Step 7: Recreate indexes for projects table
      await _logger.database('MIGRATION', 'Recreating indexes for projects table');
      await db.execute(
          'CREATE INDEX idx_projects_category ON projects(category_id)');
      await db.execute('CREATE INDEX idx_projects_name ON projects(name)');
      await db.execute('CREATE INDEX idx_projects_sr_no ON projects(sr_no)');

      // Step 8: Recreate trigger for projects table
      await _logger.database('MIGRATION', 'Recreating trigger for projects table');
      await db.execute('''
        CREATE TRIGGER update_projects_timestamp
        AFTER UPDATE ON projects
        BEGIN
          UPDATE projects SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
        END
      ''');

      await _logger.database('MIGRATION', 'v1→v2 migration completed successfully');
    } catch (e, stackTrace) {
      await _logger.database('MIGRATION', 'Migration error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Migrate from version 2 to version 3
  /// - Adds work_id and name_of_work columns to work_entry table
  Future<void> _migrateV2ToV3(Database db) async {
    await _logger.database('MIGRATION', 'Starting v2→v3 migration');

    try {
      // Add work_id and name_of_work columns to work_entry table
      await _logger.database('MIGRATION', 'Adding work_id column to work_entry table');
      await db.execute('''
        ALTER TABLE work_entry ADD COLUMN work_id TEXT
      ''');

      await _logger.database('MIGRATION', 'Adding name_of_work column to work_entry table');
      await db.execute('''
        ALTER TABLE work_entry ADD COLUMN name_of_work TEXT
      ''');

      await _logger.database('MIGRATION', 'v2→v3 migration completed successfully');
    } catch (e, stackTrace) {
      await _logger.database('MIGRATION', 'Migration error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Migrate from version 3 to version 4
  /// - Adds location and status columns to projects table
  Future<void> _migrateV3ToV4(Database db) async {
    await _logger.database('MIGRATION', 'Starting v3→v4 migration');

    try {
      // Add location column to projects table
      await _logger.database('MIGRATION', 'Adding location column to projects table');
      await db.execute('''
        ALTER TABLE projects ADD COLUMN location TEXT DEFAULT 'Maharashtra'
      ''');

      // Add status column to projects table
      await _logger.database('MIGRATION', 'Adding status column to projects table');
      await db.execute('''
        ALTER TABLE projects ADD COLUMN status TEXT DEFAULT 'In Progress'
      ''');

      await _logger.database('MIGRATION', 'v3→v4 migration completed successfully');
    } catch (e, stackTrace) {
      await _logger.database('MIGRATION', 'Migration error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Create all tables and triggers
  Future<void> _createDB(Database db, int version) async {
    await _logger.database('CREATE', 'Creating database schema version $version');

    // Table 1: Categories (new in v2)
    await _logger.database('CREATE', 'Creating categories table');
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        color_hex TEXT DEFAULT '#0061FF',
        icon_name TEXT DEFAULT 'folder',
        display_order INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('CREATE INDEX idx_categories_name ON categories(name)');
    await db.execute(
        'CREATE INDEX idx_categories_display_order ON categories(display_order)');
    await db.execute(
        'CREATE INDEX idx_categories_active ON categories(is_active)');

    // Insert default 5 categories
    final categoryInserts = [
      "INSERT INTO categories (name, description, color_hex, icon_name, display_order) VALUES ('Nashik Kumbhmela', '8 projects for Nashik Kumbhmela development', '#0061FF', 'festival', 1)",
      "INSERT INTO categories (name, description, color_hex, icon_name, display_order) VALUES ('HAM Projects', '2 HAM (Hybrid Annuity Model) projects', '#00E676', 'handshake', 2)",
      "INSERT INTO categories (name, description, color_hex, icon_name, display_order) VALUES ('Nagpur Works', '14 infrastructure projects in Nagpur region', '#FF1744', 'apartment', 3)",
      "INSERT INTO categories (name, description, color_hex, icon_name, display_order) VALUES ('NHAI Projects', '4 National Highway Authority projects', '#FF9100', 'route', 4)",
      "INSERT INTO categories (name, description, color_hex, icon_name, display_order) VALUES ('Other Projects', '6 miscellaneous infrastructure projects', '#9C27B0', 'business', 5)",
    ];

    for (final insert in categoryInserts) {
      await db.execute(insert);
    }

    // Table 2: Projects (updated in v2 to use category_id FK, v4 adds location and status)
    await _logger.database('CREATE', 'Creating projects table');
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sr_no INTEGER NOT NULL,
        name TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        broad_scope TEXT,
        location TEXT DEFAULT 'Maharashtra',
        status TEXT DEFAULT 'In Progress',
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(sr_no),
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT ON UPDATE CASCADE
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_projects_category ON projects(category_id)');
    await db.execute('CREATE INDEX idx_projects_name ON projects(name)');
    await db.execute('CREATE INDEX idx_projects_sr_no ON projects(sr_no)');

    // Table 3: DPR Data
    await _logger.database('CREATE', 'Creating dpr_data table');
    await db.execute('''
      CREATE TABLE dpr_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        broad_scope TEXT,
        bid_doc_dpr TEXT,
        invite TEXT,
        prebid TEXT,
        csd TEXT,
        bid_submit TEXT,
        work_order TEXT,
        inception_report TEXT,
        survey TEXT,
        alignment_layout TEXT,
        draft_dpr TEXT,
        drawings TEXT,
        boq TEXT,
        env_clearance TEXT,
        cash_flow TEXT,
        la_proposal TEXT,
        utility_shifting TEXT,
        final_dpr TEXT,
        bid_doc_work TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        UNIQUE(project_id)
      )
    ''');

    await db.execute('CREATE INDEX idx_dpr_project ON dpr_data(project_id)');

    // Table 4: Work Data
    await _logger.database('CREATE', 'Creating work_data table');
    await db.execute('''
      CREATE TABLE work_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        aa TEXT,
        dpr TEXT,
        ts TEXT,
        bid_doc TEXT,
        bid_invite TEXT,
        prebid TEXT,
        csd TEXT,
        bid_submit TEXT,
        fin_bid TEXT,
        loi TEXT,
        loa TEXT,
        pbg TEXT,
        agreement TEXT,
        work_order TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        UNIQUE(project_id)
      )
    ''');

    await db.execute('CREATE INDEX idx_work_project ON work_data(project_id)');

    // Table 5: Monitoring Data
    await _logger.database('CREATE', 'Creating monitoring_data table');
    await db.execute('''
      CREATE TABLE monitoring_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        agmnt_amount REAL,
        appointed_date TEXT,
        tender_period INTEGER,
        first_milestone_date TEXT,
        first_milestone_amount REAL,
        second_milestone_date TEXT,
        second_milestone_amount REAL,
        third_milestone_date TEXT,
        third_milestone_amount REAL,
        fourth_milestone_date TEXT,
        fourth_milestone_amount REAL,
        fifth_milestone_date TEXT,
        fifth_milestone_amount REAL,
        ld REAL,
        cos REAL,
        eot INTEGER,
        cum_exp REAL,
        final_bill REAL,
        audit_para TEXT,
        replies TEXT,
        laq_lcq TEXT,
        tech_audit TEXT,
        rev_aa TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
        UNIQUE(project_id)
      )
    ''');

    await db
        .execute('CREATE INDEX idx_monitoring_project ON monitoring_data(project_id)');
    await db.execute(
        'CREATE INDEX idx_monitoring_agmnt_amount ON monitoring_data(agmnt_amount)');

    // Table 6: Work Entry (84 dynamic fields stored as JSON)
    await _logger.database('CREATE', 'Creating work_entry table');
    await db.execute('''
      CREATE TABLE work_entry (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        work_id TEXT,
        name_of_work TEXT,
        person_responsible TEXT,
        post_held TEXT,
        pending_with TEXT,
        dpr_section TEXT,
        work_section TEXT,
        pms_section TEXT,
        is_draft INTEGER DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_work_entry_project ON work_entry(project_id)');
    await db.execute(
        'CREATE INDEX idx_work_entry_draft ON work_entry(is_draft)');

    // Table 7: Import Logs
    await _logger.database('CREATE', 'Creating import_logs table');
    await db.execute('''
      CREATE TABLE import_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_name TEXT NOT NULL,
        module_type TEXT NOT NULL CHECK(module_type IN ('DPR', 'Work', 'PMS', 'WorkEntry')),
        rows_imported INTEGER NOT NULL,
        rows_failed INTEGER DEFAULT 0,
        status TEXT NOT NULL CHECK(status IN ('success', 'partial', 'failed')),
        error_message TEXT,
        imported_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        imported_by TEXT NOT NULL DEFAULT 'admin'
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_import_logs_module ON import_logs(module_type)');
    await db.execute(
        'CREATE INDEX idx_import_logs_date ON import_logs(imported_at)');

    // Table 8: Audit Log
    await _logger.database('CREATE', 'Creating audit_log table');
    await db.execute('''
      CREATE TABLE audit_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        action TEXT NOT NULL CHECK(action IN ('INSERT', 'UPDATE', 'DELETE')),
        old_value TEXT,
        new_value TEXT,
        user_id TEXT NOT NULL DEFAULT 'admin',
        changed_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL
      )
    ''');

    await db
        .execute('CREATE INDEX idx_audit_project ON audit_log(project_id)');
    await db.execute('CREATE INDEX idx_audit_table ON audit_log(table_name)');
    await db.execute('CREATE INDEX idx_audit_date ON audit_log(changed_at)');

    // Create triggers for auto-updating timestamps
    await _createTimestampTriggers(db);

    await _logger.database('CREATE', 'Database schema created successfully');
  }

  /// Create triggers for auto-updating timestamps on UPDATE
  Future<void> _createTimestampTriggers(Database db) async {
    // Categories table trigger
    await db.execute('''
      CREATE TRIGGER update_categories_timestamp
      AFTER UPDATE ON categories
      BEGIN
        UPDATE categories SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
      END
    ''');

    // Projects table trigger
    await db.execute('''
      CREATE TRIGGER update_projects_timestamp
      AFTER UPDATE ON projects
      BEGIN
        UPDATE projects SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
      END
    ''');

    // DPR data trigger
    await db.execute('''
      CREATE TRIGGER update_dpr_timestamp
      AFTER UPDATE ON dpr_data
      BEGIN
        UPDATE dpr_data SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
      END
    ''');

    // Work data trigger
    await db.execute('''
      CREATE TRIGGER update_work_timestamp
      AFTER UPDATE ON work_data
      BEGIN
        UPDATE work_data SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
      END
    ''');

    // Monitoring data trigger
    await db.execute('''
      CREATE TRIGGER update_monitoring_timestamp
      AFTER UPDATE ON monitoring_data
      BEGIN
        UPDATE monitoring_data SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
      END
    ''');

    // Work entry trigger
    await db.execute('''
      CREATE TRIGGER update_work_entry_timestamp
      AFTER UPDATE ON work_entry
      BEGIN
        UPDATE work_entry SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
      END
    ''');
  }

  /// Close database
  Future<void> close() async {
    await _logger.database('CLOSE', 'Closing database connection');
    final db = await database;
    await db.close();
    await _logger.database('CLOSE', 'Database connection closed');
  }

  /// Delete database (for testing)
  Future<void> deleteDB() async {
    await _logger.database('DELETE', 'Deleting database');
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'msidc.db');
    await deleteDatabase(path);
    _database = null;
    await _logger.database('DELETE', 'Database deleted successfully');
  }
}
