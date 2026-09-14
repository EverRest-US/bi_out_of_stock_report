SELECT COALESCE(spr.everrest_product, pi.product) as product,
       pi.available_quantity,
       pl.hq_location_name
FROM analytics.pipe_inventory pi
LEFT JOIN analytics.sinomax_product_reference spr on pi.product = spr.sinomax_product
JOIN analytics.pipe_locations pl on pi.location = pl.name
