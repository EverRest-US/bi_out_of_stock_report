-- Available inventory per product, split by entity and channel.
-- Both sources are stacked into a common shape, then aggregated once.

WITH all_inv AS (
    SELECT COALESCE(spr.everrest_product, pi.product) as sku,
           CASE WHEN pl.entity = 'EVR' THEN SUM(pi.available_quantity) ELSE 0 END as evr_qty,
           CASE WHEN pl.entity = 'SMX' THEN SUM(pi.available_quantity) ELSE 0 END as smx_qty,
           0 as amz_qty
    FROM analytics.pipe_inventory pi
        LEFT JOIN analytics.sinomax_product_reference spr on pi.product = spr.sinomax_product and spr.default_flag = 1
        JOIN analytics.pipe_locations pl on pi.location = pl.name
    WHERE pi.available_quantity > 0
    GROUP BY COALESCE(spr.everrest_product, pi.product)

    UNION ALL

    SELECT p.oproduct_sku as sku,
           0 as evr_qty,
           0 as smx_qty,
           SUM(IFNULL(i.oinventory_ext_pos_available, 0)) as amz_qty
    FROM hq.oInventoryExtPOS i
        JOIN hq.oproducts p on i.oproduct_id = p.oproduct_id
    WHERE i.ochannel_id IN (27, 31)
    AND i.oinventory_ext_pos_available > 0
    GROUP BY p.oproduct_sku
)
SELECT sku as product,
       ROUND(SUM(evr_qty), 0) as evr_available_quantity,
       ROUND(SUM(smx_qty), 0) as smx_available_quantity,
       ROUND(SUM(amz_qty), 0) as amz_available_quantity
FROM all_inv
GROUP BY product;
