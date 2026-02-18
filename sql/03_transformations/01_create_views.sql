/*==============================================================================
VIEWS - Fiberific
Analytics views for network health, customer 360, and circuit utilization.
==============================================================================*/

USE SCHEMA SNOWFLAKE_EXAMPLE.FIBERIFIC;
USE WAREHOUSE SFE_FIBERIFIC_WH;

----------------------------------------------------------------------
-- V_NETWORK_HEALTH: Real-time network health overview
----------------------------------------------------------------------
CREATE OR REPLACE VIEW V_NETWORK_HEALTH
  COMMENT = 'DEMO: Network health summary by node (Expires: 2026-03-20)'
AS
SELECT
  n.node_id,
  n.node_name,
  n.node_type,
  n.city,
  n.state,
  n.status AS node_status,
  n.capacity_gbps AS node_capacity_gbps,
  COUNT(DISTINCT e.event_id) AS total_events_30d,
  COUNT(DISTINCT CASE WHEN e.severity = 'CRITICAL' THEN e.event_id END) AS critical_events_30d,
  COUNT(DISTINCT CASE WHEN e.severity = 'MAJOR' THEN e.event_id END) AS major_events_30d,
  COUNT(DISTINCT CASE WHEN e.resolved_at IS NULL AND e.event_type != 'MAINTENANCE' THEN e.event_id END) AS open_incidents,
  ROUND(AVG(e.duration_minutes), 1) AS avg_resolution_minutes,
  COUNT(DISTINCT c.circuit_id) AS connected_circuits,
  ROUND(SUM(c.capacity_gbps), 2) AS total_circuit_capacity_gbps,
  CASE
    WHEN COUNT(DISTINCT CASE WHEN e.severity = 'CRITICAL' AND e.resolved_at IS NULL THEN e.event_id END) > 0 THEN 'RED'
    WHEN COUNT(DISTINCT CASE WHEN e.severity IN ('CRITICAL','MAJOR') THEN e.event_id END) > 5 THEN 'YELLOW'
    ELSE 'GREEN'
  END AS health_status
FROM RAW_NETWORK_NODES n
LEFT JOIN RAW_NETWORK_EVENTS e
  ON n.node_id = e.node_id
  AND e.event_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP())
LEFT JOIN RAW_NETWORK_CIRCUITS c
  ON (n.node_id = c.node_a_id OR n.node_id = c.node_b_id)
  AND c.status = 'ACTIVE'
GROUP BY n.node_id, n.node_name, n.node_type, n.city, n.state, n.status, n.capacity_gbps;

----------------------------------------------------------------------
-- V_CUSTOMER_360: Unified customer view
----------------------------------------------------------------------
CREATE OR REPLACE VIEW V_CUSTOMER_360
  COMMENT = 'DEMO: Customer 360 with services, tickets, and revenue (Expires: 2026-03-20)'
AS
SELECT
  cu.customer_id,
  cu.company_name,
  cu.industry,
  cu.segment,
  cu.city,
  cu.state,
  cu.contract_start,
  cu.contract_end,
  cu.mrr,
  cu.status AS customer_status,
  cu.nps_score,
  DATEDIFF('day', CURRENT_DATE(), cu.contract_end) AS days_to_renewal,
  COUNT(DISTINCT so.order_id) AS total_orders,
  COUNT(DISTINCT CASE WHEN so.order_type = 'NEW_INSTALL' THEN so.order_id END) AS new_installs,
  COUNT(DISTINCT CASE WHEN so.order_type = 'DISCONNECT' THEN so.order_id END) AS disconnects,
  ROUND(SUM(CASE WHEN so.status = 'COMPLETED' THEN so.revenue_impact ELSE 0 END), 2) AS realized_revenue_impact,
  COUNT(DISTINCT t.ticket_id) AS total_tickets,
  COUNT(DISTINCT CASE WHEN t.priority IN ('CRITICAL','HIGH') THEN t.ticket_id END) AS high_priority_tickets,
  COUNT(DISTINCT CASE WHEN t.status = 'OPEN' THEN t.ticket_id END) AS open_tickets,
  ROUND(AVG(t.resolution_hours), 1) AS avg_resolution_hours,
  CASE
    WHEN cu.nps_score < 0 THEN 'DETRACTOR'
    WHEN cu.nps_score <= 6 THEN 'PASSIVE'
    WHEN cu.nps_score <= 8 THEN 'PROMOTER'
    ELSE 'CHAMPION'
  END AS nps_category,
  CASE
    WHEN cu.status = 'CHURNED' THEN 'CHURNED'
    WHEN cu.nps_score < 0
      AND COUNT(DISTINCT CASE WHEN t.priority IN ('CRITICAL','HIGH') THEN t.ticket_id END) > 3
      THEN 'HIGH_RISK'
    WHEN DATEDIFF('day', CURRENT_DATE(), cu.contract_end) < 90
      AND cu.nps_score < 30
      THEN 'AT_RISK'
    ELSE 'HEALTHY'
  END AS churn_risk
FROM RAW_CUSTOMERS cu
LEFT JOIN RAW_SERVICE_ORDERS so ON cu.customer_id = so.customer_id
LEFT JOIN RAW_TICKETS t ON cu.customer_id = t.customer_id
GROUP BY
  cu.customer_id, cu.company_name, cu.industry, cu.segment,
  cu.city, cu.state, cu.contract_start, cu.contract_end,
  cu.mrr, cu.status, cu.nps_score;

----------------------------------------------------------------------
-- V_CIRCUIT_UTILIZATION: Circuit capacity analysis
----------------------------------------------------------------------
CREATE OR REPLACE VIEW V_CIRCUIT_UTILIZATION
  COMMENT = 'DEMO: Circuit utilization and performance metrics (Expires: 2026-03-20)'
AS
SELECT
  c.circuit_id,
  c.circuit_name,
  c.circuit_type,
  c.capacity_gbps,
  c.status AS circuit_status,
  c.sla_uptime_pct,
  c.monthly_cost,
  na.node_name AS node_a_name,
  na.city AS node_a_city,
  nb.node_name AS node_b_name,
  nb.city AS node_b_city,
  c.distance_miles,
  ROUND(AVG(tm.inbound_gbps), 4) AS avg_inbound_gbps,
  ROUND(AVG(tm.outbound_gbps), 4) AS avg_outbound_gbps,
  ROUND(MAX(tm.inbound_gbps + tm.outbound_gbps), 4) AS peak_total_gbps,
  ROUND(AVG(tm.inbound_gbps + tm.outbound_gbps) / NULLIF(c.capacity_gbps, 0) * 100, 2) AS avg_utilization_pct,
  ROUND(MAX(tm.inbound_gbps + tm.outbound_gbps) / NULLIF(c.capacity_gbps, 0) * 100, 2) AS peak_utilization_pct,
  ROUND(AVG(tm.packet_loss_pct), 4) AS avg_packet_loss_pct,
  ROUND(AVG(tm.latency_ms), 2) AS avg_latency_ms,
  ROUND(AVG(tm.jitter_ms), 2) AS avg_jitter_ms,
  CASE
    WHEN MAX(tm.inbound_gbps + tm.outbound_gbps) / NULLIF(c.capacity_gbps, 0) * 100 > 90 THEN 'CRITICAL'
    WHEN MAX(tm.inbound_gbps + tm.outbound_gbps) / NULLIF(c.capacity_gbps, 0) * 100 > 75 THEN 'WARNING'
    ELSE 'NORMAL'
  END AS capacity_status,
  COUNT(DISTINCT e.event_id) AS events_30d,
  ROUND(c.monthly_cost / NULLIF(c.capacity_gbps, 0), 2) AS cost_per_gbps
FROM RAW_NETWORK_CIRCUITS c
LEFT JOIN RAW_NETWORK_NODES na ON c.node_a_id = na.node_id
LEFT JOIN RAW_NETWORK_NODES nb ON c.node_b_id = nb.node_id
LEFT JOIN RAW_TRAFFIC_METRICS tm
  ON c.circuit_id = tm.circuit_id
  AND tm.metric_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP())
LEFT JOIN RAW_NETWORK_EVENTS e
  ON c.circuit_id = e.circuit_id
  AND e.event_timestamp >= DATEADD('day', -30, CURRENT_TIMESTAMP())
WHERE c.status = 'ACTIVE'
GROUP BY
  c.circuit_id, c.circuit_name, c.circuit_type, c.capacity_gbps,
  c.status, c.sla_uptime_pct, c.monthly_cost,
  na.node_name, na.city, nb.node_name, nb.city, c.distance_miles;
