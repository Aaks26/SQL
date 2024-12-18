DECLARE @SQL NVARCHAR(MAX);
SET @SQL = N'

SELECT 
    H.BUKRS, 
    H.RFHA,
    H.SFGTYP,
    H.SGSART,
    H.KONTRH,
    H.RPORTB,
    H.WGSCHFT,
    H.DBLFZ,
    Z.DELFZ,
    H.ZUOND,
    H.REFER,
    H.MERKM,
    H.RCOMVALCL,
    H.FACILITYNR,
    H.RCNTR,
    P.RFHAZB,
    P.SFHAZBA,
    P.DGUEL_KP,
    P.SPAYRQ,
    P.SBEWEBE,
    P.SSTORNOBWG,
    P.BELNR,
    P.DZTERM,
    P.BZBETR,
    P.DBERVON,
    P.DBERBIS,
    P.ATAGE,
    P.ABASTAGE,
    P.PKOND,
    P.BBASIS
FROM SAPABAP1.VTBFHA AS H
left outer join SAPABAP1.VTBFHAPO AS P
    ON H.BUKRS = P.BUKRS
   AND H.RFHA  = P.RFHA
left outer join SAPABAP1.VTBFHAZU AS Z
	on z.bukrs = P.BUKRS
    and Z.RFHA = P.RFHA
	and z.rfhazu = p.rfhazu
	and z.dcrdat = p.dcrdat
	and z.tcrtim = p.tcrtim
	
WHERE P.SBEWEBE <> 0;

';



-- Execute the SQL on a linked server  

EXEC (@SQL) AT sap_GHP;

 

 

 
