DECLARE @SQL NVARCHAR(MAX);

SET @SQL = N'
SELECT 
    S.BUKRS  AS Company_Code,
    S.BELNR  AS Document_Number, 
    S.BLART  AS Document_Type, 
    S.BLDAT  AS Document_Date, 
    S.CPUDT  AS Entry_Date, 
    S.BUDAT  AS Posting_Date, 
    S.XBLNR  AS Reference, 
    S.GJAHR  AS Fiscal_Year, 
    S.MONAT  AS Posting_Period, 
    S.WAERS  AS Document_Currency_Key, 
    S.PRCTR  AS Profit_Center, 
    S.HKONT  AS GL_Account, 
    
    -- Apply CASE condition for Debit/Credit adjustment
    CASE 
        WHEN S.SHKZG = ''H'' THEN -S.WRBTR  
        ELSE S.WRBTR  
    END AS Company_Code_Currency_Value, 

    S.AUGBL  AS Offsetting_Account, 
    S.LIFNR  AS Supplier, 
    S.SGTXT  AS Text, 
    S.SHKZG  AS Debit_Credit_Indicator, 
    S.UMSKZ  AS Special_GL_Indicator, 

    -- Apply CASE condition for Debit/Credit adjustment
    CASE 
        WHEN S.SHKZG = ''H'' THEN -S.DMBTR  
        ELSE S.DMBTR  
    END AS Document_Currency_Value, 

    S.EBELN  AS Purchasing_Document,
    
    -- Profit Center Long Text (From CEPCT)
    C.LTEXT  AS Profit_Center_Long_Text, 

    -- Vendor Account Name (From LFA1)
    L.NAME1  AS Vendor_Name, 

    -- G/L Account Short Text (From SKAT)
    K.TXT50  AS GL_Account_Short_Text  

FROM SAPABAP1.BSIK AS S  

-- Left Join for Profit Center Description
LEFT JOIN SAPABAP1.CEPCT AS C  
    ON S.PRCTR = C.PRCTR  

-- Left Join for Vendor Name
LEFT JOIN SAPABAP1.LFA1 AS L  
    ON S.LIFNR = L.LIFNR  
    AND S.LIFNR <> ''''  -- Ensures vendor exists

-- Left Join for G/L Account Description
LEFT JOIN SAPABAP1.SKAT AS K  
    ON S.HKONT = K.SAKNR  
    AND K.SPRAS = ''EN''  -- Filter for English descriptions

WHERE S.HKONT IN (
    ''0000253030'', ''0000253040'', ''0000130010'', ''0000130030'', 
    ''0000132340'', ''0000207300'', ''0000130020'', ''0000207200'', 
    ''0000104060'' 
)
AND S.UMSKZ <> ''F''  -- Excluding Special G/L Indicator 
AND S.BUDAT < CURRENT_DATE; -- Ensuring Posting Date is greater than the system date
';

-- Execute the SQL on a linked SAP server
EXEC (@SQL) AT sap_GHP;
