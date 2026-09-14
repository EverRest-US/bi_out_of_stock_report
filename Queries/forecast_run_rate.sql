-- Daily forecast run rate per SKU, from monthly forecasts.
-- Rolls up all months (and all echannels) into one total per SKU, then divides by the
-- number of calendar days those months actually cover.

WITH sku_totals AS (
    SELECT p.oproduct_sku,
           COUNT(DISTINCT cf.ecf_date) AS forecast_months,
           SUM(cf.ecf_qty)             AS forecast_qty_total,
           -- normalize to the first day of the earliest month and the last day of the
           -- latest, so the span is right wherever in the month ecf_date happens to sit
           DATE_SUB(MIN(cf.ecf_date), INTERVAL DAYOFMONTH(MIN(cf.ecf_date)) - 1 DAY) AS period_start,
           LAST_DAY(MAX(cf.ecf_date))  AS period_end
    FROM analytics.echannel_forecasts cf
    JOIN hq.oproducts p ON cf.oproduct_id = p.oproduct_id
    -- current month plus the two prior, anchored to month boundaries
    WHERE TRUE
        AND cf.ecf_date >= CURDATE()  # next month
        AND cf.ecf_date <= DATE_FORMAT(CURDATE(), '%Y-%m-01') + INTERVAL 3 MONTH # three months from current month
    GROUP BY p.oproduct_sku
)
SELECT oproduct_sku,
       forecast_months,
       forecast_qty_total,
       period_start,
       period_end,
       DATEDIFF(period_end, period_start) + 1                                  AS days_in_period,
       ROUND(forecast_qty_total / (DATEDIFF(period_end, period_start) + 1), 4) AS daily_run_rate
FROM sku_totals
ORDER BY daily_run_rate DESC;
