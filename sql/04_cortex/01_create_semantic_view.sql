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
    -- Node facts
    nodes.node_capacity AS capacity_gbps
      SYNONYMS = ('node capacity', 'pop capacity', 'site capacity'),

    -- Circuit facts
    circuits.circuit_capacity AS capacity_gbps
      SYNONYMS = ('circuit bandwidth', 'link capacity', 'circuit speed'),
    circuits.circuit_distance AS distance_miles
      SYNONYMS = ('fiber miles', 'span length', 'route distance'),
    circuits.circuit_cost AS monthly_cost
      SYNONYMS = ('circuit MRC', 'monthly recurring cost', 'circuit price'),
    circuits.sla_target AS sla_uptime_pct
      SYNONYMS = ('uptime SLA', 'availability target'),

    -- Event facts
    events.event_duration AS duration_minutes
      SYNONYMS = ('outage duration', 'incident length', 'downtime minutes'),

    -- Customer facts
    customers.monthly_revenue AS mrr
      SYNONYMS = ('MRR', 'monthly recurring revenue', 'customer revenue'),
    customers.customer_nps AS nps_score
      SYNONYMS = ('NPS', 'net promoter score', 'satisfaction score'),

    -- Order facts
    orders.order_bandwidth AS bandwidth_gbps
      SYNONYMS = ('ordered bandwidth', 'service speed'),
    orders.order_install_time AS install_days
      SYNONYMS = ('installation time', 'provisioning days', 'turn-up time'),
    orders.order_revenue AS revenue_impact
      SYNONYMS = ('revenue impact', 'order value', 'deal size'),

    -- Ticket facts
    tickets.ticket_resolution_time AS resolution_hours
      SYNONYMS = ('time to resolve', 'MTTR', 'resolution time'),

    -- Traffic facts
    traffic.traffic_inbound AS inbound_gbps
      SYNONYMS = ('download speed', 'inbound traffic', 'ingress'),
    traffic.traffic_outbound AS outbound_gbps
      SYNONYMS = ('upload speed', 'outbound traffic', 'egress'),
    traffic.traffic_packet_loss AS packet_loss_pct
      SYNONYMS = ('packet loss', 'loss rate', 'dropped packets'),
    traffic.traffic_latency AS latency_ms
      SYNONYMS = ('latency', 'delay', 'round trip time', 'RTT'),
    traffic.traffic_jitter AS jitter_ms
      SYNONYMS = ('jitter', 'delay variation', 'PDV')
  )

  DIMENSIONS (
    -- Node dimensions
    nodes.node_name
      SYNONYMS = ('POP name', 'site name', 'node'),
    nodes.node_type
      SYNONYMS = ('POP type', 'site type', 'facility type'),
    nodes.node_city AS city
      SYNONYMS = ('city', 'location'),
    nodes.node_state AS state
      SYNONYMS = ('state', 'region'),
    nodes.node_status AS status
      SYNONYMS = ('node status', 'site status'),

    -- Circuit dimensions
    circuits.circuit_name
      SYNONYMS = ('circuit ID', 'link name', 'CKT'),
    circuits.circuit_type
      SYNONYMS = ('service type', 'product type', 'circuit product'),
    circuits.circuit_status AS status
      SYNONYMS = ('circuit status', 'link status'),

    -- Event dimensions
    events.event_type
      SYNONYMS = ('incident type', 'alarm type', 'event category'),
    events.event_severity AS severity
      SYNONYMS = ('severity', 'priority', 'impact level'),
    events.event_time AS event_timestamp
      SYNONYMS = ('event time', 'alarm time', 'incident time'),
    events.event_root_cause AS root_cause
      SYNONYMS = ('root cause', 'failure reason', 'cause'),

    -- Customer dimensions
    customers.company_name
      SYNONYMS = ('customer name', 'account name', 'company'),
    customers.customer_industry AS industry
      SYNONYMS = ('industry', 'vertical', 'sector'),
    customers.customer_segment AS segment
      SYNONYMS = ('segment', 'tier', 'customer tier'),
    customers.customer_status AS status
      SYNONYMS = ('customer status', 'account status'),
    customers.contract_start_date AS contract_start
      SYNONYMS = ('contract start', 'start date'),
    customers.contract_end_date AS contract_end
      SYNONYMS = ('contract end', 'renewal date', 'expiration'),

    -- Order dimensions
    orders.order_type
      SYNONYMS = ('order type', 'request type'),
    orders.service_type
      SYNONYMS = ('service type', 'product ordered'),
    orders.order_status AS status
      SYNONYMS = ('order status', 'fulfillment status'),
    orders.order_date AS requested_date
      SYNONYMS = ('order date', 'request date'),

    -- Ticket dimensions
    tickets.ticket_category AS category
      SYNONYMS = ('ticket category', 'issue type', 'problem type'),
    tickets.ticket_priority AS priority
      SYNONYMS = ('ticket priority', 'urgency'),
    tickets.ticket_status AS status
      SYNONYMS = ('ticket status'),
    tickets.ticket_date AS created_date
      SYNONYMS = ('ticket date', 'opened date'),

    -- Traffic dimensions
    traffic.metric_time AS metric_timestamp
      SYNONYMS = ('measurement time', 'sample time')
  )

  METRICS (
    -- Network metrics
    nodes.total_nodes AS COUNT(node_id)
      SYNONYMS = ('node count', 'POP count', 'number of sites'),
    circuits.total_circuits AS COUNT(circuit_id)
      SYNONYMS = ('circuit count', 'number of circuits', 'link count'),
    circuits.total_capacity_gbps AS SUM(circuit_capacity)
      SYNONYMS = ('total bandwidth', 'aggregate capacity'),
    circuits.total_circuit_cost AS SUM(circuit_cost)
      SYNONYMS = ('total MRC', 'total monthly cost'),
    circuits.avg_cost_per_gbps AS AVG(circuit_cost / NULLIF(circuit_capacity, 0))
      SYNONYMS = ('cost per gig', 'price per gbps'),

    -- Event metrics
    events.total_events AS COUNT(event_id)
      SYNONYMS = ('event count', 'incident count', 'alarm count'),
    events.avg_resolution_minutes AS AVG(event_duration)
      SYNONYMS = ('mean time to repair', 'MTTR', 'average resolution time'),

    -- Customer metrics
    customers.total_customers AS COUNT(customer_id)
      SYNONYMS = ('customer count', 'number of customers'),
    customers.total_mrr AS SUM(monthly_revenue)
      SYNONYMS = ('total MRR', 'total monthly revenue', 'aggregate revenue'),
    customers.avg_mrr AS AVG(monthly_revenue)
      SYNONYMS = ('average MRR', 'average revenue per customer', 'ARPU'),
    customers.avg_nps AS AVG(customer_nps)
      SYNONYMS = ('average NPS', 'overall satisfaction'),

    -- Order metrics
    orders.total_orders AS COUNT(order_id)
      SYNONYMS = ('order count', 'number of orders'),
    orders.total_revenue_impact AS SUM(order_revenue)
      SYNONYMS = ('total order value', 'pipeline value'),
    orders.avg_install_days AS AVG(order_install_time)
      SYNONYMS = ('average install time', 'mean provisioning time'),

    -- Ticket metrics
    tickets.total_tickets AS COUNT(ticket_id)
      SYNONYMS = ('ticket count', 'number of tickets', 'support volume'),
    tickets.avg_resolution_hours AS AVG(ticket_resolution_time)
      SYNONYMS = ('average resolution time', 'mean time to resolve'),

    -- Traffic metrics
    traffic.avg_inbound AS AVG(traffic_inbound)
      SYNONYMS = ('average download', 'mean inbound traffic'),
    traffic.avg_outbound AS AVG(traffic_outbound)
      SYNONYMS = ('average upload', 'mean outbound traffic'),
    traffic.avg_latency AS AVG(traffic_latency)
      SYNONYMS = ('average latency', 'mean delay'),
    traffic.avg_packet_loss AS AVG(traffic_packet_loss)
      SYNONYMS = ('average packet loss', 'mean loss rate')
  )

  COMMENT = 'DEMO: Fiber telecom operations semantic model for Cortex Analyst (Expires: 2026-03-20)'

  AI_SQL_GENERATION 'This semantic model covers a regional fiber telecom operator in the Northeastern US. '
    'The network consists of 50 POPs (points of presence) connected by 120 fiber circuits serving 200 enterprise customers. '
    'When asked about outages or incidents, query the events table filtered by event_type and severity. '
    'When asked about network performance, use the traffic table for latency, jitter, and packet loss metrics. '
    'When asked about customer health, combine customers with tickets and orders data. '
    'MRR means monthly recurring revenue. MTTR means mean time to repair. '
    'Circuit types include DARK_FIBER, WAVELENGTH, ETHERNET, and DEDICATED_INTERNET. '
    'Customer segments are ENTERPRISE, BUSINESS, and SMB. '
    'For time-based queries, use sargable date range predicates (e.g., event_timestamp >= DATEADD). '
    'States in the network: NY, VT, ME, MA, CT, NH.'
;
