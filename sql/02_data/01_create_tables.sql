/*==============================================================================
TABLES - Fiberific
Fiber telecom network operations and customer management tables.
==============================================================================*/

USE SCHEMA SNOWFLAKE_EXAMPLE.FIBERIFIC;
USE WAREHOUSE SFE_FIBERIFIC_WH;

CREATE OR REPLACE TABLE RAW_NETWORK_NODES (
  node_id         NUMBER AUTOINCREMENT,
  node_name       VARCHAR(100)   NOT NULL,
  node_type       VARCHAR(30)    NOT NULL,
  city            VARCHAR(100)   NOT NULL,
  state           VARCHAR(2)     NOT NULL,
  latitude        FLOAT,
  longitude       FLOAT,
  status          VARCHAR(20)    DEFAULT 'ACTIVE',
  capacity_gbps   NUMBER(10,2),
  installed_date  DATE,
  last_maint_date DATE,
  created_at      TIMESTAMP_NTZ  DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'DEMO: Fiber network nodes and POPs (Expires: 2026-03-20)';

CREATE OR REPLACE TABLE RAW_NETWORK_CIRCUITS (
  circuit_id      NUMBER AUTOINCREMENT,
  circuit_name    VARCHAR(100)   NOT NULL,
  circuit_type    VARCHAR(30)    NOT NULL,
  node_a_id       NUMBER         NOT NULL,
  node_b_id       NUMBER         NOT NULL,
  capacity_gbps   NUMBER(10,2)   NOT NULL,
  distance_miles  NUMBER(10,2),
  status          VARCHAR(20)    DEFAULT 'ACTIVE',
  sla_uptime_pct  NUMBER(5,2)    DEFAULT 99.99,
  monthly_cost    NUMBER(12,2),
  provisioned_date DATE,
  created_at      TIMESTAMP_NTZ  DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'DEMO: Fiber circuits between nodes (Expires: 2026-03-20)';

CREATE OR REPLACE TABLE RAW_NETWORK_EVENTS (
  event_id        NUMBER AUTOINCREMENT,
  node_id         NUMBER         NOT NULL,
  circuit_id      NUMBER,
  event_type      VARCHAR(30)    NOT NULL,
  severity        VARCHAR(20)    NOT NULL,
  event_timestamp TIMESTAMP_NTZ  NOT NULL,
  resolved_at     TIMESTAMP_NTZ,
  duration_minutes NUMBER(10,2),
  description     VARCHAR(2000),
  root_cause      VARCHAR(500),
  created_at      TIMESTAMP_NTZ  DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'DEMO: Network alarms and incident events (Expires: 2026-03-20)';

CREATE OR REPLACE TABLE RAW_CUSTOMERS (
  customer_id     NUMBER AUTOINCREMENT,
  company_name    VARCHAR(200)   NOT NULL,
  industry        VARCHAR(50),
  segment         VARCHAR(30)    NOT NULL,
  city            VARCHAR(100),
  state           VARCHAR(2),
  primary_node_id NUMBER,
  contract_start  DATE,
  contract_end    DATE,
  mrr             NUMBER(12,2),
  status          VARCHAR(20)    DEFAULT 'ACTIVE',
  nps_score       NUMBER(3),
  created_at      TIMESTAMP_NTZ  DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'DEMO: Fiber customer accounts (Expires: 2026-03-20)';

CREATE OR REPLACE TABLE RAW_SERVICE_ORDERS (
  order_id        NUMBER AUTOINCREMENT,
  customer_id     NUMBER         NOT NULL,
  circuit_id      NUMBER,
  order_type      VARCHAR(30)    NOT NULL,
  service_type    VARCHAR(50)    NOT NULL,
  bandwidth_gbps  NUMBER(10,2),
  status          VARCHAR(20)    DEFAULT 'PENDING',
  requested_date  DATE           NOT NULL,
  completed_date  DATE,
  install_days    NUMBER(5),
  revenue_impact  NUMBER(12,2),
  created_at      TIMESTAMP_NTZ  DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'DEMO: Service installation and change orders (Expires: 2026-03-20)';

CREATE OR REPLACE TABLE RAW_TICKETS (
  ticket_id       NUMBER AUTOINCREMENT,
  customer_id     NUMBER         NOT NULL,
  circuit_id      NUMBER,
  category        VARCHAR(50)    NOT NULL,
  priority        VARCHAR(20)    NOT NULL,
  subject         VARCHAR(300)   NOT NULL,
  description     VARCHAR(4000)  NOT NULL,
  status          VARCHAR(20)    DEFAULT 'OPEN',
  created_date    DATE           NOT NULL,
  resolved_date   DATE,
  resolution_hours NUMBER(10,2),
  created_at      TIMESTAMP_NTZ  DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'DEMO: Customer support tickets (Expires: 2026-03-20)';

CREATE OR REPLACE TABLE RAW_TRAFFIC_METRICS (
  metric_id       NUMBER AUTOINCREMENT,
  circuit_id      NUMBER         NOT NULL,
  metric_timestamp TIMESTAMP_NTZ NOT NULL,
  inbound_gbps    FLOAT          NOT NULL,
  outbound_gbps   FLOAT          NOT NULL,
  packet_loss_pct FLOAT          DEFAULT 0,
  latency_ms      FLOAT,
  jitter_ms       FLOAT,
  created_at      TIMESTAMP_NTZ  DEFAULT CURRENT_TIMESTAMP()
) COMMENT = 'DEMO: Circuit traffic and utilization metrics (Expires: 2026-03-20)';
