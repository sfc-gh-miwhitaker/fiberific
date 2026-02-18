/*==============================================================================
SAMPLE DATA - Fiberific
Generates realistic fiber telecom data using GENERATOR (no external files).
==============================================================================*/

USE SCHEMA SNOWFLAKE_EXAMPLE.FIBERIFIC;
USE WAREHOUSE SFE_FIBERIFIC_WH;

----------------------------------------------------------------------
-- Network Nodes: 50 POPs across the Northeast US
----------------------------------------------------------------------
INSERT INTO RAW_NETWORK_NODES (node_name, node_type, city, state, latitude, longitude, status, capacity_gbps, installed_date, last_maint_date)
SELECT
  'POP-' || LPAD(SEQ4()::VARCHAR, 3, '0') AS node_name,
  CASE MOD(SEQ4(), 5)
    WHEN 0 THEN 'CORE'
    WHEN 1 THEN 'DISTRIBUTION'
    WHEN 2 THEN 'ACCESS'
    WHEN 3 THEN 'DATA_CENTER'
    ELSE 'COLOCATION'
  END AS node_type,
  CASE MOD(SEQ4(), 12)
    WHEN 0  THEN 'Albany'
    WHEN 1  THEN 'Burlington'
    WHEN 2  THEN 'Portland'
    WHEN 3  THEN 'Boston'
    WHEN 4  THEN 'Hartford'
    WHEN 5  THEN 'Syracuse'
    WHEN 6  THEN 'Manchester'
    WHEN 7  THEN 'Bangor'
    WHEN 8  THEN 'Rutland'
    WHEN 9  THEN 'Springfield'
    WHEN 10 THEN 'Worcester'
    ELSE 'New Haven'
  END AS city,
  CASE MOD(SEQ4(), 12)
    WHEN 0  THEN 'NY'
    WHEN 1  THEN 'VT'
    WHEN 2  THEN 'ME'
    WHEN 3  THEN 'MA'
    WHEN 4  THEN 'CT'
    WHEN 5  THEN 'NY'
    WHEN 6  THEN 'NH'
    WHEN 7  THEN 'ME'
    WHEN 8  THEN 'VT'
    WHEN 9  THEN 'MA'
    WHEN 10 THEN 'MA'
    ELSE 'CT'
  END AS state,
  42.0 + UNIFORM(0::FLOAT, 3.0::FLOAT, RANDOM()) AS latitude,
  -73.5 + UNIFORM(0::FLOAT, 3.0::FLOAT, RANDOM()) AS longitude,
  CASE WHEN UNIFORM(1, 100, RANDOM()) <= 95 THEN 'ACTIVE' ELSE 'MAINTENANCE' END AS status,
  CASE MOD(SEQ4(), 5)
    WHEN 0 THEN 400
    WHEN 1 THEN 200
    WHEN 2 THEN 100
    WHEN 3 THEN 800
    ELSE 400
  END AS capacity_gbps,
  DATEADD('day', -UNIFORM(365, 2500, RANDOM()), CURRENT_DATE()) AS installed_date,
  DATEADD('day', -UNIFORM(1, 180, RANDOM()), CURRENT_DATE()) AS last_maint_date
FROM TABLE(GENERATOR(ROWCOUNT => 50));

----------------------------------------------------------------------
-- Network Circuits: 120 fiber links between nodes
----------------------------------------------------------------------
INSERT INTO RAW_NETWORK_CIRCUITS (circuit_name, circuit_type, node_a_id, node_b_id, capacity_gbps, distance_miles, status, sla_uptime_pct, monthly_cost, provisioned_date)
SELECT
  'CKT-' || LPAD(SEQ4()::VARCHAR, 4, '0') AS circuit_name,
  CASE MOD(SEQ4(), 4)
    WHEN 0 THEN 'DARK_FIBER'
    WHEN 1 THEN 'WAVELENGTH'
    WHEN 2 THEN 'ETHERNET'
    ELSE 'DEDICATED_INTERNET'
  END AS circuit_type,
  UNIFORM(1, 50, RANDOM()) AS node_a_id,
  UNIFORM(1, 50, RANDOM()) AS node_b_id,
  CASE MOD(SEQ4(), 4)
    WHEN 0 THEN 100
    WHEN 1 THEN 10
    WHEN 2 THEN 1
    ELSE 10
  END AS capacity_gbps,
  ROUND(UNIFORM(5.0::FLOAT, 200.0::FLOAT, RANDOM()), 1) AS distance_miles,
  CASE WHEN UNIFORM(1, 100, RANDOM()) <= 92 THEN 'ACTIVE'
       WHEN UNIFORM(1, 100, RANDOM()) <= 97 THEN 'PROVISIONING'
       ELSE 'DECOMMISSIONED'
  END AS status,
  ROUND(99.0 + UNIFORM(0.0::FLOAT, 0.99::FLOAT, RANDOM()), 2) AS sla_uptime_pct,
  ROUND(UNIFORM(500.0::FLOAT, 25000.0::FLOAT, RANDOM()), 2) AS monthly_cost,
  DATEADD('day', -UNIFORM(30, 1800, RANDOM()), CURRENT_DATE()) AS provisioned_date
FROM TABLE(GENERATOR(ROWCOUNT => 120));

----------------------------------------------------------------------
-- Network Events: 2000 events over the past 6 months
----------------------------------------------------------------------
INSERT INTO RAW_NETWORK_EVENTS (node_id, circuit_id, event_type, severity, event_timestamp, resolved_at, duration_minutes, description, root_cause)
SELECT
  UNIFORM(1, 50, RANDOM()) AS node_id,
  CASE WHEN UNIFORM(1, 100, RANDOM()) <= 70 THEN UNIFORM(1, 120, RANDOM()) ELSE NULL END AS circuit_id,
  CASE MOD(SEQ4(), 8)
    WHEN 0 THEN 'FIBER_CUT'
    WHEN 1 THEN 'POWER_OUTAGE'
    WHEN 2 THEN 'HARDWARE_FAILURE'
    WHEN 3 THEN 'LATENCY_SPIKE'
    WHEN 4 THEN 'PACKET_LOSS'
    WHEN 5 THEN 'CAPACITY_WARNING'
    WHEN 6 THEN 'MAINTENANCE'
    ELSE 'ENVIRONMENTAL'
  END AS event_type,
  CASE MOD(SEQ4(), 4)
    WHEN 0 THEN 'CRITICAL'
    WHEN 1 THEN 'MAJOR'
    WHEN 2 THEN 'MINOR'
    ELSE 'WARNING'
  END AS severity,
  DATEADD('minute', -UNIFORM(1, 259200, RANDOM()), CURRENT_TIMESTAMP()) AS event_timestamp,
  CASE WHEN UNIFORM(1, 100, RANDOM()) <= 85
    THEN DATEADD('minute', UNIFORM(5, 480, RANDOM()), DATEADD('minute', -UNIFORM(1, 259200, RANDOM()), CURRENT_TIMESTAMP()))
    ELSE NULL
  END AS resolved_at,
  CASE WHEN UNIFORM(1, 100, RANDOM()) <= 85 THEN ROUND(UNIFORM(5.0::FLOAT, 480.0::FLOAT, RANDOM()), 1) ELSE NULL END AS duration_minutes,
  CASE MOD(SEQ4(), 8)
    WHEN 0 THEN 'Fiber cut detected on span between ' || 'POP-' || LPAD(UNIFORM(1,50,RANDOM())::VARCHAR,3,'0') || ' and ' || 'POP-' || LPAD(UNIFORM(1,50,RANDOM())::VARCHAR,3,'0') || '. Construction crew hit underground conduit on Route ' || UNIFORM(1,99,RANDOM())::VARCHAR || '. Emergency splice team dispatched. Estimated restore: ' || UNIFORM(2,8,RANDOM())::VARCHAR || ' hours.'
    WHEN 1 THEN 'Commercial power failure at site. UPS battery backup engaged with ' || UNIFORM(15,180,RANDOM())::VARCHAR || ' minutes remaining. Generator startup sequence initiated. Utility company contacted - estimated power restoration in ' || UNIFORM(1,6,RANDOM())::VARCHAR || ' hours.'
    WHEN 2 THEN 'Optical transceiver module reporting elevated bit error rate on port ' || UNIFORM(1,48,RANDOM())::VARCHAR || '. Signal degradation exceeding threshold. Pre-emptive replacement recommended during next maintenance window. Affected services: ' || UNIFORM(1,25,RANDOM())::VARCHAR || ' customers.'
    WHEN 3 THEN 'Latency spike detected averaging ' || UNIFORM(15,150,RANDOM())::VARCHAR || 'ms on backbone circuit. Normal baseline is 3-5ms. Investigation shows possible congestion at peering point. Traffic engineering team reviewing OSPF metrics and considering path redistribution.'
    WHEN 4 THEN 'Packet loss rate elevated to ' || ROUND(UNIFORM(0.5::FLOAT, 5.0::FLOAT, RANDOM()), 2)::VARCHAR || '% on customer-facing interface. Threshold exceeded at 0.1%. CRC errors suggest possible physical layer issue. Field technician dispatched for cable testing and connector inspection.'
    WHEN 5 THEN 'Circuit utilization reached ' || UNIFORM(80,98,RANDOM())::VARCHAR || '% capacity. Growth trend suggests upgrade needed within ' || UNIFORM(30,90,RANDOM())::VARCHAR || ' days. Capacity planning team notified. Recommend provisioning additional wavelength or upgrading to next bandwidth tier.'
    WHEN 6 THEN 'Scheduled maintenance window for firmware upgrade on DWDM platform. Maintenance ID: MW-' || UNIFORM(1000,9999,RANDOM())::VARCHAR || '. Expected duration: ' || UNIFORM(1,4,RANDOM())::VARCHAR || ' hours. ' || UNIFORM(5,30,RANDOM())::VARCHAR || ' circuits will experience brief hitless switchover.'
    ELSE 'Environmental alarm: HVAC temperature reading ' || UNIFORM(78,110,RANDOM())::VARCHAR || 'F in equipment room (threshold: 77F). Cooling system inspection requested. Secondary cooling unit activated. Equipment operating within spec but monitoring closely.'
  END AS description,
  CASE MOD(SEQ4(), 6)
    WHEN 0 THEN 'Third-party construction damage'
    WHEN 1 THEN 'Utility power grid failure'
    WHEN 2 THEN 'Equipment end-of-life'
    WHEN 3 THEN 'Network congestion'
    WHEN 4 THEN 'Physical layer degradation'
    ELSE 'Planned maintenance'
  END AS root_cause
FROM TABLE(GENERATOR(ROWCOUNT => 2000));

----------------------------------------------------------------------
-- Customers: 200 enterprise and business customers
----------------------------------------------------------------------
INSERT INTO RAW_CUSTOMERS (company_name, industry, segment, city, state, primary_node_id, contract_start, contract_end, mrr, status, nps_score)
SELECT
  CASE MOD(SEQ4(), 20)
    WHEN 0  THEN 'Northeast Health Partners'
    WHEN 1  THEN 'Granite State Financial'
    WHEN 2  THEN 'Green Mountain Data'
    WHEN 3  THEN 'Bay State Manufacturing'
    WHEN 4  THEN 'Pine Tree Media Group'
    WHEN 5  THEN 'Nutmeg Insurance Corp'
    WHEN 6  THEN 'Empire Logistics'
    WHEN 7  THEN 'Maple Leaf Education'
    WHEN 8  THEN 'Harbor Tech Solutions'
    WHEN 9  THEN 'Summit Research Labs'
    WHEN 10 THEN 'Lighthouse Legal'
    WHEN 11 THEN 'Berkshire Analytics'
    WHEN 12 THEN 'Coastal Defense Systems'
    WHEN 13 THEN 'River Valley Hospital'
    WHEN 14 THEN 'New England Biotech'
    WHEN 15 THEN 'Colonial Energy Partners'
    WHEN 16 THEN 'Patriots DataCenter'
    WHEN 17 THEN 'Atlantic Cloud Services'
    WHEN 18 THEN 'Minuteman Security'
    ELSE 'Yankee Retail Group'
  END || ' ' || LPAD(SEQ4()::VARCHAR, 3, '0') AS company_name,
  CASE MOD(SEQ4(), 10)
    WHEN 0 THEN 'Healthcare'
    WHEN 1 THEN 'Financial Services'
    WHEN 2 THEN 'Technology'
    WHEN 3 THEN 'Manufacturing'
    WHEN 4 THEN 'Media'
    WHEN 5 THEN 'Insurance'
    WHEN 6 THEN 'Logistics'
    WHEN 7 THEN 'Education'
    WHEN 8 THEN 'Government'
    ELSE 'Retail'
  END AS industry,
  CASE
    WHEN UNIFORM(1, 100, RANDOM()) <= 30 THEN 'ENTERPRISE'
    WHEN UNIFORM(1, 100, RANDOM()) <= 60 THEN 'BUSINESS'
    ELSE 'SMB'
  END AS segment,
  CASE MOD(SEQ4(), 12)
    WHEN 0  THEN 'Albany'      WHEN 1  THEN 'Burlington'
    WHEN 2  THEN 'Portland'   WHEN 3  THEN 'Boston'
    WHEN 4  THEN 'Hartford'   WHEN 5  THEN 'Syracuse'
    WHEN 6  THEN 'Manchester' WHEN 7  THEN 'Bangor'
    WHEN 8  THEN 'Rutland'    WHEN 9  THEN 'Springfield'
    WHEN 10 THEN 'Worcester'  ELSE 'New Haven'
  END AS city,
  CASE MOD(SEQ4(), 12)
    WHEN 0  THEN 'NY'  WHEN 1  THEN 'VT'  WHEN 2  THEN 'ME'
    WHEN 3  THEN 'MA'  WHEN 4  THEN 'CT'  WHEN 5  THEN 'NY'
    WHEN 6  THEN 'NH'  WHEN 7  THEN 'ME'  WHEN 8  THEN 'VT'
    WHEN 9  THEN 'MA'  WHEN 10 THEN 'MA'  ELSE 'CT'
  END AS state,
  UNIFORM(1, 50, RANDOM()) AS primary_node_id,
  DATEADD('day', -UNIFORM(90, 1800, RANDOM()), CURRENT_DATE()) AS contract_start,
  DATEADD('day', UNIFORM(90, 730, RANDOM()), CURRENT_DATE()) AS contract_end,
  ROUND(UNIFORM(500.0::FLOAT, 50000.0::FLOAT, RANDOM()), 2) AS mrr,
  CASE WHEN UNIFORM(1, 100, RANDOM()) <= 90 THEN 'ACTIVE'
       WHEN UNIFORM(1, 100, RANDOM()) <= 95 THEN 'CHURNED'
       ELSE 'PROSPECT'
  END AS status,
  UNIFORM(-10, 100, RANDOM()) AS nps_score
FROM TABLE(GENERATOR(ROWCOUNT => 200));

----------------------------------------------------------------------
-- Service Orders: 500 orders over the past year
----------------------------------------------------------------------
INSERT INTO RAW_SERVICE_ORDERS (customer_id, circuit_id, order_type, service_type, bandwidth_gbps, status, requested_date, completed_date, install_days, revenue_impact)
SELECT
  UNIFORM(1, 200, RANDOM()) AS customer_id,
  CASE WHEN UNIFORM(1, 100, RANDOM()) <= 80 THEN UNIFORM(1, 120, RANDOM()) ELSE NULL END AS circuit_id,
  CASE MOD(SEQ4(), 5)
    WHEN 0 THEN 'NEW_INSTALL'
    WHEN 1 THEN 'UPGRADE'
    WHEN 2 THEN 'CHANGE'
    WHEN 3 THEN 'DISCONNECT'
    ELSE 'RENEWAL'
  END AS order_type,
  CASE MOD(SEQ4(), 6)
    WHEN 0 THEN 'DEDICATED_INTERNET'
    WHEN 1 THEN 'DARK_FIBER'
    WHEN 2 THEN 'WAVELENGTH'
    WHEN 3 THEN 'ETHERNET_PRIVATE_LINE'
    WHEN 4 THEN 'SD_WAN'
    ELSE 'CLOUD_CONNECT'
  END AS service_type,
  CASE MOD(SEQ4(), 4)
    WHEN 0 THEN 1
    WHEN 1 THEN 10
    WHEN 2 THEN 100
    ELSE 0.1
  END AS bandwidth_gbps,
  CASE
    WHEN UNIFORM(1, 100, RANDOM()) <= 60 THEN 'COMPLETED'
    WHEN UNIFORM(1, 100, RANDOM()) <= 80 THEN 'IN_PROGRESS'
    WHEN UNIFORM(1, 100, RANDOM()) <= 90 THEN 'PENDING'
    ELSE 'CANCELLED'
  END AS status,
  DATEADD('day', -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()) AS requested_date,
  CASE WHEN UNIFORM(1, 100, RANDOM()) <= 60
    THEN DATEADD('day', -UNIFORM(1, 300, RANDOM()), CURRENT_DATE())
    ELSE NULL
  END AS completed_date,
  CASE WHEN UNIFORM(1, 100, RANDOM()) <= 60 THEN UNIFORM(3, 90, RANDOM()) ELSE NULL END AS install_days,
  ROUND(UNIFORM(-5000.0::FLOAT, 50000.0::FLOAT, RANDOM()), 2) AS revenue_impact
FROM TABLE(GENERATOR(ROWCOUNT => 500));

----------------------------------------------------------------------
-- Support Tickets: 800 tickets with realistic descriptions
----------------------------------------------------------------------
INSERT INTO RAW_TICKETS (customer_id, circuit_id, category, priority, subject, description, status, created_date, resolved_date, resolution_hours)
SELECT
  UNIFORM(1, 200, RANDOM()) AS customer_id,
  CASE WHEN UNIFORM(1, 100, RANDOM()) <= 75 THEN UNIFORM(1, 120, RANDOM()) ELSE NULL END AS circuit_id,
  CASE MOD(SEQ4(), 8)
    WHEN 0 THEN 'OUTAGE'
    WHEN 1 THEN 'PERFORMANCE'
    WHEN 2 THEN 'BILLING'
    WHEN 3 THEN 'INSTALLATION'
    WHEN 4 THEN 'MAINTENANCE'
    WHEN 5 THEN 'CAPACITY'
    WHEN 6 THEN 'CONFIGURATION'
    ELSE 'GENERAL'
  END AS category,
  CASE MOD(SEQ4(), 4)
    WHEN 0 THEN 'CRITICAL'
    WHEN 1 THEN 'HIGH'
    WHEN 2 THEN 'MEDIUM'
    ELSE 'LOW'
  END AS priority,
  CASE MOD(SEQ4(), 16)
    WHEN 0  THEN 'Complete circuit outage affecting all services'
    WHEN 1  THEN 'Intermittent packet loss on primary circuit'
    WHEN 2  THEN 'Billing discrepancy on last invoice'
    WHEN 3  THEN 'New circuit installation delayed'
    WHEN 4  THEN 'Request maintenance window for upgrade'
    WHEN 5  THEN 'Bandwidth upgrade needed urgently'
    WHEN 6  THEN 'BGP session flapping on peering link'
    WHEN 7  THEN 'Question about contract renewal terms'
    WHEN 8  THEN 'Latency issues impacting voice services'
    WHEN 9  THEN 'Request for additional IP addresses'
    WHEN 10 THEN 'Fiber cut reported near our facility'
    WHEN 11 THEN 'DWDM wavelength performance degradation'
    WHEN 12 THEN 'Need SLA report for quarterly review'
    WHEN 13 THEN 'Cloud connect provisioning issue'
    WHEN 14 THEN 'Jitter affecting video conferencing'
    ELSE 'General inquiry about available services'
  END AS subject,
  CASE MOD(SEQ4(), 16)
    WHEN 0  THEN 'Our primary circuit went completely down at ' || UNIFORM(1,12,RANDOM())::VARCHAR || ':' || LPAD(UNIFORM(0,59,RANDOM())::VARCHAR,2,'0') || ' AM this morning. All of our branch offices lost connectivity and we cannot process any transactions. This is a critical business impact - we have ' || UNIFORM(50,500,RANDOM())::VARCHAR || ' employees unable to work. Please escalate immediately. Our backup circuit is also showing degraded performance. We need an ETA for restoration ASAP.'
    WHEN 1  THEN 'We have been experiencing intermittent packet loss on circuit CKT-' || LPAD(UNIFORM(1,120,RANDOM())::VARCHAR,4,'0') || ' for the past ' || UNIFORM(2,14,RANDOM())::VARCHAR || ' days. Loss rates spike to ' || ROUND(UNIFORM(1.0::FLOAT,8.0::FLOAT,RANDOM()),1)::VARCHAR || '% during business hours. Our VoIP quality has degraded significantly and customers are complaining about call drops. We ran traceroutes showing the issue between your POP and our premises. Please investigate.'
    WHEN 2  THEN 'Our invoice for this month shows charges of $' || UNIFORM(5000,50000,RANDOM())::VARCHAR || ' which is $' || UNIFORM(500,5000,RANDOM())::VARCHAR || ' higher than our contracted rate. We believe there may be overage charges that were not communicated. Can you please provide a detailed breakdown? Our finance team needs this resolved before end of quarter. Reference contract #' || UNIFORM(10000,99999,RANDOM())::VARCHAR || '.'
    WHEN 3  THEN 'Our new circuit installation was originally scheduled for ' || UNIFORM(1,4,RANDOM())::VARCHAR || ' weeks ago but we still dont have service. The construction crew came out once, said they needed permits, and we havent heard anything since. Our project deadline is in ' || UNIFORM(1,3,RANDOM())::VARCHAR || ' weeks and we absolutely need this circuit live. This delay is costing us approximately $' || UNIFORM(1000,10000,RANDOM())::VARCHAR || ' per day in lost productivity.'
    WHEN 4  THEN 'We would like to schedule a maintenance window for upgrading our primary circuit from ' || UNIFORM(1,10,RANDOM())::VARCHAR || 'Gbps to ' || UNIFORM(10,100,RANDOM())::VARCHAR || 'Gbps. Preferred window is Saturday ' || UNIFORM(1,4,RANDOM())::VARCHAR || ':00 AM to ' || UNIFORM(5,8,RANDOM())::VARCHAR || ':00 AM Eastern. We will need to coordinate failover to our backup circuit during the cutover. Please confirm availability and any required lead time.'
    WHEN 5  THEN 'We are consistently hitting ' || UNIFORM(85,98,RANDOM())::VARCHAR || '% utilization on our primary circuit during peak hours. Our traffic has grown significantly due to cloud migration and remote workers. We need an emergency bandwidth upgrade within the next ' || UNIFORM(1,2,RANDOM())::VARCHAR || ' weeks. What are our options and what is the fastest path to additional capacity? We are evaluating competitor proposals.'
    WHEN 6  THEN 'Our BGP session with your network keeps dropping approximately every ' || UNIFORM(2,8,RANDOM())::VARCHAR || ' hours. We are seeing route flapping in our logs and it is causing brief connectivity interruptions for all our sites. Our network team suspects an MTU issue or a flaky interface on your side. Can you check the physical port and BGP session logs? Our AS number is ' || UNIFORM(64512,65534,RANDOM())::VARCHAR || '.'
    WHEN 7  THEN 'Our contract is coming up for renewal in ' || UNIFORM(30,90,RANDOM())::VARCHAR || ' days and we would like to discuss terms. We are currently on a ' || UNIFORM(1,3,RANDOM())::VARCHAR || '-year agreement at $' || UNIFORM(5000,30000,RANDOM())::VARCHAR || '/month. We have had generally good service but want to explore options for price improvement given our loyalty and volume. Can someone from your commercial team reach out to our procurement department?'
    WHEN 8  THEN 'We are experiencing unacceptable latency on our circuit. Round-trip times are averaging ' || UNIFORM(25,150,RANDOM())::VARCHAR || 'ms when our SLA specifies under 10ms. This is destroying our VoIP call quality and our hosted PBX vendor says the problem is on the transport side. Our users report echo, delay, and dropped calls throughout the day. This has been going on for ' || UNIFORM(3,14,RANDOM())::VARCHAR || ' days. Please prioritize.'
    WHEN 9  THEN 'We need ' || UNIFORM(8,64,RANDOM())::VARCHAR || ' additional public IP addresses for our new server deployment. Our current /28 block is fully utilized. Can you provision a /24 or larger block? We also need reverse DNS configured for the new addresses. Please advise on availability and any associated cost changes to our service.'
    WHEN 10 THEN 'There appears to be a fiber cut near our facility at ' || UNIFORM(100,999,RANDOM())::VARCHAR || ' Industrial Drive. We noticed construction vehicles working on the road this morning and our circuit went down at approximately ' || UNIFORM(8,11,RANDOM())::VARCHAR || ':' || LPAD(UNIFORM(0,59,RANDOM())::VARCHAR,2,'0') || ' AM. We have visual confirmation of excavation equipment near your fiber markers. Are you aware of this cut? What is the estimated time to repair?'
    WHEN 11 THEN 'The DWDM wavelength we lease has been showing increasing signal degradation. Our optical power readings have dropped by ' || UNIFORM(2,8,RANDOM())::VARCHAR || 'dBm over the past month. Pre-FEC bit error rate is approaching threshold. We believe there may be a connector issue or fiber aging on the span. Can you dispatch a technician for OTDR testing? We cannot afford an unplanned outage on this critical circuit.'
    WHEN 12 THEN 'We need our quarterly SLA compliance report for circuits CKT-' || LPAD(UNIFORM(1,120,RANDOM())::VARCHAR,4,'0') || ' through CKT-' || LPAD(UNIFORM(1,120,RANDOM())::VARCHAR,4,'0') || '. Our contract requires ' || ROUND(UNIFORM(99.0::FLOAT,99.99::FLOAT,RANDOM()),2)::VARCHAR || '% uptime and we want to verify performance against SLA. Please include all outage events, maintenance windows, and mean time to repair data. Our board meeting is in ' || UNIFORM(1,3,RANDOM())::VARCHAR || ' weeks.'
    WHEN 13 THEN 'We provisioned a new cloud connect circuit to AWS us-east-1 but the virtual interface is not coming up. The physical port shows link but the BGP session is stuck in Active state. We have configured VLAN ' || UNIFORM(100,4000,RANDOM())::VARCHAR || ' and ASN ' || UNIFORM(64512,65534,RANDOM())::VARCHAR || ' as specified in the LOA. Can your NOC verify the cross-connect and VLAN configuration on your side? We need this live by end of week.'
    WHEN 14 THEN 'Video conferencing quality has become unusable on our circuit. Jitter measurements show ' || UNIFORM(10,80,RANDOM())::VARCHAR || 'ms variation which is well above our ' || UNIFORM(3,5,RANDOM())::VARCHAR || 'ms tolerance. Our Teams and Zoom calls are breaking up constantly. We have ' || UNIFORM(50,300,RANDOM())::VARCHAR || ' employees relying on video daily. QoS settings on our end look correct. Can you check for congestion or buffering issues in your network?'
    ELSE 'We are evaluating expanding our network with additional services. Currently we have ' || UNIFORM(1,5,RANDOM())::VARCHAR || ' circuits with you and are interested in learning about your SD-WAN, cloud connectivity, and managed security offerings. Could you arrange a meeting with a solutions architect? We are also talking to ' || UNIFORM(1,3,RANDOM())::VARCHAR || ' other providers so a prompt response would be appreciated.'
  END AS description,
  CASE
    WHEN UNIFORM(1, 100, RANDOM()) <= 65 THEN 'RESOLVED'
    WHEN UNIFORM(1, 100, RANDOM()) <= 85 THEN 'IN_PROGRESS'
    ELSE 'OPEN'
  END AS status,
  DATEADD('day', -UNIFORM(1, 180, RANDOM()), CURRENT_DATE()) AS created_date,
  CASE WHEN UNIFORM(1, 100, RANDOM()) <= 65
    THEN DATEADD('day', -UNIFORM(0, 170, RANDOM()), CURRENT_DATE())
    ELSE NULL
  END AS resolved_date,
  CASE WHEN UNIFORM(1, 100, RANDOM()) <= 65 THEN ROUND(UNIFORM(0.5::FLOAT, 240.0::FLOAT, RANDOM()), 1) ELSE NULL END AS resolution_hours
FROM TABLE(GENERATOR(ROWCOUNT => 800));

----------------------------------------------------------------------
-- Traffic Metrics: 50,000 data points (hourly for 120 circuits)
----------------------------------------------------------------------
INSERT INTO RAW_TRAFFIC_METRICS (circuit_id, metric_timestamp, inbound_gbps, outbound_gbps, packet_loss_pct, latency_ms, jitter_ms)
SELECT
  MOD(SEQ4(), 120) + 1 AS circuit_id,
  DATEADD('hour', -MOD(SEQ4(), 720), CURRENT_TIMESTAMP()) AS metric_timestamp,
  ROUND(UNIFORM(0.01::FLOAT, 10.0::FLOAT, RANDOM()) *
    CASE
      WHEN EXTRACT(HOUR FROM DATEADD('hour', -MOD(SEQ4(), 720), CURRENT_TIMESTAMP())) BETWEEN 9 AND 17
        THEN 1.5
      ELSE 0.6
    END, 4) AS inbound_gbps,
  ROUND(UNIFORM(0.01::FLOAT, 8.0::FLOAT, RANDOM()) *
    CASE
      WHEN EXTRACT(HOUR FROM DATEADD('hour', -MOD(SEQ4(), 720), CURRENT_TIMESTAMP())) BETWEEN 9 AND 17
        THEN 1.4
      ELSE 0.5
    END, 4) AS outbound_gbps,
  ROUND(CASE
    WHEN UNIFORM(1, 100, RANDOM()) <= 90 THEN UNIFORM(0.0::FLOAT, 0.05::FLOAT, RANDOM())
    ELSE UNIFORM(0.1::FLOAT, 3.0::FLOAT, RANDOM())
  END, 4) AS packet_loss_pct,
  ROUND(CASE
    WHEN UNIFORM(1, 100, RANDOM()) <= 85 THEN UNIFORM(1.0::FLOAT, 8.0::FLOAT, RANDOM())
    ELSE UNIFORM(10.0::FLOAT, 100.0::FLOAT, RANDOM())
  END, 2) AS latency_ms,
  ROUND(CASE
    WHEN UNIFORM(1, 100, RANDOM()) <= 85 THEN UNIFORM(0.1::FLOAT, 3.0::FLOAT, RANDOM())
    ELSE UNIFORM(5.0::FLOAT, 50.0::FLOAT, RANDOM())
  END, 2) AS jitter_ms
FROM TABLE(GENERATOR(ROWCOUNT => 50000));
