# Phase 1: Database Cleanup

**Date**: 2026-01-10
**Status**: ✅ COMPLETED

## Objective

Clear all existing data from the `work_entry` table while preserving the table structure and relationships.

## What Was Done

### 1. Database Helper Updates

**File**: `lib/core/database/database_helper.dart`

#### Changes Made:

1. **Version Bump**: `4` → `5`
   ```dart
   version: 5,  // Previously 4
   ```

2. **New Migration Method**: `_migrateV4ToV5()`
   ```dart
   /// Migrate from version 4 to version 5
   /// - Clears all data from work_entry table (for restructuring)
   Future<void> _migrateV4ToV5(Database db) async {
     await _logger.database('MIGRATION', 'Starting v4→v5 migration');

     try {
       await _logger.database('MIGRATION', 'Clearing all data from work_entry table for restructuring');
       await db.delete('work_entry');
       await _logger.database('MIGRATION', 'work_entry table cleared successfully');

       await _logger.database('MIGRATION', 'v4→v5 migration completed successfully');
     } catch (e, stackTrace) {
       await _logger.database('MIGRATION', 'Migration error', error: e, stackTrace: stackTrace);
       rethrow;
     }
   }
   ```

3. **Upgrade Handler Update**:
   ```dart
   Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
     // ... existing migrations ...

     if (oldVersion < 5) {
       await _migrateV4ToV5(db);
     }

     // ...
   }
   ```

4. **Utility Method**: `clearWorkEntryTable()`
   ```dart
   /// Clear work_entry table (remove all data but keep structure)
   Future<void> clearWorkEntryTable() async {
     try {
       await _logger.database('CLEAR', 'Clearing work_entry table');
       final db = await database;
       await db.delete('work_entry');
       await _logger.database('CLEAR', 'work_entry table cleared successfully');
     } catch (e, stackTrace) {
       await _logger.database('CLEAR', 'Failed to clear work_entry table', error: e, stackTrace: stackTrace);
       rethrow;
     }
   }
   ```

### 2. Migration Behavior

When the app starts next time:
- Database version check: `4` → `5`
- Automatic execution of `_migrateV4ToV5()`
- All rows in `work_entry` table deleted
- Table structure preserved
- Foreign key relationships intact

### 3. What Remains Unchanged

- ✅ Table structure (`work_entry` schema)
- ✅ Indexes on `project_id` and `is_draft`
- ✅ Foreign key constraint to `projects` table
- ✅ Timestamp triggers
- ✅ Other database tables (categories, projects, dpr_data, work_data, monitoring_data)

## Testing Verification

To verify the migration works:

1. **Check Database Version**:
   ```dart
   final db = await DatabaseHelper.instance.database;
   final version = await db.getVersion();
   print('Database version: $version'); // Should print 5
   ```

2. **Check work_entry Table is Empty**:
   ```dart
   final db = await DatabaseHelper.instance.database;
   final count = Sqflite.firstIntValue(
     await db.rawQuery('SELECT COUNT(*) FROM work_entry')
   );
   print('work_entry rows: $count'); // Should print 0
   ```

3. **Verify Table Structure**:
   ```dart
   final db = await DatabaseHelper.instance.database;
   final result = await db.rawQuery('PRAGMA table_info(work_entry)');
   print(result); // Should show all columns intact
   ```

## UI Impact

### Current Behavior After Migration:

1. **Work Entry Tab**:
   - Form fields will be empty (no data to load)
   - User can interact with UI
   - Attempting to save will create new entries with new schema

2. **Review Tab**:
   - Grid will show empty state
   - No completion percentages (no data)
   - Filters will work but return no results

## Rollback Plan

If needed to rollback:

1. **Option A**: Delete database file
   ```dart
   await DatabaseHelper.instance.deleteDB();
   // App will recreate with fresh schema
   ```

2. **Option B**: Restore from backup
   - Locate: `[AppData]/databases/msidc.db`
   - Replace with backup copy
   - Restart app

## Next Phase Prerequisites

Before moving to Phase 2:
- [ ] Confirm UI displays correctly with empty data
- [ ] Verify no errors in logs during migration
- [ ] Document desired new input fields
- [ ] Design new database schema

## Logs to Monitor

Watch for these log entries:
```
[DATABASE][UPGRADE] Upgrading database from v4 to v5
[DATABASE][MIGRATION] Starting v4→v5 migration
[DATABASE][MIGRATION] Clearing all data from work_entry table for restructuring
[DATABASE][MIGRATION] work_entry table cleared successfully
[DATABASE][MIGRATION] v4→v5 migration completed successfully
[DATABASE][UPGRADE] Database upgrade completed successfully
```

## Summary

✅ Database version upgraded: v4 → v5
✅ Migration script created: `_migrateV4ToV5()`
✅ All work_entry data cleared
✅ Table structure preserved
✅ Utility method added: `clearWorkEntryTable()`
✅ Ready for Phase 2: New Input Design
