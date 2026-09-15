SELECT p.oproduct_sku as product,
       CASE WHEN ida.ainventory_depletions_owned_locations = 1 THEN 'SMX' ELSE 'EVR' END AS entity,
       ida.ainventory_depletions_month,
       SUM(ida.ainventory_depletions_quantity) as quantity
FROM analytics.ainventory_depletions_aggregate ida
JOIN hq.oproducts p on ida.oproduct_id = p.oproduct_id
WHERE TRUE
    AND ida.ainventory_depletions_owned_locations IN (1, 2) # 1 = SMX and 2 = EVR
GROUP BY p.oproduct_sku, entity, ida.ainventory_depletions_month
ORDER BY p.oproduct_sku, entity, ida.ainventory_depletions_month
;
