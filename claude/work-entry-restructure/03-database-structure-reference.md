# Database Structure Reference

Complete reference for the current database schema (v5) as of 2026-01-10.

## Database Overview

- **Database Name**: `msidc.db`
- **Current Version**: 5
- **Database Type**: SQLite (via sqflite_common_ffi)
- **Location**: Platform-specific databases directory
- **Foreign Keys**: ENABLED

## Complete Schema Diagram

```
┌─────────────┐
│ categories  │
│ (5 default) │
└──────┬──────┘
       │ 1
       │
       │ M
┌──────▼──────────┐
│   projects      │
│   (34 total)    │
└──────┬──────────┘
       │ 1
       │
       ├─────┬─────────┬──────────────┬─────────────┐
       │ 1   │ 1       │ 1            │ M           │
       │     │         │              │             │
   ┌───▼───┐ │    ┌────▼─────┐   ┌───▼──────┐  ┌──▼─────────┐
   │  dpr  │ │    │   work   │   │monitoring│  │work_entry  │
   │ _data │ │    │  _data   │   │  _data   │  │ (CLEARED)  │
   └───────┘ │    └──────────┘   └──────────┘  └────────────┘
             │
        ┌────▼────────┐
        │ audit_log   │
        │(SET NULL FK)│
        └─────────────┘
```

## Table: work_entry (PRIMARY FOCUS)

### Current Schema (v5)

```sql
CREATE TABLE work_entry (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  project_id INTEGER NOT NULL,
  work_id TEXT,
  name_of_work TEXT,
  person_responsible TEXT,
  post_held TEXT,
  pending_with TEXT,
  dpr_section TEXT,      -- JSON blob (65 fields)
  work_section TEXT,     -- JSON blob (26 fields)
  pms_section TEXT,      -- JSON blob (90 fields)
  is_draft INTEGER DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_work_entry_project ON work_entry(project_id);
CREATE INDEX idx_work_entry_draft ON work_entry(is_draft);

-- Triggers
CREATE TRIGGER update_work_entry_timestamp
AFTER UPDATE ON work_entry
BEGIN
  UPDATE work_entry SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;
```

### Field Descriptions

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | INTEGER | NO | AUTO | Primary key |
| `project_id` | INTEGER | NO | - | Foreign key to projects table |
| `work_id` | TEXT | YES | NULL | Work identifier/code |
| `name_of_work` | TEXT | YES | NULL | Work description/title |
| `person_responsible` | TEXT | YES | NULL | Person handling this work |
| `post_held` | TEXT | YES | NULL | Position/designation |
| `pending_with` | TEXT | YES | NULL | Current pending authority |
| `dpr_section` | TEXT | YES | NULL | JSON: DPR fields (65 fields) |
| `work_section` | TEXT | YES | NULL | JSON: Work fields (26 fields) |
| `pms_section` | TEXT | YES | NULL | JSON: PMS fields (90 fields) |
| `is_draft` | INTEGER | YES | 0 | 0=final, 1=draft |
| `created_at` | TEXT | NO | CURRENT_TIMESTAMP | Creation timestamp |
| `updated_at` | TEXT | NO | CURRENT_TIMESTAMP | Last update timestamp |

### JSON Section Structures (OLD - FOR REFERENCE)

#### DPR Section (65 fields)
Fields include: AA status/amount/date, DPR bid process, CSD, technical evaluation, bid acceptance, PBG, insurance, work order, survey, technical work, BOQ, clearances, final DPR

#### Work Section (26 fields)
Fields include: Admin approval, tech sanction, DTP approval, NIT invitation, bid process, CSD replies, financial eval, offer acceptance, LOI, LOA, PBG, agreement, work order

#### PMS Section (90 fields)
Fields include: Agreement amount, 5 milestones (8 fields each), LD, COS, EOT, expenditure, renewals, revisions, final bill, LAQ/LCQ, audit paras, technical audit, revised AA, supplementary agreement

## Related Tables (For Context)

### Table: projects

```sql
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
  FOREIGN KEY (category_id) REFERENCES categories(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);
```

**Current Data**: 34 projects across 5 categories

### Table: categories

```sql
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
);
```

**Default Categories**:
1. Nashik Kumbhmela (8 projects)
2. HAM Projects (2 projects)
3. Nagpur Works (14 projects)
4. NHAI Projects (4 projects)
5. Other Projects (6 projects)

### Table: dpr_data

19 date fields for DPR milestones (one-to-one with projects)

### Table: work_data

15 date fields for work milestones (one-to-one with projects)

### Table: monitoring_data

Financial tracking with 5 milestone sets, expenditure, and audit fields (one-to-one with projects)

### Table: import_logs

CSV import tracking (no FK to projects)

### Table: audit_log

Change tracking with optional FK to projects (SET NULL on delete)

## Migration History

| Version | Migration | Description |
|---------|-----------|-------------|
| v1 | Initial | Original schema with text-based categories |
| v2 | v1→v2 | Categories table + category_id FK in projects |
| v3 | v2→v3 | Add work_id, name_of_work to work_entry |
| v4 | v3→v4 | Add location, status to projects |
| v5 | v4→v5 | **Clear all work_entry data for restructuring** |

## Important Constraints

1. **Cascade Deletes**:
   - Delete project → Deletes all related work_entry, dpr_data, work_data, monitoring_data
   - Delete project → Sets audit_log.project_id to NULL

2. **Unique Constraints**:
   - projects.sr_no (no duplicate serial numbers)
   - categories.name (no duplicate category names)
   - dpr_data.project_id (one DPR record per project)
   - work_data.project_id (one Work record per project)
   - monitoring_data.project_id (one PMS record per project)

3. **Foreign Key Restrictions**:
   - Cannot delete category if projects reference it
   - Categories can be updated (CASCADE to projects)

## Data Flow

```
User Input (work_entry_tab.dart)
  ↓
WorkEntryData Model (work_entry_data.dart)
  ↓
WorkEntryRepository (work_entry_repository.dart)
  ↓
DatabaseHelper (database_helper.dart)
  ↓
SQLite Database (msidc.db → work_entry table)
  ↓
WorkEntryRepository (fetch)
  ↓
Review Tab (review_tab.dart)
```

## File Locations

- **Database Helper**: `lib/core/database/database_helper.dart`
- **Model**: `lib/data/models/work_entry_data.dart`
- **Repository**: `lib/core/database/repositories/work_entry_repository.dart`
- **DB File**: `[Platform AppData]/databases/msidc.db`

## Current State (After Phase 1)

```sql
SELECT COUNT(*) FROM work_entry;
-- Returns: 0 (all data cleared)

SELECT * FROM work_entry;
-- Returns: (empty result set)

PRAGMA table_info(work_entry);
-- Returns: (13 columns as defined above)
```

## Notes for Next Phase

When redesigning the schema for new inputs:

1. **Keep**:
   - `id`, `project_id`, `created_at`, `updated_at` (essential)
   - `is_draft` (if draft functionality needed)
   - Indexes and triggers

2. **Consider Removing/Changing**:
   - `work_id`, `name_of_work` (if not needed)
   - `person_responsible`, `post_held`, `pending_with` (may move to new fields)
   - `dpr_section`, `work_section`, `pms_section` (JSON blobs - replace with new structure)

3. **Design Decisions**:
   - Single JSON column vs. multiple specific columns?
   - Multiple related tables vs. one normalized table?
   - Keep draft support or remove?
   - Version history tracking?
