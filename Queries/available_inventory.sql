SELECT COALESCE(spr.everrest_product, pi.product) as product,
       pl.entity,
       SUM(pi.available_quantity) as available_quantity
FROM analytics.pipe_inventory pi
LEFT JOIN analytics.sinomax_product_reference spr on pi.product = spr.sinomax_product
JOIN analytics.pipe_locations pl on pi.location = pl.name
GROUP BY product, entity
