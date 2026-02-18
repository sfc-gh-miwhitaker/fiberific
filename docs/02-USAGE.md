# Usage Guide

## Streamlit Dashboard

After deployment, open the Streamlit app:

1. In Snowsight, navigate to **Projects → Streamlit**
2. Find **FIBERIFIC_DASHBOARD** in the `SNOWFLAKE_EXAMPLE.FIBERIFIC` schema
3. Click to open

### Dashboard Tabs

**Network Health** — Node-level health overview with event counts, severity breakdown,
and open incidents. Use the sidebar filters to focus on specific states or severity levels.

**Circuit Utilization** — Top circuits by utilization percentage, capacity status distribution,
and performance metrics (latency, packet loss).

**Customer Intelligence** — MRR by segment, churn risk indicators (low NPS + expiring
contracts + high ticket volume), and industry breakdown.

**AI Ticket Analysis** — Real-time Cortex AI analysis of open support tickets. Each ticket
gets sentiment scoring, automatic summary, and urgency classification. Adjust the slider
to analyze more or fewer tickets.

## Cortex Agent (Snowflake Intelligence)

The Fiberific agent can answer natural language questions about the entire operational dataset.

### Access the Agent

1. In Snowsight, navigate to **AI & ML → Snowflake Intelligence**
2. Find **Fiberific Network Ops** agent
3. Start asking questions

### Example Questions

**Network Operations:**
- "How many critical events happened this week?"
- "What is the mean time to repair for fiber cut events?"
- "Which nodes had the most outages in January?"
- "Show me all active critical incidents"

**Circuit Performance:**
- "Which circuits have the highest utilization?"
- "What is the average latency across all circuits?"
- "List circuits with packet loss above 1%"
- "What is our total circuit capacity by type?"

**Customer Intelligence:**
- "What is our average MRR by customer segment?"
- "Which customers have the most open tickets?"
- "Show enterprise customers with NPS below 20"
- "How many customers have contracts expiring in the next 90 days?"

**Service Orders:**
- "How many new install orders are pending?"
- "What is the average installation time?"
- "Show the total revenue impact of completed orders this quarter"

## AI-Enriched Views

Query these views directly for AI-powered insights:

### V_TICKET_ANALYSIS
```sql
SELECT ticket_id, company_name, subject, sentiment_score, sentiment_label, ai_summary
FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.V_TICKET_ANALYSIS
WHERE sentiment_label = 'NEGATIVE'
ORDER BY sentiment_score
LIMIT 10;
```

### V_EVENT_INTELLIGENCE
```sql
SELECT event_id, node_name, event_type, severity, ai_summary, ai_customer_impact
FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.V_EVENT_INTELLIGENCE
WHERE resolution_status = 'ACTIVE'
ORDER BY event_timestamp DESC
LIMIT 10;
```
