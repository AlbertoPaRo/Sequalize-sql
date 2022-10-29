select dm.Gestion, dm.Semana, case
                when dm.Id_linea = 1 then 'AUTOMOTRIZ'
                when dm.Id_linea = 2 then 'CELULARES'
                when dm.Id_linea = 3 then 'COMPUTO'
                when dm.Id_linea = 4 then 'ELECTRONICA'
                when dm.Id_linea = 5 then 'HOGAR'
                when dm.Id_linea = 6 then 'LINEA BLANCA'
				when dm.Id_linea = 7 then 'OTRAS LINEAS'
				when dm.Id_linea = 8 then 'SERVICIOS'
             
            end Super_Linea, tbvc.monto_vendido, dm.Meta, ((tbvc.monto_vendido)/(dm.Meta)) Cumplimiento
from (
select Gestion, Semana, Id_linea, sum(Meta)*0.87 Meta
	from DM_MetasLineaGeneral
	where  Gestion=DATEPART(year,getdate()-14) and Semana=DATEPART(week,getdate()-14)
	group by Id_linea, Semana, Gestion) as dm inner join
	(select sum(Monto_real)*0.87 monto_vendido, ID_super_linea, Gestion, Semana
	from TB_VISTA_COMERCIAL
	where Gestion=DATEPART(year,getdate()-14) and Semana=DATEPART(week,getdate()-14)
	group by ID_super_linea, Gestion, Semana) as tbvc on dm.Gestion=tbvc.Gestion and dm.Semana=tbvc.Semana and tbvc.ID_super_linea=dm.Id_linea
	
