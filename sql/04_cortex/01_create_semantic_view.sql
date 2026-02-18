/*==============================================================================
SEMANTIC VIEW - Fiberific
Cortex Analyst semantic model for fiber telecom operations analytics.
==============================================================================*/

USE SCHEMA SNOWFLAKE_EXAMPLE.SEMANTIC_MODELS;
USE WAREHOUSE SFE_FIBERIFIC_WH;

CREATE OR REPLACE SEMANTIC VIEW SV_FIBERIFIC_OPS

  TABLES (
    nodes AS SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_NETWORK_NODES
      PRIMARY KEY (node_id),
    circuits AS SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_NETWORK_CIRCUITS
      PRIMARY KEY (circuit_id),
    events AS SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_NETWORK_EVENTS
      PRIMARY KEY (event_id),
    customers AS SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_CUSTOMERS
      PRIMARY KEY (customer_id),
    orders AS SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_SERVICE_ORDERS
      PRIMARY KEY (order_id),
    tickets AS SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_TICKETS
      PRIMARY KEY (ticket_id),
    traffic AS SNOWFLAKE_EXAMPLE.FIBERIFIC.RAW_TRAFFIC_METRICS
      PRIMARY KEY (metric_id)
  )

  RELATIONSHIPS (
    circuits  (node_a_id)    REFERENCES nodes,
    events    (node_id)      REFERENCES nodes,
    events    (circuit_id)   REFERENCES circuits,
    customers (primary_node_id) REFERENCES nodes,
    orders    (customer_id)  REFERENCES customers,
    orders    (circuit_id)   REFERENCES circuits,
    tickets   (customer_id)  REFERENCES customers,
    tickets   (circuit_id)   REFERENCES circuits,
    traffic   (circuit_id)   REFERENCES circuits
  )

  FACTS (
    nodes.node_capacity AS capacity_gbps
      WITH SYNONYMS = ('node capacity', 'pop capacity', 'site capacity'),

    circuits.circuit_capacity AS capacity_gbps
      WITH SYNONYMS = ('circuit bandwidth', 'link capacity', 'circuit speed'),
    circuits.circuit_distance AS distance_miles
      WITH SYNONYMS = ('fiber miles', 'span length', 'route distance'),
    circuits.circuit_cost AS monthly_cost
      WITH SYNONYMS = ('circuit MRC', 'monthly recurring cost', 'circuit price'),
    circuits.sla_target AS sla_uptime_pct
      WITH SYNONYMS = ('uptime SLA', 'availability target'),

    events.event_duration AS duration_minutes
      WITH SYNONYMS = ('outage duration', 'incident length', 'downtime minutes'),

    customers.monthly_revenue AS mrr
      WITH SYNONYMS = ('MRR', 'monthly recurring revenue', 'customer revenue'),
    customers.customer_nps AS nps_score
      WITH SYNONYMS = ('NPS', 'net promoter score', 'satisfaction score'),

    orders.order_bandwidth AS bandwidth_gbps
      WITH SYNONYMS = ('ordered bandwidth', 'service speed'),
    orders.order_install_time AS install_days
      WITH SYNONYMS = ('installation time', 'provisioning days', 'turn-up time'),
    orders.order_revenue AS revenue_impact
      WITH SYNONYMS = ('revenue impact', 'order value', 'deal size'),

    tickets.ticket_resolution_time AS resolution_hours
      WITH SYNONYMS = ('time to resolve', 'MTTR', 'resolution time'),

    traffic.traffic_inbound AS inbound_gbps
      WITH SYNONYMS = ('download speed', 'inbound traffic', 'ingress'),
    traffic.traffic_outbound AS outbound_gbps
      WITH SYNONYMS = ('upload speed', 'outbound traffic', 'egress'),
    traffic.traffic_packet_loss AS packet_loss_pct
      WITH SYNONYMS = ('packet loss', 'loss rate', 'dropped packets'),
    traffic.traffic_latency AS latency_ms
      WITH SYNONYMS = ('latency', 'delay', 'round trip time', 'RTT'),
    traffic.traffic_jitter AS jitter_ms
      WITH SYNONYMS = ('jitter', 'delay variation', 'PDV')
  )

  DIMENSIONS (
    nodes.node_name
      WITH SYNONYMS = ('POP name', 'site name', 'node'),
    nodes.node_type
      WITH SYNONYMS = ('POP type', 'site type', 'facility type'),
    nodes.node_city AS city
      WITH SYNONYMS = ('city', 'location'),
    nodes.node_state AS state
      WITH SYNONYMS = ('state', 'region'),
    nodes.node_status AS status
      WITH SYNONYMS = ('node status', 'site status'),

    circuits.circuit_name
      WITH SYNONYMS = ('circuit ID', 'link name', 'CKT'),
    circuits.circuit_type
      WITH SYNONYMS = ('service type', 'product type', 'circuit product'),
    circuits.circuit_status AS status
      WITH SYNONYMS = ('circuit status', 'link status'),

    events.event_type
      WITH SYNONYMS = ('incident type', 'alarm type', 'event category'),
    events.event_severity AS severity
      WITH SYNONYMS = ('severity', 'priority', 'impact level'),
    events.event_time AS event_timestamp
      WITH SYNONYMS = ('event time', 'alarm time', 'incident time'),
    events.event_root_cause AS root_cause
      WITH SYNONYMS = ('root cause', 'failure reason', 'cause'),

    customers.company_name
      WITH SYNONYMS = ('customer name', 'account name', 'company'),
    customers.customer_industry AS industry
      WITH SYNONYMS = ('industry', 'vertical', 'sector'),
    customers.customer_segment AS segment
      WITH SYNONYMS = ('segment', 'tier', 'customer tier'),
    customers.customer_status AS status
      WITH SYNONYMS = ('customer status', 'account status'),
    customers.contract_start_date AS contract_start
      WITH SYNONYMS = ('contract start', 'start date'),
    customers.contract_end_date AS contract_end
      WITH SYNONYMS = ('contract end', 'renewal date', 'expiration'),

    orders.order_type
      WITH SYNONYMS = ('order type', 'request type'),
    orders.service_type
      WITH SYNONYMS = ('service type', 'product ordered'),
    orders.order_status AS status
      WITH SYNONYMS = ('order status', 'fulfillment status'),
    orders.order_date AS requested_date
      WITH SYNONYMS = ('order date', 'request date'),

    tickets.ticket_category AS category
      WITH SYNONYMS = ('ticket category', 'issue type', 'problem type'),
    tickets.ticket_priority AS priority
      WITH SYNONYMS = ('ticket priority', 'urgency'),
    tickets.ticket_status AS status
      WITH SYNONYMS = ('ticket status'),
    tickets.ticket_date AS created_date
      WITH SYNONYMS = ('ticket date', 'opened date'),

    traffic.metric_time AS metric_timestamp
      WITH SYNONYMS = ('measurement time', 'sample time')
  )

  METRICS (
    nodes.total_nodes AS COUNT(node_id)
      WITH SYNONYMS = ('node count', 'POP count', 'number of sites'),
    circuits.total_circuits AS COUNT(circuit_id)
      WITH SYNONYMS = ('circuit count', 'number of circuits', 'link count'),
    circuits.total_capacity_gbps AS SUM(circuit_capacity)
      WITH SYNONYMS = ('total bandwidth', 'aggregate capacity'),
    circuits.total_circuit_cost AS SUM(circuit_cost)
      WITH SYNONYMS = ('total MRC', 'total monthly cost'),
    circuits.avg_cost_per_gbps AS AVG(circuit_cost / NULLIF(circuit_capacity, 0))
      WITH SYNONYMS = ('cost per gig', 'price per gbps'),

    events.total_events AS COUNT(event_id)
      WITH SYNONYMS = ('event count', 'incident count', 'alarm count'),
    events.avg_resolution_minutes AS AVG(event_duration)
      WITH SYNONYMS = ('mean time to repair', 'MTTR', 'average resolution time'),

    customers.total_customers AS COUNT(customer_id)
      WITH SYNONYMS = ('customer count', 'number of customers'),
    customers.total_mrr AS SUM(monthly_revenue)
      WITH SYNONYMS = ('total MRR', 'total monthly revenue', 'aggregate revenue'),
    customers.avg_mrr AS AVG(monthly_revenue)
      WITH SYNONYMS = ('average MRR', 'average revenue per customer', 'ARPU'),
    customers.avg_nps AS AVG(customer_nps)
      WITH SYNONYMS = ('average NPS', 'overall satisfaction'),

    orders.total_orders AS COUNT(order_id)
      WITH SYNONYMS = ('order count', 'number of orders'),
    orders.total_revenue_impact AS SUM(order_revenue)
      WITH SYNONYMS = ('total order value', 'pipeline value'),
    orders.avg_install_days AS AVG(order_install_time)
      WITH SYNONYMS = ('average install time', 'mean provisioning time'),

    tickets.total_tickets AS COUNT(ticket_id)
      WITH SYNONYMS = ('ticket count', 'number of tickets', 'support volume'),
    tickets.avg_resolution_hours AS AVG(ticket_resolution_time)
      WITH SYNONYMS = ('average resolution time', 'mean time to resolve'),

    traffic.avg_inbound AS AVG(traffic_inbound)
      WITH SYNONYMS = ('average download', 'mean inbound traffic'),
    traffic.avg_outbound AS AVG(traffic_outbound)
      WITH SYNONYMS = ('average upload', 'mean outbound traffic'),
    traffic.avg_latency AS AVG(traffic_latency)
      WITH SYNONYMS = ('average latency', 'mean delay'),
    traffic.avg_packet_loss AS AVG(traffic_packet_loss)
      WITH SYNONYMS = ('average packet loss', 'mean loss rate')
  )

  COMMENT = 'DEMO: Fiber telecom operations semantic model for Cortex Analyst (Expires: 2026-03-20)'

  AI_SQL_GENERATION 'This semantic model covers a regional fiber telecom operator in the Northeastern US. The network consists of 50 POPs (points of presence) connected by 120 fiber circuits serving 200 enterprise customers. When asked about outages or incidents, query the events table filtered by event_type and severity. When asked about network performance, use the traffic table for latency, jitter, and packet loss metrics. When asked about customer health, combine customers with tickets and orders data. MRR means monthly recurring revenue. MTTR means mean time to repair. Circuit types include DARK_FIBER, WAVELENGTH, ETHERNET, and DEDICATED_INTERNET. Customer segments are ENTERPRISE, BUSINESS, and SMB. For time-based queries, use sargable date range predicates. States in the network: NY, VT, ME, MA, CT, NH.'
;
