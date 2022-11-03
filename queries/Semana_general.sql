select tp.Gestion, tp.Semana, vt.VENTATOTAL 'Monto Vendido', mt.metaGeneral 'Meta Ventas', (vt.VENTATOTAL)/(MT.metaGeneral)*100 '% Logrado',
	tp.Credito 'Ventas al Credito', tp.Contado 'Ventas al Contado', vt.VPTGENERAL 'VTP Logrado', MTTCVPT.VPT_META 'VTP META', ((vt.VPTGENERAL)/(MTTCVPT.VPT_META)) '% VTP Logrado', vptmet.UPT 'UPT Logrado'
from (select sum(Monto_real)*0.87 Credito, tb1.Contado Contado, Gestion, Semana
	from TB_VISTA_COMERCIAL tb2,
		(select sum(Monto_real)*0.87 Contado
		from TB_VISTA_COMERCIAL
		where Gestion=DATEPART(year,getdate()-21) and Semana=DATEPART(week,getdate()-21) and Anulado=0 and TipoVenta not like 'Crédito') as tb1
	where Gestion=DATEPART(year,getdate()-21) and Semana=DATEPART(week,getdate()-21) and Anulado=0 and TipoVenta not like 'Contado'
	group by tb1.Contado,Gestion,Semana) as tp inner join (SELECT sum(Monto_real)*0.87 VENTATOTAL, (sum(Monto_real)*0.87  /COUNT(DISTINCT NroDocumento) ) VPTGENERAL, Gestion , Semana
	from TB_VISTA_COMERCIAL
	where Gestion=DATEPART(year,getdate()-21) and Semana=DATEPART(week,getdate()-21) and Anulado=0
	group by Gestion, Semana) as VT on tp.Gestion=vt.Gestion and tp.Semana=VT.Semana
	INNER JOIN
	(select sum(Meta)*0.87  metaGeneral, Gestion, Semana
	from DM_MetasLineaGeneral
	where Gestion=DATEPART(year,getdate()-21) and Semana=DATEPART(week,getdate()-21)
	group by Semana,Gestion) AS mt on mt.Gestion=vt.Gestion and mt.Semana=VT.Semana
	inner join
	(select sum(M_VPT_con_TO) VPT_META, M_Gestion_g, semana
	from METAS_SEMANALES_TCVPT_GLOBAL
	where M_Gestion_g=DATEPART(year,getdate()-21) and semana=DATEPART(week,getdate()-21)
	group by M_Gestion_g, semana) AS MTTCVPT
	inner join
	(select
		(sum(vc.Cant)/sum( vc.doc)) UPT,
		vc.Gestion ,
		vc.Semana
	from
		(select v1.Gestion, v1.Semana,
			sum(v1.Cantidad) Cant,
			COUNT (DISTINCT v1.NroDocumento ) as doc
		from TB_VISTA_COMERCIAL  v1
		where Gestion =DATEPART(year,getdate()-21) and semana=DATEPART(week,getdate()-21) and Anulado = 0
		group by v1.gestion ,Semana,Cantidad) as vc
	group by vc.Gestion,vc.Semana
		) as vptmet on vptmet.Gestion=MTTCVPT.M_Gestion_g and vptmet.Semana=MTTCVPT.semana
	on mt.Gestion=MTTCVPT.M_Gestion_g and mt.Semana=MTTCVPT.semana
group by tp.Gestion, tp.Semana, tp.Contado,tp.Credito,vt.VENTATOTAL,vt.VPTGENERAL, mt.metaGeneral, MTTCVPT.VPT_META, vptmet.UPT
 