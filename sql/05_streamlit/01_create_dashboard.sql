/*==============================================================================
STREAMLIT - Fiberific
Deploys the fiber network operations dashboard from Git repository.
==============================================================================*/

USE SCHEMA SNOWFLAKE_EXAMPLE.FIBERIFIC;
USE WAREHOUSE SFE_FIBERIFIC_WH;

CREATE OR REPLACE STREAMLIT FIBERIFIC_DASHBOARD
  FROM '@SNOWFLAKE_EXAMPLE.TOOLS.SFE_FIBERIFIC_REPO/branches/main/streamlit'
  MAIN_FILE = 'streamlit_app.py'
  QUERY_WAREHOUSE = SFE_FIBERIFIC_WH
  TITLE = 'Fiberific Network Ops'
  COMMENT = 'DEMO: Fiber telecom AI operations dashboard (Expires: 2026-03-20)';

SHOW STREAMLITS LIKE 'FIBERIFIC_DASHBOARD' IN SCHEMA SNOWFLAKE_EXAMPLE.FIBERIFIC;
