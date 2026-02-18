from snowflake.snowpark.context import get_active_session
import streamlit as st

st.set_page_config(
    page_title="Fiberific Network Ops",
    page_icon="🔌",
    layout="wide"
)

session = get_active_session()


def run_query(sql):
    return session.sql(sql).to_pandas()


# ------------------------------------------------------------------
# Sidebar
# ------------------------------------------------------------------
st.sidebar.title("Fiberific")
st.sidebar.caption("AI-Powered Fiber Network Operations")

states = run_query(
    "SELECT DISTINCT state FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_NETWORK_NODES ORDER BY state"
)
selected_states = st.sidebar.multiselect(
    "Filter by State", states["STATE"].tolist(), default=states["STATE"].tolist()
)
state_filter = ",".join([f"'{s}'" for s in selected_states])

severity_options = ["ALL", "CRITICAL", "MAJOR", "MINOR", "WARNING"]
selected_severity = st.sidebar.selectbox("Event Severity", severity_options)

st.sidebar.markdown("---")
st.sidebar.markdown("**Data Source:** SNOWFLAKE_EXAMPLE.FIBERIFIC")
st.sidebar.markdown("**Tech:** Streamlit in Snowflake + Cortex AI")

# ------------------------------------------------------------------
# Header
# ------------------------------------------------------------------
st.title("Fiber Network Operations Dashboard")
st.markdown(
    "Real-time visibility into network health, circuit utilization, "
    "customer intelligence, and AI-powered ticket analysis."
)

# ------------------------------------------------------------------
# KPI Row
# ------------------------------------------------------------------
kpi_sql = f"""
SELECT
  (SELECT COUNT(DISTINCT node_id) FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_NETWORK_NODES
   WHERE state IN ({state_filter})) AS total_nodes,
  (SELECT COUNT(DISTINCT circuit_id) FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_NETWORK_CIRCUITS
   WHERE status = 'ACTIVE') AS active_circuits,
  (SELECT COUNT(DISTINCT customer_id) FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_CUSTOMERS
   WHERE status = 'ACTIVE') AS active_customers,
  (SELECT COUNT(DISTINCT event_id) FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_NETWORK_EVENTS
   WHERE event_timestamp >= DATEADD('day', -7, CURRENT_TIMESTAMP())
     AND severity = 'CRITICAL') AS critical_events_7d,
  (SELECT ROUND(SUM(mrr), 0) FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_CUSTOMERS
   WHERE status = 'ACTIVE') AS total_mrr,
  (SELECT COUNT(DISTINCT ticket_id) FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_TICKETS
   WHERE status = 'OPEN') AS open_tickets
"""
kpis = run_query(kpi_sql)

col1, col2, col3, col4, col5, col6 = st.columns(6)
col1.metric("Network Nodes", f"{kpis['TOTAL_NODES'][0]:,}")
col2.metric("Active Circuits", f"{kpis['ACTIVE_CIRCUITS'][0]:,}")
col3.metric("Active Customers", f"{kpis['ACTIVE_CUSTOMERS'][0]:,}")
col4.metric("Critical Events (7d)", f"{kpis['CRITICAL_EVENTS_7D'][0]:,}")
col5.metric("Total MRR", f"${kpis['TOTAL_MRR'][0]:,.0f}")
col6.metric("Open Tickets", f"{kpis['OPEN_TICKETS'][0]:,}")

st.markdown("---")

# ------------------------------------------------------------------
# Network Health
# ------------------------------------------------------------------
tab1, tab2, tab3, tab4 = st.tabs([
    "Network Health", "Circuit Utilization", "Customer Intelligence", "AI Ticket Analysis"
])

with tab1:
    st.subheader("Network Health by Node")

    severity_clause = ""
    if selected_severity != "ALL":
        severity_clause = f"AND e.severity = '{selected_severity}'"

    health_sql = f"""
    SELECT
      n.node_name,
      n.node_type,
      n.city,
      n.state,
      n.status AS node_status,
      COUNT(DISTINCT e.event_id) AS events_30d,
      COUNT(DISTINCT CASE WHEN e.severity = 'CRITICAL' THEN e.event_id END) AS critical_30d,
      COUNT(DISTINCT CASE WHEN e.resolved_at IS NULL AND e.event_type != 'MAINTENANCE'
            THEN e.event_id END) AS open_incidents,
      ROUND(AVG(e.duration_minutes), 1) AS avg_resolution_min
    FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_NETWORK_NODES n
    LEFT JOIN SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_NETWORK_EVENTS e
      ON n.node_id = e.node_id
      AND e.event_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP())
      {severity_clause}
    WHERE n.state IN ({state_filter})
    GROUP BY n.node_name, n.node_type, n.city, n.state, n.status
    ORDER BY events_30d DESC
    LIMIT 25
    """
    health_df = run_query(health_sql)
    st.dataframe(health_df, use_container_width=True)

    col_a, col_b = st.columns(2)
    with col_a:
        st.subheader("Events by Type (30 days)")
        events_by_type = run_query(f"""
          SELECT event_type, COUNT(event_id) AS event_count
          FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_NETWORK_EVENTS
          WHERE event_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP())
          GROUP BY event_type ORDER BY event_count DESC
        """)
        st.bar_chart(events_by_type.set_index("EVENT_TYPE"))

    with col_b:
        st.subheader("Events by Severity (30 days)")
        events_by_sev = run_query(f"""
          SELECT severity,
            COUNT(event_id) AS event_count
          FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_NETWORK_EVENTS
          WHERE event_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP())
          GROUP BY severity ORDER BY event_count DESC
        """)
        st.bar_chart(events_by_sev.set_index("SEVERITY"))

# ------------------------------------------------------------------
# Circuit Utilization
# ------------------------------------------------------------------
with tab2:
    st.subheader("Circuit Utilization Overview")

    util_sql = """
    SELECT
      c.circuit_name,
      c.circuit_type,
      c.capacity_gbps,
      ROUND(AVG(tm.inbound_gbps + tm.outbound_gbps), 4) AS avg_total_gbps,
      ROUND(AVG(tm.inbound_gbps + tm.outbound_gbps) / NULLIF(c.capacity_gbps, 0) * 100, 1)
        AS avg_util_pct,
      ROUND(MAX(tm.inbound_gbps + tm.outbound_gbps) / NULLIF(c.capacity_gbps, 0) * 100, 1)
        AS peak_util_pct,
      ROUND(AVG(tm.latency_ms), 2) AS avg_latency_ms,
      ROUND(AVG(tm.packet_loss_pct), 3) AS avg_loss_pct
    FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_NETWORK_CIRCUITS c
    JOIN SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_TRAFFIC_METRICS tm
      ON c.circuit_id = tm.circuit_id
      AND tm.metric_timestamp >= DATEADD('day', -7, CURRENT_TIMESTAMP())
    WHERE c.status = 'ACTIVE'
    GROUP BY c.circuit_name, c.circuit_type, c.capacity_gbps
    ORDER BY avg_util_pct DESC
    LIMIT 30
    """
    util_df = run_query(util_sql)
    st.dataframe(util_df, use_container_width=True)

    st.subheader("Capacity Status Distribution")
    cap_status = run_query("""
      SELECT
        CASE
          WHEN MAX(tm.inbound_gbps + tm.outbound_gbps) / NULLIF(c.capacity_gbps, 0) * 100 > 90
            THEN 'CRITICAL (>90%)'
          WHEN MAX(tm.inbound_gbps + tm.outbound_gbps) / NULLIF(c.capacity_gbps, 0) * 100 > 75
            THEN 'WARNING (75-90%)'
          ELSE 'NORMAL (<75%)'
        END AS capacity_status,
        COUNT(DISTINCT c.circuit_id) AS circuit_count
      FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_NETWORK_CIRCUITS c
      JOIN SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_TRAFFIC_METRICS tm
        ON c.circuit_id = tm.circuit_id
        AND tm.metric_timestamp >= DATEADD('day', -7, CURRENT_TIMESTAMP())
      WHERE c.status = 'ACTIVE'
      GROUP BY capacity_status
      ORDER BY circuit_count DESC
    """)
    st.bar_chart(cap_status.set_index("CAPACITY_STATUS"))

# ------------------------------------------------------------------
# Customer Intelligence
# ------------------------------------------------------------------
with tab3:
    st.subheader("Customer Intelligence")

    col_c, col_d = st.columns(2)
    with col_c:
        st.markdown("**MRR by Segment**")
        mrr_seg = run_query("""
          SELECT segment,
            COUNT(customer_id) AS customers,
            ROUND(SUM(mrr), 2) AS total_mrr,
            ROUND(AVG(mrr), 2) AS avg_mrr
          FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_CUSTOMERS
          WHERE status = 'ACTIVE'
          GROUP BY segment ORDER BY total_mrr DESC
        """)
        st.dataframe(mrr_seg, use_container_width=True)

    with col_d:
        st.markdown("**Churn Risk Indicators**")
        churn_sql = """
        SELECT
          cu.company_name,
          cu.segment,
          cu.mrr,
          cu.nps_score,
          DATEDIFF('day', CURRENT_DATE(), cu.contract_end) AS days_to_renewal,
          COUNT(DISTINCT t.ticket_id) AS total_tickets,
          COUNT(DISTINCT CASE WHEN t.priority IN ('CRITICAL','HIGH') THEN t.ticket_id END)
            AS high_pri_tickets
        FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_CUSTOMERS cu
        LEFT JOIN SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_TICKETS t ON cu.customer_id = t.customer_id
        WHERE cu.status = 'ACTIVE'
          AND (cu.nps_score < 20 OR DATEDIFF('day', CURRENT_DATE(), cu.contract_end) < 90)
        GROUP BY cu.company_name, cu.segment, cu.mrr, cu.nps_score, cu.contract_end
        ORDER BY cu.mrr DESC
        LIMIT 15
        """
        churn_df = run_query(churn_sql)
        st.dataframe(churn_df, use_container_width=True)

    st.subheader("Customers by Industry")
    industry_df = run_query("""
      SELECT industry,
        COUNT(customer_id) AS customers,
        ROUND(SUM(mrr), 2) AS total_mrr,
        ROUND(AVG(nps_score), 1) AS avg_nps
      FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_CUSTOMERS
      WHERE status = 'ACTIVE'
      GROUP BY industry ORDER BY total_mrr DESC
    """)
    st.bar_chart(industry_df.set_index("INDUSTRY")["TOTAL_MRR"])

# ------------------------------------------------------------------
# AI Ticket Analysis
# ------------------------------------------------------------------
with tab4:
    st.subheader("AI-Powered Ticket Analysis")
    st.info(
        "This tab uses Cortex LLM functions (SENTIMENT, SUMMARIZE, COMPLETE) "
        "to enrich support tickets with AI insights in real time."
    )

    ai_limit = st.slider("Number of tickets to analyze", 5, 50, 10)

    ai_sql = f"""
    SELECT
      t.ticket_id,
      cu.company_name,
      t.category,
      t.priority,
      t.subject,
      t.status AS ticket_status,
      t.created_date,
      ROUND(SNOWFLAKE.CORTEX.SENTIMENT(t.description), 3) AS sentiment_score,
      CASE
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(t.description) < -0.3 THEN 'NEGATIVE'
        WHEN SNOWFLAKE.CORTEX.SENTIMENT(t.description) > 0.3 THEN 'POSITIVE'
        ELSE 'NEUTRAL'
      END AS sentiment,
      SNOWFLAKE.CORTEX.SUMMARIZE(t.description) AS ai_summary
    FROM SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_TICKETS t
    LEFT JOIN SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_CUSTOMERS cu ON t.customer_id = cu.customer_id
    WHERE t.status IN ('OPEN', 'IN_PROGRESS')
    ORDER BY t.created_date DESC
    LIMIT {ai_limit}
    """
    with st.spinner("Running Cortex AI analysis..."):
        ai_df = run_query(ai_sql)

    st.dataframe(ai_df, use_container_width=True)

    if not ai_df.empty:
        st.subheader("Sentiment Distribution")
        sent_counts = ai_df["SENTIMENT"].value_counts().reset_index()
        sent_counts.columns = ["SENTIMENT", "COUNT"]
        st.bar_chart(sent_counts.set_index("SENTIMENT"))

# ------------------------------------------------------------------
# Footer
# ------------------------------------------------------------------
st.markdown("---")
st.caption(
    "Fiberific Demo | Snowflake Cortex AI + Streamlit in Snowflake | "
    "Data: SNOWFLAKE_EXAMPLE.FIBERIFIC"
)
