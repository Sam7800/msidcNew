# MSIDC Project Management System - Simplified Database Design

## Overview
This document describes the **simplified** SQLite database structure for the MSIDC Project Management System.

**Total Tables:** 5 (simplified from 10)
**Database Name:** `msidc.db`

---

## Why Simplified?

The previous design had 10 tables which was unnecessarily complex. This new design consolidates everything into 5 essential tables:

### Old Design (10 Tables) ❌
- categories
- projects
- dpr_data ← Separate table
- work_data ← Separate table
- monitoring_data ← Separate table
- work_entry
- work_entry_attachments ← Separate table
- critical_subsections
- import_logs ← Not needed
- audit_log ← Not needed

### New Design (5 Tables) ✅
1. **categories** - Project categories
2. **projects** - Project basic info
3. **project_details** - All DPR/Work/Monitoring data consolidated
4. **work_entry** - Work entry tracking
5. **critical_items** - Critical subsections tracking

**Removed:** import_logs, audit_log, work_entry_attachments (can store file paths in work_entry JSON)

---

## Table Definitions

### 1. **categories**
**Purpose:** Stores project categories for classification.

**Columns:**
| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique category ID |
| `name` | TEXT | NOT NULL, UNIQUE | Category name |
| `color_hex` | TEXT | DEFAULT '#0061FF' | Display color |
| `icon_name` | TEXT | DEFAULT 'folder' | Icon identifier |
| `display_order` | INTEGER | DEFAULT 0 | Sort order |
| `created_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | Created timestamp |
| `updated_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | Updated timestamp |

**Default Categories:**
1. Nashik Kumbhmela (#0061FF, festival)
2. HAM Projects (#00E676, handshake)
3. Nagpur Works (#FF1744, apartment)
4. NHAI Projects (#FF9100, route)
5. Other Projects (#9C27B0, business)

---

### 2. **projects**
**Purpose:** Core project information.

**Columns:**
| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique project ID |
| `sr_no` | INTEGER | NOT NULL, UNIQUE | Serial/Reference number |
| `name` | TEXT | NOT NULL | Project name |
| `category_id` | INTEGER | NOT NULL, FK → categories(id) | Category reference |
| `location` | TEXT | DEFAULT 'Maharashtra' | Project location |
| `status` | TEXT | DEFAULT 'In Progress' | Project status |
| `created_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | Created timestamp |
| `updated_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | Updated timestamp |

**Indexes:**
- `idx_projects_category` on `category_id`
- `idx_projects_sr_no` on `sr_no`

**Foreign Keys:**
- `category_id` → `categories(id)` ON DELETE RESTRICT

---

### 3. **project_details**
**Purpose:** All project details (DPR, Work, Monitoring) consolidated in ONE table.

**Columns:**
| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique detail record ID |
| `project_id` | INTEGER | NOT NULL, UNIQUE, FK → projects(id) | Project reference |
| `dpr_data` | TEXT | NULL | All DPR fields as JSON |
| `work_data` | TEXT | NULL | All Work fields as JSON |
| `monitoring_data` | TEXT | NULL | All Monitoring fields as JSON |
| `created_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | Created timestamp |
| `updated_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | Updated timestamp |

**Indexes:**
- `idx_project_details_project` on `project_id`

**Foreign Keys:**
- `project_id` → `projects(id)` ON DELETE CASCADE

**JSON Structure Examples:**

```json
{
  "dpr_data": {
    "broad_scope": "Highway construction",
    "bid_doc_dpr": "Completed",
    "invite": "2024-01-15",
    "prebid": "2024-02-01",
    "csd": "In Progress",
    "bid_submit": "2024-03-15",
    "work_order": "Approved",
    "inception_report": "Submitted",
    "survey": "Completed",
    "alignment_layout": "Approved",
    "draft_dpr": "Under Review",
    "drawings": "50% Complete",
    "boq": "Final",
    "env_clearance": "Obtained",
    "cash_flow": "Prepared",
    "la_proposal": "Submitted",
    "utility_shifting": "In Progress",
    "final_dpr": "Approved",
    "bid_doc_work": "Prepared"
  },
  "work_data": {
    "aa": "Approved",
    "dpr": "Complete",
    "ts": "Obtained",
    "bid_doc": "Prepared",
    "bid_invite": "2024-04-01",
    "prebid": "2024-04-15",
    "csd": "Completed",
    "bid_submit": "2024-05-01",
    "fin_bid": "Opened",
    "loi": "Issued",
    "loa": "Issued",
    "pbg": "Submitted",
    "agreement": "Signed",
    "work_order": "Issued"
  },
  "monitoring_data": {
    "agmnt_amount": 50000000,
    "appointed_date": "2024-06-01",
    "tender_period": 180,
    "first_milestone_date": "2024-09-01",
    "first_milestone_amount": 10000000,
    "second_milestone_date": "2024-12-01",
    "second_milestone_amount": 15000000,
    "third_milestone_date": "2025-03-01",
    "third_milestone_amount": 15000000,
    "fourth_milestone_date": "2025-06-01",
    "fourth_milestone_amount": 7000000,
    "fifth_milestone_date": "2025-09-01",
    "fifth_milestone_amount": 3000000,
    "ld": 500000,
    "cos": 48000000,
    "eot": 30,
    "cum_exp": 35000000,
    "final_bill": null,
    "audit_para": "No objections",
    "replies": "All cleared",
    "laq_lcq": "None",
    "tech_audit": "Completed",
    "rev_aa": "Not required"
  }
}
```

---

### 4. **work_entry**
**Purpose:** Track work entries with flexible JSON storage for all subsections.

**Columns:**
| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique work entry ID |
| `project_id` | INTEGER | NOT NULL, FK → projects(id) | Project reference |
| `work_id` | TEXT | NULL | Work identifier |
| `name_of_work` | TEXT | NULL | Work name |
| `person_responsible` | TEXT | NULL | Responsible person |
| `post_held` | TEXT | NULL | Position held |
| `pending_with` | TEXT | NULL | Currently pending with |
| `dpr_section` | TEXT | NULL | DPR subsections data (JSON) |
| `work_section` | TEXT | NULL | Work subsections data (JSON) |
| `pms_section` | TEXT | NULL | PMS subsections data (JSON) |
| `attachments` | TEXT | NULL | File attachments data (JSON) |
| `is_draft` | INTEGER | DEFAULT 0 | Draft status (0=final, 1=draft) |
| `created_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | Created timestamp |
| `updated_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | Updated timestamp |

**Indexes:**
- `idx_work_entry_project` on `project_id`
- `idx_work_entry_draft` on `is_draft`
- `idx_work_entry_work_id` on `work_id`

**Foreign Keys:**
- `project_id` → `projects(id)` ON DELETE CASCADE

**Attachments JSON Structure:**
```json
{
  "attachments": [
    {
      "category": "DPR",
      "subsection": "bid_doc_dpr",
      "file_name": "bid_document.pdf",
      "file_path": "/storage/files/bid_document.pdf",
      "file_type": "PDF",
      "file_size": 2048576,
      "uploaded_at": "2024-01-15T10:30:00"
    },
    {
      "category": "Work",
      "subsection": "loa",
      "file_name": "letter_of_acceptance.pdf",
      "file_path": "/storage/files/loa.pdf",
      "file_type": "PDF",
      "file_size": 1024000,
      "uploaded_at": "2024-02-20T14:15:00"
    }
  ]
}
```

---

### 5. **critical_items**
**Purpose:** Track critical subsections for highlighting and tracking.

**Columns:**
| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique critical item ID |
| `project_id` | INTEGER | NOT NULL, FK → projects(id) | Project reference |
| `category` | TEXT | NOT NULL, CHECK IN ('DPR', 'Work', 'PMS') | Category type |
| `subsection_name` | TEXT | NOT NULL | Subsection identifier |
| `created_at` | TEXT | DEFAULT CURRENT_TIMESTAMP | Marked critical timestamp |

**Indexes:**
- `idx_critical_project` on `project_id`
- `idx_critical_category` on `category`

**Foreign Keys:**
- `project_id` → `projects(id)` ON DELETE CASCADE

**Unique Constraint:**
- `(project_id, category, subsection_name)` - One entry per subsection per project

---

## Database Relationships

```
categories (1) ──────< (N) projects (1) ──┬──< (N) work_entry
                                           ├──< (1) project_details
                                           └──< (N) critical_items
```

### Relationship Details:
- **One-to-Many:** 1 Category → Many Projects
- **One-to-Many:** 1 Project → Many Work Entries
- **One-to-One:** 1 Project → 1 Project Details
- **One-to-Many:** 1 Project → Many Critical Items

---

## Auto-Update Triggers

All tables have automatic `updated_at` timestamp triggers:
1. `update_categories_timestamp`
2. `update_projects_timestamp`
3. `update_project_details_timestamp`
4. `update_work_entry_timestamp`

---

## Benefits of Simplified Design

### ✅ Advantages:
1. **Less Complexity** - Only 5 tables instead of 10
2. **Easier Queries** - No need to join multiple detail tables
3. **Flexible Storage** - JSON allows adding fields without schema changes
4. **Better Performance** - Fewer joins, faster queries
5. **Easier Maintenance** - Simpler to understand and modify
6. **File Management** - Attachments stored in JSON, no separate table needed

### 🎯 What Got Consolidated:
- `dpr_data` + `work_data` + `monitoring_data` → `project_details` (one table with JSON)
- `work_entry_attachments` → `work_entry.attachments` (JSON field)
- `critical_subsections` → `critical_items` (renamed for clarity)
- `import_logs` → Removed (not essential)
- `audit_log` → Removed (can be added later if needed)

---

## Sample Queries

### Get Project with All Details
```sql
SELECT
  p.*,
  c.name as category_name,
  c.color_hex,
  pd.dpr_data,
  pd.work_data,
  pd.monitoring_data
FROM projects p
JOIN categories c ON p.category_id = c.id
LEFT JOIN project_details pd ON p.id = pd.project_id
WHERE p.id = 1;
```

### Get Work Entries for Project
```sql
SELECT *
FROM work_entry
WHERE project_id = 1 AND is_draft = 0
ORDER BY updated_at DESC;
```

### Get Critical Items for Project
```sql
SELECT *
FROM critical_items
WHERE project_id = 1
ORDER BY category, subsection_name;
```

---

## Migration Plan

### From Current (v6) to Simplified Design:

1. **Create new simplified tables**
2. **Migrate data:**
   - Keep `categories` and `projects` as-is
   - Merge `dpr_data`, `work_data`, `monitoring_data` → `project_details` (convert to JSON)
   - Keep `work_entry` structure, add `attachments` JSON field
   - Merge attachment records into `work_entry.attachments` JSON
   - Rename `critical_subsections` → `critical_items`
3. **Drop old tables:**
   - Drop `dpr_data`, `work_data`, `monitoring_data`
   - Drop `work_entry_attachments`
   - Drop `import_logs`, `audit_log`
4. **Update application code** to use new structure

---

## Database Size Estimate

### Simplified Design Storage:
- **categories**: ~5 rows (< 1 KB)
- **projects**: ~34 projects (< 10 KB)
- **project_details**: ~34 rows with JSON (< 100 KB)
- **work_entry**: 100-1000 entries (100-500 KB)
- **critical_items**: ~50-200 entries (< 5 KB)

**Estimated Total:** 500 KB - 1 MB (excluding attachment files)

---

## Implementation Status

🔴 **NOT YET IMPLEMENTED** - This is the proposed simplified design.

Current implementation still has 10 tables. After your approval, I will:
1. Create migration script
2. Consolidate tables
3. Update all repository code
4. Test the migration

---

## Your Approval Needed

Please confirm:
1. ✅ **5 tables is good** (categories, projects, project_details, work_entry, critical_items)
2. ✅ **JSON storage for details** instead of separate columns
3. ✅ **Attachments in JSON** instead of separate table
4. ✅ **Remove audit_log and import_logs**

Once you approve, I'll implement this simplified database structure!
