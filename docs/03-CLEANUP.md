# Cleanup Guide

## Quick Cleanup

1. Open **Snowsight**
2. Click **+ → SQL Worksheet**
3. Copy the entire contents of `teardown_all.sql` and paste
4. Click **Run All**

The script drops all Fiberific objects while preserving shared infrastructure.

## What Gets Removed

| Object | Action |
|--------|--------|
| `FIBERIFIC_DASHBOARD` | Streamlit dropped |
| `FIBERIFIC_AGENT` | Agent dropped |
| `SV_FIBERIFIC_OPS` | Semantic view dropped |
| `SNOWFLAKE_EXAMPLE.FIBERIFIC` | Schema + all objects dropped (CASCADE) |
| `SFE_FIBERIFIC_WH` | Warehouse dropped |
| `SFE_FIBERIFIC_REPO` | Git repo object dropped |

## What Is Preserved

| Object | Reason |
|--------|--------|
| `SNOWFLAKE_EXAMPLE` database | Shared by all demos |
| `SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS` schema | Shared semantic views |
| `SNOWFLAKE_EXAMPLE.TOOLS` schema | Shared infrastructure |
| `SFE_GIT_API_INTEGRATION` | Shared across projects |

## Re-Deploy

To re-deploy after cleanup, simply run `deploy_all.sql` again.
The deployment script is fully idempotent.
