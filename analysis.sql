/*
revenue-driven funnel optimization
analysis reference (postgresql)

purpose:
this file documents how business questions are answered
using the analytics views defined in schema.sql.

important notes:
-heavy 
- analysis is intentionally view-driven (semantic layer)
- no raw exploratory queries are duplicated here
- final interpretation is done via power bi dashboards
*/
/*NOTE : all heavy logic lives in schema.sql as views.
this file represents the analysis layer.
*/

/* ============================================================
   funnel performance: where users are lost
   ============================================================ */

-- business question:
-- how many sessions survive each funnel step?

select *
from funnel_baseline
order by stage_order;

/*
business meaning:
this shows absolute volume drop across the funnel.
used to understand whether the problem is traffic quality
or downstream conversion friction.
*/


-- business question:
-- which funnel transition leaks the most users?

select *
from funnel_conversion;

/*
business meaning:
this isolates the weakest step-to-step transition.
product and ux teams can focus here instead of guessing.
*/


-- business question:
-- what does the complete funnel look like at a glance?

select *
from funnel_summary;

/*
business meaning:
executive-ready summary of funnel health.
this is the primary visual used in dashboard 1.
*/


/* ============================================================
   funnel impact: translating conversion into revenue
   ============================================================ */

-- business question:
-- if we improve conversion slightly, where does revenue grow most?

select *
from funnel_impact;

/*
business meaning:
connects funnel performance directly to revenue impact.
helps prioritize fixes based on financial upside,
not just percentage conversion.
*/


/* ============================================================
   traffic quality: are we attracting the right users?
   ============================================================ */

-- business question:
-- what share of sessions fail to engage at all?

select *
from overall_bounce_rate;

/*
business meaning:
baseline signal of traffic quality across the platform.
*/


-- business question:
-- which channels bring high-volume but low-quality traffic?

select *
from bounce_by_channel
order by bounce_rate desc;

/*
business meaning:
guides marketing spend decisions.
high bounce + low value channels are candidates for optimization or reduction.
*/


-- business question:
-- does user experience differ by device?

select *
from bounce_by_device
order by bounce_rate desc;

/*
business meaning:
high mobile bounce often points to usability or performance issues.
*/


-- business question:
-- are there regions with consistently poor engagement?

select *
from bounce_by_region
order by bounce_rate desc;

/*
business meaning:
helps identify geographic or localization problems.
*/


/* ============================================================
   revenue efficiency: not all traffic is equal
   ============================================================ */

-- business question:
-- which channels produce the most valuable sessions?

select *
from channel_avg_revenue
order by avg_revenue_per_session desc;

/*
business meaning:
focuses on value per session, not just traffic volume.
*/


-- business question:
-- which channels are actually profitable after acquisition cost?

select *
from channel_revenue_profit
order by profit desc;

/*
business meaning:
supports budget reallocation toward high-return channels.
*/


-- business question:
-- how does revenue efficiency differ by device?

select *
from device_revenue_efficiency
order by avg_revenue desc;

/*
business meaning:
balances monetization against bounce behavior by device.
*/

-- question:
-- which channels generate the highest value per session?

select
    channel,
    avg_revenue_per_session
from channel_avg_revenue
order by avg_revenue_per_session desc;

/* ============================================================
   customer intent & session behavior
   ============================================================ */

-- business question:
-- how deep do users typically move into the funnel?

select
    customer_segment,
    count(*) as sessions
from customer_intent_segments
group by customer_segment;

/*
business meaning:
groups sessions by intent level.
used for intent-based targeting and analysis.
*/


-- business question:
-- are first-time sessions lower quality than returning ones?

select *
from first_session_quality;

/*
business meaning:
evaluates onboarding effectiveness for new users.
*/


-- business question:
-- how does behavior differ between new and returning users?

select *
from user_type_behavior;

/*
business meaning:
returning users typically generate higher value
and lower bounce rates.
*/


/* ============================================================
   purchase economics
   ============================================================ */

-- business question:
-- what is the average value of a completed purchase?

select *
from purchase_aov;

/*
business meaning:
used as a core input for revenue modeling
and funnel impact estimation.
*/
/* ============================================================
   strategic diagnostics: prioritization & trade-offs
   ============================================================ */

-- business question:
-- which funnel step deserves immediate attention?

select
    funnel_step,
    sessions,
    revenue_lift_1pct
from funnel_impact
order by revenue_lift_1pct desc;

/*
business meaning:
ranks funnel steps by financial upside.
used to prioritize engineering and ux effort.
*/


/* ============================================================
   channel effectiveness vs quality trade-off
   ============================================================ */

-- business question:
-- which channels combine high value with acceptable quality?

select
    c.channel,
    c.avg_revenue_per_session,
    b.bounce_rate
from channel_avg_revenue c
join bounce_by_channel b
  on c.channel = b.channel
order by c.avg_revenue_per_session desc;

/* ============================================================
   funnel revenue impact analysis
   ============================================================ */

-- question:
-- where does a small conversion lift create the most revenue?

select
    funnel_step,
    sessions,
    avg_order_value,
    revenue_lift_1pct,
    revenue_lift_5pct
from funnel_impact
order by revenue_lift_1pct desc;

/*
interpretation:
prioritizes funnel fixes by financial upside,
not by conversion percentage alone.
*/
