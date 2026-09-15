-- One row per product, with each entity's tier in its own column.

WITH product_lead AS (
    SELECT
        i.product,
        i.everrest_tier,
        i.sinomax_tier,
        v.ovendor_code as vendor_number,
        CASE
            WHEN v.ovendor_id = 1254859 AND AVG(pv.oproduct_vendor_production_days) IS NULL THEN 40 + 45
            WHEN v.ovendor_id = 78038 AND AVG(pv.oproduct_vendor_production_days) IS NULL THEN 45 + 57
            WHEN v.ovendor_id = 1254876 AND AVG(pv.oproduct_vendor_production_days) IS NULL THEN 100 + 14 + 44
            WHEN v.ovendor_id = 1254877 AND AVG(pv.oproduct_vendor_production_days) IS NULL THEN 100 + 14 + 44
            WHEN v.ovendor_id = 1254878 AND AVG(pv.oproduct_vendor_production_days) IS NULL THEN 100 + 14 + 44
            WHEN v.ovendor_id = 1254879 AND AVG(pv.oproduct_vendor_production_days) IS NULL THEN 100 + 14 + 44
            WHEN v.ovendor_id = 440174 THEN 60
            ELSE ROUND(AVG(pv.oproduct_vendor_production_days) + IFNULL(AVG(IFNULL(ld.avg_dwell, 0) + IFNULL(ld.avg_water_transit, 0) + IFNULL(ld.avg_land_transit, 0)), AVG(pv.oproduct_vendor_transit_days)), 0)
            END as avg_lead_days
    FROM
        analytics.bc_us_items i
        JOIN hq.ovendors v ON i.vendor_number = v.ovendor_code
        LEFT JOIN hq.oproductsvendors pv ON v.ovendor_id = pv.ovendor_id
                                         AND i.product_id = pv.oproduct_id
        LEFT JOIN analytics.alead_days ld ON v.ovendor_id = ld.avendor_id AND ld.alocation_id IN (12, 44, 47)
    GROUP BY i.product, i.everrest_tier, i.sinomax_tier, v.ovendor_code, v.ovendor_id
),
avg_price AS (
    SELECT ip.product,
           AVG(ip.unit_price) as price
    FROM analytics.bc_us_item_prices ip
    WHERE TRUE
        AND ip.ending_date IS NULL
    GROUP BY ip.product
)
SELECT pl.product,
       pl.everrest_tier,
       pl.sinomax_tier,
       pl.vendor_number,
       pl.avg_lead_days,
       ap.price
FROM product_lead pl
LEFT JOIN avg_price ap ON pl.product = ap.product
WHERE TRUE
    -- keep the product if it carries a tier on either side
    AND (pl.everrest_tier IS NOT NULL OR pl.sinomax_tier IS NOT NULL)
    AND pl.avg_lead_days IS NOT NULL;
