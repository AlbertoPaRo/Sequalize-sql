select dm.Gestion, dm.Semana, case
                when dm.Id_linea = 1 then 'CELULARES'
                when dm.Id_linea = 2 then 'COMPUTO'
                when dm.Id_linea = 3 then 'ELECTRONICA'
                when dm.Id_linea = 4 then 'HOGAR'
                when dm.Id_linea = 5 then 'LINEA BLANCA'
                when dm.Id_linea = 6 then 'OTRAS LINEAS'
				when dm.Id_linea = 7 then 'SERVICIOS'
				when dm.Id_linea = 8 then 'AUTOMOTRIZ'
             
            end Super_Linea, tbvc.monto_vendido, dm.Meta, (((tbvc.monto_vendido)/(dm.Meta))*100) '% Cumplimiento'
from (
select Gestion, Semana, Id_linea, sum(Meta)*0.87 Meta
	from DM_MetasLineaGeneral
	where  Gestion=DATEPART(year,getdate()-28) and Semana=DATEPART(week,getdate()-28)
	group by Id_linea, Semana, Gestion) as dm inner join
	(select sum(Monto_real)*0.87 monto_vendido, ID_super_linea, Gestion, Semana 
	from TB_VISTA_COMERCIAL
	where Gestion=DATEPART(year,getdate()-28) and Semana=DATEPART(week,getdate()-28) and Anulado=0
	group by ID_super_linea, Gestion, Semana) as tbvc on dm.Gestion=tbvc.Gestion and dm.Semana=tbvc.Semana and tbvc.ID_super_linea=dm.Id_linea
	
