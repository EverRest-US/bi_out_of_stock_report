SELECT p.oproduct_sku as product,
       ida.*
FROM analytics.ainventory_depletions_aggregate ida
JOIN hq.oproducts p on ida.oproduct_id = p.oproduct_id
