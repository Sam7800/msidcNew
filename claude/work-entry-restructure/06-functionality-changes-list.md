# Functionality Changes Required After UI Update

**Date**: 2026-01-10
**Purpose**: Comprehensive list of all functionality changes needed once UI is updated

## Overview

This document lists ALL functionality changes that will be required to make the new UI work with the backend. After UI changes are complete, this serves as a checklist for Phase 2 (Functionality Implementation).

---

## Phase 2: Backend & Functionality Changes

### 1. Database Schema Changes

#### 1.1 Update work_entry Table Structure
**File**: `lib/core/database/database_helper.dart`

**What to Change**:
- Modify `work_entry` table schema to match new input fields
- Options:
  - Option A: Keep JSON columns, update field names
  - Option B: Create new specific columns for each field
  - Option C: Create separate related tables (normalized)

**Required Changes**:
```dart
// In _createDB method (around line 452)
// Update table creation SQL to match new field structure

CREATE TABLE work_entry (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  project_id INTEGER NOT NULL,

  // Option A: Keep JSON approach
  basic_info_section TEXT,  // New name for metadata
  [new_section_name]_section TEXT,  // Replace dpr_section
  [new_section_name]_section TEXT,  // Replace work_section
  [new_section_name]_section TEXT,  // Replace pms_section

  // Option B: Specific columns
  // Add individual columns for each new field

  is_draft INTEGER DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);
```

**Migration Required**: YES
- Create migration v4→v5 (or v5→v6 if v5 exists)
- Data migration strategy if existing data needs preservation

**Estimated Changes**: 50-100 lines

---

#### 1.2 Update Indexes
**File**: `lib/core/database/database_helper.dart`

**What to Change**:
- Review and update indexes based on new query patterns
- Add indexes for frequently queried fields

**Required Changes**:
```dart
// Add/modify indexes for new fields
CREATE INDEX idx_work_entry_[new_field] ON work_entry([new_field]);
```

**Estimated Changes**: 10-20 lines

---

### 2. Data Model Changes

#### 2.1 Update WorkEntryData Model
**File**: `lib/data/models/work_entry_data.dart`

**Current Structure**: 181 fields across 3 JSON sections
**New Structure**: To be defined based on new UI fields

**What to Change**:
- Remove old field definitions (dprSection, workSection, pmsSection)
- Add new field definitions matching new UI
- Update JSON serialization methods (toJson, fromJson)
- Update field getters/setters
- Update constructor

**Example Changes**:
```dart
class WorkEntryData {
  final int? id;
  final int projectId;

  // Remove old sections
  // final Map<String, dynamic> dprSection;
  // final Map<String, dynamic> workSection;
  // final Map<String, dynamic> pmsSection;

  // Add new sections/fields
  final Map<String, dynamic> [newSection1];
  final Map<String, dynamic> [newSection2];
  final Map<String, dynamic> [newSection3];

  // ... rest of model

  // Update toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      '[new_section_1]': jsonEncode([newSection1]),
      '[new_section_2]': jsonEncode([newSection2]),
      // ...
    };
  }

  // Update fromJson
  factory WorkEntryData.fromJson(Map<String, dynamic> json) {
    return WorkEntryData(
      id: json['id'] as int?,
      projectId: json['project_id'] as int,
      [newSection1]: _parseJsonSection(json['[new_section_1]']),
      // ...
    );
  }
}
```

**Estimated Changes**: 200-400 lines (major refactor)

---

#### 2.2 Create New Model Classes (If Needed)
**File**: `lib/data/models/[new_model].dart`

**What to Create**:
- If new UI introduces new data structures (e.g., tables, lists)
- Create dedicated model classes for reusability

**Example**:
```dart
// If new UI has a milestone tracking table
class MilestoneData {
  final String description;
  final DateTime? targetDate;
  final double? targetAmount;
  // ...
}
```

**Estimated Changes**: 50-100 lines per new model

---

### 3. Repository Changes

#### 3.1 Update WorkEntryRepository
**File**: `lib/core/database/repositories/work_entry_repository.dart`

**What to Change**:
- Update CRUD methods to work with new model structure
- Update SQL queries to match new table schema
- Add/remove methods based on new functionality

**Methods to Update**:
1. `getWorkEntryByProjectId()` - Update SQL SELECT
2. `getWorkEntryOrDraftByProjectId()` - Update SQL SELECT
3. `getDraftByProjectId()` - Update SQL SELECT
4. `insertWorkEntry()` - Update SQL INSERT
5. `updateWorkEntry()` - Update SQL UPDATE
6. `deleteWorkEntry()` - May need changes
7. `saveDraft()` - Update logic

**Example Changes**:
```dart
Future<WorkEntryData?> getWorkEntryByProjectId(int projectId) async {
  final db = await DatabaseHelper.instance.database;

  // Update SQL to match new schema
  final result = await db.query(
    'work_entry',
    where: 'project_id = ? AND is_draft = 0',
    whereArgs: [projectId],
  );

  if (result.isEmpty) return null;

  // Update fromJson to use new model
  return WorkEntryData.fromJson(result.first);
}
```

**Estimated Changes**: 100-200 lines

---

### 4. UI Component Changes

#### 4.1 Update Work Entry Tab Logic
**File**: `lib/presentation/widgets/module_tabs/work_entry_tab.dart`

**What to Change**:
1. **Form Data Storage** (`_formData` Map):
   - Update keys to match new field names
   - Remove old section data extraction methods

2. **Data Loading** (`_loadData` method):
   - Update to load new field structure
   - Update controller assignments for new fields

3. **Data Saving** (`_saveData` method):
   - Update to save new field structure
   - Update validation logic

4. **Section Data Extraction** (methods like `_getDPRSectionData`):
   - Completely rewrite to extract new sections
   - Update field key lists

5. **Search Functionality** (`_performSearch`):
   - Update search keywords for new sections
   - Update section content strings

**Example Changes**:
```dart
// Remove old methods
// Map<String, dynamic> _getDPRSectionData() { ... }
// Map<String, dynamic> _getWorkSectionData() { ... }
// Map<String, dynamic> _getPMSSectionData() { ... }

// Add new methods
Map<String, dynamic> _get[NewSection1]Data() {
  final keys = [
    '[new_field_1]',
    '[new_field_2]',
    // ...
  ];

  return {
    for (var key in keys)
      if (_formData.containsKey(key))
        key: _formData[key],
  };
}
```

**Estimated Changes**: 300-500 lines

---

#### 4.2 Update Review Tab Logic
**File**: `lib/presentation/widgets/module_tabs/review_tab.dart`

**What to Change**:
- Update data provider usage if model changes
- Update section filtering if sections change
- Minimal changes expected (mostly display logic)

**Estimated Changes**: 20-50 lines

---

### 5. Review Component Mapping Changes

#### 5.1 Update ReviewComponentMapper
**File**: `lib/utils/review_component_mapper.dart`

**MAJOR CHANGES REQUIRED**: This file defines all 37 review components

**What to Change**:
1. **Component Configurations** (`getAllComponents()` method):
   - Update `fieldKeys` for each component to match new data fields
   - Update `stateField` if state logic changes
   - Add/remove components if needed
   - Update component titles, colors, icons if needed

2. **Field Extraction** (`extractComponentData()` method):
   - Update section data extraction logic
   - Update to work with new model structure

3. **Field Mapping** (`_getMapperKey()` method):
   - Update if component IDs change
   - Update mapper key logic

**Example Changes**:
```dart
// Update component config
ReviewComponentConfig(
  type: ReviewComponentType.aa,
  id: 'AA',
  title: 'Administrative Approval',
  section: ReviewSection.dpr,

  // Update these field keys to match new model
  fieldKeys: [
    '[new_field_1]',  // was 'aa_status'
    '[new_field_2]',  // was 'broad_scope_aa'
    '[new_field_3]',  // was 'aa_amount'
    // ...
  ],

  stateField: '[new_state_field]',  // was 'aa_status'
  primaryColor: const Color(0xFF6366F1),
  icon: Icons.approval,
),
```

**Estimated Changes**: 200-400 lines (update all 37 components)

---

#### 5.2 Update FieldNameMapper (If Exists)
**File**: `lib/utils/field_name_mapper.dart`

**What to Change**:
- Update field name translations for new fields
- Add mappings for new component types

**Estimated Changes**: 50-150 lines

---

### 6. Provider Changes

#### 6.1 Update Review Providers
**File**: `lib/presentation/providers/review_providers.dart`

**What to Change**:
- Update `workEntryDataProvider` if model structure changes
- Update any computed providers that depend on field structure

**Example Changes**:
```dart
@riverpod
Future<WorkEntryData?> workEntryData(
  WorkEntryDataRef ref,
  int projectId,
) async {
  final repository = ref.watch(workEntryRepositoryProvider);

  // Logic likely stays the same, but ensure it works with new model
  return await repository.getWorkEntryOrDraftByProjectId(projectId);
}
```

**Estimated Changes**: 10-30 lines

---

#### 6.2 Update Repository Providers
**File**: `lib/presentation/providers/repository_providers.dart`

**What to Change**:
- Likely minimal changes (providers just instantiate repositories)
- Update if repository constructor changes

**Estimated Changes**: 0-10 lines

---

### 7. Review Component UI Changes

#### 7.1 Update ReviewComponentConfig Model
**File**: `lib/domain/models/review_component_config.dart`

**What to Change**:
- Update `states` definitions if state logic changes
- Update field key validation
- Add new properties if needed

**Estimated Changes**: 20-50 lines

---

#### 7.2 Update Review Section Grid
**File**: `lib/presentation/widgets/review/review_section_grid.dart`

**What to Change**:
- Update grid layout if component count changes
- Update component rendering logic if data structure changes

**Estimated Changes**: 50-100 lines

---

#### 7.3 Update Review Card Base
**File**: `lib/presentation/widgets/review/review_card_base.dart`

**What to Change**:
- Update field display logic if field structure changes
- Update state badge logic if state fields change

**Estimated Changes**: 30-80 lines

---

### 8. Validation & Business Logic

#### 8.1 Add Field Validation
**Files**: Multiple (work_entry_tab.dart, model classes)

**What to Add**:
- Field validation rules for new inputs
- Required field checks
- Data type validations (date, number, etc.)
- Range validations
- Cross-field validations

**Example**:
```dart
// In Work Entry Tab
String? _validate[NewField](String? value) {
  if (value == null || value.isEmpty) {
    return 'This field is required';
  }

  if (/* custom validation */) {
    return 'Invalid format';
  }

  return null;
}
```

**Estimated Changes**: 100-200 lines

---

#### 8.2 Update Business Logic
**Files**: Various

**What to Update**:
- Completion percentage calculations
- Progress tracking logic
- State transition rules
- Auto-fill logic (if any)

**Estimated Changes**: 50-150 lines

---

### 9. Import/Export Functionality

#### 9.1 Update CSV Import Logic (If Exists)
**Files**: Import service files

**What to Change**:
- Update field mapping for new structure
- Update CSV column headers
- Update data validation

**Estimated Changes**: 100-200 lines

---

#### 9.2 Update CSV Export Logic (If Exists)
**Files**: Export service files

**What to Change**:
- Update field extraction for new structure
- Update CSV column headers
- Update data formatting

**Estimated Changes**: 100-200 lines

---

### 10. Testing

#### 10.1 Unit Tests
**Files**: `test/**/*.dart`

**What to Create/Update**:
- Model tests (toJson, fromJson, validation)
- Repository tests (CRUD operations)
- Component mapper tests
- Business logic tests

**Estimated Changes**: 300-500 lines (new tests)

---

#### 10.2 Integration Tests
**Files**: `integration_test/**/*.dart`

**What to Create/Update**:
- Work Entry tab tests (form fill, save, validation)
- Review tab tests (data display, filtering)
- End-to-end workflow tests

**Estimated Changes**: 200-400 lines (new tests)

---

## Change Summary by File

| File | Est. Lines Changed | Priority | Complexity |
|------|-------------------|----------|-----------|
| `database_helper.dart` | 50-100 | HIGH | Medium |
| `work_entry_data.dart` | 200-400 | HIGH | High |
| `work_entry_repository.dart` | 100-200 | HIGH | Medium |
| `work_entry_tab.dart` | 300-500 | HIGH | High |
| `review_component_mapper.dart` | 200-400 | HIGH | High |
| `review_tab.dart` | 20-50 | MEDIUM | Low |
| `review_providers.dart` | 10-30 | MEDIUM | Low |
| `review_section_grid.dart` | 50-100 | MEDIUM | Medium |
| `review_card_base.dart` | 30-80 | LOW | Low |
| `field_name_mapper.dart` | 50-150 | MEDIUM | Medium |
| Various validation | 100-200 | HIGH | Medium |
| Import/Export | 200-400 | LOW | Medium |
| Tests | 500-900 | HIGH | Medium |
| **TOTAL** | **~1800-3500** | - | - |

---

## Implementation Order (Recommended)

### Step 1: Database & Models (Week 1)
1. Update database schema
2. Create migration
3. Update WorkEntryData model
4. Test database operations

### Step 2: Repository Layer (Week 1-2)
1. Update WorkEntryRepository methods
2. Test CRUD operations
3. Ensure data persistence works

### Step 3: Work Entry Tab (Week 2-3)
1. Update form data handling
2. Update save/load logic
3. Add validation
4. Test form functionality

### Step 4: Review Components (Week 3-4)
1. Update ReviewComponentMapper
2. Update field mappings
3. Test component rendering
4. Fix any display issues

### Step 5: Testing & Polish (Week 4-5)
1. Write unit tests
2. Write integration tests
3. Fix bugs
4. Performance optimization
5. User acceptance testing

---

## Risk Assessment

### High Risk Changes
1. **Database Migration**: Could lose data if not done carefully
2. **Model Structure**: Breaking change affects entire app
3. **Component Mapping**: All 37 components must be updated correctly

### Medium Risk Changes
1. **Repository Methods**: SQL query errors could cause crashes
2. **Form Validation**: Missing validation could allow bad data
3. **State Management**: Provider updates could break reactivity

### Low Risk Changes
1. **UI Tweaks**: Review tab display logic
2. **Import/Export**: Nice to have, not critical
3. **Icons/Colors**: Visual changes only

---

## Rollback Plan

If functionality changes fail:

1. **Database**: Keep old schema until new one is tested
2. **Code**: Use feature flags to toggle between old/new logic
3. **Git**: Maintain separate branch for new functionality
4. **Testing**: Thorough testing before merging to main

---

## Questions to Answer Before Implementation

1. **What are the new input fields?**
   - List all new fields for Work Entry tab
   - Define field types (text, date, number, dropdown, etc.)
   - Define required vs. optional

2. **How should data be structured?**
   - JSON columns vs. normalized tables?
   - Single table vs. multiple related tables?

3. **Do review components change?**
   - Same 37 components or different ones?
   - Same sections (DPR/Work/PMS) or new sections?

4. **What about existing data?**
   - Migrate old data or start fresh?
   - Backwards compatibility needed?

5. **Validation rules?**
   - What fields are required?
   - What formats are valid?
   - Any cross-field dependencies?

---

## Next Steps

1. **Define New UI Fields**: Create detailed spec of new input fields
2. **Design Database Schema**: Plan new table structure
3. **Create Mockups**: If visual changes needed
4. **Prototype**: Build small prototype to test approach
5. **Implement**: Follow implementation order above

---

## Notes

- All line count estimates are approximate
- Actual changes may vary based on final UI design
- Consider using code generation tools for repetitive changes (e.g., field mappings)
- Ensure comprehensive testing before deploying to production
- Consider data backup before database migration
