/*==============================================================================
TEARDOWN ALL - Fiberific
WARNING: This will DELETE all demo objects. Cannot be undone.

INSTRUCTIONS: Open in Snowsight → Click "Run All"
==============================================================================*/

USE ROLE SYSADMIN;

-- Drop Streamlit app
DROP STREAMLIT IF EXISTS SNOWFLAKE_EXAMPLE.FIBERIFIC.FIBERIFIC_DASHBOARD;

-- Drop Cortex Agent
DROP AGENT IF EXISTS SNOWFLAKE_EXAMPLE.FIBERIFIC.FIBERIFIC_AGENT;

-- Drop semantic view (keep SEMANTIC_MODELS schema)
DROP VIEW IF EXISTS SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS.SV_FIBERIFIC_OPS;

-- Drop project schema (CASCADE removes all tables, views, streams, tasks)
DROP SCHEMA IF EXISTS SNOWFLAKE_EXAMPLE.FIBERIFIC CASCADE;

-- Drop project warehouse
DROP WAREHOUSE IF EXISTS SFE_FIBERIFIC_WH;

-- Drop Git repo object
DROP GIT REPOSITORY IF EXISTS SNOWFLAKE_EXAMPLE.TOOLS.SFE_FIBERIFIC_REPO;

-- PROTECTED - NEVER DROP:
-- SNOWFLAKE_EXAMPLE database
-- SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS schema
-- SNOWFLAKE_EXAMPLE.TOOLS schema
-- SFE_GIT_API_INTEGRATION

SELECT 'Fiberific teardown complete!' AS status, CURRENT_TIMESTAMP() AS completed_at;
