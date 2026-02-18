/*==============================================================================
AI VIEWS - Fiberific
Views enriched with Cortex LLM functions (SENTIMENT, SUMMARIZE, COMPLETE).
==============================================================================*/

USE SCHEMA SNOWFLAKE_EXAMPLE.FIBERIFIC;
USE WAREHOUSE SFE_FIBERIFIC_WH;

----------------------------------------------------------------------
-- V_TICKET_ANALYSIS: Support tickets with AI-powered enrichment
-- Uses SNOWFLAKE.CORTEX.SENTIMENT for customer mood detection
-- Uses SNOWFLAKE.CORTEX.COMPLETE for category and urgency classification
----------------------------------------------------------------------
CREATE OR REPLACE VIEW V_TICKET_ANALYSIS
  COMMENT = 'DEMO: AI-enriched ticket analysis with sentiment and classification (Expires: 2026-03-20)'
AS
SELECT
  t.ticket_id,
  t.customer_id,
  cu.company_name,
  cu.segment,
  cu.industry,
  t.circuit_id,
  t.category,
  t.priority,
  t.subject,
  t.description,
  t.status AS ticket_status,
  t.created_date,
  t.resolved_date,
  t.resolution_hours,
  SNOWFLAKE.CORTEX.SENTIMENT(t.description) AS sentiment_score,
  CASE
    WHEN SNOWFLAKE.CORTEX.SENTIMENT(t.description) < -0.3 THEN 'NEGATIVE'
    WHEN SNOWFLAKE.CORTEX.SENTIMENT(t.description) > 0.3 THEN 'POSITIVE'
    ELSE 'NEUTRAL'
  END AS sentiment_label,
  SNOWFLAKE.CORTEX.SUMMARIZE(t.description) AS ai_summary,
  TRIM(SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-large2',
    'Classify this telecom support ticket into exactly one category. '
    || 'Return ONLY the category name, nothing else. '
    || 'Categories: NETWORK_OUTAGE, PERFORMANCE_DEGRADATION, BILLING_DISPUTE, '
    || 'PROVISIONING_DELAY, CAPACITY_UPGRADE, CONFIGURATION_ISSUE, CONTRACT_INQUIRY, GENERAL. '
    || 'Ticket: ' || t.subject || ' - ' || LEFT(t.description, 500)
  )) AS ai_category,
  TRIM(SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-large2',
    'Rate the business urgency of this telecom support ticket on a scale of 1-10 '
    || 'where 10 is most urgent. Return ONLY the number. '
    || 'Ticket: ' || t.subject || ' - ' || LEFT(t.description, 500)
  )) AS ai_urgency_score
FROM RAW_TICKETS t
LEFT JOIN RAW_CUSTOMERS cu ON t.customer_id = cu.customer_id;

----------------------------------------------------------------------
-- V_EVENT_INTELLIGENCE: Network events with AI summarization
-- Uses SNOWFLAKE.CORTEX.COMPLETE for root cause classification
----------------------------------------------------------------------
CREATE OR REPLACE VIEW V_EVENT_INTELLIGENCE
  COMMENT = 'DEMO: AI-enriched network event intelligence (Expires: 2026-03-20)'
AS
SELECT
  e.event_id,
  e.node_id,
  n.node_name,
  n.city,
  n.state,
  e.circuit_id,
  c.circuit_name,
  e.event_type,
  e.severity,
  e.event_timestamp,
  e.resolved_at,
  e.duration_minutes,
  e.description,
  e.root_cause,
  CASE WHEN e.resolved_at IS NOT NULL THEN 'RESOLVED' ELSE 'ACTIVE' END AS resolution_status,
  SNOWFLAKE.CORTEX.SUMMARIZE(e.description) AS ai_summary,
  TRIM(SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-large2',
    'Analyze this fiber network event and classify the likely impact on customers. '
    || 'Return ONLY one of: NO_IMPACT, LOW_IMPACT, MODERATE_IMPACT, HIGH_IMPACT, SERVICE_AFFECTING. '
    || 'Event: ' || e.event_type || ' - ' || LEFT(e.description, 500)
  )) AS ai_customer_impact,
  TRIM(SNOWFLAKE.CORTEX.COMPLETE(
    'mistral-large2',
    'Based on this fiber network event, suggest a preventive action in one sentence. '
    || 'Event: ' || e.event_type || ' - Severity: ' || e.severity
    || ' - Root cause: ' || COALESCE(e.root_cause, 'Unknown')
    || ' - Description: ' || LEFT(e.description, 300)
  )) AS ai_prevention_recommendation
FROM RAW_NETWORK_EVENTS e
LEFT JOIN RAW_NETWORK_NODES n ON e.node_id = n.node_id
LEFT JOIN RAW_NETWORK_CIRCUITS c ON e.circuit_id = c.circuit_id;
