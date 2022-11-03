select vc.ID_Sucursal, vc.Gestion, vc.Semana, vc.NO_Sucursal, vc.Monto 'Monto de Venta', mtsuc.vmeta 'Meta de Venta',(vc.Monto/mtsuc.vmeta) 'Cumplimiento Ventas(%)' ,
mstcvpt.M_Trafico Trafico, mstcvpt.M_Conversion 'Conversion (%)' ,  tdtc.Cumplimiento 'Cumplimiento Trafico',tdtc.CumpliminetoCv 'Cumplimiento Conversion' ,vc.Facturas 'Cantidad de Facturas'
from
(select sum(Monto_real)*0.87 Monto, Gestion, COUNT(DISTINCT NroDocumento) Facturas, Semana, case
                when Sucursal = 'BR' then 1
                when Sucursal = 'CE' then 2
                when Sucursal = 'VI' then 4
                when Sucursal = 'PA' then 3
                when Sucursal = 'SD' then 5
                when Sucursal = 'TO' then 6
             
            end ID_Sucursal,
            case
                when Sucursal = 'BR' then 'BRASIL'
                when Sucursal = 'CE' then 'EQUIPETROL'
                when Sucursal = 'VI' then 'VILLA'
                when Sucursal = 'PA' then 'PAMPA'
                when Sucursal = 'SD' then 'SANTOS DUMONT'
                when Sucursal = 'TO' then 'TIENDA ONLINE'
             
            end NO_Sucursal
from TB_VISTA_COMERCIAL
where Semana=DATEPART(week,getdate()-21) and Gestion=DATEPART(year,getdate()-21) and Anulado=0
GROUP BY Sucursal, Gestion,Semana ) as vc
inner join
(select (sum(metaSuc)*0.87) vmeta, Id_sucursal, Gestion, Semana
from DM_MetasSucursalGeneral
where Gestion=DATEPART(year,getdate()-21) and Semana=DATEPART(week,getdate()-21)
group by Id_sucursal,Gestion,Semana) as mtsuc on vc.Gestion=mtsuc.Gestion and vc.Semana=mtsuc.Semana and vc.ID_Sucursal=mtsuc.Id_sucursal
inner join
(select M_IdSucursal, M_Trafico, M_Conversion, M_Gestion, M_Semana
from METAS_SEMANALES_TCVPT
where M_Semana=DATEPART(week,getdate()-21) and M_Gestion=DATEPART(year,getdate()-21)
group by M_IdSucursal, M_Trafico, M_Conversion, M_Gestion, M_Semana)
as mstcvpt on vc.Gestion=mstcvpt.M_Gestion and vc.Semana=mstcvpt.M_Semana and vc.ID_Sucursal=M_IdSucursal
inner join (select sum(CumplimientoConv) CumpliminetoCv, sum(Cumplimiento) Cumplimiento, semana,Gestion, cod_sucursal
from TA_DatosTraficoConversion where semana=DATEPART(week,getdate()-21) and Gestion=DATEPART(year,getdate()-21) group by semana, Gestion,cod_sucursal) as tdtc on tdtc.semana=vc.Semana and tdtc.Gestion=vc.Gestion and tdtc.cod_sucursal=vc.ID_Sucursal
order by Id_sucursal