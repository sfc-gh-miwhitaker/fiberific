# Deployment Guide

## Prerequisites

- Snowflake account with **Enterprise Edition** (required for Cortex AI)
- `SYSADMIN` role access
- `SFE_GIT_API_INTEGRATION` configured (shared Git API integration)
- `SFE_GIT_CREDS` secret in `SNOWFLAKE_EXAMPLE.TOOLS` schema

## Deploy (One Command)

1. Open **Snowsight** (the Snowflake web UI)
2. Click **+ → SQL Worksheet**
3. Copy the entire contents of `deploy_all.sql` and paste into the worksheet
4. Click **Run All** (or Ctrl+Shift+Enter)
5. Wait ~5 minutes for completion

The final result will show:
```
status: Fiberific deployment complete!
next_step: Open Streamlit dashboard or ask the Cortex Agent a question
```

## What Gets Created

### Schema & Warehouse
| Object | Description |
|--------|-------------|
| `SNOWFLAKE_EXAMPLE.FIBERIFIC` | Project schema |
| `SFE_FIBERIFIC_WH` | XS warehouse (auto-suspend 60s) |

### Tables (in FIBERIFIC schema)
| Table | Rows | Description |
|-------|------|-------------|
| `RAW_NETWORK_NODES` | 50 | Fiber POPs across NE US |
| `RAW_NETWORK_CIRCUITS` | 120 | Fiber links between nodes |
| `RAW_NETWORK_EVENTS` | 2,000 | Network alarms/incidents |
| `RAW_CUSTOMERS` | 200 | Enterprise customers |
| `RAW_SERVICE_ORDERS` | 500 | Install/change/disconnect orders |
| `RAW_TICKETS` | 800 | Support tickets with text |
| `RAW_TRAFFIC_METRICS` | 50,000 | Hourly circuit utilization |

### Views
| View | Description |
|------|-------------|
| `V_NETWORK_HEALTH` | Network health by node |
| `V_CUSTOMER_360` | Unified customer view |
| `V_CIRCUIT_UTILIZATION` | Circuit capacity analysis |
| `V_TICKET_ANALYSIS` | AI-enriched ticket analysis (Cortex) |
| `V_EVENT_INTELLIGENCE` | AI-enriched event analysis (Cortex) |

### Cortex AI Objects
| Object | Description |
|--------|-------------|
| `SEMANTIC_MODELS.SV_FIBERIFIC_OPS` | Semantic view for Cortex Analyst |
| `FIBERIFIC_AGENT` | Snowflake Intelligence agent |
| `FIBERIFIC_DASHBOARD` | Streamlit operations dashboard |

## Estimated Runtime

| Phase | Time |
|-------|------|
| Schema/warehouse setup | ~10s |
| Table creation | ~5s |
| Sample data generation | ~30s |
| View creation | ~5s |
| Cortex objects | ~15s |
| Streamlit deployment | ~10s |
| **Total** | **~1-2 minutes** |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "DEMO EXPIRED" error | Demo expired. Update `SET DEMO_EXPIRES` date |
| Git fetch fails | Verify `SFE_GIT_API_INTEGRATION` exists |
| Cortex functions fail | Ensure Enterprise Edition and `SNOWFLAKE.CORTEX_USER` role |
| Streamlit won't load | Check warehouse is running, try refreshing |
