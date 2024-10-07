-- FUNCTION: B1_PaymentLinesView
CREATE VIEW [dbo].[B1_PaymentLinesView] AS SELECT T0.[ObjType], T0.[DocNum], T0.[InvoiceId] AS 'LineId', T0.[InvType], T0.[DocEntry], N'' AS 'AcctCode', T1.[BPLId] FROM  [dbo].[RCT2] T0  INNER  JOIN [dbo].[B1_MarketingDocumentsView] T1  ON  T1.[ObjType] = T0.[InvType]  AND  T1.[DocEntry] = T0.[DocEntry]   UNION ALL SELECT T0.[ObjType], T0.[DocNum], T0.[InvoiceId] AS 'LineId', T0.[InvType], T0.[DocEntry], N'' AS 'AcctCode', T1.[BPLId] FROM  [dbo].[VPM2] T0  INNER  JOIN [dbo].[B1_MarketingDocumentsView] T1  ON  T1.[ObjType] = T0.[InvType]  AND  T1.[DocEntry] = T0.[DocEntry]   UNION ALL SELECT T0.[ObjType], T0.[DocNum], T0.[LineId], N'' AS 'InvType', 0 AS 'DocEntry', T0.[AcctCode], T1.[BPLId] FROM  [dbo].[RCT4] T0  INNER  JOIN [dbo].[OACT] T1  ON  T1.[AcctCode] = T0.[AcctCode]  AND  T1.[BPLId] IS NOT NULL   AND  T1.[BPLId] > 0   UNION ALL SELECT T0.[ObjType], T0.[DocNum], T0.[LineId], N'' AS 'InvType', 0 AS 'DocEntry', T0.[AcctCode], T1.[BPLId] FROM  [dbo].[VPM4] T0  INNER  JOIN [dbo].[OACT] T1  ON  T1.[AcctCode] = T0.[AcctCode]  AND  T1.[BPLId] IS NOT NULL   AND  T1.[BPLId] > 0   UNION ALL SELECT T0.[ObjType], T0.[DocNum], T0.[LineId], N'' AS 'InvType', 0 AS 'DocEntry', T0.[AcctCode], T2.[BPLId] FROM  [dbo].[RCT4] T0  INNER  JOIN [dbo].[OACT] T1  ON  T1.[AcctCode] = T0.[AcctCode]  AND  (T1.[BPLId] IS NULL   OR  T1.[BPLId] <= 0 )  INNER  JOIN [dbo].[ORCT] T2  ON  T2.[DocEntry] = T0.[DocNum]   UNION ALL SELECT T0.[ObjType], T0.[DocNum], T0.[LineId], N'' AS 'InvType', 0 AS 'DocEntry', T0.[AcctCode], T2.[BPLId] FROM  [dbo].[VPM4] T0  INNER  JOIN [dbo].[OACT] T1  ON  T1.[AcctCode] = T0.[AcctCode]  AND  (T1.[BPLId] IS NULL   OR  T1.[BPLId] <= 0 )  INNER  JOIN [dbo].[OVPM] T2  ON  T2.[DocEntry] = T0.[DocNum]  ;
