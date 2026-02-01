# Revenue-Driven Funnel Optimization Analysis

## Overview
This project is an end-to-end **funnel analytics case study** focused on identifying conversion bottlenecks, validating drop-off causes, and prioritizing optimization efforts based on **revenue impact and consumer behavior**.

Rather than reporting isolated metrics, the analysis is designed to support **decision-making** — answering *what to fix first*, *why it matters*, and *whether the issue is controllable*.

---

## Analytical Framework
The project is structured into three dashboards, each addressing a specific analytical layer:

1. **Funnel Performance & Optimization** — where is the funnel breaking and what is the revenue impact?
2. **Drop-off & Quality Diagnostics** — are losses caused by traffic quality or funnel friction?
3. **Consumer & Revenue Behavior Analysis** — how do customer segments and monetization patterns influence prioritization?

---

## Dashboard 1 — Funnel Performance & Optimization
This dashboard identifies funnel drop-offs and translates them into business impact.

**Key features:**
- Session-level funnel analysis (Browse → Add to Cart → Checkout → Purchase)
- Step-wise conversion rates using same-session progression
- **Checkout → Purchase conversion trend** with 7-day moving average vs baseline
- Revenue lift simulations for **1% and 5% conversion improvements**
- Feasibility-adjusted optimization recommendation

**Key insight:**
Although early funnel stages have higher volume, **Checkout → Purchase** shows the lowest conversion and a flat-to-declining trend, making it the most practical and controllable optimization priority.

---

## Dashboard 2 — Drop-off & Quality Diagnostics
This dashboard validates whether funnel losses are driven by poor traffic quality or structural friction.

**Key features:**
- Bounce rate analysis
- Conversion breakdown by **channel, device, and region**
- Cross-segment consistency checks

**Key insight:**
Bounce and conversion behavior are consistent across segments, indicating **funnel-level friction rather than isolated acquisition quality issues**.

---

## Dashboard 3 — Consumer & Revenue Behavior Analysis
This dashboard adds business and customer context to ensure optimization aligns with monetization reality.

**Key features:**
- New vs returning user revenue contribution
- Profit by acquisition channel
- Average revenue per session by channel and device
- Customer segmentation and efficiency analysis

**Key insight:**
Returning users and Organic/Email channels demonstrate higher revenue efficiency, reinforcing the importance of checkout optimization and retention-focused improvements.

---

## Key Insights
- Checkout → Purchase is the most critical and controllable funnel bottleneck.
- Revenue impact modeling enables prioritization beyond raw conversion percentages.
- Drop-offs are structural and not driven by specific channels, devices, or regions.
- Consumer behavior analysis ensures optimizations align with revenue quality, not just volume.

---

## Methodology & Assumptions
- Funnel progression is calculated at the **session level** to prevent false step attribution.
- Conversion is defined as next-step sessions divided by previous-step sessions.
- Revenue lift assumes linear response to conversion improvements with constant traffic.
- A 7-day moving average is used for **trend analysis**, not forecasting or alerting.

---

## Tools & Skills
- **Power BI** (DAX, data modeling, dashboard design)
- **SQL** (data extraction and funnel logic)
- Funnel analysis, revenue impact modeling, trend analysis
- Consumer behavior analysis and segmentation

---

## Outcome
This project demonstrates how funnel analytics can move beyond descriptive reporting to support **revenue-driven optimization decisions**, balancing theoretical upside with real-world feasibility.

---

## Notes
This repository is presented as an analytical **case study**.  
Dashboard screenshots are included for quick review, with the Power BI file provided for transparency.
