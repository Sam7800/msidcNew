# Current UI Structure - Complete Reference

**Date**: 2026-01-10
**Purpose**: Document the current UI structure before making changes

## Work Entry Tab Structure

### File Location
`lib/presentation/widgets/module_tabs/work_entry_tab.dart`

### Tab Overview
The Work Entry tab is a comprehensive form with 4 collapsible sections containing 181+ input fields.

### Top-Level Fields (Always Visible)
- **Work ID**: Text input
- **Name of Work**: Text input
- **Search Bar**: Search across all fields with auto-scroll to section

### Section 1: Basic Information
**Expandable**: Yes (default: expanded)
**Fields**:
- Work ID
- Name of Work

### Section 2: DPR Section
**Expandable**: Yes (default: expanded)
**Total Fields**: 65 fields

**Subsections**:
1. Administrative Approval (AA) - 6 fields
2. DPR Bid Doc - 4 fields
3. Consultant Selection & Agreement - 3 fields
4. NIT Appointment - 4 fields
5. Survey & Geotechnical Investigation - 4 fields
6. Alignment, Plan, Profile - 3 fields
7. Pavement Design - 3 fields
8. Structures & Bridges - 3 fields
9. Traffic Studies - 3 fields
10. Junctions, Drainage, Furniture, Layout, Signage - 3 fields
11. Miscellaneous - 3 fields
12. BOQ & Quantities - 3 fields
13. Draft DPR - 3 fields
14. Environmental Clearance - 3 fields
15. Forest Clearance - 3 fields
16. Land Acquisition - 3 fields
17. Utility Shifting - 3 fields
18. Power & Quarry - 3 fields
19. Cash Flow Chart - 3 fields
20. Final DPR Approval - 3 fields
21. Bid Doc for Contractor - 3 fields

### Section 3: Work Section
**Expandable**: Yes (default: collapsed)
**Total Fields**: 26 fields

**Subsections**:
1. Admin Approval - 3 fields
2. Tech Sanction - 3 fields
3. DTP Approval - 3 fields
4. NIT Invitation - 3 fields
5. Bid Process - 3 fields
6. CSD Replies - 3 fields
7. Financial Evaluation - 3 fields
8. Offer Acceptance - 3 fields
9. LOI - 3 fields

### Section 4: PMS Section
**Expandable**: Yes (default: collapsed)
**Total Fields**: 90 fields

**Subsections**:
1. Agreement Amount - 1 field
2. Milestone I - 13 fields
3. Milestone II - 13 fields
4. Milestone III - 13 fields
5. Milestone IV - 13 fields
6. Milestone V - 13 fields
7. LD (Liquidated Damages) - 11 fields
8. COS (Change of Scope) - 9 fields
9. EOT (Extension of Time) - 14 fields

## Review Tab Structure

### File Location
`lib/presentation/widgets/module_tabs/review_tab.dart`

### Tab Overview
The Review tab displays all work entry data in a grid of 37 expandable component cards.

### Top Controls
- **Section Filters**: All | DPR | Work | PMS (4 buttons)
- **Collapse All Button**: Collapse all expanded cards
- **Search Bar**: Filter components by name

### Grid Layout
37 components arranged in 4 rows as expandable cards.

### 37 Review Components Breakdown

#### Row 1: DPR Documents (10 components)

1. **AA (Administrative Approval)**
   - Section: DPR
   - Fields: status, broad_scope, amount, sanctioned_date
   - Color: Indigo (#6366F1)
   - Icon: approval

2. **DPR (Detailed Project Report)**
   - Section: DPR
   - Fields: status, name, broad_scope, pa_name, submitted_date, approved_date
   - Color: Blue (#3B82F6)
   - Icon: description

3. **BOQ (Bill of Quantities)**
   - Section: DPR
   - Fields: status, likely_completion, items
   - Color: Cyan (#06B6D4)
   - Icon: table_chart

4. **Sch (Schedules)**
   - Section: DPR
   - Fields: status
   - Color: Teal (#14B8A6)
   - Icon: schedule

5. **Dwg (Drawings)**
   - Section: DPR
   - Fields: status
   - Color: Green (#10B981)
   - Icon: draw

6. **Bid Doc (Bid Documents)**
   - Section: DPR
   - Fields: status
   - Color: Lime (#84CC16)
   - Icon: folder

7. **ENV (Environmental Clearance)**
   - Section: DPR
   - Fields: status, proposal_submitted_date, status_description
   - Color: Green (#22C55E)
   - Icon: eco

8. **LA (Land Acquisition)**
   - Section: DPR
   - Fields: status, proposal_submitted_date, status_description
   - Color: Amber (#F59E0B)
   - Icon: landscape

9. **Utility (Utility Shifting)**
   - Section: DPR
   - Fields: status, proposal_submitted_date, status_description
   - Color: Yellow (#EAB308)
   - Icon: build

10. **TS (Technical Sanction)**
    - Section: Work
    - Fields: status, accorded_date, sanctioned_cost, items
    - Color: Green (#10B981)
    - Icon: verified

#### Row 2: Bidding & Award (10 components)

11. **NIT (Notice Inviting Tender)**
    - Section: Work
    - Fields: status, issued_date, likely_issue_date, bid_submission_date, method, type
    - Color: Amber (#F59E0B)
    - Icon: announcement

12. **Pre-bid (Pre-bid Meeting)**
    - Section: Work
    - Fields: status, date, number_of_bidders, written_applications
    - Color: Yellow (#EAB308)
    - Icon: meeting_room

13. **CSD (Common Set of Deviations)**
    - Section: DPR
    - Fields: status, date
    - Color: Purple (#8B5CF6)
    - Icon: lock

14. **Bid Sub (Bid Submission)**
    - Section: DPR
    - Fields: status, date
    - Color: Light Purple (#A78BFA)
    - Icon: upload

15. **Tech Eval (Technical Evaluation)**
    - Section: DPR
    - Fields: status, qualified, likely_completion, results_published_date, fin_bid_opening_informed, person_responsible, post_held, pending_with
    - Color: Indigo (#6366F1)
    - Icon: assessment

16. **Fin Bid (Financial Bid)**
    - Section: DPR
    - Fields: opening_date, qualified_count, opening_bid, opening_amount, opening_variance
    - Color: Blue (#3B82F6)
    - Icon: attach_money

17. **Bid Accept (Bid Acceptance)**
    - Section: DPR
    - Fields: status
    - Color: Cyan (#06B6D4)
    - Icon: check_circle

18. **LOA (Letter of Acceptance)**
    - Section: DPR
    - Fields: status, date
    - Color: Teal (#14B8A6)
    - Icon: mail

19. **Work Order**
    - Section: Work
    - Fields: number, issue_date, contractor_name
    - Color: Green (#10B981)
    - Icon: work

20. **PBG (Performance Bank Guarantee)**
    - Section: DPR
    - Fields: status, amount
    - Color: Lime (#84CC16)
    - Icon: account_balance

#### Row 3: Contract & Milestones (11 components)

21. **Agr Amt (Agreement Amount)**
    - Section: Work
    - Fields: agreement_amount
    - Color: Green (#22C55E)
    - Icon: currency_rupee

22. **App Date (Appointed Date)**
    - Section: Work
    - Fields: appointed_date
    - Color: Amber (#F59E0B)
    - Icon: calendar_today

23. **Tender (Tender Period)**
    - Section: Work
    - Fields: tender_period
    - Color: Yellow (#EAB308)
    - Icon: timelapse

24. **MS-I (Milestone I)**
    - Section: PMS
    - Fields: description, period, target_date, target_amount, physical_target, achieved_date, achieved_amount, physical_achieved, person_responsible, post_held, pending_with, ld_applicable, remarks (13 fields)
    - Color: Purple (#8B5CF6)
    - Icon: flag

25. **MS-II (Milestone II)**
    - Section: PMS
    - Fields: Same as MS-I (13 fields)
    - Color: Light Purple (#A78BFA)
    - Icon: flag

26. **MS-III (Milestone III)**
    - Section: PMS
    - Fields: Same as MS-I (13 fields)
    - Color: Indigo (#6366F1)
    - Icon: flag

27. **MS-IV (Milestone IV)**
    - Section: PMS
    - Fields: Same as MS-I (13 fields)
    - Color: Blue (#3B82F6)
    - Icon: flag

28. **MS-V (Milestone V)**
    - Section: PMS
    - Fields: Same as MS-I (13 fields)
    - Color: Cyan (#06B6D4)
    - Icon: flag

29. **LD (Liquidated Damages)**
    - Section: PMS
    - Fields: applicable, rate, recovery, amount_deposited, amount_released, person_responsible, post_held, pending_with, ms1-5 recovery amounts (12 fields)
    - Color: Red (#EF4444)
    - Icon: gavel

30. **EOT (Extension of Time)**
    - Section: PMS
    - Fields: applicable, period, proposal_submitted_date, with_escalation, without_escalation, by_freezing_indices, without_ld, with_ld, compensation_payable, compensation_claimed_amount, compensation_admitted_amount, person_responsible, post_held, pending_with (14 fields)
    - Color: Amber (#F59E0B)
    - Icon: update

31. **COS (Change of Scope)**
    - Section: PMS
    - Fields: status, date, amount, scope, proposed_items, approved_items, person_responsible, post_held, pending_with (9 fields)
    - Color: Yellow (#EAB308)
    - Icon: swap_horiz

#### Row 4: Monitoring & Audit (6 components)

32. **Exp (Expenditure)**
    - Section: PMS
    - Fields: agreement_amount, expenditure_till_date, expenditure_percentage
    - Color: Green (#10B981)
    - Icon: currency_rupee

33. **Audit Para**
    - Section: PMS
    - Fields: applicable, points, replied, pending, dp, dropped, details_items (table), replies_items (table), closed_items (table), person_responsible, post_held, pending_with (12 fields)
    - Color: Red (#EF4444)
    - Icon: receipt_long

34. **LAQ (Legislative Assembly Questions)**
    - Section: PMS
    - Fields: status, action, description, laq_count, lcq_count, lakshvwdhi_count, others_count, questions_items (table), replies_items (table), promises_items (table), compliance_items (table) (11 fields)
    - Color: Amber (#F59E0B)
    - Icon: help_outline

35. **Tech Audit (Technical Audit)**
    - Section: PMS
    - Fields: status, report, action, no_action, responsible_ee, compliance_count, compliance_dates (7 fields)
    - Color: Indigo (#6366F1)
    - Icon: search

36. **Rev AA (Revised Administrative Approval)**
    - Section: PMS
    - Fields: status, amount, percentage, recap_sheet_items (table) (4 fields)
    - Color: Purple (#8B5CF6)
    - Icon: refresh

37. **Supp Agr (Supplementary Agreement)**
    - Section: Work
    - Fields: status, date, number, amount, period, scope (6 fields)
    - Color: Blue (#3B82F6)
    - Icon: note_add

## Component States

Many components have different "states" that change the fields displayed:
- **Awaited**: Initial state, minimal fields
- **In Progress**: Work started, more fields visible
- **Accorded/Completed**: Final state, all fields visible
- **Not Applicable**: Component not relevant for this project

## Current Data Flow

```
User fills form in Work Entry Tab
  ↓
Data saved to WorkEntryData model (181 fields)
  ↓
Split into 3 JSON sections:
  - dprSection (65 fields)
  - workSection (26 fields)
  - pmsSection (90 fields)
  ↓
Saved to database (work_entry table)
  ↓
Loaded in Review Tab
  ↓
Mapped to 37 review components
  ↓
Displayed in grid layout
```

## UI Features

### Work Entry Tab Features
1. **Search & Auto-Scroll**: Search for fields and auto-expand/scroll to section
2. **Section Expansion**: Collapsible sections to reduce visual clutter
3. **Draft Auto-Save**: Automatic saving as draft
4. **Validation**: Form validation before save
5. **Loading States**: Show loading spinner when loading data

### Review Tab Features
1. **Section Filtering**: Filter by DPR/Work/PMS sections
2. **Collapse All**: Collapse all expanded cards at once
3. **Expandable Cards**: Click card to expand and view details
4. **Completion Tracking**: Visual indicators for completion percentage
5. **Empty State**: Shows message when no data exists
6. **Auto-Refresh**: Automatically refreshes when Work Entry saves draft

## Component Card Features
- **Color Coding**: Each component has unique color
- **Icon**: Visual icon representing component
- **Status Badge**: Shows current state (Awaited/In Progress/Accorded)
- **Progress Bar**: Visual progress indicator
- **Expand/Collapse**: Click to see detailed fields
- **Responsive Layout**: Grid adapts to screen size

## Current Issues / Limitations
1. **Too Many Fields**: 181 fields overwhelming for users
2. **Complex Navigation**: Hard to find specific fields
3. **Data Structure**: JSON storage makes querying difficult
4. **Field Mapping**: Complex mapping between form fields and review components
5. **Validation**: Limited validation on many fields
6. **Mobile**: Not optimized for mobile/tablet
