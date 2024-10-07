-- VIEW: OSRD

		CREATE VIEW OSRD
		AS 

		SELECT		MIN(a.ItemCode)		as ItemCode,
					MIN(a.ApplyType)	as DocType,
					MIN(a.ApplyEntry)	as DocEntry,
					MIN(a.AppDocNum)	as DocNum,
					MIN(a.ApplyLine)	as DocLineNum,
					ABS(SUM(a.DocQty) - SUM(ISNULL (d.DocQty, 0)))	as DocQuty,
					ABS(SUM(a.DocQty) - SUM(ISNULL (d.DocQty, 0))) - MIN(b.DefinedQty) as DocOpenQty,
					MIN(a.DocDate)		as DocDate,
					(
						CASE WHEN ABS(SUM(a.DocQty) - SUM(ISNULL (d.DocQty, 0))) > MIN(b.DefinedQty) THEN '0'
						ELSE '1' END
					)					as Status,
					(
						CASE WHEN MIN(a.ManagedBy) = 10000044 THEN 106
						ELSE 94 END
					)					as SrdType,
					MIN(a.ItemName)		as ItemName,
					MIN(a.LocCode)		as WhsCode,
					MIN(a.CardCode)		as CardCode,
					MIN(a.CardName)		as CardName,
					MIN(c.ManOutOnly)	as ManOutOnly,
					(
						CASE WHEN (SUM(a.DocQty) > 0 AND MIN(a.StockEff) = 1) 
							OR (SUM(a.DocQty) < 0 AND MIN(a.StockEff) = 2)  THEN '0'	-- To specially deal with SO and AR Reserve Inv
						ELSE '1' END
					)					as Direction,
					NULL				as CreateNew,
					'N'					as DataSource,
					NULL				as UserSign
		FROM		OITL a
		LEFT JOIN	(
						select		(CASE 
										when ISNULL(ABS(SUM(bb.Quantity)), 0) > 0 THEN ISNULL(ABS(SUM(bb.Quantity)), 0)
										else ISNULL(ABS(SUM(bb.AllocQty)), 0)
									END) as DefinedQty,
									MIN (aa.LogEntry) as LogEntry
						from		OITL aa 
						left join	ITL1 bb on aa.LogEntry=bb.LogEntry
						group by	aa.ItemCode, aa.ApplyType, aa.ApplyEntry, aa.ApplyLine, aa.LocCode
					)  b on b.LogEntry = a.LogEntry
		INNER JOIN	OITM c on c.ItemCode = a.ItemCode
		LEFT OUTER JOIN OITL d on(d.LogEntry = a.LogEntry and d.StockQty = 0 and d.DefinedQty > 0 and d.StockEff = 1)
		or (d.LogEntry = a.LogEntry and d.StockEff = 2 and 
            (d.ApplyType in (14,15,60,59,67) or d.ApplyType = 13 and exists (select 1 from OITL U0 WHERE U0.[TransId] = a.[TransId] AND U0.[StockEff] <> 2))
        )
		GROUP BY	a.ItemCode, a.ApplyType, a.ApplyEntry, a.ApplyLine, a.LocCode
		HAVING		(MIN(a.ApplyType) <> 67 and SUM(a.DocQty) <> 0) -- To exclude those document lines with batch numbers that have been totally deallocated.
		OR			(MIN(a.ApplyType) = 67 and SUM(a.DocQty) < 0)		-- For backward compatibility, ensure only one record is generated in OSRD for stock transfer.
	;
