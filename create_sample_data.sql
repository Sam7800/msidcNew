-- Sample Project with Complete DPR Data
-- Execute this in the SQLite database to create sample project

-- Insert a sample project in Nashik Kumbhmela category (category_id = 1)
INSERT INTO projects (sr_no, name, category_id, broad_scope, created_at, updated_at)
VALUES (
  101,
  'Sample Highway Development Project',
  1,
  'Development of 45km highway stretch with modern infrastructure including drainage, lighting, and safety features',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
);

-- Get the project_id that was just inserted
-- Insert comprehensive Work Entry data with all DPR fields filled
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
  is_draft,
  created_at,
  updated_at
)
VALUES (
  (SELECT id FROM projects WHERE sr_no = 101),
  'NH-45-2024',
  'Sample Highway Development Project - Complete DPR',
  NULL,
  NULL,
  NULL,
  json('{
    "aa_status": "Accorded",
    "aa_amount": "1250.50",
    "broad_scope_aa": "Complete highway development with modern infrastructure including drainage systems, street lighting, traffic management, and safety barriers. Project includes land acquisition and utility shifting.",
    "aa_person_responsible": "Rajesh Kumar",
    "aa_post_held": "Chief Engineer",
    "aa_pending_with": "N/A",

    "dpr_bid_doc_status": "Approved",
    "dpr_bid_doc_person_responsible": "Priya Sharma",
    "dpr_bid_doc_post_held": "DPR Consultant",
    "dpr_bid_doc_pending_with": "N/A",

    "invite_dpr_bid_status": "Invited",
    "invite_dpr_bid_date": "2024-01-15",
    "invite_dpr_person_responsible": "Amit Patel",
    "invite_dpr_post_held": "Procurement Officer",
    "invite_dpr_pending_with": "N/A",

    "prebid_meeting_date": "2024-02-01",
    "prebid_participants": "12",
    "prebid_person_responsible": "Amit Patel",
    "prebid_post_held": "Procurement Officer",
    "prebid_pending_with": "N/A",

    "csd_status": "Uploaded",
    "csd_date": "2024-02-10",
    "csd_person_responsible": "Neha Desai",
    "csd_post_held": "Technical Officer",
    "csd_pending_with": "N/A",

    "bid_submission_date": "2024-02-28",
    "bid_submission_person_responsible": "Amit Patel",
    "bid_submission_post_held": "Procurement Officer",
    "bid_submission_pending_with": "N/A",

    "bid_opening_date": "2024-03-01",
    "bid_opening_count": "8",
    "bid_opening_person_responsible": "Rajesh Kumar",
    "bid_opening_post_held": "Chief Engineer",
    "bid_opening_pending_with": "N/A",

    "tech_eval_status": "Completed",
    "tech_eval_qualified": "5",
    "tech_eval_person_responsible": "Dr. Sunita Mehta",
    "tech_eval_post_held": "Technical Evaluator",
    "tech_eval_pending_with": "N/A",

    "fin_opening_date": "2024-03-15",
    "fin_opening_bid": "M/s ABC Infrastructure Ltd",
    "fin_opening_amount": "1180.75",
    "fin_opening_variance": "-5.6",
    "fin_opening_person_responsible": "Rajesh Kumar",
    "fin_opening_post_held": "Chief Engineer",
    "fin_opening_pending_with": "N/A",

    "bid_acceptance_status": "Accepted",
    "bid_acceptance_amount": "1180.75",
    "bid_acceptance_person_responsible": "Managing Director",
    "bid_acceptance_post_held": "MD",
    "bid_acceptance_pending_with": "N/A",

    "loa_status": "Issued",
    "loa_date": "2024-03-25",
    "loa_person_responsible": "Rajesh Kumar",
    "loa_post_held": "Chief Engineer",
    "loa_pending_with": "N/A",

    "pbg_status": "Submitted",
    "pbg_amount": "118.08",
    "pbg_date": "2024-04-05",
    "pbg_period": "24",
    "pbg_person_responsible": "Finance Team",
    "pbg_post_held": "Finance Officer",
    "pbg_pending_with": "N/A",

    "insurance_pii_status": "Submitted",
    "insurance_pii_amount": "59.04",
    "insurance_pii_date": "2024-04-05",
    "insurance_pii_period": "24",
    "insurance_pii_person_responsible": "Finance Team",
    "insurance_pii_post_held": "Finance Officer",
    "insurance_pii_pending_with": "N/A",

    "work_order_status": "Issued",
    "work_order_date": "2024-04-15",
    "work_order_person_responsible": "Rajesh Kumar",
    "work_order_post_held": "Chief Engineer",
    "work_order_pending_with": "N/A",

    "inception_report_status": "Approved",
    "inception_person_responsible": "M/s ABC Infrastructure Ltd",
    "inception_post_held": "Contractor",
    "inception_pending_with": "N/A",

    "survey_status": "Completed",
    "survey_person_responsible": "Survey Team - ABC Ltd",
    "survey_post_held": "Survey Consultant",
    "survey_pending_with": "N/A",

    "geotech_status": "Completed",
    "geotech_person_responsible": "Dr. Geeta Rao",
    "geotech_post_held": "Geotechnical Expert",
    "geotech_pending_with": "N/A",

    "alignment_status": "Approved",
    "alignment_person_responsible": "Highway Design Team",
    "alignment_post_held": "Design Consultant",
    "alignment_pending_with": "N/A",

    "plan_profile_status": "Approved",
    "plan_profile_person_responsible": "Highway Design Team",
    "plan_profile_post_held": "Design Consultant",
    "plan_profile_pending_with": "N/A",

    "pavement_design_status": "Approved",
    "pavement_design_person_responsible": "Dr. Vikram Singh",
    "pavement_design_post_held": "Pavement Expert",
    "pavement_design_pending_with": "N/A",

    "structures_design_status": "Approved",
    "structures_design_person_responsible": "Structural Team",
    "structures_design_post_held": "Structural Consultant",
    "structures_design_pending_with": "N/A",

    "traffic_study_status": "Completed",
    "traffic_study_person_responsible": "Traffic Consultants Pvt Ltd",
    "traffic_study_post_held": "Traffic Consultant",
    "traffic_study_pending_with": "N/A",

    "junctions_status": "Approved",
    "junctions_person_responsible": "Highway Design Team",
    "junctions_post_held": "Design Consultant",
    "junctions_pending_with": "N/A",

    "drainage_status": "Approved",
    "drainage_person_responsible": "Drainage Expert Team",
    "drainage_post_held": "Drainage Consultant",
    "drainage_pending_with": "N/A",

    "furniture_layout_status": "Approved",
    "furniture_layout_person_responsible": "Urban Planning Team",
    "furniture_layout_post_held": "Urban Planner",
    "furniture_layout_pending_with": "N/A",

    "misc_structures_status": "Approved",
    "misc_structures_person_responsible": "Structural Team",
    "misc_structures_post_held": "Structural Consultant",
    "misc_structures_pending_with": "N/A",

    "boq_status": "Approved",
    "boq_amount": "1180.75",
    "boq_person_responsible": "Quantity Surveyor",
    "boq_post_held": "QS",
    "boq_pending_with": "N/A",

    "draft_dpr_status": "Submitted",
    "draft_dpr_person_responsible": "DPR Consultant Team",
    "draft_dpr_post_held": "DPR Consultant",
    "draft_dpr_pending_with": "Technical Committee",

    "env_clearance_applicable": "Yes",
    "env_clearance_status": "In progress",
    "env_clearance_person_responsible": "Environment Cell",
    "env_clearance_post_held": "Environment Officer",
    "env_clearance_pending_with": "State Environment Board",

    "land_acquisition_applicable": "Yes",
    "land_acquisition_status": "In progress",
    "land_acquisition_person_responsible": "Land Acquisition Officer",
    "land_acquisition_post_held": "LAO",
    "land_acquisition_pending_with": "District Collector",

    "utility_shifting_applicable": "Yes",
    "utility_shifting_status": "Ready",
    "utility_shifting_person_responsible": "Utility Coordination Team",
    "utility_shifting_post_held": "Utility Officer",
    "utility_shifting_pending_with": "Various Utility Companies",

    "quarry_chart_status": "Approved",
    "quarry_chart_person_responsible": "Mining Department",
    "quarry_chart_post_held": "Mining Officer",
    "quarry_chart_pending_with": "N/A",

    "final_dpr_status": "Ready",
    "final_dpr_person_responsible": "DPR Consultant Team",
    "final_dpr_post_held": "DPR Consultant",
    "final_dpr_pending_with": "Finance Department",

    "dpr_approval_status": "Submitted",
    "dpr_approval_person_responsible": "Chief Engineer",
    "dpr_approval_post_held": "CE",
    "dpr_approval_pending_with": "Board of Directors",

    "contractor_bid_doc_status": "Approved",
    "contractor_bid_doc_person_responsible": "Procurement Team",
    "contractor_bid_doc_post_held": "Procurement Officer",
    "contractor_bid_doc_pending_with": "N/A",

    "rfp_status": "Approved",
    "rfp_person_responsible": "Legal & Procurement",
    "rfp_post_held": "Legal Advisor",
    "rfp_pending_with": "N/A",

    "gcc_status": "Approved",
    "gcc_person_responsible": "Legal Team",
    "gcc_post_held": "Legal Advisor",
    "gcc_pending_with": "N/A",

    "schedules_status": "Approved",
    "schedules_person_responsible": "Technical Team",
    "schedules_post_held": "Technical Officer",
    "schedules_pending_with": "N/A",

    "drawings_volume_status": "Uploaded",
    "drawings_volume_person_responsible": "Design Team",
    "drawings_volume_post_held": "Design Consultant",
    "drawings_volume_pending_with": "N/A"
  }'),
  json('{
    "work_admin_approval_status": "Yes",
    "work_admin_approval_amount": "1180750000",
    "work_broad_scope": "Complete highway development including pavement works, drainage, street lighting, traffic signals, safety barriers, road furniture, and landscaping. The project covers 45km stretch with 4-lane configuration.",
    "work_tech_sanction_status": "Approved",
    "work_tech_sanction_amount": "1180750000",
    "work_contract_type": "EPC",
    "work_nit_invitation_status": "Invited",
    "work_nit_invitation_date": "2024-01-20"
  }'),
  json('{
    "pms_agreement_amount": "1180.75",
    "pms_tender_period": "24",
    "pms_insurance_status": "Yes",
    "pms_insurance_penalty": "No",
    "pms_milestone_1_target_date": "2024-10-15",
    "pms_milestone_1_achieved_date": "2024-10-12",
    "pms_milestone_1_target_amt": "236.15",
    "pms_milestone_1_achieved_amt": "236.15",
    "pms_milestone_2_target_date": "2025-04-15",
    "pms_milestone_2_target_amt": "354.22",
    "pms_milestone_3_target_date": "2025-10-15",
    "pms_milestone_3_target_amt": "354.22",
    "pms_milestone_4_target_date": "2026-04-15",
    "pms_milestone_4_target_amt": "177.11",
    "pms_milestone_5_target_date": "2026-10-15",
    "pms_milestone_5_target_amt": "59.05",
    "pms_ld_1_applicability": "Not Applicable"
  }'),
  1,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
);

-- Verify the insertion
SELECT 'Sample project created successfully!' as message;
SELECT p.id, p.sr_no, p.name, c.name as category
FROM projects p
JOIN categories c ON p.category_id = c.id
WHERE p.sr_no = 101;
