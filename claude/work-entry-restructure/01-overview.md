# Work Entry & Review Tabs Restructuring - Overview

**Date Started**: 2026-01-10
**Status**: In Progress - UI Changes Phase
**Approach**: UI-First (Change UI, then functionality later)

## Project Context

This folder contains documentation for the complete restructuring of the Work Entry and Review tabs in the MSIDC project management application.

## ⚠️ APPROACH CHANGE (2026-01-10)

**Previous Approach**: Database cleanup first, then UI changes
**New Approach**: UI changes first, functionality changes later
**Reason**: User discarded database changes, wants to see UI updates first

Database version reverted to: v4 (no v5 migration)

### Navigation Flow
```
Dashboard
  → CategoriesScreen (categories_screen.dart:917-926)
    → ProjectsScreen (projects_screen.dart:387-395)
      → ProjectDetailScreen (project_detail_screen.dart:130-157)
        → TabBar with 2 tabs:
          1. Work Entry Tab (work_entry_tab.dart)
          2. Review Tab (review_tab.dart)
```

## Restructuring Goals

1. **Keep the UI**: Maintain the existing tab structure and layout
2. **Change Inputs**: Replace the current 181-field form with new input fields
3. **Update Database**: Clear old schema and create new one aligned with new inputs
4. **Preserve Architecture**: Maintain repository pattern and state management

## Current State (Before Restructuring)

### Database Table: `work_entry`
- **Primary Key**: `id` (INTEGER)
- **Foreign Keys**:
  - `project_id` → `projects(id)` ON DELETE CASCADE
- **Metadata Fields** (7):
  - `work_id` (TEXT)
  - `name_of_work` (TEXT)
  - `person_responsible` (TEXT)
  - `post_held` (TEXT)
  - `pending_with` (TEXT)
  - `is_draft` (INTEGER: 0=final, 1=draft)
  - `created_at`, `updated_at` (TEXT timestamps)
- **Data Sections** (3 JSON columns):
  - `dpr_section` (TEXT/JSON) - 65 fields
  - `work_section` (TEXT/JSON) - 26 fields
  - `pms_section` (TEXT/JSON) - 90 fields
- **Total Dynamic Fields**: 181 across all sections

### Model: WorkEntryData
- **Location**: `lib/data/models/work_entry_data.dart`
- Manages 181 fields with JSON serialization
- Sections: DPR (65), Work (26), PMS (90)

### Repository: WorkEntryRepository
- **Location**: `lib/core/database/repositories/work_entry_repository.dart`
- CRUD operations for work_entry table
- Draft/final version management

### UI Components
1. **Work Entry Tab** (`lib/presentation/widgets/module_tabs/work_entry_tab.dart`)
   - Form with 4 sections: Basic Info, DPR, Work, PMS
   - Auto-save draft functionality
   - Field validation

2. **Review Tab** (`lib/presentation/widgets/module_tabs/review_tab.dart`)
   - Grid view of 33 review components
   - Section filters (DPR, Work, PMS, All)
   - Completion percentage tracking

## Phases (New Approach)

### 🔄 Phase 1: UI Changes (CURRENT)
- Update Work Entry tab UI with new input fields
- Update Review tab UI
- Keep existing functionality intact (non-functional UI)
- Document all functionality changes needed
See: [05-phase1-ui-changes.md](./05-phase1-ui-changes.md)

### 📋 Phase 2: Functionality Implementation (PENDING)
- Implement functionality for new UI elements
- Update database schema
- Update models and repositories
- Connect UI to backend
See: [06-functionality-changes-list.md](./06-functionality-changes-list.md)

### 📋 Phase 3: Testing & Validation (PENDING)
- Unit tests
- Integration tests
- User acceptance testing

## Key Files Involved

| File Path | Purpose | Status |
|-----------|---------|--------|
| `lib/core/database/database_helper.dart` | Database schema & migrations | ✅ Updated (v5) |
| `lib/data/models/work_entry_data.dart` | Data model | 🔄 Pending |
| `lib/core/database/repositories/work_entry_repository.dart` | Data access layer | 🔄 Pending |
| `lib/presentation/widgets/module_tabs/work_entry_tab.dart` | Work Entry UI | 🔄 Pending |
| `lib/presentation/widgets/module_tabs/review_tab.dart` | Review UI | 🔄 Pending |

## Important Notes

- **Backward Compatibility**: Migration v4→v5 clears all work_entry data
- **Draft Support**: New implementation should maintain draft/final version support
- **Foreign Keys**: Maintain cascade delete on project deletion
- **Audit Trail**: Consider implementing change tracking

## Next Steps

1. Define new input field requirements
2. Design new database schema
3. Plan UI changes
4. Implement changes phase by phase
