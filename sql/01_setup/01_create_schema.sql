/*==============================================================================
SETUP - Fiberific
Creates project schema and warehouse for fiber telecom AI operations demo.
==============================================================================*/

USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS SNOWFLAKE_EXAMPLE;

CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.FIBERIFIC
  COMMENT = 'DEMO: Fiber telecom AI operations (Expires: 2026-03-20)';

CREATE SCHEMA IF NOT EXISTS SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS
  COMMENT = 'Shared semantic views for Cortex Analyst';

CREATE WAREHOUSE IF NOT EXISTS SFE_FIBERIFIC_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  COMMENT = 'DEMO: Fiberific compute (Expires: 2026-03-20)';

USE SCHEMA SNOWFLAKE_EXAMPLE.FIBERIFIC;
USE WAREHOUSE SFE_FIBERIFIC_WH;
