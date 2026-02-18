# Fiberific - Fiber Telecom AI Operations Demo

## Business Use Case

A regional fiber telecom operator has invested heavily in Snowflake for data engineering
(ingestion, transformation, BI) but has zero AI/ML adoption. This demo shows how Cortex AI
transforms their existing data investment into intelligent operations — from natural language
queries about network performance to AI-powered anomaly detection and customer churn signals.

**Narrative arc:** "You already did the hard work. Now unlock the AI."

## Target Persona / Industry

- **Industry:** Telecommunications (physical fiber optic networks)
- **Personas:** VP Network Operations, Director of Customer Experience, Data Engineering Lead
- **Pain points:**
  - Manual log triage for network events (1000s of alarms/day)
  - No self-service analytics for business users
  - Customer churn detected reactively (after disconnect)
  - Siloed data across network, customer, and field service systems

## Key Features to Demonstrate

1. **Data Foundation** — Unified schema for network nodes, circuits, customers, tickets, traffic
2. **Cortex LLM Functions** — SENTIMENT on support tickets, SUMMARIZE on network event logs,
   COMPLETE for anomaly classification
3. **Cortex Analyst (Semantic View)** — Natural language queries across network ops and customer data
4. **Cortex Agent (Snowflake Intelligence)** — Self-service agent combining structured analytics
   with unstructured ticket search
5. **Streamlit Dashboard** — Network health, circuit utilization, customer intelligence, AI ticket analysis

## Technical Requirements

- Snowflake Enterprise Edition (Cortex AI functions)
- XSMALL warehouse (all queries < 5s)
- Cortex LLM functions: SNOWFLAKE.CORTEX.COMPLETE, SNOWFLAKE.CORTEX.SUMMARIZE, SNOWFLAKE.CORTEX.SENTIMENT
- Semantic View in SEMANTIC_MODELS schema
- Cortex Agent in snowflake_intelligence.agents namespace
- Streamlit in Snowflake (Git-integrated deployment)
- Sample data via GENERATOR (no external files)

## GitHub Repo URL

https://github.com/sfc-gh-miwhitaker/fiberific
