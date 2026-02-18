# Fiberific — AI-Powered Fiber Network Operations

![Expires](https://img.shields.io/badge/Expires-2026--03--20-orange)

> **Warning:** This demo expires on 2026-03-20. After expiration, deployment will fail.

Transform a fiber telecom operator's existing data investment into intelligent operations with Snowflake Cortex AI. Natural language queries on network performance, AI-powered anomaly detection, and customer intelligence — all without moving data.

**Author:** SE Community
**Created:** 2026-02-18 | **Expires:** 2026-03-20 | **Status:** ACTIVE

## First Time Here?

1. **Deploy** — Copy `deploy_all.sql` into Snowsight, click **Run All** (~5 minutes)
2. **Explore** — Open the Streamlit dashboard or ask the Cortex Agent questions
3. **Cleanup** — Run `teardown_all.sql` when done

## The Story

A regional fiber telecom has 1,800+ credits of data engineering workloads flowing through Snowflake — ingestion, transformation, BI. But their AI adoption score? **Zero.** This demo shows what happens when you flip the AI switch on a mature data foundation:

- **Network Ops** asks: *"Which circuits had the most outages last month?"* → Cortex Agent answers in seconds
- **Customer Experience** asks: *"What's the sentiment trend on our support tickets?"* → AI-powered ticket analysis
- **Engineering** asks: *"Summarize last night's network events"* → LLM-generated incident summaries

## What Gets Created

| Object | Type | Purpose |
|--------|------|---------|
| `SNOWFLAKE_EXAMPLE.FIBERIFIC` | Schema | Project schema |
| `SFE_FIBERIFIC_WH` | Warehouse | XS compute |
| `RAW_NETWORK_NODES` | Table | Fiber network nodes/POPs |
| `RAW_NETWORK_CIRCUITS` | Table | Fiber circuits between nodes |
| `RAW_NETWORK_EVENTS` | Table | Network alarms and incidents |
| `RAW_CUSTOMERS` | Table | Customer accounts |
| `RAW_SERVICE_ORDERS` | Table | Service install/change orders |
| `RAW_TICKETS` | Table | Support tickets (text) |
| `RAW_TRAFFIC_METRICS` | Table | Circuit utilization metrics |
| `V_NETWORK_HEALTH` | View | Network health dashboard |
| `V_CUSTOMER_360` | View | Customer unified view |
| `V_CIRCUIT_UTILIZATION` | View | Circuit capacity analysis |
| `V_TICKET_ANALYSIS` | View | AI-enriched ticket analysis |
| `SV_FIBERIFIC_OPS` | Semantic View | Cortex Analyst semantic model |
| `FIBERIFIC_AGENT` | Agent | Snowflake Intelligence agent |
| `FIBERIFIC_DASHBOARD` | Streamlit | Operations dashboard |

## Project Structure

```
fiberific/
├── README.md
├── LICENSE
├── deploy_all.sql
├── teardown_all.sql
├── plan.md
├── diagrams/
│   └── data-flow.md
├── sql/
│   ├── 01_setup/
│   │   └── 01_create_schema.sql
│   ├── 02_data/
│   │   ├── 01_create_tables.sql
│   │   └── 02_load_sample_data.sql
│   ├── 03_transformations/
│   │   ├── 01_create_views.sql
│   │   └── 02_create_ai_views.sql
│   ├── 04_cortex/
│   │   ├── 01_create_semantic_view.sql
│   │   └── 02_create_agent.sql
│   ├── 05_streamlit/
│   │   └── 01_create_dashboard.sql
│   └── 99_cleanup/
│       └── 01_drop_objects.sql
├── streamlit/
│   └── streamlit_app.py
└── docs/
    ├── 01-DEPLOYMENT.md
    ├── 02-USAGE.md
    └── 03-CLEANUP.md
```

## Estimated Demo Costs

| Component | Size | Est. Credits/Hour | Notes |
|-----------|------|-------------------|-------|
| Warehouse | XS | 1 | AUTO_SUSPEND = 60s |
| Cortex LLM | — | ~0.5 | COMPLETE, SUMMARIZE, SENTIMENT on sample data |
| Cortex Agent | — | ~0.2 | Per-query cost |
| Storage | ~10 MB | negligible | Sample data only |

**Edition:** Enterprise ($3/credit) — required for Cortex AI functions
**Estimated deployment cost:** < 1 credit
**Estimated hourly demo cost:** ~1.7 credits (~$5.10/hr)

## License

This demo is provided as-is for demonstration purposes.
