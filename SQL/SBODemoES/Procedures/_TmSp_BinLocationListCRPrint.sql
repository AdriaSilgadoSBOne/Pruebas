-- PROCEDURE: _TmSp_BinLocationListCRPrint
CREATE PROCEDURE _TmSp_BinLocationListCRPrint
	@type int,
	@binSublevels nvarchar(500),-- (sublevel1From|sublevel1To|sublevel2From|sublevel2To|...)
	@binAttributes nvarchar(500),-- (attr1From|attr1To|attr2From|attr2To|...)
	@binCodeFromTo nvarchar(500),-- (binLocationFrom|binLocationTo|)
	@itemCodeFromTo nvarchar(110),
	@itemGroups nvarchar(max),
	@batchFromTo nvarchar(300),
	@serialFromTo nvarchar(300),
	@binAbsSet nvarchar(max),
	@batchAbs nvarchar(100),
	@serialAbs nvarchar(100),
	@whsCodeFromTo nvarchar(100), -- (warehouseIncludingFrom|warehouseIncludingTo|warehouseExcludingFrom|warehouseExcludingTo|)
	@flag int
	
	AS
	DECLARE
		@displayInactiveBin nvarchar(1),
		@T_SQL nvarchar(max),
		
		@ADD_RANGE_COND_STR nvarchar(max) = 
		N'IF @from_value <> '''' 
			SET @T_SQL = @T_SQL + '' AND '' + @table_alias + ''.'' + @table_field + ''>=(N'''''' + @from_value + '''''')''
		IF @to_value <> ''''
			SET @T_SQL = @T_SQL + '' AND '' + @table_alias + ''.'' + @table_field + ''<=(N'''''' + @to_value + '''''')''',
			
		@ADD_BIN_SUBLEVEL_COND nvarchar(max) = 
		N'SET @table_alias = @T_OBIN
		SET @table_field = ''SL1Code''
		SET @from_value = @binSbl1From
		SET @to_value = @binSbl1To
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''SL2Code''
		SET @from_value = @binSbl2From
		SET @to_value = @binSbl2To
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''SL3Code''
		SET @from_value = @binSbl3From
		SET @to_value = @binSbl3To
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''SL4Code''
		SET @from_value = @binSbl4From
		SET @to_value = @binSbl4To
		$ADD_RANGE_COND_STR',
		
		@ADD_BIN_ATTR_COND nvarchar(max) =
		N'SET @table_alias = @T_OBIN
		SET @table_field = ''Attr1Val''
		SET @from_value = @binAttr1From
		SET @to_value = @binAttr1To
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''Attr2Val''
		SET @from_value = @binAttr2From
		SET @to_value = @binAttr2To
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''Attr3Val''
		SET @from_value = @binAttr3From
		SET @to_value = @binAttr3To
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''Attr4Val''
		SET @from_value = @binAttr4From
		SET @to_value = @binAttr4To
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''Attr5Val''
		SET @from_value = @binAttr5From
		SET @to_value = @binAttr5To
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''Attr6Val''
		SET @from_value = @binAttr6From
		SET @to_value = @binAttr6To
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''Attr7Val''
		SET @from_value = @binAttr7From
		SET @to_value = @binAttr7To
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''Attr8Val''
		SET @from_value = @binAttr8From
		SET @to_value = @binAttr8To
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''Attr9Val''
		SET @from_value = @binAttr9From
		SET @to_value = @binAttr9To
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''Attr10Val''
		SET @from_value = @binAttr10From
		SET @to_value = @binAttr10To
		$ADD_RANGE_COND_STR',
		
		@ADD_BIN_CODE_COND nvarchar(max) =
		N'SET @table_alias = @T_OBIN
		SET @table_field = ''BinCode''
		SET @from_value = @binLocCodeFrom
		SET @to_value = @binLocCodeTo
		$ADD_RANGE_COND_STR',
		
		@ADD_WHS_INCLUD_COND nvarchar(max) =
		N'SET @table_alias = @T_OBIN
		SET @table_field = ''WhsCode''
		SET @from_value = @whsIncludingFrom
		SET @to_value = @whsIncludingTo
		$ADD_RANGE_COND_STR',
		
		@ADD_WHS_EXCLUD_COND nvarchar(max) =
		N'SET @table_alias = @T_OBIN
		SET @table_field = ''WhsCode''
		SET @from_value = @whsExcludingFrom
		SET @to_value = @whsExcludingTo
		IF @from_value <> '''' OR @to_value <> ''''
			BEGIN
				SET @T_SQL = @T_SQL + '' AND (''
				IF @from_value <> ''''
					SET @T_SQL = @T_SQL + @table_alias + ''.'' + @table_field + ''<(N'''''' + @from_value + '''''')''
				IF @to_value <> ''''
					BEGIN
						IF @from_value <> ''''
							SET @T_SQL = @T_SQL + '' OR '' + @table_alias + ''.'' + @table_field + ''>(N'''''' + @to_value + '''''')''
						ELSE
							SET @T_SQL = @T_SQL + @table_alias + ''.'' + @table_field + ''>(N'''''' + @to_value + '''''')''
					END
				SET @T_SQL = @T_SQL + '') ''
			END',
		
		@ADD_INACTIVE_BIN_COND nvarchar(max) =
		N'IF @displayInactiveBin = ''N''
			SET @T_SQL = @T_SQL + '' AND '' + @T_OBIN + ''.Disabled = ''''N'''' ''',
		
		@ParmDefinition nvarchar(max) =
		N'
		@binSublevels nvarchar(500),
		@binAttributes nvarchar(500),
		@binCodeFromTo nvarchar(500),
		@itemCodeFromTo nvarchar(110),
		@itemGroups nvarchar(max),
		@batchFromTo nvarchar(300),
		@serialFromTo nvarchar(300),
		@binAbsSet nvarchar(max),
		@batchAbs nvarchar(100),
		@serialAbs nvarchar(100),
		@whsCodeFromTo nvarchar(100),
		@displayInactiveBin nvarchar(1),
	
		@T_SQL nvarchar(max) = N'''',
		
		@BIN_SUBLEVEL_LENGTH int = 50,
		@BIN_ATTR_LENGTH int = 20,
		@BIN_LOC_CODE_LENGTH int = 228,
		@ITEM_CODE_LENGTH int = 50,
		@SNB_NUMBER_LENGTH int = 36,
		@SNB_ATTR_LENGTH int = 32,
		@WHS_CODE_LENGTH int = 8,
		
		@BIN_SUBLEVEL_COUNT int = 4,
		@BIN_ATTR_COUNT int = 10,
		
		@T_OBIN nvarchar(4) = N''OBIN'',
		@T_OIBQ nvarchar(4) = N''OIBQ'',
		@T_OBBQ nvarchar(4) = N''OBBQ'',
		@T_OSBQ nvarchar(4) = N''OSBQ'',
		@T_OITM nvarchar(4) = N''OITM'',
		@T_OBTN nvarchar(4) = N''OBTN'',
		@T_OSRN nvarchar(4) = N''OSRN'',
		@T_OITB nvarchar(4) = N''OITB'',
		@T_ITM_RTRICT nvarchar(10) = N''ITM_RTRICT'',
		@T_BATCH_RTRICT nvarchar(12) = N''BATCH_RTRICT'',
		@T_REPLENISH_QTY nvarchar(20) = N''REPLENISH_QTY'',
		
		@ITM_RTRICT_SPC_ITM nvarchar(4) = N''1'',
		@ITM_RTRICT_SNG_ITM nvarchar(4) = N''2'',
		@ITM_RTRICT_SPC_ITM_GROUP nvarchar(4) = N''3'',
		@ITM_RTRICT_SNG_ITM_GROUP nvarchar(4) = N''4'',

		@binSbl1From nvarchar(50) = N'''',
		@binSbl1To nvarchar(50) = N'''',
		@binSbl2From nvarchar(50) = N'''',
		@binSbl2To nvarchar(50) = N'''',
		@binSbl3From nvarchar(50) = N'''',
		@binSbl3To nvarchar(50) = N'''',		
		@binSbl4From nvarchar(50) = N'''',
		@binSbl4To nvarchar(50) = N'''',
		
		@binAttr1From nvarchar(20) = N'''',
		@binAttr1To nvarchar(20) = N'''',
		@binAttr2From nvarchar(20) = N'''',
		@binAttr2To nvarchar(20) = N'''',
		@binAttr3From nvarchar(20) = N'''',
		@binAttr3To nvarchar(20) = N'''',
		@binAttr4From nvarchar(20) = N'''',
		@binAttr4To nvarchar(20) = N'''',
		@binAttr5From nvarchar(20) = N'''',
		@binAttr5To nvarchar(20) = N'''',
		@binAttr6From nvarchar(20) = N'''',
		@binAttr6To nvarchar(20) = N'''',
		@binAttr7From nvarchar(20) = N'''',
		@binAttr7To nvarchar(20) = N'''',
		@binAttr8From nvarchar(20) = N'''',
		@binAttr8To nvarchar(20) = N'''',
		@binAttr9From nvarchar(20) = N'''',
		@binAttr9To nvarchar(20) = N'''',
		@binAttr10From nvarchar(20) = N'''',
		@binAttr10To nvarchar(20) = N'''',
		
		@binLocCodeFrom nvarchar(228) = N'''',
		@binLocCodeTo nvarchar(228) = N'''',
		
		@itemCodeFrom nvarchar(50) = N'''',
		@itemCodeTo nvarchar(50) = N'''',
		
		@batchNumberFrom nvarchar(36) = N'''',
		@batchNumberTo nvarchar(36) = N'''',
		@batchAttr1From nvarchar(32) = N'''',
		@batchAttr1To nvarchar(32) = N'''',
		@batchAttr2From nvarchar(32) = N'''',
		@batchAttr2To nvarchar(32) = N'''',
		
		@serialNumberFrom nvarchar(36) = N'''',
		@serialNumberTo nvarchar(36) = N'''',
		@mfrSerialNumberFrom nvarchar(32) = N'''',
		@mfrSerialNumberTo nvarchar(32) = N'''',
		@lotNumberFrom nvarchar(32) = N'''',
		@lotNumberTo nvarchar(32) = N'''',
		
		@whsIncludingFrom nvarchar(8) = N'''',
		@whsIncludingTo nvarchar(8) = N'''',
		
		@whsExcludingFrom nvarchar(8) = N'''',
		@whsExcludingTo nvarchar(8) = N'''',
		
		@displayInactiveItem nvarchar(1) = N'''',
		
		@T_SQL_ITEM_RTRICT nvarchar(max) = N'''',
		@T_SQL_BATCH_RTRICT nvarchar(max) = N'''',
		@T_SQL_REPLENISH_QTY nvarchar(max) = N'''',
		
		@V_INT int = 0,
		@table_alias nvarchar(10) = N'''',
		@table_field nvarchar(20) = N'''',
		@from_value nvarchar(250) = N'''',
		@to_value nvarchar(250) = N'''',
		
		@COMMA nvarchar(1) = N'','',
		
		@BIN_LOC_TABLE_BASE_FIELD nvarchar(max) = N'''' ',
		
		@PREPARE_SQL nvarchar(max) =
		N'IF @binSublevels <> ''''
			BEGIN
				SET @V_INT = 1
				SET @binSbl1From = RTRIM(SUBSTRING(@binSublevels, @V_INT, @BIN_SUBLEVEL_LENGTH))
				SET @V_INT = @V_INT + @BIN_SUBLEVEL_LENGTH
				SET @binSbl1To = RTRIM(SUBSTRING(@binSublevels, @V_INT, @BIN_SUBLEVEL_LENGTH))
				SET @V_INT = @V_INT + @BIN_SUBLEVEL_LENGTH
				SET @binSbl2From = RTRIM(SUBSTRING(@binSublevels, @V_INT, @BIN_SUBLEVEL_LENGTH))
				SET @V_INT = @V_INT + @BIN_SUBLEVEL_LENGTH
				SET @binSbl2To = RTRIM(SUBSTRING(@binSublevels, @V_INT, @BIN_SUBLEVEL_LENGTH))
				SET @V_INT = @V_INT + @BIN_SUBLEVEL_LENGTH
				SET @binSbl3From = RTRIM(SUBSTRING(@binSublevels, @V_INT, @BIN_SUBLEVEL_LENGTH))
				SET @V_INT = @V_INT + @BIN_SUBLEVEL_LENGTH
				SET @binSbl3To = RTRIM(SUBSTRING(@binSublevels, @V_INT, @BIN_SUBLEVEL_LENGTH))
				SET @V_INT = @V_INT + @BIN_SUBLEVEL_LENGTH
				SET @binSbl4From = RTRIM(SUBSTRING(@binSublevels, @V_INT, @BIN_SUBLEVEL_LENGTH))
				SET @V_INT = @V_INT + @BIN_SUBLEVEL_LENGTH
				SET @binSbl4To = RTRIM(SUBSTRING(@binSublevels, @V_INT, @BIN_SUBLEVEL_LENGTH))
			END
			
		IF @binAttributes <> ''''
			BEGIN	
				SET @V_INT = 1
				SET @binAttr1From = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr1To = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr2From = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr2To = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr3From = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr3To = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr4From = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr4To = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr5From = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr5To = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr6From = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr6To = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr7From = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr7To = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr8From = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr8To = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr9From = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr9To = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr10From = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
				SET @V_INT = @V_INT + @BIN_ATTR_LENGTH
				SET @binAttr10To = RTRIM(SUBSTRING(@binAttributes, @V_INT, @BIN_ATTR_LENGTH))
			END
			
		IF @binCodeFromTo <> ''''
			BEGIN
				SET @V_INT = 1
				SET @binLocCodeFrom = RTRIM(SUBSTRING(@binCodeFromTo, @V_INT, @BIN_LOC_CODE_LENGTH))
				SET @V_INT = @V_INT + @BIN_LOC_CODE_LENGTH
				SET @binLocCodeTo = RTRIM(SUBSTRING(@binCodeFromTo, @V_INT, @BIN_LOC_CODE_LENGTH))
			END
			
		IF @itemCodeFromTo <> ''''
			BEGIN
				SET @V_INT = 1
				SET @itemCodeFrom = RTRIM(SUBSTRING(@itemCodeFromTo, @V_INT, @ITEM_CODE_LENGTH))
				SET @V_INT = @V_INT + @BIN_LOC_CODE_LENGTH
				SET @itemCodeTo = RTRIM(SUBSTRING(@itemCodeFromTo, @V_INT, @ITEM_CODE_LENGTH))
			END
			
		IF @batchFromTo <> ''''
			BEGIN
				SET @V_INT = 1
				SET @batchNumberFrom = RTRIM(SUBSTRING(@batchFromTo, @V_INT, @SNB_NUMBER_LENGTH))
				SET @V_INT = @V_INT + @SNB_NUMBER_LENGTH
				SET @batchNumberTo = RTRIM(SUBSTRING(@batchFromTo, @V_INT, @SNB_NUMBER_LENGTH))
				SET @V_INT = @V_INT + @SNB_NUMBER_LENGTH
				
				SET @batchAttr1From = RTRIM(SUBSTRING(@batchFromTo, @V_INT, @SNB_ATTR_LENGTH))
				SET @V_INT = @V_INT + @SNB_ATTR_LENGTH
				SET @batchAttr1To = RTRIM(SUBSTRING(@batchFromTo, @V_INT, @SNB_ATTR_LENGTH))
				SET @V_INT = @V_INT + @SNB_ATTR_LENGTH
				SET @batchAttr2From = RTRIM(SUBSTRING(@batchFromTo, @V_INT, @SNB_ATTR_LENGTH))
				SET @V_INT = @V_INT + @SNB_ATTR_LENGTH
				SET @batchAttr2To = RTRIM(SUBSTRING(@batchFromTo, @V_INT, @SNB_ATTR_LENGTH))
			END
			
		IF @serialFromTo <> ''''
			BEGIN
				SET @V_INT = 1
				SET @serialNumberFrom = RTRIM(SUBSTRING(@serialFromTo, @V_INT, @SNB_NUMBER_LENGTH))
				SET @V_INT = @V_INT + @SNB_NUMBER_LENGTH
				SET @serialNumberTo = RTRIM(SUBSTRING(@serialFromTo, @V_INT, @SNB_NUMBER_LENGTH))
				SET @V_INT = @V_INT + @SNB_NUMBER_LENGTH
				
				SET @mfrSerialNumberFrom = RTRIM(SUBSTRING(@serialFromTo, @V_INT, @SNB_ATTR_LENGTH))
				SET @V_INT = @V_INT + @SNB_ATTR_LENGTH
				SET @mfrSerialNumberTo = RTRIM(SUBSTRING(@serialFromTo, @V_INT, @SNB_ATTR_LENGTH))
				SET @V_INT = @V_INT + @SNB_ATTR_LENGTH
				SET @lotNumberFrom = RTRIM(SUBSTRING(@serialFromTo, @V_INT, @SNB_ATTR_LENGTH))
				SET @V_INT = @V_INT + @SNB_ATTR_LENGTH
				SET @lotNumberTo = RTRIM(SUBSTRING(@serialFromTo, @V_INT, @SNB_ATTR_LENGTH))
			END
			
		IF @whsCodeFromTo <> ''''
			BEGIN
				SET @V_INT = 1
				SET @whsIncludingFrom = RTRIM(SUBSTRING(@whsCodeFromTo, @V_INT, @WHS_CODE_LENGTH))
				SET @V_INT = @V_INT + @WHS_CODE_LENGTH
				SET @whsIncludingTo = RTRIM(SUBSTRING(@whsCodeFromTo, @V_INT, @WHS_CODE_LENGTH))
				SET @V_INT = @V_INT + @WHS_CODE_LENGTH
				SET @whsExcludingFrom = RTRIM(SUBSTRING(@whsCodeFromTo, @V_INT, @WHS_CODE_LENGTH))
				SET @V_INT = @V_INT + @WHS_CODE_LENGTH
				SET @whsExcludingTo = RTRIM(SUBSTRING(@whsCodeFromTo, @V_INT, @WHS_CODE_LENGTH))
			END
		
		SET @binAbsSet = LTRIM(RTRIM(@binAbsSet))
		IF @binAbsSet <> ''''
			BEGIN
				DECLARE
					@start int = 1,
					@length int = 1,
					@BinAbs nvarchar(10)
					
				CREATE TABLE #TMP_TABLE_BIN_ABS (BinAbs INTEGER)
				SET @V_INT = CHARINDEX(@COMMA, @binAbsSet)
					
				WHILE @V_INT <> 0
					BEGIN
						SET @length = @V_INT - @start
						SET @BinAbs = SUBSTRING(@binAbsSet, @start, @length)
						
						INSERT INTO #TMP_TABLE_BIN_ABS VALUES(@BinAbs)
						
						SET @start = @V_INT + 1
						SET @V_INT = CHARINDEX(@COMMA, @binAbsSet, @start)
					END
						
				IF @V_INT = 0
					BEGIN
						SET @length = LEN(@binAbsSet) + 1 - @start
						SET @BinAbs = SUBSTRING(@binAbsSet, @start, @length)
						INSERT INTO #TMP_TABLE_BIN_ABS VALUES(@BinAbs)
					END		
			END
			
		SET @BIN_LOC_TABLE_BASE_FIELD = 
		@T_OBIN + ''.BinCode,'' 
		+ @T_OBIN + ''.WhsCode,'' 
		+ @T_OBIN + ''.SL1Code,'' 
		+ @T_OBIN + ''.SL2Code,'' 
		+ @T_OBIN + ''.SL3Code,''
		+ @T_OBIN + ''.SL4Code,'' 
		+ @T_OBIN + ''.Disabled,'' 
		+ @T_OBIN + ''.ReceiveBin,'' 
		+ @T_OBIN + ''.Descr,'' 
		+ @T_OBIN + ''.AltSortCod,''
		+ @T_OBIN + ''.BarCode,'' 
		+ ''CASE '' + @T_OBIN + ''.MinLevel WHEN 0 THEN NULL ELSE '' + @T_OBIN + ''.MinLevel END AS MinLevel,'' 
		+ ''CASE '' + @T_OBIN + ''.MaxLevel WHEN 0 THEN NULL ELSE '' + @T_OBIN + ''.MaxLevel END AS MaxLevel,'' 
		+ @T_OBIN + ''.Attr1Val,'' 
		+ @T_OBIN + ''.Attr2Val,'' 
		+ @T_OBIN + ''.Attr3Val,'' 
		+ @T_OBIN + ''.Attr4Val,'' 
		+ @T_OBIN + ''.Attr5Val,'' 
		+ @T_OBIN + ''.Attr6Val,'' 
		+ @T_OBIN + ''.Attr7Val,''
		+ @T_OBIN + ''.Attr8Val,'' 
		+ @T_OBIN + ''.Attr9Val,''
		+ @T_OBIN + ''.Attr10Val,'' 
		+ @T_OBIN + ''.RtrictType,'' 
		+ @T_OBIN + ''.RtrictResn,''
		+ @T_OBIN + ''.RtrictDate,'' 
			
		SET @T_SQL_ITEM_RTRICT = 
		N''(SELECT '' + @T_OBIN + ''.AbsEntry AS ''''BinAbs'''','' 
			+ @T_OBIN + ''.SpcItmCode AS ''''RestrictedTo'''' FROM '' 
			+ @T_OBIN + '' WHERE '' + @T_OBIN + ''.ItmRtrictT = '' + @ITM_RTRICT_SPC_ITM 
		+ '' UNION ALL ''
		+ '' SELECT '' + @T_OIBQ + ''.BinAbs AS ''''BinAbs'''', '' + @T_OIBQ + ''.ItemCode AS ''''RestrictedTo'''' FROM '' 
		+ @T_OIBQ + '' WHERE '' + @T_OIBQ + ''.BinAbs IN (SELECT AbsEntry FROM '' + @T_OBIN + '' WHERE '' 
		+ @T_OBIN + ''.ItmRtrictT = '' + @ITM_RTRICT_SNG_ITM + '') AND '' + @T_OIBQ + ''.OnHandQty > 0 GROUP BY '' 
		+ @T_OIBQ + ''.BinAbs, '' + @T_OIBQ + ''.ItemCode HAVING COUNT('' + @T_OIBQ + ''.BinAbs) < 2 '' 
		+ '' UNION ALL '' 
		+ '' SELECT '' + @T_OBIN + ''.AbsEntry AS ''''BinAbs'''', '' + @T_OITB + ''.ItmsGrpNam AS ''''RestrictedTo'''' FROM '' 
		+ @T_OBIN + '' INNER JOIN '' + @T_OITB + '' ON '' + @T_OBIN + ''.SpcItmGrpC = '' + @T_OITB + ''.ItmsGrpCod''
		+ '' WHERE '' + @T_OBIN + ''.ItmRtrictT = '' + @ITM_RTRICT_SPC_ITM_GROUP + 
		'' UNION ALL '' +
		'' SELECT '' + @T_OIBQ + ''.BinAbs AS ''''BinAbs'''', '' + '' MAX('' + @T_OITB + ''.ItmsGrpNam) '' 
		+ '' AS ''''RestrictedTo'''' FROM '' + @T_OIBQ + '' INNER JOIN '' + @T_OITM + '' ON '' 
		+ @T_OIBQ + ''.ItemCode = '' + @T_OITM + ''.ItemCode '' + '' INNER JOIN '' + @T_OITB + '' ON ''
		+ @T_OITM + ''.ItmsGrpCod = '' + @T_OITB + ''.ItmsGrpCod '' + '' WHERE '' 
		+ @T_OIBQ + ''.BinAbs IN (SELECT AbsEntry FROM '' + @T_OBIN + '' WHERE '' + @T_OBIN + ''.ItmRtrictT = '' 
		+ @ITM_RTRICT_SNG_ITM_GROUP + '') AND '' + @T_OIBQ + ''.OnHandQty > 0 GROUP BY '' + @T_OIBQ
		+ ''.BinAbs, '' + @T_OITM + ''.ItmsGrpCod HAVING COUNT('' + @T_OIBQ + ''.BinAbs) < 2) AS '' + @T_ITM_RTRICT
		
		SET @T_SQL_BATCH_RTRICT =
		N''(SELECT '' + @T_OBBQ + ''.BinAbs AS ''''BinAbs'''', '' + ''Min('' + @T_OBTN + ''.DistNumber) AS ''''Batch'''' FROM '' 
		+ @T_OBBQ + '' INNER JOIN '' + @T_OBTN + '' ON '' + @T_OBBQ + ''.SnBMDAbs = '' + @T_OBTN + ''.AbsEntry WHERE '' 
		+ @T_OBBQ + ''.BinAbs IN (SELECT AbsEntry FROM '' + @T_OBIN + '' WHERE '' + @T_OBIN + ''.SngBatch = ''''Y'''') AND '' 
		+ @T_OBBQ + ''.OnHandQty <> 0 GROUP BY '' + @T_OBBQ + ''.BinAbs, '' + @T_OBBQ
		+ ''.SnBMDAbs HAVING COUNT(*) < 2) AS '' + @T_BATCH_RTRICT
		
		SET @T_SQL_REPLENISH_QTY = 
		N'' (SELECT '' + @T_OIBQ + ''.BinAbs, SUM('' + @T_OIBQ + ''.OnHandQty) AS ReplenishOnHandQty FROM '' + @T_OIBQ
		+ '' INNER JOIN '' + @T_OBIN + '' ON '' + @T_OIBQ + ''.BinAbs = '' + @T_OBIN + ''.AbsEntry  AND '' + @T_OIBQ
		+ ''.ItemCode = '' + @T_OBIN + ''.SpcItmCode AND '' + @T_OBIN + ''.ItmRtrictT = '' + @ITM_RTRICT_SPC_ITM
		+ '' WHERE '' + @T_OIBQ + ''.OnHandQty <> 0 GROUP BY '' + @T_OIBQ + ''.BinAbs ''
		+ '' UNION ALL ''
		+ '' SELECT '' + @T_OIBQ + ''.BinAbs, SUM('' + @T_OIBQ + ''.OnHandQty) AS ReplenishOnHandQty FROM '' + @T_OIBQ
		+ '' WHERE '' + @T_OIBQ + ''.OnHandQty > 0 AND '' + @T_OIBQ + ''.BinAbs IN (SELECT AbsEntry FROM '' + @T_OBIN
		+ '' WHERE '' + @T_OBIN + ''.ItmRtrictT = '' + @ITM_RTRICT_SNG_ITM + '' ) GROUP BY '' + @T_OIBQ + ''.BinAbs ) AS '' + @T_REPLENISH_QTY
		'
		
	BEGIN
		SET NOCOUNT ON;
		
		IF @flag & 4 = 4
			SET @displayInactiveBin = N'Y'
		ELSE
			SET @displayInactiveBin = N'N'
			
		SET @ADD_BIN_SUBLEVEL_COND = REPLACE(@ADD_BIN_SUBLEVEL_COND, N'$ADD_RANGE_COND_STR', @ADD_RANGE_COND_STR)
		SET @ADD_BIN_ATTR_COND = REPLACE(@ADD_BIN_ATTR_COND, N'$ADD_RANGE_COND_STR', @ADD_RANGE_COND_STR)
		SET @ADD_BIN_CODE_COND = REPLACE(@ADD_BIN_CODE_COND, N'$ADD_RANGE_COND_STR', @ADD_RANGE_COND_STR)
		SET @ADD_WHS_INCLUD_COND = REPLACE(@ADD_WHS_INCLUD_COND, N'$ADD_RANGE_COND_STR', @ADD_RANGE_COND_STR)
		
		SET @T_SQL =
			N'
			BEGIN
				$PREPARE_SQL
					
				SET @T_SQL = 
				N''SELECT '' + @BIN_LOC_TABLE_BASE_FIELD
					+ @T_OBIN + ''.ItmRtrictT, '' 
					+ @T_ITM_RTRICT + ''.RestrictedTo, '' 
					+ @T_OBIN + ''.SngBatch, '' 
					+ @T_BATCH_RTRICT + ''.Batch,''
					+ '' CASE B.ItemCount WHEN 0 THEN NULL ELSE B.ItemCount END AS ItemCount, ''
					+ '' CASE B.OnHandQty WHEN 0 THEN NULL ELSE B.OnHandQty END AS OnHandQty, ''
					+ '' CASE B.SnBCount WHEN 0 THEN NULL ELSE B.SnBCount END AS SnBCount, ''
					+ '' CASE ''
					+ '' WHEN B.ItmCountNeg = 1 AND '' + @T_OBIN + ''.ItmRtrictT <> '' + @ITM_RTRICT_SPC_ITM + '' THEN '' 
					+ '' CASE WHEN '' + @T_OBIN + ''.MinLevel <> ISNULL(B.OnHandQty, 0) THEN '' + @T_OBIN + ''.MinLevel - ISNULL(B.OnHandQty, 0) ELSE NULL END ''
					+ '' WHEN '' + @T_OBIN + ''.ItmRtrictT = '' + @ITM_RTRICT_SPC_ITM + '' AND '' + @T_OBIN + ''.Disabled = N''''N'''' THEN ''
					+ '' CASE WHEN '' + @T_OBIN + ''.MinLevel <> '' + ''ISNULL('' + @T_REPLENISH_QTY + ''.ReplenishOnHandQty, 0) ''
					+ '' THEN '' + + @T_OBIN + ''.MinLevel - '' + ''ISNULL('' + @T_REPLENISH_QTY + ''.ReplenishOnHandQty, 0) ELSE NULL END ''
					+ '' WHEN B.ItmCountNeg <> 1 AND '' + @T_OBIN + ''.ItmRtrictT = '' + @ITM_RTRICT_SNG_ITM + '' THEN ''
					+ '' CASE WHEN '' + @T_OBIN + ''.MinLevel <> '' + @T_REPLENISH_QTY + ''.ReplenishOnHandQty THEN ''
					+ @T_OBIN + ''.MinLevel - '' + @T_REPLENISH_QTY + ''.ReplenishOnHandQty ELSE NULL END ''
					+ '' ELSE NULL ''
					+ '' END AS QtyBelowMin, ''
					+ '' CASE ''
					+ '' WHEN B.ItmCountNeg = 1 AND '' + @T_OBIN + ''.ItmRtrictT <> '' + @ITM_RTRICT_SPC_ITM 
					+ '' AND '' + @T_OBIN + ''.MaxLevel <> 0 AND '' + @T_OBIN + ''.MaxLevel > ISNULL(B.OnHandQty, 0) '' 
					+ '' THEN ('' + @T_OBIN + ''.MaxLevel - ISNULL(B.OnHandQty, 0)) ''
					+ '' WHEN '' + @T_OBIN + ''.ItmRtrictT = '' + @ITM_RTRICT_SPC_ITM + '' AND '' + @T_OBIN + ''.Disabled = N''''N'''' ''
					+ '' AND '' + @T_OBIN + ''.MaxLevel <> 0 AND '' + @T_OBIN + ''.MaxLevel > '' + ''ISNULL( '' + @T_REPLENISH_QTY + ''.ReplenishOnHandQty, 0) ''
					+ '' THEN '' + @T_OBIN + ''.MaxLevel - '' + ''ISNULL('' + @T_REPLENISH_QTY + ''.ReplenishOnHandQty, 0) ''
					+ '' WHEN B.ItmCountNeg <> 1 AND '' + @T_OBIN + ''.ItmRtrictT = '' + @ITM_RTRICT_SNG_ITM
					+ '' AND '' + @T_OBIN + ''.MaxLevel <> 0 AND '' + @T_OBIN + ''.MaxLevel > '' + @T_REPLENISH_QTY + ''.ReplenishOnHandQty ''
					+ '' THEN '' + @T_OBIN + ''.MaxLevel - '' + @T_REPLENISH_QTY + ''.ReplenishOnHandQty ''
					+ '' ELSE NULL ''
					+ '' END AS ReplenishmentQty ''
					+ '' FROM '' + @T_OBIN + '' LEFT OUTER JOIN ''
					+ '' (SELECT	MAX(A.BinAbs) AS ''''BinAbs'''',''
								+ ''SUM(A.ItemCount) AS ''''ItemCount'''',''
								+ ''SUM(A.OnHandQty) AS ''''OnHandQty'''',''
								+ ''SUM(A.SnBCount) AS ''''SnBCount'''',''
								+ ''SUM(A.ItmCountNeg) AS ''''ItmCountNeg'''' ''
						+ '' FROM ''
						+ '' (SELECT '' + @T_OIBQ + ''.BinAbs						AS ''''BinAbs'''','' 
							+ ''Count(DISTINCT '' + @T_OIBQ + ''.ItemCode)		AS ''''ItemCount'''','' 
							+ ''Max('' + @T_OIBQ + ''.OnHandQty)					AS ''''OnHandQty'''','' 
							+ ''Count(DISTINCT '' + @T_OBBQ + ''.SnBMDAbs) '' 
							+ '' + Count(DISTINCT '' + @T_OSBQ + ''.SnBMDAbs) AS ''''SnBCount'''',''  
							+ ''Count(DISTINCT '' + @T_OIBQ + ''.ItemCode)		AS ''''ItmCountNeg''''''
						+ '' FROM '' + @T_OIBQ 
							+ '' LEFT OUTER JOIN '' + @T_OBBQ + '' ON '' 
								+ @T_OIBQ + ''.BinAbs = '' + @T_OBBQ + ''.BinAbs'' 
								+ '' AND '' + @T_OIBQ + ''.ItemCode = '' + @T_OBBQ + ''.ItemCode'' 
								+ '' AND '' + @T_OBBQ + ''.OnHandQty <> 0''
							+ '' LEFT OUTER JOIN '' + @T_OSBQ
								+ '' ON '' + @T_OIBQ + ''.BinAbs = '' + @T_OSBQ + ''.BinAbs'' 
								+ '' AND '' + @T_OIBQ + ''.ItemCode = '' + @T_OSBQ + ''.ItemCode'' 
								+ '' AND '' + @T_OSBQ + ''.OnHandQty <> 0''
								+ '' WHERE '' + @T_OIBQ + ''.OnHandQty > 0 ''
							+ '' GROUP BY '' + @T_OIBQ + ''.BinAbs,'' + @T_OIBQ + ''.AbsEntry''
						+ '' UNION ALL ''
						+ '' SELECT '' + @T_OIBQ + ''.BinAbs						AS ''''BinAbs'''','' 
							+ ''0													AS ''''ItemCount'''','' 
							+ ''Max('' + @T_OIBQ + ''.OnHandQty)					AS ''''OnHandQty'''','' 
							+ ''Count(DISTINCT '' + @T_OBBQ + ''.SnBMDAbs) ''
							+ '' + Count(DISTINCT '' + @T_OSBQ + ''.SnBMDAbs) AS ''''SnBCount'''','' 
							+ ''Count(DISTINCT '' + @T_OIBQ + ''.ItemCode)		AS ''''ItmContNeg'''''' 
						+ '' FROM '' + @T_OIBQ
							+ '' LEFT OUTER JOIN '' + @T_OBBQ + '' ON ''
								+ @T_OIBQ + ''.BinAbs = '' + @T_OBBQ + ''.BinAbs'' 
								+ '' AND '' + @T_OIBQ + ''.ItemCode = '' + @T_OBBQ + ''.ItemCode'' 
								+ '' AND '' + @T_OBBQ + ''.OnHandQty <> 0'' 
							+ '' LEFT OUTER JOIN '' + @T_OSBQ
								+ '' ON '' + @T_OIBQ + ''.BinAbs = '' + @T_OSBQ + ''.BinAbs'' 
								+ '' AND '' + @T_OIBQ + ''.ItemCode = '' + @T_OSBQ + ''.ItemCode'' 
								+ '' AND '' + @T_OSBQ + ''.OnHandQty <> 0''
								+ '' WHERE '' + @T_OIBQ + ''.OnHandQty < 0''
								+ '' GROUP BY '' + @T_OIBQ + ''.BinAbs,'' + @T_OIBQ + ''.AbsEntry) AS A''
						+ '' GROUP BY A.BinAbs) AS B''
						+ '' ON '' + @T_OBIN + ''.AbsEntry = B.BinAbs''
					+ '' LEFT OUTER JOIN '' +
						@T_SQL_ITEM_RTRICT + '' ON '' + @T_OBIN + ''.AbsEntry = '' + @T_ITM_RTRICT + ''.BinAbs''
					+ '' LEFT OUTER JOIN '' +
						@T_SQL_BATCH_RTRICT + '' ON '' + @T_OBIN + ''.AbsEntry = '' + @T_BATCH_RTRICT + ''.BinAbs''
					+ '' LEFT OUTER JOIN '' +
						@T_SQL_REPLENISH_QTY + '' ON '' + @T_OBIN + ''.AbsEntry = '' + @T_REPLENISH_QTY + ''.BinAbs''
				+ '' WHERE '' + @T_OBIN + ''.AbsEntry > 0 ''
				
				SET @T_SQL = @T_SQL + '' AND '' + @T_OBIN + ''.WhsCode IN ( SELECT WhsCode FROM OWHS WHERE Inactive = N''''N'''') ''

				IF @binAbsSet <> ''''
					SET @T_SQL = @T_SQL + '' AND '' + @T_OBIN + ''.AbsEntry IN (SELECT BinAbs FROM #TMP_TABLE_BIN_ABS) ''
					
				$ADD_WHS_INCLUD_COND
				$ADD_WHS_EXCLUD_COND
				$ADD_BIN_SUBLEVEL_COND
				$ADD_BIN_ATTR_COND
				$ADD_BIN_CODE_COND
				$ADD_INACTIVE_BIN_COND
					
				SET @T_SQL = @T_SQL + '' ORDER BY '' + @T_OBIN + ''.BinCode''
				
				--PRINT(@T_SQL)	
				EXEC(@T_SQL)
			END'
			
		SET @T_SQL = REPLACE(@T_SQL, N'$PREPARE_SQL', @PREPARE_SQL)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_WHS_INCLUD_COND', @ADD_WHS_INCLUD_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_WHS_EXCLUD_COND', @ADD_WHS_EXCLUD_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_BIN_SUBLEVEL_COND', @ADD_BIN_SUBLEVEL_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_BIN_ATTR_COND', @ADD_BIN_ATTR_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_BIN_CODE_COND', @ADD_BIN_CODE_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_INACTIVE_BIN_COND', @ADD_INACTIVE_BIN_COND)
		
		EXEC sp_executesql
			@T_SQL,
			@ParmDefinition,
			@binSublevels = @binSublevels,
			@binAttributes = @binAttributes,
			@binCodeFromTo = @binCodeFromTo,
			@itemCodeFromTo = @itemCodeFromTo,
			@itemGroups = @itemGroups,
			@batchFromTo = @batchFromTo,
			@serialFromTo = @serialFromTo,
			@binAbsSet = @binAbsSet,
			@batchAbs = @batchAbs,
			@serialAbs = @serialAbs,
			@whsCodeFromTo = @whsCodeFromTo,
			@displayInactiveBin = @displayInactiveBin
	END;
