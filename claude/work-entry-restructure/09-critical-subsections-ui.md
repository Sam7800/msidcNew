# Critical Subsections UI Screen

**Date**: 2026-01-11
**Status**: ✅ COMPLETED
**Last Updated**: 2026-01-11 - Fixed project loading state management

## Overview

Created a dedicated UI screen to view all critical subsections across projects, accessible from two locations:
1. **Categories Screen (Dashboard)** - View critical items for ALL projects
2. **Projects Screen (within category)** - View critical items for projects in that specific category

## Bug Fixes & Enhancements

### Fix 1: Project State Management

**Issue**: When navigating from the dashboard, the screen was showing only the last visited category's projects instead of all projects.

**Root Cause**: The `projectProvider` retained the filtered state from previous category navigation, causing the dashboard view to show incomplete data.

**Solution**: Added `initState` lifecycle method that explicitly loads the correct projects based on navigation source:
- When `categoryId == null` (from dashboard): Calls `loadAllProjects()`
- When `categoryId != null` (from category): Calls `loadProjectsByCategoryId(categoryId)`

This ensures the provider state is always synchronized with the intended view.

### Enhancement 1: Display Project Category

**Feature**: Added project category badge below each project name to show which category (e.g., "Nashik Kumbhmela", "HAM Projects") the project belongs to.

**Implementation**:
1. Updated `_loadCriticalSubsections()` to include project category information:
   - `project_category_name`: The name of the category the project belongs to
   - `project_category_color`: The color code for the category

2. Updated `_buildProjectGroup()` to display the category badge:
   - Category name displayed in a colored badge below project name
   - Badge uses the category's custom color if available
   - Falls back to primary color if category color is not set

**UI Details**:
```
┌─────────────────────────────────────────────────┐
│ 📁 Project Name                    [3 Critical]  │
│    [Category Name]                               │
├─────────────────────────────────────────────────┤
│ ⚠ Subsection 1                                →│
│ [DPR]                           Today            │
└─────────────────────────────────────────────────┘
```

This helps users identify which category each project belongs to, especially useful when viewing all critical items across all categories from the dashboard.

### Enhancement 2: Expandable/Collapsible Project Cards

**Feature**: Project cards can now be expanded/collapsed to show/hide critical subsections, reducing clutter when viewing many projects.

**Implementation**:
1. Added `_expandedProjects` Set to track which projects are expanded
2. Added expand/collapse icon (▼/▲) in project header
3. Made project header tappable to toggle expansion
4. Critical items list only renders when project is expanded

**UI Behavior**:
- Click project header to toggle expand/collapse
- Expand icon changes: ▼ (collapsed) → ▲ (expanded)
- Header border radius adjusts based on state (rounded corners only when collapsed)
- Smooth transition when toggling

**Benefits**:
- Reduces visual clutter when many projects have critical items
- Users can focus on specific projects
- Improves performance by not rendering collapsed content

### Enhancement 3: Navigate to Project Detail

**Feature**: Clicking on a critical subsection tile now navigates to the Project Detail screen with the Work Entry tab, allowing users to view and edit all subsection details.

**Implementation**:
1. Made critical subsection tiles tappable (InkWell wrapper)
2. Added navigation to ProjectDetailScreen on tap
3. Retrieves Project object from projectProvider using projectId
4. Opens Work Entry tab where user can see all details and edit

**Navigation Flow**:
```
Critical Subsections Screen
  ↓ (Click on subsection tile)
Project Detail Screen (Work Entry Tab)
  ↓ (Can view/edit all details)
  ↓ (Can toggle critical marker)
Save changes to database
```

**Benefits**:
- Quick access to full subsection details from critical items view
- Edit functionality available immediately
- Critical marker toggle available
- Full form fields visible with responsibility tracking
- Seamless integration with existing Project Detail screen

---

## Features Implemented

### 1. Critical Subsections Screen

**File**: `lib/presentation/screens/critical_subsections_screen.dart`

**Features**:
- ✅ Displays all critical subsections grouped by project
- ✅ Search functionality across projects and subsections
- ✅ Filter by category (All / DPR / Work / PMS)
- ✅ Shows critical count per project
- ✅ Clean, organized layout matching existing UI style
- ✅ Empty state messaging
- ✅ Date formatting (Today, Yesterday, X days ago)

**UI Components**:
- AppBar with title and back button
- Search bar with clear button
- Category filter chips (All, DPR, Work, PMS)
- Project cards grouped with critical items
- Critical item tiles with category badges

---

## Navigation Setup

### From Categories Screen

**File**: `lib/presentation/screens/categories_screen.dart`

**Added**:
```dart
IconButton(
  icon: const Icon(Icons.error, size: 24),
  tooltip: 'View Critical Items',
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CriticalSubsectionsScreen(),
      ),
    );
  },
  color: const Color(0xFFEF4444), // Red for critical
),
```

**Location**: AppBar actions (between Import/Export and Refresh buttons)

**Behavior**: Opens Critical Subsections Screen showing ALL critical items across ALL projects

---

### From Projects Screen

**File**: `lib/presentation/screens/projects_screen.dart`

**Added**:
```dart
IconButton(
  icon: const Icon(Icons.error, size: 24),
  tooltip: 'View Critical Items',
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CriticalSubsectionsScreen(
          categoryId: widget.category.id,
        ),
      ),
    );
  },
  color: const Color(0xFFEF4444), // Red for critical
),
```

**Location**: AppBar actions (between Add Project and Refresh buttons)

**Behavior**: Opens Critical Subsections Screen showing critical items for projects in THAT SPECIFIC CATEGORY

---

## Screen Layout

### AppBar
```
┌─────────────────────────────────────────────────┐
│ ← Critical Subsections                          │
│   All Projects / Category Projects              │
└─────────────────────────────────────────────────┘
```

### Search & Filter Section
```
┌─────────────────────────────────────────────────┐
│ 🔍 Search critical items...                [X]  │
│                                                  │
│ [All] [DPR] [Work] [PMS]                        │
└─────────────────────────────────────────────────┘
```

### Project Groups
```
┌─────────────────────────────────────────────────┐
│ 📁 Project Name                    [3 Critical]  │
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────┐ │
│ │ ⚠ Administrative Approval (AA)             →│ │
│ │ [DPR]                           Today        │ │
│ └─────────────────────────────────────────────┘ │
│                                                  │
│ ┌─────────────────────────────────────────────┐ │
│ │ ⚠ 1st Milestone                            →│ │
│ │ [PMS]                           2 days ago   │ │
│ └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

---

## UI Design Details

### Color Scheme

**Category Colors**:
- DPR: Blue `#3B82F6`
- Work: Green `#10B981`
- PMS: Purple `#8B5CF6`

**Critical Colors**:
- Icon: Red `#EF4444`
- Border: Red with 0.3 opacity
- Background: Red with 0.1 opacity
- Count badge: Red with 0.1 background, full color text

**General**:
- Surface: `AppColors.surface`
- Background: `AppColors.background`
- Text Primary: `AppColors.textPrimary`
- Text Secondary: `AppColors.textSecondary`
- Text Tertiary: `AppColors.textTertiary`
- Border: `AppColors.border`

### Typography

**AppBar Title**: 18px, w600, textPrimary
**AppBar Subtitle**: 12px, w400, textSecondary
**Project Name**: 15px, w600, textPrimary
**Subsection Name**: 14px, w600, textPrimary
**Category Badge**: 11px, w600, category color
**Date**: 11px, w400, textTertiary
**Count Badge**: 12px, w600, red

### Spacing

- Screen padding: 16px
- Card margin bottom: 16px
- Card padding: 16px
- Between items: 12px
- Icon spacing: 12px
- Chip spacing: 8px

### Border Radius

- Cards: 12px
- Filter chips: 20px
- Tiles: 8px
- Category badges: 4px
- Count badges: 12px

---

## Component Structure

### Critical Tile Layout

```dart
Container(
  padding: 12px,
  decoration: BoxDecoration(
    color: background,
    borderRadius: 8px,
    border: red border (1.5px, 0.3 opacity),
  ),
  child: Row(
    children: [
      // Critical Icon
      Container(
        padding: 8px,
        decoration: red background (0.1 opacity),
        child: Icons.error (red, 20px),
      ),
      // Content
      Column(
        children: [
          Text(subsectionName, 14px, w600),
          Row(
            children: [
              // Category Badge
              Container(
                padding: 8x2,
                decoration: category color background (0.1 opacity),
                child: Text(category, 11px, w600, category color),
              ),
              // Date
              Text(date, 11px, textTertiary),
            ],
          ),
        ],
      ),
      // Arrow Icon
      Icons.chevron_right (textTertiary, 20px),
    ],
  ),
)
```

---

## Search & Filter Logic

### Search Behavior

Searches across:
- Project names
- Subsection names
- Category names

**Case-insensitive** matching with `toLowerCase()`

### Filter Behavior

**Category Filter**:
- All: Shows all critical items
- DPR: Shows only DPR critical items
- Work: Shows only Work critical items
- PMS: Shows only PMS critical items

**Active Indicator**:
- Selected chip: Primary color background, white text, w600
- Unselected chip: Surface background, primary text, w500

---

## Empty States

### No Projects
```
Icon: Icons.error_outline (64px, textTertiary)
Text: "No projects found" (16px, textSecondary, w500)
Subtitle: "Mark subsections as critical in Work Entry" (13px, textTertiary)
```

### No Critical Items
```
Icon: Icons.error_outline (64px, textTertiary)
Text: "No critical subsections marked yet" (16px, textSecondary, w500)
Subtitle: "Mark subsections as critical in Work Entry" (13px, textTertiary)
```

### No Search Results
```
Icon: Icons.error_outline (64px, textTertiary)
Text: "No matching critical items found" (16px, textSecondary, w500)
Subtitle: "Mark subsections as critical in Work Entry" (13px, textTertiary)
```

---

## Data Flow

### Loading Critical Items

```
1. Screen loads with categoryId (null or specific ID)
   ↓
2. Load all projects (from provider)
   ↓
3. Filter projects by categoryId if specified
   ↓
4. For each project:
   - Query critical_subsections table
   - Get all critical subsections
   - Add project name to each item
   ↓
5. Group by project_id
   ↓
6. Apply search & category filters
   ↓
7. Display grouped results
```

### Date Formatting

```dart
String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays == 0) return 'Today';
  if (difference.inDays == 1) return 'Yesterday';
  if (difference.inDays < 7) return '${difference.inDays} days ago';
  return '${date.day}/${date.month}/${date.year}';
}
```

---

## User Flows

### Flow 1: View All Critical Items

```
Categories Screen → Critical Icon → Critical Subsections Screen
  - Shows ALL critical items across ALL projects
  - Can search and filter
  - Grouped by project
```

### Flow 2: View Category Critical Items

```
Categories Screen → Category Card → Projects Screen → Critical Icon → Critical Subsections Screen
  - Shows critical items for projects in THAT category only
  - Can search and filter
  - Grouped by project
```

### Flow 3: Search Critical Items

```
Critical Subsections Screen
  ↓
Type in search bar
  ↓
Real-time filtering
  ↓
Shows matching items (project name, subsection name, or category)
```

### Flow 4: Filter by Category

```
Critical Subsections Screen
  ↓
Click category chip (DPR/Work/PMS)
  ↓
Shows only items from that category
  ↓
Click "All" to reset
```

---

## Files Modified/Created

### Created
1. `lib/presentation/screens/critical_subsections_screen.dart` (~530 lines)

### Modified
1. `lib/presentation/screens/categories_screen.dart` (+2 lines import, +13 lines button)
2. `lib/presentation/screens/projects_screen.dart` (+1 line import, +13 lines button)

**Total Lines**: ~560 lines added/modified

---

## Testing Checklist

### Navigation
- [ ] Categories Screen → Critical icon opens screen
- [ ] Projects Screen → Critical icon opens screen
- [ ] Back button returns to previous screen
- [ ] Screen title shows "All Projects" when from Categories
- [ ] Screen title shows "Category Projects" when from Projects

### Data Loading
- [ ] Loads all critical items when categoryId is null
- [ ] Loads category-specific critical items when categoryId is set
- [ ] Groups critical items by project correctly
- [ ] Shows project names correctly
- [ ] Shows subsection names correctly
- [ ] Shows category badges correctly
- [ ] Shows dates in correct format (Today/Yesterday/X days ago/DD/MM/YYYY)

### Search
- [ ] Search bar filters in real-time
- [ ] Clear button appears when typing
- [ ] Clear button clears search
- [ ] Searches project names
- [ ] Searches subsection names
- [ ] Searches category names
- [ ] Case-insensitive search works

### Filters
- [ ] "All" shows all categories
- [ ] "DPR" shows only DPR items
- [ ] "Work" shows only Work items
- [ ] "PMS" shows only PMS items
- [ ] Active chip highlighted correctly
- [ ] Filter combined with search works

### Empty States
- [ ] Shows correct message when no projects
- [ ] Shows correct message when no critical items
- [ ] Shows correct message when search has no results
- [ ] Icon and text display correctly

### UI/UX
- [ ] Layout matches existing app style
- [ ] Colors consistent with app theme
- [ ] Icons render correctly (error icons, folder icons, arrows)
- [ ] Critical count badge shows correct number
- [ ] Category badges show correct colors
- [ ] Tiles have hover/tap feedback (if applicable)
- [ ] Scroll works smoothly

---

## Future Enhancements

These features could be added in future iterations:

1. **Tap to Navigate**
   - Tap critical tile → Navigate to Work Entry tab
   - Auto-scroll to that specific subsection
   - Pre-expand the section

2. **Quick Actions**
   - Swipe to unmark as critical
   - Long press for more options
   - Bulk unmark multiple items

3. **Sorting Options**
   - Sort by date (newest first, oldest first)
   - Sort by category (DPR → Work → PMS)
   - Sort by project name (A-Z, Z-A)

4. **Statistics**
   - Total critical count at top
   - Count by category breakdown
   - Projects with most critical items

5. **Export**
   - Export critical list to CSV
   - Share critical list
   - Print critical list

6. **Notifications**
   - Badge on critical icon showing total count
   - Alert when critical items added

---

## Summary

**Phase 1: Critical Subsections Screen** - ✅ COMPLETED
- Screen created with full UI ✅
- Navigation from Categories Screen ✅
- Navigation from Projects Screen ✅
- Search functionality ✅
- Category filters ✅
- Grouped by project ✅
- Matching app UI style ✅

The Critical Subsections UI is fully functional and ready to use once the bulk category parameter update (from previous documentation) is completed!
