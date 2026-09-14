-- One row per product per entity, with that entity's tier.
-- Product, vendor and lead time repeat across the two rows by design.

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
)
SELECT product,
       'everrest' AS entity,
       everrest_tier AS tier,
       vendor_number,
       avg_lead_days
FROM product_lead
WHERE TRUE
    AND everrest_tier IS NOT NULL
    AND avg_lead_days IS NOT NULL

UNION ALL

SELECT product,
       'sinomax' AS entity,
       sinomax_tier AS tier,
       vendor_number,
       avg_lead_days
FROM product_lead
WHERE TRUE
    AND sinomax_tier IS NOT NULL
    AND avg_lead_days IS NOT NULL
ORDER BY product, entity;
