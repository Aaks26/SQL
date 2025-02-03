DECLARE @SQL NVARCHAR(MAX);

SET @SQL = N'
SELECT  
-----------------------------------------------------------------------------------------------------------
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
	bk.BKTXT  AS Document_Header_Text,
    S.XBLNR  AS Reference,
    
    -- Apply CASE condition for Debit/Credit adjustment
	 Ac.hsl as Company_Code_Currency_Value, 

    -- Apply CASE condition for Debit/Credit adjustment
	ac.wsl AS Document_Currency_Value, 

    ac.GKONT  AS Offsetting_Account, 
    BS.KOART  AS Offsetting_Account_Type,
    S.SGTXT  AS Text, 
    S.LIFNR  AS Supplier, 
    L.NAME1  AS Vendor_Name, 
    S.WAERS  AS Document_Currency_Key,
    S.EBELN  AS Purchasing_Document,
    S.SHKZG  AS Debit_Credit_Indicator, 
    S.UMSKZ  AS Special_GL_Indicator, 
    bk.KURSF  AS Exchange_Rate, 
    S.GJAHR  AS Fiscal_Year,
    S.MONAT  AS Posting_Period
-----------------------------------------------------------------------------------------------------------------------

FROM SAPABAP1.BSIK AS S 
----------------------------- Left join ACDOCA  ------------------------------------------------------------------------
LEFT JOIN SAPABAP1.ACDOCA AS AC
    ON S.BELNR = AC.BELNR
    AND S.GJAHR = AC.GJAHR
    AND S.BUKRS = AC.RBUKRS
    AND S.AUGDT = AC.AUGDT
    AND S.HKONT = AC.RACCT
    AND S.BUZEI = AC.BUZEI
    AND S.UMSKZ = AC.UMSKZ
-----------------------------------------------------------------------------------------------------------
-------------------------- left join for the BSEG ----------------------------------------------------------
left  join SAPABAP1.bseg as BS
on s.belnr = BS.belnr
and S.gjahr = bs.gjahr
and S.bukrs = BS.bukrs
and S.augdt = BS.augdt
and S.hkont = BS.hkont
and S.buzei = BS.buzei
-------------------------------------------------------------------------------------------------------------
-----------------------------left join BKPF -----------------------------------------------------------------
left join  SAPABAP1.BKPF as BK
on s.belnr = Bk.belnr
and S.gjahr = bk.gjahr
and S.bukrs = Bk.bukrs
----------------------------------------------------------------------------------------------------------------
------------------- Left Join for Profit Center Description ----------------------------------------------------
LEFT JOIN SAPABAP1.CEPCT AS C  
    ON ac.PRCTR = C.PRCTR 
-----------------------------------------------------------------------------------------------------------------
---------------- -- Left Join for Vendor Name---------------------------------------------------------------------
LEFT JOIN SAPABAP1.LFA1 AS L  
    ON S.LIFNR = L.LIFNR  
    AND S.LIFNR <> ''''  -- Ensures vendor exists
-------------------------------------------------------------------------------------------------------------------
---------------------------- -- Left Join for G/L Account Description ----------------------------------------------
left  JOIN SAPABAP1.SKAt AS K  
    ON S.HKONT = K.SAKNR  
    AND K.SPRAS = ''En''  -- Filter for English descriptions
----------------------------------------------------------------------------------------------------------------------
WHERE S.HKONT IN (
    ''0000253030'', ''0000253040'', ''0000130010'', ''0000130030'', 
    ''0000132340'', ''0000207300'', ''0000130020'', ''0000207200'', 
    ''0000104060'' 
)
AND S.UMSKZ <> ''F''  -- Excluding Special G/L Indicator 
AND S.BUDAT < CURRENT_DATE; -- Ensuring Posting Date is less than the system date
';

-- Execute the SQL on a linked SAP server
EXEC (@SQL) AT sap_GHP;