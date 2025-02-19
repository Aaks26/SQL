DECLARE @SQL NVARCHAR(MAX);
SET @SQL = N'
SELECT  
    S.BUKRS  AS Company_Code,
    LEFT(ac.PRCTR, 4)  AS Plant,
    ac.PRCTR  AS Profit_Center,
    C.LTEXT  AS Profit_Center_Long_Text,
    S.HKONT  AS GL_Account,
    K.TXT20  AS GL_Account_Short_Text,
    S.BLART  AS Document_Type,
    S.BELNR  AS Document_Number,
    S.CPUDT  AS Entry_Date,
    S.BLDAT  AS Document_Date,
    S.BUDAT  AS Posting_Date,
    BK.BKTXT  AS Document_Header_Text,
    S.XBLNR  AS Reference,
    
    Ac.hsl AS Company_Code_Currency_Value, 
    Ac.wsl AS Document_Currency_Value, 
    Ac.GKONT AS Offsetting_Account, 
    BS.KOART AS Offsetting_Account_Type,
    S.SGTXT AS Text, 
    S.LIFNR AS Supplier, 
    L.NAME1 AS Vendor_Name, 
    S.WAERS AS Document_Currency_Key,
    S.EBELN AS Purchasing_Document,
    S.SHKZG AS Debit_Credit_Indicator, 
    S.UMSKZ AS Special_GL_Indicator, 
    BK.KURSF AS Exchange_Rate, 
    S.GJAHR AS Fiscal_Year,
    S.MONAT AS Posting_Period,
    S.ZLSPR AS Payment_Block,
	
    -- MSME Code Condition
    COALESCE(DM.TAXNUMXL, NULL) AS MSME_Code,

    -- MSME Status
    T13.GROUP_D_T AS MSME_Status,

    -- MSME Category Description (Only when language is English)
	TB2.TEXTSHORT AS MSME_Cat_Desc
	
FROM SAPABAP1.BSIK AS S 

-- Join with ACDOCA
LEFT JOIN SAPABAP1.ACDOCA AS AC
    ON S.BELNR = AC.BELNR
    AND S.GJAHR = AC.GJAHR
    AND S.BUKRS = AC.RBUKRS
    AND S.AUGDT = AC.AUGDT
    AND S.HKONT = AC.RACCT
    AND S.BUZEI = AC.BUZEI
    AND S.UMSKZ = AC.UMSKZ

-- Join with BSEG
LEFT JOIN SAPABAP1.BSEG AS BS
    ON S.BELNR = BS.BELNR
    AND S.GJAHR = BS.GJAHR
    AND S.BUKRS = BS.BUKRS
    AND S.AUGDT = BS.AUGDT
    AND S.HKONT = BS.HKONT
    AND S.BUZEI = BS.BUZEI

-- Join with BKPF
LEFT JOIN SAPABAP1.BKPF AS BK
    ON S.BELNR = BK.BELNR
    AND S.GJAHR = BK.GJAHR
    AND S.BUKRS = BK.BUKRS

-- Join with Profit Center Description
LEFT JOIN SAPABAP1.CEPCT AS C  
    ON AC.PRCTR = C.PRCTR 

-- Join with Vendor Name
LEFT JOIN SAPABAP1.LFA1 AS L  
    ON S.LIFNR = L.LIFNR  
    AND S.LIFNR <> ''''  

-- Join with G/L Account Description
LEFT JOIN SAPABAP1.SKAT AS K  
    ON S.HKONT = K.SAKNR  
    AND K.SPRAS = ''En''  


-- Join with MSME Code
LEFT JOIN SAPABAP1.DFKKBPTAXNUM AS DM
    ON S.LIFNR = DM.PARTNER
    AND DM.TAXTYPE = ''IN7'' 

-- Join with MSME Status
LEFT JOIN SAPABAP1.BP001 AS BP
    ON S.LIFNR = BP.PARTNER

LEFT JOIN SAPABAP1.TP13T AS T13
    ON BP.GROUP_D = T13.GROUP_D
	and T13.LANGU = ''E''   ---  language

-- Join with MSME Category Description
LEFT JOIN SAPABAP1.BUT000 AS BT0
    ON S.LIFNR = BT0.PARTNER


LEFT JOIN SAPABAP1.TB032T AS TB2
    ON BT0.LEGAL_ORG = TB2.LEGAL_ORG
    AND TB2.SPRAS = ''E'' -- Ensuring English descriptions
	
WHERE S.HKONT IN (
    ''0000253030'', ''0000253040'', ''0000130010'', ''0000130030'', 
    ''0000132340'', ''0000207300'', ''0000130020'', ''0000207200'', 
    ''0000104060'' 
)
AND S.UMSKZ <> ''F''  
AND S.BUDAT < CURRENT_DATE; 

-- Execute the SQL on a linked SAP server

';
EXEC (@SQL) AT sap_GHP;