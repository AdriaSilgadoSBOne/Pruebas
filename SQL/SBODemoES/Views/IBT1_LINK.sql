-- VIEW: IBT1_LINK

		create view IBT1_LINK
		as 

		SELECT		MIN(b.LogEntry)		as LogEntry,
					MIN(b.ItemCode)		as [ItemCode],
					MIN(c.DistNumber)	as [BatchNum],
					MIN(b.LocCode)		as [WhsCode],
					MIN(b.ItemName)		as [ItemName],
					MIN(b.ApplyType)	as [BaseType],      
					MIN(b.ApplyEntry)	as [BaseEntry],
					MIN(b.AppDocNum)	as [BaseNum],
					MIN(b.ApplyLine)	as [BaseLinNum],
					MIN(b.DocDate)		as [DocDate],
					(								 
						CASE WHEN ABS(SUM(a.Quantity)) = 0 THEN SUM(a.AllocQty)
						ELSE ABS(SUM(a.Quantity)) END
					)					as [Quantity],
					MIN(b.CardCode)		as [CardCode],
					MIN(b.CardName)		as [CardName],
					(
						CASE WHEN  SUM(a.Quantity) > 0 THEN 0
						WHEN SUM(a.Quantity) < 0 THEN 1
						ELSE 2 END
					)					as [Direction],
					MIN(b.CreateDate)	as [CreateDate],
					MIN(b.BaseType)		as [BsDocType],
					MIN(b.BaseEntry)	as [BsDocEntry],
					MIN(b.BaseLine)		as [BsDocLine],
					'N'				as [DataSource],
					NULL				as [UserSign]
		FROM		ITL1 a
		INNER JOIN	OITL b ON a.LogEntry = b.LogEntry
		INNER JOIN	OBTN c ON a.ItemCode = c.ItemCode and a.SysNumber = c.SysNumber
		GROUP BY	b.ItemCode, a.SysNumber, b.ApplyType, b.ApplyEntry, b.ApplyLine, b.LocCode, b.StockEff
		having		(SUM(b.DocQty) <> 0)		-- To exclude those document lines with batch numbers that have been totally deallocated.
		OR			(SUM(b.DefinedQty) <> 0)	-- For the case: batch is on release only and use complete operation to define batch.
		OR			(SUM(b.DocQty) = 0 and b.StockEff = 2 
					 and min(b.BaseType) <> 17 and min(b.BaseType) <> 13 ) -- for the case DLN/INV based on sales order with allocated batch.
	;
