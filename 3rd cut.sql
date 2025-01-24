DECLARE @SQL NVARCHAR(MAX);

SET @SQL = N'
SELECT 
    S.BUKRS  AS Company,
    BS.WERKS AS Plant,  -- Fetching Plant from BSEG
    S.PRCTR  AS Pctr, 
    S.HKONT  AS GL_Acc,
    S.BELNR  AS Doc_No, 
    S.BLART  AS Doc_Type, 
    S.BLDAT  AS Doc_Date, 
    BK.CPUDT AS Entry_Date, 
    S.BUDAT  AS Post_Date, 
    S.WRBTR  AS CoCd_Curr_Val, 
    S.AUGBL  AS Offset_Acc, 
    BS.KOART AS Offset_Type, 
    BS.LIFNR AS Supplier, 
    S.SGTXT  AS Txt, 
    S.XBLNR  AS Ref,
    S.SHKZG  AS D_C_Ind, 
    L.NAME1  AS Vendor_Name, 
    BS.UMSKZ  AS SGL_Ind, 
    S.GJAHR  AS Fisc_Year, 
    BK.MONAT AS Post_Period, 
    C.LTEXT  AS Pctr_Txt, 
    BK.BKTXT AS Doc_Hdr_Txt, 
    S.DMBTR  AS Doc_Curr_Val, 
    BK.WAERS AS Doc_Curr_Key, 
    S.EBELN  AS Pur_Doc,
    K.TXT50  AS GL_Txt50, 
    BK.KURSF AS Exch_Rate
FROM SAPABAP1.BSIS AS S 
INNER JOIN SAPABAP1.BKPF AS BK
    ON S.BELNR = BK.BELNR
    AND S.GJAHR = BK.GJAHR
    AND S.BUKRS = BK.BUKRS  -- Fixed join condition

INNER JOIN SAPABAP1.BSEG AS BS
    ON S.BELNR = BS.BELNR
    AND S.GJAHR = BS.GJAHR
    AND S.BUKRS = BS.BUKRS  -- Added Company Code match

LEFT JOIN SAPABAP1.LFA1 AS L 
    ON BS.LIFNR = L.LIFNR AND BS.LIFNR <> '''' -- Ensure Vendor exists before joining

LEFT JOIN SAPABAP1.CEPCT AS C 
    ON S.PRCTR = C.PRCTR

LEFT JOIN SAPABAP1.SKAT AS K 
    ON S.HKONT = K.SAKNR
    AND K.SPRAS = ''EN''  -- Language Filter (English)

WHERE S.HKONT IN (
    ''0000253030'', ''0000253040'', ''0000130010'', ''0000130030'', 
    ''0000132340'', ''0000207300'', ''0000130020'', ''0000207200'', 
    ''0000104060''
);';

-- Execute the SQL on a linked SAP server
EXEC (@SQL) AT sap_GHP;
