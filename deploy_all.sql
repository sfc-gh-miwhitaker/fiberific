/*==============================================================================
DEPLOY ALL - Fiberific: AI-Powered Fiber Network Operations
Author: SE Community | Expires: 2026-03-20

INSTRUCTIONS: Open in Snowsight → Click "Run All" (~5 minutes)

Creates a complete fiber telecom operations demo with:
  - Network infrastructure tables (nodes, circuits, events, traffic)
  - Customer and service management tables
  - AI-enriched views (sentiment, summarization, anomaly detection)
  - Cortex Analyst semantic view for natural language queries
  - Snowflake Intelligence agent for self-service analytics
  - Streamlit operations dashboard
==============================================================================*/

-- SSOT: Change ONLY here, then run: sync-expiration
SET DEMO_EXPIRES = '2026-03-20';

DECLARE
  demo_expired EXCEPTION (-20001, 'DEMO EXPIRED - contact SE Community owner');
BEGIN
  IF (CURRENT_DATE() > $DEMO_EXPIRES::DATE) THEN
    RAISE demo_expired;
  END IF;
END;

-- Setup: schema, warehouse
USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE;

CREATE WAREHOUSE IF NOT EXISTS SFE_FIBERIFIC_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'DEMO: Fiberific compute (Expires: 2026-03-20)';

USE WAREHOUSE SFE_FIBERIFIC_WH;

-- Git repo setup
CREATE GIT REPOSITORY IF NOT EXISTS SNOWFLAKE_EXAMPLE.TOOLS.SFE_FIBERIFIC_REPO
  API_INTEGRATION = SFE_GIT_API_INTEGRATION
  GIT_CREDENTIALS = SNOWFLAKE_EXAMPLE.TOOLS.SFE_GIT_CREDS
  ORIGIN = 'https://github.com/sfc-gh-miwhitaker/fiberific.git'
  COMMENT = 'DEMO: Fiberific source repo (Expires: 2026-03-20)';

ALTER GIT REPOSITORY SNOWFLAKE_EXAMPLE.TOOLS.SFE_FIBERIFIC_REPO FETCH;

-- Execute scripts in order
EXECUTE IMMEDIATE FROM '@SNOWFLAKE_EXAMPLE.TOOLS.SFE_FIBERIFIC_REPO/branches/main/sql/01_setup/01_create_schema.sql';
EXECUTE IMMEDIATE FROM '@SNOWFLAKE_EXAMPLE.TOOLS.SFE_FIBERIFIC_REPO/branches/main/sql/02_data/01_create_tables.sql';
EXECUTE IMMEDIATE FROM '@SNOWFLAKE_EXAMPLE.TOOLS.SFE_FIBERIFIC_REPO/branches/main/sql/02_data/02_load_sample_data.sql';
EXECUTE IMMEDIATE FROM '@SNOWFLAKE_EXAMPLE.TOOLS.SFE_FIBERIFIC_REPO/branches/main/sql/03_transformations/01_create_views.sql';
EXECUTE IMMEDIATE FROM '@SNOWFLAKE_EXAMPLE.TOOLS.SFE_FIBERIFIC_REPO/branches/main/sql/03_transformations/02_create_ai_views.sql';
EXECUTE IMMEDIATE FROM '@SNOWFLAKE_EXAMPLE.TOOLS.SFE_FIBERIFIC_REPO/branches/main/sql/04_cortex/01_create_semantic_view.sql';
EXECUTE IMMEDIATE FROM '@SNOWFLAKE_EXAMPLE.TOOLS.SFE_FIBERIFIC_REPO/branches/main/sql/04_cortex/02_create_agent.sql';
EXECUTE IMMEDIATE FROM '@SNOWFLAKE_EXAMPLE.TOOLS.SFE_FIBERIFIC_REPO/branches/main/sql/05_streamlit/01_create_dashboard.sql';

-- Final summary (ONLY visible result in Run All)
SELECT
  'Fiberific deployment complete!' AS status,
  CURRENT_TIMESTAMP() AS completed_at,
  'Open Streamlit dashboard or ask the Cortex Agent a question' AS next_step;
