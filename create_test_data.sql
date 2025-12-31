-- ================================================================
-- TEST DATA CREATION SCRIPT
-- Creates comprehensive test data for review screen validation
-- ================================================================

-- Step 1: Create Test Category
INSERT INTO categories (name, description, color_hex, icon_name, display_order, is_active)
VALUES ('Test Category', 'Category for comprehensive testing of review screen fields', '#FF6B6B', 'science', 99, 1);

-- Step 2: Create Test Project
INSERT INTO projects (sr_no, name, category_id, broad_scope, location, status)
VALUES (
  999,
  'Test Project - Full Data Population',
  (SELECT id FROM categories WHERE name = 'Test Category'),
  'Comprehensive test project with all fields populated for review screen validation',
  'Test Location, Maharashtra',
  'In Progress'
);

-- Step 3: Create Work Entry with ALL fields populated
INSERT INTO work_entry (
  project_id,
  work_id,
  name_of_work,
  person_responsible,
  post_held,
  pending_with,
  dpr_section,
  work_section,
  pms_section,
  is_draft
)
VALUES (
  (SELECT id FROM projects WHERE sr_no = 999),
  'TEST-WRK-999',
  'Comprehensive Test Infrastructure Development Project',
  'Mr. Test Engineer',
  'Executive Engineer',
  'Quality Control Department',

  -- DPR SECTION JSON
  '{
    "aa_status": "Accorded",
    "aa_amount": 125.5,
    "aa_number": "AA/TEST/2024/001",
    "aa_date": "2024-01-15",
    "aa_proposed_amount": 120.0,
    "aa_proposal_date": "2023-12-01",
    "aa_pending_with": "Chief Engineer",
    "broad_scope_aa": "Development of test infrastructure including roads, bridges, and utilities",

    "dpr_status": "Approved",
    "dpr_name": "DPR for Test Infrastructure Development",
    "broad_scope_dpr": "Detailed project report covering all aspects of infrastructure development",
    "dpr_pa_name": "Test Consultancy Services Pvt Ltd",
    "dpr_submitted_date": "2024-02-20",
    "dpr_approved_date": "2024-03-10",
    "likely_completion_date": "2024-04-30",

    "boq_status": "Completed",
    "likely_completion": "2024-03-25",
    "boq_items": "[{\"srNo\":1,\"item\":\"Earthwork\",\"quantity\":5000,\"unit\":\"cum\",\"rate\":450,\"amount\":2250000},{\"srNo\":2,\"item\":\"Concrete M25\",\"quantity\":2000,\"unit\":\"cum\",\"rate\":6500,\"amount\":13000000},{\"srNo\":3,\"item\":\"Steel Reinforcement\",\"quantity\":150,\"unit\":\"MT\",\"rate\":65000,\"amount\":9750000},{\"srNo\":4,\"item\":\"Bituminous Road\",\"quantity\":12,\"unit\":\"km\",\"rate\":4500000,\"amount\":54000000},{\"srNo\":5,\"item\":\"Drainage System\",\"quantity\":8,\"unit\":\"km\",\"rate\":2500000,\"amount\":20000000}]",

    "schedules_status": "Approved",
    "drawings_status": "Approved",
    "bid_documents_status": "Completed",

    "env_clearance_status": "Applicable",
    "env_status": "Applicable",
    "env_proposal_submitted_date": "2024-01-20",
    "env_status_description": "Under review by State Environment Department",

    "land_acquisition_status": "Applicable",
    "la_status": "Applicable",
    "la_proposal_submitted_date": "2024-01-25",
    "la_status_description": "Compensation disbursement in progress",

    "utility_shifting_status": "Applicable",
    "utility_status": "Applicable",
    "utility_proposal_submitted_date": "2024-02-01",
    "utility_status_description": "Coordination with MSEDCL ongoing",

    "dpr_bid_doc_status": "Completed",
    "invite_dpr_bid_status": "Issued",
    "invite_dpr_bid_date": "2023-10-15",
    "prebid_meeting_date": "2023-10-25",
    "prebid_participants": 15,
    "prebid_written_applications": 8,

    "csd_status": "CSD uploaded",
    "csd_date": "2023-11-05",

    "bid_submission_date": "2023-11-15",
    "bid_submission_status": "Completed",
    "bid_submission_number_of_bidders": 12,
    "bid_submission_emd_verified": "Yes",
    "bid_submission_emd_total_amount": 2500000,

    "tech_eval_status": "Completed",
    "tech_eval_qualified": 8,
    "tech_eval_likely_completion": "2023-11-30",
    "tech_eval_results_published_date": "2023-12-01",
    "tech_eval_fin_bid_opening_informed": "2023-12-05",
    "tech_eval_person_responsible": "Mr. Rajesh Kumar",
    "tech_eval_post_held": "Superintending Engineer",
    "tech_eval_pending_with": "Finance Department",

    "fin_opening_date": "2023-12-10",
    "fin_opening_bid": "L1",
    "fin_opening_amount": 98500000,
    "fin_opening_variance": -2.5,
    "fin_bid_qualified_count": 8,

    "bid_acceptance_status": "Approved",
    "bid_acceptance_amount": 98500000,

    "loa_status": "Issued",
    "loa_date": "2023-12-20",
    "loa_issue_date": "2023-12-20",
    "loa_number": "LOA/TEST/2023/042",
    "loa_contractor_name": "Test Infrastructure Builders Ltd",
    "loa_amount": 98500000,
    "loa_validity_period": "90 days",
    "loa_valid_until": "2024-03-20",
    "loa_remarks": "All documents verified and approved",

    "pbg_status": "Submitted",
    "pbg_amount": 9850000,
    "pbg_date": "2024-01-10",
    "pbg_period": "60 months"
  }',

  -- WORK SECTION JSON
  '{
    "tech_sanction_status": "Accorded",
    "tech_sanction_amount": 98500000,
    "ts_number": "TS/TEST/2024/015",
    "ts_date": "2024-01-05",

    "nit_status": "Issued",
    "nit_date": "2024-01-20",
    "nit_amount": 98500000,
    "nit_items": "[{\"srNo\":1,\"item\":\"Civil Works\",\"amount\":65000000},{\"srNo\":2,\"item\":\"Road Construction\",\"amount\":25000000},{\"srNo\":3,\"item\":\"Drainage & Utilities\",\"amount\":8500000}]",

    "prebid_date": "2024-01-28",
    "prebid_participants_count": 18,
    "written_applications": 12,

    "work_bid_submission_date": "2024-02-10",
    "work_bid_submission_count": 15,

    "work_order_status": "Issued",
    "work_order_date": "2024-02-25",
    "work_order_amount": 98500000,
    "work_order_variance": -2.5,
    "work_order_period": 24,
    "wo_number": "WO/TEST/2024/007",
    "contractor_name": "Test Infrastructure Builders Ltd"
  }',

  -- PMS SECTION JSON
  '{
    "agreement_amount": 98500000,
    "appointed_date": "2024-03-01",
    "tender_period": 24,

    "milestone_1_period": 6,
    "milestone_1_physical_target": 20,
    "milestone_1_target_amount": 19700000,
    "milestone_1_physical_achieved": 22,
    "milestone_1_achievement_amount": 21670000,
    "milestone_1_status": "Achieved",
    "milestone_1_target_date": "2024-09-01",
    "milestone_1_achieved_date": "2024-08-25",
    "milestone_1_remarks": "Completed ahead of schedule",

    "milestone_2_period": 12,
    "milestone_2_physical_target": 40,
    "milestone_2_target_amount": 39400000,
    "milestone_2_physical_achieved": 38,
    "milestone_2_achievement_amount": 37430000,
    "milestone_2_status": "In Progress",
    "milestone_2_target_date": "2025-03-01",

    "milestone_3_period": 18,
    "milestone_3_physical_target": 60,
    "milestone_3_target_amount": 59100000,
    "milestone_3_status": "Awaited",
    "milestone_3_target_date": "2025-09-01",

    "milestone_4_period": 21,
    "milestone_4_physical_target": 80,
    "milestone_4_target_amount": 78800000,
    "milestone_4_status": "Awaited",
    "milestone_4_target_date": "2025-12-01",

    "milestone_5_period": 24,
    "milestone_5_physical_target": 100,
    "milestone_5_target_amount": 98500000,
    "milestone_5_status": "Awaited",
    "milestone_5_target_date": "2026-03-01",

    "ld_status": "Applicable",
    "ld_amount_imposed": 150000,
    "ld_amount_per_week": 25000,
    "ld_amount_recovered": 0,
    "ld_amount_deposited": 150000,
    "ld_amount_released": 0,
    "ld_final_recovered": 0,
    "ld_remarks": "Deposited in escrow account pending progress achievement",

    "eot_status": "Applicable",
    "eot_period_submitted": 3,
    "eot_period_approved": 2,
    "eot_submitted_date": "2024-08-15",
    "eot_approved_date": "2024-09-01",
    "with_escalation": "No",
    "without_escalation": "Yes",
    "by_freezing_indices": "No",
    "ld_terms_without_ld": "No",
    "ld_terms_with_ld": "Yes",
    "compensation_payable": "No",

    "cos_status": "Applicable",
    "cos_submitted_date": "2024-07-20",
    "cos_proposed_items": "[{\"srNo\":1,\"description\":\"Additional drainage work\",\"amount\":5000000,\"status\":\"Under review\"},{\"srNo\":2,\"description\":\"Extra road widening\",\"amount\":3500000,\"status\":\"Under review\"}]",
    "cos_approved_items": "[{\"srNo\":1,\"description\":\"Street lighting\",\"amount\":2500000,\"period\":2,\"approvedDate\":\"2024-06-15\",\"number\":\"COS/001\",\"date\":\"2024-06-15\",\"remarks\":\"Approved\"}]",

    "expenditure_amount": 59100000,
    "expenditure_percentage": 60.0,

    "audit_para_status": "Applicable",
    "audit_para_draft_count": 5,
    "audit_para_responsible_person": "CA Suresh Patil",
    "audit_para_details_items": "[{\"srNo\":1,\"description\":\"Excess payment in earthwork\",\"amount\":250000,\"status\":\"Pending\"},{\"srNo\":2,\"description\":\"Quantity variation in steel\",\"amount\":180000,\"status\":\"Replied\"},{\"srNo\":3,\"description\":\"Documentation gap in subcontract\",\"amount\":0,\"status\":\"Closed\"}]",
    "audit_para_replies_items": "[{\"srNo\":1,\"paraNo\":\"AP-02\",\"date\":\"2024-08-10\",\"status\":\"Submitted\"},{\"srNo\":2,\"paraNo\":\"AP-03\",\"date\":\"2024-07-25\",\"status\":\"Accepted\"}]",
    "audit_para_closed_items": "[{\"srNo\":1,\"paraNo\":\"AP-03\",\"date\":\"2024-08-01\",\"remarks\":\"Satisfactory compliance\"}]",

    "laq_status": "Applicable",
    "laq_count": 8,
    "lcq_count": 3,
    "lakshvwdhi_count": 2,
    "laq_others_count": 1,
    "laq_responsible_person": "Dr. Vijay Sharma",
    "laq_questions_items": "[{\"srNo\":1,\"question\":\"Project delay reasons\",\"askedBy\":\"MLA Patil\",\"date\":\"2024-07-15\"},{\"srNo\":2,\"question\":\"Budget utilization\",\"askedBy\":\"MLA Deshmukh\",\"date\":\"2024-08-01\"}]",
    "laq_replies_items": "[{\"srNo\":1,\"questionNo\":\"LAQ-145\",\"date\":\"2024-07-20\",\"status\":\"Submitted\"}]",
    "laq_promises_items": "[{\"srNo\":1,\"promise\":\"Complete within extended timeline\",\"date\":\"2024-07-20\",\"minister\":\"Hon. Minister PWD\"}]",
    "laq_compliance_items": "[{\"srNo\":1,\"promiseNo\":\"P-01\",\"status\":\"In progress\",\"date\":\"2024-08-15\",\"remarks\":\"On track\"}]",

    "tech_audit_status": "Carried Out",
    "tech_audit_findings_count": 7,
    "tech_audit_findings_details": "Quality issues in concrete finishing, minor deviations in drainage alignment",
    "responsible_ee": "Mr. Anil Deshmukh, EE (Civil)",
    "compliance_count": 5,
    "compliance_dates": "2024-08-20, 2024-09-10",

    "rev_aa_status": "Necessary",
    "rev_aa_reasons": "Scope enhancement due to COS and price escalation",
    "rev_aa_amount_proposed": 112000000,
    "rev_aa_status_detail": "Submitted",
    "rev_aa_number": "RAA/TEST/2024/003",
    "rev_aa_date": "2024-09-15",

    "suppl_agreement_status": "Applicable",
    "suppl_agreement_necessity": "Additional scope approved through COS",
    "suppl_agreement_amount": 8500000,
    "suppl_agreement_date": "2024-08-01",
    "suppl_agreement_number": "SA/TEST/2024/002",
    "suppl_agreement_scope": "Street lighting installation and additional drainage network",
    "period": 4,
    "suppl_agreement_remarks": "Executed with mutual consent"
  }',

  0
);

-- Display results
SELECT '================================================================';
SELECT 'TEST DATA CREATION COMPLETED SUCCESSFULLY!';
SELECT '================================================================';
SELECT 'Category: Test Category';
SELECT 'Project: Test Project - Full Data Population (Sr. No. 999)';
SELECT '';
SELECT 'You can now:';
SELECT '1. Run the app';
SELECT '2. Navigate to "Test Category" → "Test Project - Full Data Population"';
SELECT '3. Open the review screen';
SELECT '4. Click each button to verify all fields display correctly';
SELECT '================================================================';
