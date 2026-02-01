/*
revenue impact–driven funnel analytics
schema definition (postgresql)

this file defines:
- the base funnel events table
- all analytics views used in dashboards
- funnel performance, revenue impact, traffic quality,
  and customer behavior logic

focus: analytics layer, not raw ingestion
*/


/* ============================================================
   base table: funnel_events (event-level data)
   ============================================================ */

create table if not exists public.funnel_events (
    user_id varchar(20),
    session_id varchar(30),
    event varchar(20),
    "timestamp" timestamp,
    device varchar(10),
    region varchar(10),
    channel varchar(20),
    product_category varchar(20),
    revenue numeric(10,2),
    bounce_flag varchar(3),
    user_type varchar(10),
    is_first_session boolean,
    traffic_cost numeric(10,2)
);

alter table public.funnel_events owner to postgres;

/*
insight:
this table captures raw user interactions across the funnel.
each row represents a single event within a session.
*/


/* ============================================================
   session-level aggregation (core analytics layer)
   ============================================================ */

create or replace view public.session_level as
select
    session_id,
    min(user_id) as user_id,
    min(channel) as channel,
    min(device) as device,
    min(region) as region,
    min(user_type) as user_type,
    bool_or(is_first_session) as is_first_session,
    min(bounce_flag) as bounce_flag,
    sum(revenue) as revenue,
    max(traffic_cost) as traffic_cost
from funnel_events
group by session_id;

/*
insight:
converts event-level data into one row per session.
this view is the foundation for quality, revenue,
and customer behavior analysis.
*/


/* ============================================================
   traffic quality & bounce analysis
   ============================================================ */

create or replace view public.overall_bounce_rate as
select
    count(*) filter (where bounce_flag = 'Yes')::numeric
    / count(*)::numeric as bounce_rate
from session_level;

/*
insight:
overall percentage of sessions that failed to convert.
*/

create or replace view public.bounce_by_channel as
select
    channel,
    count(*) as sessions,
    count(*) filter (where bounce_flag = 'Yes')::numeric / count(*)::numeric as bounce_rate
from session_level
group by channel;

/*
insight:
identifies which acquisition channels bring low-quality traffic.
*/

create or replace view public.bounce_by_device as
select
    device,
    count(*) as sessions,
    count(*) filter (where bounce_flag = 'Yes')::numeric / count(*)::numeric as bounce_rate
from session_level
group by device;

/*
insight:
highlights device-level experience or usability issues.
*/

create or replace view public.bounce_by_region as
select
    region,
    count(*) as sessions,
    count(*) filter (where bounce_flag = 'Yes')::numeric / count(*)::numeric as bounce_rate
from session_level
group by region;

/*
insight:
shows geographic differences in user engagement quality.
*/


/* ============================================================
   revenue & efficiency analysis
   ============================================================ */

create or replace view public.channel_avg_revenue as
select
    channel,
    avg(revenue) as avg_revenue_per_session
from session_level
group by channel;

/*
insight:
measures how valuable an average session is by channel.
*/

create or replace view public.channel_revenue_profit as
select
    channel,
    count(*) as sessions,
    sum(revenue) as total_revenue,
    sum(traffic_cost) as total_cost,
    sum(revenue) - sum(traffic_cost) as profit
from session_level
group by channel;

/*
insight:
compares revenue against acquisition cost to identify
profitable vs wasteful channels.
*/

create or replace view public.device_revenue_efficiency as
select
    device,
    count(*) as sessions,
    avg(revenue) as avg_revenue,
    count(*) filter (where bounce_flag = 'Yes')::numeric / count(*)::numeric as bounce_rate
from session_level
group by device;

/*
insight:
balances monetization and bounce behavior by device.
*/


/* ============================================================
   funnel structure & performance
   ============================================================ */

create or replace view public.funnel_baseline as
select
    case event
        when 'Browse' then 1
        when 'Add to Cart' then 2
        when 'Checkout' then 3
        when 'Purchase' then 4
    end as stage_order,
    event as funnel_step,
    count(distinct session_id) as sessions
from funnel_events
group by event;

/*
insight:
shows how many sessions reach each funnel stage.
*/

create or replace view public.funnel_conversion as
with step_counts as (
    select
        case event
            when 'Browse' then 1
            when 'Add to Cart' then 2
            when 'Checkout' then 3
            when 'Purchase' then 4
        end as stage_order,
        event as funnel_step,
        count(distinct session_id) as sessions
    from funnel_events
    group by event
)
select
    curr.funnel_step as from_step,
    next.funnel_step as to_step,
    curr.sessions as from_sessions,
    next.sessions as to_sessions,
    round(
        next.sessions::numeric / nullif(curr.sessions, 0),
        4
    ) as conversion_rate
from step_counts curr
join step_counts next
  on next.stage_order = curr.stage_order + 1;

/*
insight:
identifies where users drop off between funnel stages.
*/

create or replace view public.funnel_summary as
with funnel as (
    select
        event,
        count(distinct session_id) as sessions,
        case event
            when 'Browse' then 1
            when 'Add to Cart' then 2
            when 'Checkout' then 3
            when 'Purchase' then 4
        end as step
    from funnel_events
    group by event
)
select
    event,
    sessions,
    round(
        sessions::numeric /
        nullif(lag(sessions) over (order by step), 0),
        2
    ) as conversion_rate
from funnel
order by step;

/*
insight:
presents a clean funnel view suitable for executive dashboards.
*/


/* ============================================================
   funnel revenue impact (strategic layer)
   ============================================================ */

create or replace view public.funnel_impact as
with step_sessions as (
    select
        case event
            when 'Browse' then 1
            when 'Add to Cart' then 2
            when 'Checkout' then 3
            when 'Purchase' then 4
        end as stage_order,
        event as funnel_step,
        count(distinct session_id) as sessions
    from funnel_events
    group by event
),
aov as (
    select
        avg(revenue) as avg_order_value
    from funnel_events
    where event = 'Purchase'
      and revenue > 0
)
select
    s.funnel_step,
    s.sessions,
    round(a.avg_order_value, 2) as avg_order_value,
    round(s.sessions * a.avg_order_value * 0.01, 2) as revenue_lift_1pct,
    round(s.sessions * a.avg_order_value * 0.05, 2) as revenue_lift_5pct
from step_sessions s
cross join aov a
where s.funnel_step <> 'Purchase'
order by revenue_lift_1pct desc;

/*
insight:
estimates revenue upside from small conversion improvements.
*/


/* ============================================================
   purchase metrics
   ============================================================ */

create or replace view public.purchase_aov as
select
    round(avg(revenue), 2) as avg_order_value
from funnel_events
where event = 'Purchase'
  and revenue > 0;

/*
insight:
average order value of completed purchases.
*/


/* ============================================================
   customer behavior & segmentation
   ============================================================ */

create or replace view public.customer_intent_segments as
select
    session_id,
    user_id,
    case
        when bool_or(event = 'Purchase') then 'High Intent'
        when bool_or(event = 'Checkout') then 'High Intent'
        when bool_or(event = 'Add to Cart') then 'Medium Intent'
        when bool_or(event = 'Browse') then 'Low Intent'
        else 'Low Intent'
    end as customer_segment
from funnel_events
group by session_id, user_id;

/*
insight:
classifies sessions based on how deep users move in the funnel.
*/

create or replace view public.customer_intent_segments_v2 as
select
    session_id,
    user_id,
    customer_segment
from customer_intent_segments;

/*
insight:
simplified projection of intent segmentation for reporting.
*/


/* ============================================================
   session quality & user-type behavior
   ============================================================ */

create or replace view public.first_session_quality as
select
    is_first_session,
    count(*) as sessions,
    count(*) filter (where bounce_flag = 'Yes')::numeric / count(*)::numeric as bounce_rate
from session_level
group by is_first_session;

/*
insight:
compares quality of first-time vs returning sessions.
*/

create or replace view public.user_type_behavior as
select
    user_type,
    count(*) as sessions,
    count(*) filter (where bounce_flag = 'Yes')::numeric / count(*)::numeric as bounce_rate,
    avg(revenue) as avg_revenue
from session_level
group by user_type;

/*
insight:
shows how new and returning users differ in engagement and value.
*/


/* ============================================================
   end of schema
   ============================================================ */