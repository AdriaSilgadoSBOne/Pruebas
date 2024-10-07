-- PROCEDURE: _TmSp_BinLocationContentDetailListCRPrint
CREATE PROCEDURE _TmSp_BinLocationContentDetailListCRPrint
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
		@BIN_LOC_CONTENT_DETAIL_LIST int = 3,
		@snbOnly nvarchar(1),
		@includeNonBinWhs nvarchar(1),
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
		N'SET @table_field = ''WhsCode''
		SET @from_value = @whsIncludingFrom
		SET @to_value = @whsIncludingTo
		$ADD_RANGE_COND_STR',
		
		@ADD_WHS_EXCLUD_COND nvarchar(max) =
		N'SET @table_field = ''WhsCode''
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
			
		@ADD_BATCH_RANGE_COND nvarchar(max) =
		N'SET @table_field = ''BatchNumber''
		SET @from_value = @batchNumberFrom
		SET @to_value = @batchNumberTo
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''BatchAttr1''
		SET @from_value = @batchAttr1From
		SET @to_value = @batchAttr1To
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''BatchAttr2''
		SET @from_value = @batchAttr2From
		SET @to_value = @batchAttr2To
		$ADD_RANGE_COND_STR',
		
		@ADD_SERIAL_RANGE_COND nvarchar(max) = 
		N'SET @table_field = ''SerialNumber''
		SET @from_value = @serialNumberFrom
		SET @to_value = @serialNumberTo
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''MnfSerial''
		SET @from_value = @mfrSerialNumberFrom
		SET @to_value = @mfrSerialNumberTo
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''LotNumber''
		SET @from_value = @lotNumberFrom
		SET @to_value = @lotNumberTo
		$ADD_RANGE_COND_STR',
		
		@ADD_BTN_BATCH_RANGE_COND nvarchar(max) =
		N'SET @table_alias = @T_OBTN
		SET @table_field = ''DistNumber''
		SET @from_value = @batchNumberFrom
		SET @to_value = @batchNumberTo
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''MnfSerial''
		SET @from_value = @batchAttr1From
		SET @to_value = @batchAttr1To
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''LotNumber''
		SET @from_value = @batchAttr2From
		SET @to_value = @batchAttr2To
		$ADD_RANGE_COND_STR',
		
		@ADD_SRN_SERIAL_RANGE_COND nvarchar(max) = 
		N'SET @table_alias = @T_OSRN
		SET @table_field = ''DistNumber''
		SET @from_value = @serialNumberFrom
		SET @to_value = @serialNumberTo
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''MnfSerial''
		SET @from_value = @mfrSerialNumberFrom
		SET @to_value = @mfrSerialNumberTo
		$ADD_RANGE_COND_STR
		
		SET @table_field = ''LotNumber''
		SET @from_value = @lotNumberFrom
		SET @to_value = @lotNumberTo
		$ADD_RANGE_COND_STR',
		
		@ADD_ITEM_CODE_RANGE_COND nvarchar(max) =
		N'SET @table_alias = @T_OITM
		SET @table_field = ''ItemCode''
		SET @from_value = @itemCodeFrom
		SET @to_value = @itemCodeTo
		$ADD_RANGE_COND_STR',
		
		@ADD_ITEM_GRP_CODE_COND nvarchar(max) =
		N'IF @itemGroups <> ''''
			SET @T_SQL = @T_SQL + '' AND '' + @T_OITM + ''.ItmsGrpCod IN ('' + @itemGroups + '') ''',
			
		@ADD_DISPLAY_INACTIVE_ITEM_COND nvarchar(max) =
		N'SELECT @displayInactiveItem = DspFrznITM FROM OADM
		IF @displayInactiveItem = ''N''
			SET @T_SQL = @T_SQL + '' AND ('' + @T_OITM + ''.ItemCode IS NULL OR (''+ @T_OITM + ''.validFor = (N''''Y'''') OR ('' 
						+ @T_OITM + ''.frozenFor = (N''''Y'''') AND ('' + @T_OITM + ''.frozenFrom IS NOT NULL OR '' + @T_OITM
						+ ''.frozenTo IS NOT NULL)) OR ('' + @T_OITM + ''.validFor = (N''''N'''') AND '' + @T_OITM 
						+ ''.frozenFor = (N''''N'''') )))'' ',
		
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
		@snbOnly nvarchar(1),
		@includeNonBinWhs nvarchar(1),
	
		@T_SQL nvarchar(max) = N'''',
		
		@BIN_SUBLEVEL_LENGTH int = 50,
		@BIN_ATTR_LENGTH int = 20,
		@BIN_LOC_CODE_LENGTH int = 228,
		@ITEM_CODE_LENGTH int = 50,
		@SNB_NUMBER_LENGTH int = 36,
		@SNB_ATTR_LENGTH int = 36,
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
		@T_OITW nvarchar(4) = N''OITW'',
		@T_OWHS nvarchar(4) = N''OWHS'',
		@T_OBTQ nvarchar(4) = N''OBTQ'',
		@T_OSRQ nvarchar(4) = N''OSRQ'',
		
		@T_ITM_RTRICT nvarchar(10) = N''ITM_RTRICT'',
		@T_BATCH_RTRICT nvarchar(12) = N''BATCH_RTRICT'',
		
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
		@batchAttr1From nvarchar(36) = N'''',
		@batchAttr1To nvarchar(36) = N'''',
		@batchAttr2From nvarchar(36) = N'''',
		@batchAttr2To nvarchar(36) = N'''',
		
		@serialNumberFrom nvarchar(36) = N'''',
		@serialNumberTo nvarchar(36) = N'''',
		@mfrSerialNumberFrom nvarchar(36) = N'''',
		@mfrSerialNumberTo nvarchar(36) = N'''',
		@lotNumberFrom nvarchar(36) = N'''',
		@lotNumberTo nvarchar(36) = N'''',
		
		@whsIncludingFrom nvarchar(8) = N'''',
		@whsIncludingTo nvarchar(8) = N'''',
		
		@whsExcludingFrom nvarchar(8) = N'''',
		@whsExcludingTo nvarchar(8) = N'''',
		
		@displayInactiveItem nvarchar(1) = N'''',
		
		@T_SQL_ITEM_RTRICT nvarchar(3000) = N'''',
		@T_SQL_BATCH_RTRICT nvarchar(1000) = N'''',
		
		@V_INT int = 0,
		@table_alias nvarchar(20) = N'''',
		@table_field nvarchar(20) = N'''',
		@from_value nvarchar(250) = N'''',
		@to_value nvarchar(250) = N'''',
		
		@COMMA nvarchar(1) = N'','',
		
		@BIN_LOC_TABLE_BASE_FIELD nvarchar(2000) = N'''' ',
		
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
				SET @V_INT = @V_INT + @ITEM_CODE_LENGTH
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
		+ ''CASE WHEN '' + @T_OBIN + ''.MinLevel = 0 THEN NULL ELSE '' + @T_OBIN + ''.MinLevel END AS MinLevel, '' 
		+ ''CASE WHEN '' + @T_OBIN + ''.MaxLevel = 0 THEN NULL ELSE '' + @T_OBIN + ''.MaxLevel END AS MaxLevel, ''  
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
		+ ''.SnBMDAbs HAVING COUNT(*) < 2) AS '' + @T_BATCH_RTRICT '
		
	BEGIN
	SET NOCOUNT ON;
	IF @type = @BIN_LOC_CONTENT_DETAIL_LIST
	BEGIN
		IF @flag & 2 = 2
			SET @snbOnly = N'Y'
		ELSE
			SET @snbOnly = N'N'
			
		IF @flag & 8 = 8
			SET @includeNonBinWhs = N'Y'
		ELSE
			SET @includeNonBinWhs = N'N'
				
		SET @ADD_BIN_SUBLEVEL_COND = REPLACE(@ADD_BIN_SUBLEVEL_COND, N'$ADD_RANGE_COND_STR', @ADD_RANGE_COND_STR)
		SET @ADD_BIN_ATTR_COND = REPLACE(@ADD_BIN_ATTR_COND, N'$ADD_RANGE_COND_STR', @ADD_RANGE_COND_STR)
		SET @ADD_BIN_CODE_COND = REPLACE(@ADD_BIN_CODE_COND, N'$ADD_RANGE_COND_STR', @ADD_RANGE_COND_STR)
		SET @ADD_WHS_INCLUD_COND = REPLACE(@ADD_WHS_INCLUD_COND, N'$ADD_RANGE_COND_STR', @ADD_RANGE_COND_STR)
		SET @ADD_BATCH_RANGE_COND = REPLACE(@ADD_BATCH_RANGE_COND, N'$ADD_RANGE_COND_STR', @ADD_RANGE_COND_STR)
		SET @ADD_SERIAL_RANGE_COND = REPLACE(@ADD_SERIAL_RANGE_COND, N'$ADD_RANGE_COND_STR', @ADD_RANGE_COND_STR)
		SET @ADD_BTN_BATCH_RANGE_COND = REPLACE(@ADD_BTN_BATCH_RANGE_COND, N'$ADD_RANGE_COND_STR', @ADD_RANGE_COND_STR)
		SET @ADD_SRN_SERIAL_RANGE_COND = REPLACE(@ADD_SRN_SERIAL_RANGE_COND, N'$ADD_RANGE_COND_STR', @ADD_RANGE_COND_STR)
		SET @ADD_ITEM_CODE_RANGE_COND = REPLACE(@ADD_ITEM_CODE_RANGE_COND, N'$ADD_RANGE_COND_STR', @ADD_RANGE_COND_STR)
		
		SET @T_SQL =
		N'DECLARE
			@FROM_TABLE_SQL nvarchar(max),
			@BATCH_NOT_DEFINED_SQL nvarchar(max),
			@SERIAL_NOT_DEFINED_SQL nvarchar(max),
			@BATCH_DEFINED_SQL nvarchar(max),
			@SERIAL_DEFINED_SQL nvarchar(max),
			@NOT_SNB_SQL nvarchar(max),
			@T_QTY nvarchar(10) = N''QTY_TABLE'',
			@T_QTY_NON_BIN nvarchar(20) = N''T_QTY_NON_BIN'',
			
			@SELECT_BASE_SQL_4_NON_BIN_WHS nvarchar(max),
			@FROM_TABLE_SQL_4_NON_BIN_WHS nvarchar(max),
			@BATCH_NOT_DEFINED_SQL_4_NON_BIN_WHS nvarchar(max),
			@SERIAL_NOT_DEFINED_SQL_4_NON_BIN_WHS nvarchar(max),
			@BATCH_DEFINED_SQL_4_NON_BIN_WHS nvarchar(max),
			@SERIAL_DEFINED_SQL_4_NON_BIN_WHS nvarchar(max),
			@NOT_SNB_SQL_4_NON_BIN_WHS nvarchar(max)
		BEGIN
			$PREPARE_SQL
			
			SET @FROM_TABLE_SQL = 
			N'' FROM '' + @T_OIBQ + '' LEFT OUTER JOIN '' + @T_OBBQ + '' ON '' + @T_OIBQ + ''.BinAbs = ''
			+ @T_OBBQ + ''.BinAbs AND '' + @T_OIBQ + ''.ItemCode = '' + @T_OBBQ + ''.ItemCode AND ''
			+ @T_OBBQ + ''.OnHandQty <> 0 LEFT OUTER JOIN '' + @T_OSBQ + '' ON '' + @T_OIBQ + ''.BinAbs = ''
			+ @T_OSBQ + ''.BinAbs AND '' + @T_OIBQ + ''.ItemCode = '' + @T_OSBQ + ''.ItemCode AND ''
			+ @T_OSBQ + ''.OnHandQty <> 0 LEFT OUTER JOIN '' + @T_OBTN + '' ON '' + @T_OBBQ + ''.SnBMDAbs = ''
			+ @T_OBTN + ''.AbsEntry AND '' + @T_OBBQ + ''.ItemCode = '' + @T_OBTN + ''.ItemCode ''
			+ '' LEFT OUTER JOIN '' + @T_OSRN + '' ON '' + @T_OSBQ + ''.SnBMDAbs = '' + @T_OSRN + ''.AbsEntry AND ''
			+ @T_OSBQ + ''.ItemCode = '' + @T_OSRN + ''.ItemCode ''
					
			SET @BATCH_NOT_DEFINED_SQL =
			N'' SELECT '' + @T_OIBQ + ''.BinAbs,''
			+ @T_OIBQ + ''.ItemCode,''
			+ ''MAX('' + @T_OIBQ + ''.OnHandQty) - '' + ''SUM('' + @T_OBBQ + ''.OnHandQty) AS ''''OnHandQty'''',''
			+ ''NULL AS ''''BatchNumber'''',''
			+ ''NULL AS ''''BatchAttr1'''',''
			+ ''NULL AS ''''BatchAttr2'''',''
			+ ''NULL AS ''''SerialNumber'''',''
			+ ''NULL AS ''''MnfSerial'''',''
			+ ''NULL AS ''''LotNumber'''',''
			+ ''NULL AS ''''BatchAbs'''',''
			+ ''NULL AS ''''SerialAbs'''' ''
			+ @FROM_TABLE_SQL
			+ '' WHERE '' + @T_OIBQ + ''.OnHandQty <> 0 AND '' + @T_OBBQ + ''.AbsEntry IS NOT NULL ''
			+ '' GROUP BY '' + @T_OIBQ + ''.BinAbs,'' + @T_OIBQ + ''.ItemCode '' 
			+ '' HAVING MAX('' + @T_OIBQ + ''.OnHandQty) > '' + ''SUM('' + @T_OBBQ + ''.OnHandQty) ''
					
			SET @SERIAL_NOT_DEFINED_SQL = 
			N'' SELECT '' + @T_OIBQ + ''.BinAbs,''
			+ @T_OIBQ + ''.ItemCode,''
			+ ''MAX('' + @T_OIBQ + ''.OnHandQty) - '' + ''SUM('' + @T_OSBQ + ''.OnHandQty) AS ''''OnHandQty'''',''
			+ ''NULL AS ''''BatchNumber'''',''
			+ ''NULL AS ''''BatchAttr1'''',''
			+ ''NULL AS ''''BatchAttr2'''',''
			+ ''NULL AS ''''SerialNumber'''',''
			+ ''NULL AS ''''MnfSerial'''',''
			+ ''NULL AS ''''LotNumber'''',''
			+ ''NULL AS ''''BatchAbs'''',''
			+ ''NULL AS ''''SerialAbs'''' ''
			+ @FROM_TABLE_SQL
			+ '' WHERE '' + @T_OIBQ + ''.OnHandQty <> 0 AND '' + @T_OSBQ + ''.AbsEntry IS NOT NULL ''
			+ '' GROUP BY '' + @T_OIBQ + ''.BinAbs,'' + @T_OIBQ + ''.ItemCode '' 
			+ '' HAVING MAX('' + @T_OIBQ + ''.OnHandQty) > '' + ''SUM('' + @T_OSBQ + ''.OnHandQty) ''
					
			SET @BATCH_DEFINED_SQL =
			N'' SELECT '' + @T_OIBQ + ''.BinAbs,''
			+ @T_OIBQ + ''.ItemCode,''
			+ @T_OBBQ + ''.OnHandQty,''
			+ @T_OBTN + ''.DistNumber AS ''''BatchNumber'''',''
			+ @T_OBTN + ''.MnfSerial AS ''''BatchAttr1'''',''
			+ @T_OBTN + ''.LotNumber AS ''''BatchAttr2'''',''
			+ @T_OSRN + ''.DistNumber AS ''''SerialNumber'''',''
			+ @T_OSRN + ''.MnfSerial AS ''''MnfSerial'''',''
			+ @T_OSRN + ''.LotNumber AS ''''LotNumber'''',''
			+ @T_OBTN + ''.AbsEntry AS ''''BatchAbs'''',''
			+ @T_OSRN + ''.AbsEntry AS ''''SerialAbs'''' ''
			+ @FROM_TABLE_SQL
			+ '' WHERE '' + @T_OIBQ + ''.OnHandQty <> 0 AND '' + @T_OBBQ + ''.AbsEntry IS NOT NULL ''
					
			SET @SERIAL_DEFINED_SQL = 
			N'' SELECT '' + @T_OIBQ + ''.BinAbs,''
			+ @T_OIBQ + ''.ItemCode,''
			+ @T_OSBQ + ''.OnHandQty,''
			+ @T_OBTN + ''.DistNumber AS ''''BatchNumber'''',''
			+ @T_OBTN + ''.MnfSerial AS ''''BatchAttr1'''',''
			+ @T_OBTN + ''.LotNumber AS ''''BatchAttr2'''',''
			+ @T_OSRN + ''.DistNumber AS ''''SerialNumber'''',''
			+ @T_OSRN + ''.MnfSerial AS ''''MnfSerial'''',''
			+ @T_OSRN + ''.LotNumber AS ''''LotNumber'''',''
			+ @T_OBTN + ''.AbsEntry AS ''''BatchAbs'''',''
			+ @T_OSRN + ''.AbsEntry AS ''''SerialAbs'''' ''
			+ @FROM_TABLE_SQL
			+ '' WHERE '' + @T_OIBQ + ''.OnHandQty <> 0 AND '' + @T_OSBQ + ''.AbsEntry IS NOT NULL ''
					
			SET @NOT_SNB_SQL = 
			N'' SELECT '' + @T_OIBQ + ''.BinAbs,''
			+ @T_OIBQ + ''.ItemCode,''
			+ @T_OIBQ + ''.OnHandQty,''
			+ @T_OBTN + ''.DistNumber AS ''''BatchNumber'''',''
			+ @T_OBTN + ''.MnfSerial AS ''''BatchAttr1'''',''
			+ @T_OBTN + ''.LotNumber AS ''''BatchAttr2'''',''
			+ @T_OSRN + ''.DistNumber AS ''''SerialNumber'''',''
			+ @T_OSRN + ''.MnfSerial AS ''''MnfSerial'''',''
			+ @T_OSRN + ''.LotNumber AS ''''LotNumber'''',''
			+ @T_OBTN + ''.AbsEntry AS ''''BatchAbs'''',''
			+ @T_OSRN + ''.AbsEntry AS ''''SerialAbs'''' ''
			+ @FROM_TABLE_SQL
			+ '' WHERE '' + @T_OIBQ + ''.OnHandQty <> 0 AND '' + @T_OBBQ + ''.AbsEntry IS NULL AND ''
			+ @T_OSBQ + ''.AbsEntry IS NULL ''
			
			SET @SELECT_BASE_SQL_4_NON_BIN_WHS = 
			N'' SELECT NULL AS BinCode, '' + @T_QTY_NON_BIN + ''.WhsCode AS WhsCode, ''
			+ '' NULL AS SL1Code, NULL AS SL2Code, NULL AS SL3Code, NULL AS SL4Code, ''
			+ '' NULL AS Disabled, NULL AS ReceiveBin, NULL AS Descr, NULL AS AltSortCod, ''
			+ '' NULL AS BarCode, NULL AS MinLevel, NULL AS MaxLevel, NULL AS Attr1Val, NULL AS Attr2Val, ''
			+ '' NULL AS Attr3Val, NULL AS Attr4Val, NULL AS Attr5Val, NULL AS Attr6Val, NULL AS Attr7Val, ''
			+ '' NULL AS Attr8Val, NULL AS Attr9Val, NULL AS Attr10Val, NULL AS RtrictType, NULL AS RtrictResn, ''
			+ '' NULL AS RtrictDate, NULL AS ItmRtrictT, NULL AS RestrictedTo, NULL AS SngBatch, NULL AS Batch, ''
			+ @T_OITM + ''.ItemCode AS ItemCode, '' + @T_OITM + ''.ItemName AS ItemName, ''
			+ ''(SELECT ItmsGrpNam FROM '' + @T_OITB
			+ '' WHERE '' + @T_OITB + ''.ItmsGrpCod = '' + @T_OITM + ''.ItmsGrpCod ) AS ItmsGrpNam, ''
			+ @T_OITM + ''.CodeBars AS CodeBars, '' + @T_OITM + ''.InvntryUom AS InvntryUom, ''
			
			SET @FROM_TABLE_SQL_4_NON_BIN_WHS =
			N'' FROM '' + @T_OITW + '' INNER JOIN '' + @T_OWHS + '' ON ''
			+ @T_OITW + ''.WhsCode = '' + @T_OWHS + ''.WhsCode ''
			+ '' LEFT OUTER JOIN '' + @T_OBTQ + '' ON '' + @T_OBTQ
			+ ''.WhsCode = '' + @T_OITW + ''.WhsCode AND '' + @T_OBTQ
			+ ''.ItemCode = '' + @T_OITW + ''.ItemCode LEFT OUTER JOIN ''
			+ @T_OSRQ + '' ON '' + @T_OSRQ + ''.WhsCode = '' + @T_OITW + ''.WhsCode ''
			+ '' AND '' + @T_OSRQ + ''.ItemCode = '' + @T_OITW + ''.ItemCode ''
			+ '' WHERE '' + @T_OWHS + ''.BinActivat = ''''N'''' ''
			
			SET @BATCH_NOT_DEFINED_SQL_4_NON_BIN_WHS = 
			N'' SELECT '' + @T_OITW + ''.ItemCode, ''
			+ @T_OITW + ''.WhsCode, ''
			+ '' MAX( '' + @T_OITW + ''.OnHand) - SUM('' + @T_OBTQ + ''.Quantity) AS OnHandQty, ''
			+ '' NULL AS BatchAbs, NULL AS SerialAbs ''
			+ @FROM_TABLE_SQL_4_NON_BIN_WHS
			+ '' AND '' + @T_OITW + ''.OnHand <> 0 AND '' + @T_OBTQ + ''.AbsEntry IS NOT NULL ''
			+ '' GROUP BY '' + @T_OITW + ''.WhsCode, '' + @T_OITW + ''.ItemCode ''
			+ '' HAVING MAX( '' + @T_OITW + ''.OnHand) > SUM('' + @T_OBTQ + ''.Quantity) ''
			
			SET @SERIAL_NOT_DEFINED_SQL_4_NON_BIN_WHS = 
			N'' SELECT '' + @T_OITW + ''.ItemCode, ''
			+ @T_OITW + ''.WhsCode, ''
			+ '' MAX( '' + @T_OITW + ''.OnHand) - SUM('' + @T_OSRQ + ''.Quantity) AS OnHandQty, ''
			+ '' NULL AS BatchAbs, NULL AS SerialAbs ''
			+ @FROM_TABLE_SQL_4_NON_BIN_WHS
			+ '' AND '' + @T_OITW + ''.OnHand <> 0 AND '' + @T_OSRQ + ''.AbsEntry IS NOT NULL ''
			+ '' GROUP BY '' + @T_OITW + ''.WhsCode, '' + @T_OITW + ''.ItemCode ''
			+ '' HAVING MAX( '' + @T_OITW + ''.OnHand) > SUM('' + @T_OSRQ + ''.Quantity) ''
			
			SET @BATCH_DEFINED_SQL_4_NON_BIN_WHS =
			N'' SELECT '' + @T_OITW + ''.ItemCode, ''
			+ @T_OITW + ''.WhsCode, ''
			+ @T_OBTQ + ''.Quantity AS OnHandQty, ''
			+ @T_OBTQ + ''.MdAbsEntry AS BatchAbs, ''
			+ @T_OSRQ + ''.MdAbsEntry AS SerialAbs ''
			+ @FROM_TABLE_SQL_4_NON_BIN_WHS
			+ '' AND '' + @T_OBTQ + ''.Quantity <> 0 AND '' + @T_OBTQ + ''.AbsEntry IS NOT NULL ''	

			SET @SERIAL_DEFINED_SQL_4_NON_BIN_WHS = 
			N'' SELECT '' + @T_OITW + ''.ItemCode, ''
			+ @T_OITW + ''.WhsCode, ''
			+ @T_OSRQ + ''.Quantity AS OnHandQty, ''
			+ @T_OBTQ + ''.MdAbsEntry AS BatchAbs, ''
			+ @T_OSRQ + ''.MdAbsEntry AS SerialAbs ''
			+ @FROM_TABLE_SQL_4_NON_BIN_WHS
			+ '' AND '' + @T_OSRQ + ''.Quantity <> 0 AND '' + @T_OSRQ + ''.AbsEntry IS NOT NULL ''

			SET @NOT_SNB_SQL_4_NON_BIN_WHS = 
			N'' SELECT '' + @T_OITW + ''.ItemCode, ''
			+ @T_OITW + ''.WhsCode, ''
			+ @T_OITW + ''.OnHand AS OnHandQty, ''
			+ @T_OBTQ + ''.MdAbsEntry AS BatchAbs, ''
			+ @T_OSRQ + ''.MdAbsEntry AS SerialAbs ''
			+ @FROM_TABLE_SQL_4_NON_BIN_WHS
			+ '' AND '' + @T_OITW + ''.OnHand <> 0 AND '' + @T_OBTQ + ''.AbsEntry IS NULL AND ''
			+ @T_OSRQ + ''.AbsEntry IS NULL ''
			
			IF @includeNonBinWhs = N''Y''
				SET @T_SQL =
				N''SELECT A.BinCode, A.WhsCode, A.SL1Code, A.SL2Code, A.SL3Code, A.SL4Code, ''
				+ '' A.Disabled, A.ReceiveBin, A.Descr, A.AltSortCod, A.BarCode, A.MinLevel, ''
				+ '' A.MaxLevel, A.Attr1Val, A.Attr2Val, A.Attr3Val, A.Attr4Val, A.Attr5Val, ''
				+ '' A.Attr6Val, A.Attr7Val, A.Attr8Val, A.Attr9Val, A.Attr10Val, A.RtrictType, ''
				+ '' A.RtrictResn, A.RtrictDate, A.ItmRtrictT, A.RestrictedTo, A.SngBatch, A.Batch, ''
				+ '' A.ItemCode, A.ItemName, A.ItmsGrpNam, A.CodeBars, A.InvntryUom, A.OnHandQty, ''
				+ '' A.BatchNumber, A.BatchAttr1, A.BatchAttr2, A.SerialNumber, A.MnfSerial, A.LotNumber, ''
				+ '' A.QtyBelowMin, A.ReplenishmentQty FROM (''
					
			SET @T_SQL = @T_SQL +
			N''SELECT '' + @BIN_LOC_TABLE_BASE_FIELD
				+ @T_OBIN + ''.ItmRtrictT, '' 
				+ @T_ITM_RTRICT + ''.RestrictedTo, '' 
				+ @T_OBIN + ''.SngBatch, '' 
				+ @T_BATCH_RTRICT + ''.Batch,''
				+ @T_OITM + ''.ItemCode,''
				+ @T_OITM + ''.ItemName,''
				+ ''(SELECT ItmsGrpNam FROM '' + @T_OITB
				+ '' WHERE '' + @T_OITB + ''.ItmsGrpCod = '' + @T_OITM + ''.ItmsGrpCod ) AS ItmsGrpNam, ''
				+ @T_OITM + ''.CodeBars,''
				+ @T_OITM + ''.InvntryUom,''
				+ @T_QTY + ''.OnHandQty,''
				+ @T_QTY + ''.BatchNumber,''
				+ @T_QTY + ''.BatchAttr1,''
				+ @T_QTY + ''.BatchAttr2,''
				+ @T_QTY + ''.SerialNumber,''
				+ @T_QTY + ''.MnfSerial,''
				+ @T_QTY + ''.LotNumber,''
				+ ''NULL AS QtyBelowMin, NULL AS ReplenishmentQty ''
			
			IF @includeNonBinWhs = N''Y''
				SET @T_SQL = @T_SQL + '', '' + @T_QTY + ''.BatchAbs AS BatchAbs, ''
							+ @T_QTY + ''.serialAbs AS serialAbs ''
			
			SET @T_SQL = @T_SQL + '' FROM '' + @T_OBIN + '' INNER JOIN ''
			+ '' ('' + @BATCH_DEFINED_SQL
			+ '' UNION ALL '' + @SERIAL_DEFINED_SQL
					
			IF @snbOnly = ''N''
				BEGIN
				SET @T_SQL = @T_SQL + '' UNION ALL '' + @NOT_SNB_SQL
							+ '' UNION ALL '' + @BATCH_NOT_DEFINED_SQL
							+ '' UNION ALL '' + @SERIAL_NOT_DEFINED_SQL
				END
					
			SET @T_SQL = @T_SQL + '') AS '' + @T_QTY + '' ON ''
						+ @T_OBIN + ''.AbsEntry = '' + @T_QTY + ''.BinAbs ''
						+ '' INNER JOIN '' + @T_OITM
						+ '' ON '' + @T_QTY + ''.ItemCode = '' + @T_OITM + ''.ItemCode ''
						+ '' LEFT OUTER JOIN ''
						+ @T_SQL_ITEM_RTRICT + '' ON '' + @T_OBIN + ''.AbsEntry = '' + @T_ITM_RTRICT + ''.BinAbs''
						+ '' LEFT OUTER JOIN '' 
						+ @T_SQL_BATCH_RTRICT + '' ON '' + @T_OBIN + ''.AbsEntry = '' + @T_BATCH_RTRICT + ''.BinAbs''
						+ '' WHERE '' + @T_OBIN + ''.[AbsEntry] > 0 ''
						
			IF @binAbsSet <> ''''
				SET @T_SQL = @T_SQL + '' AND '' + @T_OBIN + ''.AbsEntry IN (SELECT BinAbs FROM #TMP_TABLE_BIN_ABS) ''
			
			SET @table_alias = @T_OBIN			
			$ADD_WHS_INCLUD_COND
			$ADD_WHS_EXCLUD_COND
			$ADD_BIN_SUBLEVEL_COND
			$ADD_BIN_ATTR_COND
			$ADD_BIN_CODE_COND
			$ADD_ITEM_CODE_RANGE_COND
			$ADD_ITEM_GRP_CODE_COND
			
			SET @table_alias = @T_QTY
			$ADD_BATCH_RANGE_COND
			$ADD_SERIAL_RANGE_COND
					
			IF @batchAbs <> ''''
				SET @T_SQL = @T_SQL + '' AND '' + @T_QTY + ''.BatchAbs IN ('' + @batchAbs + '')''
			IF @serialAbs <> ''''
				SET @T_SQL = @T_SQL + '' AND '' + @T_QTY + ''.SerialAbs IN ('' + @serialAbs + '')''
					
			$ADD_DISPLAY_INACTIVE_ITEM_COND
			
			IF @includeNonBinWhs = N''N''			
				SET @T_SQL = @T_SQL + '' ORDER BY '' + @T_OBIN + ''.BinCode,'' + @T_OITM + ''.ItemCode,''
						+ @T_QTY + ''.BatchAbs,'' + @T_QTY + ''.SerialAbs''
						
			IF @includeNonBinWhs = N''Y''
			BEGIN
				SET @T_SQL = @T_SQL + ''UNION ALL ''
				+ @SELECT_BASE_SQL_4_NON_BIN_WHS
				+ @T_QTY_NON_BIN + ''.OnHandQty, ''
				+ @T_OBTN + ''.DistNumber AS BatchNumber, '' + @T_OBTN + ''.MnfSerial AS BatchAttr1, '' + @T_OBTN + ''.LotNumber AS BatchAttr2, ''
				+ @T_OSRN + ''.DistNumber AS SerialNumber, '' + @T_OSRN + ''.MnfSerial AS MnfSerial, '' + @T_OSRN + ''.LotNumber AS LotNumber, ''
				+ '' NULL AS QtyBelowMin, NULL AS ReplenishmentQty, ''
				+ @T_OBTN + ''.AbsEntry AS BatchAbs, ''
				+ @T_OSRN + ''.AbsEntry AS SerialAbs ''
				+ '' FROM ( '' + @BATCH_DEFINED_SQL_4_NON_BIN_WHS
				+ '' UNION ALL '' + @SERIAL_DEFINED_SQL_4_NON_BIN_WHS
				
				IF @snbOnly = ''N''
				BEGIN
					SET @T_SQL = @T_SQL + '' UNION ALL '' + @NOT_SNB_SQL_4_NON_BIN_WHS
							+ '' UNION ALL '' + @BATCH_NOT_DEFINED_SQL_4_NON_BIN_WHS
							+ '' UNION ALL '' + @SERIAL_NOT_DEFINED_SQL_4_NON_BIN_WHS
				END
				
				SET @T_SQL = @T_SQL + '') AS '' + @T_QTY_NON_BIN + '' INNER JOIN ''
							+ @T_OITM + '' ON '' + @T_QTY_NON_BIN + ''.ItemCode = '' + @T_OITM + ''.ItemCode ''
							+ '' LEFT OUTER JOIN '' + @T_OBTN + '' ON '' + @T_QTY_NON_BIN + ''.BatchAbs = ''
							+ @T_OBTN + ''.AbsEntry LEFT OUTER JOIN '' + @T_OSRN + '' ON '' + @T_QTY_NON_BIN + ''.SerialAbs = ''
							+ @T_OSRN + ''.AbsEntry ''
							+ '' WHERE '' + @T_OITM + ''.ItemCode IS NOT NULL ''
							
				SET @table_alias = @T_QTY_NON_BIN			
				$ADD_WHS_INCLUD_COND
				$ADD_WHS_EXCLUD_COND
			
				$ADD_ITEM_CODE_RANGE_COND
				$ADD_ITEM_GRP_CODE_COND
				$ADD_DISPLAY_INACTIVE_ITEM_COND
			
				$ADD_BTN_BATCH_RANGE_COND
				$ADD_SRN_SERIAL_RANGE_COND
				
				SET @T_SQL = @T_SQL + '') AS A ORDER BY A.WhsCode, A.BinCode, A.ItemCode, A.BatchAbs, A.SerialAbs ''
				
			END
				
					
			--PRINT(@T_SQL)
			EXEC(@T_SQL)
		END'
				
		SET @T_SQL = REPLACE(@T_SQL, N'$PREPARE_SQL', @PREPARE_SQL)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_WHS_INCLUD_COND', @ADD_WHS_INCLUD_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_WHS_EXCLUD_COND', @ADD_WHS_EXCLUD_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_BIN_SUBLEVEL_COND', @ADD_BIN_SUBLEVEL_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_BIN_ATTR_COND', @ADD_BIN_ATTR_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_BIN_CODE_COND', @ADD_BIN_CODE_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_ITEM_CODE_RANGE_COND', @ADD_ITEM_CODE_RANGE_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_ITEM_GRP_CODE_COND', @ADD_ITEM_GRP_CODE_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_BATCH_RANGE_COND', @ADD_BATCH_RANGE_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_SERIAL_RANGE_COND', @ADD_SERIAL_RANGE_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_DISPLAY_INACTIVE_ITEM_COND', @ADD_DISPLAY_INACTIVE_ITEM_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_BTN_BATCH_RANGE_COND', @ADD_BTN_BATCH_RANGE_COND)
		SET @T_SQL = REPLACE(@T_SQL, N'$ADD_SRN_SERIAL_RANGE_COND', @ADD_SRN_SERIAL_RANGE_COND)
		
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
			@snbOnly = @snbOnly,
			@includeNonBinWhs = @includeNonBinWhs
	END
	ELSE
	BEGIN
		SET @T_SQL =
		N'SELECT
		BinCode,
		WhsCode,
		SL1Code,
		SL2Code,
		SL3Code,
		SL4Code,
		Disabled,
		ReceiveBin,
		Descr,
		AltSortCod,
		BarCode,
		MinLevel,
		MaxLevel,
		Attr1Val,
		Attr2Val,
		Attr3Val,
		Attr4Val,
		Attr5Val,
		Attr6Val,
		Attr7Val,
		Attr8Val,
		Attr9Val,
		Attr10Val,
		RtrictType,
		RtrictResn,
		RtrictDate,
		ItmRtrictT,
		NULL AS RestrictedTo,
		SngBatch,
		NULL AS Batch,
		NULL AS ItemCode,
		NULL AS ItemName,
		NULL AS ItmsGrpNam,
		NULL AS CodeBars,
		NULL AS InvntryUom,
		NULL AS OnHandQty,
		NULL AS BatchNumber,
		NULL AS BatchAttr1,
		NULL AS BatchAttr2,
		NULL AS SerialNumber,
		NULL AS MnfSerial,
		NULL AS LotNumber,
		NULL AS QtyBelowMin,
		NULL AS ReplenishmentQty
		FROM OBIN
		WHERE 1 <> 1'
		
		--PRINT(@T_SQL)
		EXEC(@T_SQL)
	END -- IF @type = @BIN_LOC_CONTENT_DETAIL_LIST
	END;
