-- Daily forecast run rate per SKU, from monthly forecasts.
-- Next month through three months out

SELECT p.oproduct_sku AS product,
       w.period_start,
       w.period_end,
       w.days_in_period,
       SUM(CASE WHEN cf.echannel_id = 27 THEN cf.ecf_qty ELSE 0 END) AS channel_27_qty,
       SUM(CASE WHEN cf.echannel_id = 31 THEN cf.ecf_qty ELSE 0 END) AS channel_31_qty,
       SUM(CASE WHEN crg.adepartment_rollup_name IN ('Direct to Consumer', 'Specialty Retail') OR cf.echannel_id IN (27,31) THEN 0 ELSE cf.ecf_qty END) AS other_ecom_channels_qty,
       SUM(CASE WHEN crg.adepartment_rollup_name IN ('Direct to Consumer', 'Specialty Retail') THEN cf.ecf_qty ELSE 0 END) AS evr_channels_qty,

       ROUND(SUM(CASE WHEN crg.adepartment_rollup_name IN ('Direct to Consumer', 'Specialty Retail') THEN cf.ecf_qty ELSE 0 END) / w.days_in_period, 4) AS evr_daily_run_rate,
       -- anything not EVR is SMX, including channels with no active reporting group
       ROUND(SUM(CASE WHEN crg.adepartment_rollup_name IN ('Direct to Consumer', 'Specialty Retail') THEN 0 ELSE cf.ecf_qty END) / w.days_in_period, 4) AS smx_daily_run_rate

FROM analytics.echannel_forecasts cf
JOIN hq.oproducts p ON cf.oproduct_id = p.oproduct_id
LEFT JOIN analytics.achannel_reporting_groups crg ON cf.echannel_id = crg.ochannel_id AND crg.achannel_reporting_group_is_active = 1
CROSS JOIN ( -- the forecast window, defined once: next month through three months out-- the forecast window, defined once: next month through three months out
    SELECT period_start,
           LAST_DAY(period_start + INTERVAL 2 MONTH)                          AS period_end,
           DATEDIFF(LAST_DAY(period_start + INTERVAL 2 MONTH), period_start) + 1 AS days_in_period
    FROM (SELECT DATE_FORMAT(CURDATE(), '%Y-%m-01') + INTERVAL 1 MONTH AS period_start) b
) w
WHERE cf.ecf_date >= w.period_start
  AND cf.ecf_date <= w.period_end
  AND cf.ecf_qty > 0
GROUP BY product, w.period_start, w.period_end, w.days_in_period;