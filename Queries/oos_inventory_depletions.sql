SELECT p.oproduct_sku as product,
       CASE WHEN ida.ainventory_depletions_owned_locations = 0 THEN 'SMX' ELSE 'EVR' END AS entity,
       ida.ainventory_depletions_month,
       SUM(ida.ainventory_depletions_quantity) as quantity
FROM analytics.ainventory_depletions_aggregate ida
JOIN hq.oproducts p on ida.oproduct_id = p.oproduct_id
WHERE TRUE
    AND ida.ainventory_depletions_owned_locations IN (0, 2) # 0 = SMX, 2 = EVR
GROUP BY p.oproduct_sku, entity, ida.ainventory_depletions_month

