
SELECT I.ITEMNMBR Item_Number,
       I.ITEMDESC Item_Description,
       Q.QTYONHND Quantity_on_Hand,
       U.BASEUOFM U_of_M,
       CASE I.ITEMTYPE
          WHEN 1 THEN 'Inventory'
          WHEN 2 THEN 'Discontinued'
          WHEN 3 THEN 'Kit'
          WHEN 4 THEN 'Misc Charges'
          WHEN 5 THEN 'Services'
          WHEN 6 THEN 'Flat Fee'
          END Item_Type,
       I.CURRCOST Current_Cost,
       I.ITMCLSCD Item_Class,
       coalesce(Q.LSRCPTDT,'1/1/1900') Last_Receipt_Date,
       coalesce(Q.LSORDVND,'') Last_Vendor
 
FROM IV00101 I
 
LEFT OUTER JOIN
     (SELECT ITEMNMBR, MAX(DOCDATE) LastSale
      FROM IV30300
      WHERE DOCTYPE = 6
      GROUP BY ITEMNMBR) S
     ON I.ITEMNMBR = S.ITEMNMBR
 
INNER JOIN
     IV00102 Q
     ON I.ITEMNMBR = Q.ITEMNMBR
     AND RCRDTYPE = 1
 
INNER JOIN
     IV40201 U
     ON U.UOMSCHDL = I.UOMSCHDL
 
WHERE Q.QTYONHND <> 0