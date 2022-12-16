-- select [Fecha solicitud de préstamo],
--     [Crédito N°] as 'DocNum',
--     [ID cliente] as 'Codigo',
--     cuotas as Cuota,
--     [valor cuota USD] + case when [Mora USD] is null then 0 end as 'MontoCancelado',
--     MAX([Fecha Pago]) as 'FechaUltimoPago'
-- from VW_CREDITO_EXTRACTO_PAGOS vw
-- where [ID cliente] = '1971921'
--     and [Crédito N°] = 210509915
--     AND [Fecha Pago] IS NOT NULL
--     and [Fecha Pago] =(
--         select max([Fecha Pago])
--     from VW_CREDITO_EXTRACTO_PAGOS vw1
--     where vw.[Crédito N°] = vw1.[Crédito N°]
--     )
-- group by [Fecha solicitud de préstamo],
--     [Crédito N°],
--     [ID cliente],
-- (cuotas),
--     [Valor cuota USD],
--     [Mora USD],
--     [Fecha Pago]
DECLARE @DocNum int,
    @Nombre NVARCHAR(50),
    @Codigo int
DECLARE Customer_Cursor CURSOR FOR
select DocNum,
    Nombre,
    Código as Codigo
from [Base_para_medir_efectividad_08-12-22]
where DocNum is not null OPEN Customer_Cursor FETCH NEXT
FROM Customer_Cursor INTO @DocNum,
    @Nombre,
    @Codigo WHILE @@FETCH_STATUS = 0 BEGIN
DECLARE @Cuota NUMERIC(18, 5),
    @MontoCancelado NUMERIC(18, 5),
    @FechaUltimoPago DATE
select @Cuota = Cuota,
    @MontoCancelado = MontoCancelado,
    @FechaUltimoPago = FechaUltimoPago
from (
        select TOP 1 [Fecha solicitud de préstamo],
            [Crédito N°] as 'DocNum',
            [ID cliente] as 'Codigo',
            cuotas as Cuota,
            ISNULL([Valor cuota USD], 0) + ISNULL([Mora USD], 0) as 'MontoCancelado',
            MAX([Fecha Pago]) as 'FechaUltimoPago'
        from VW_CREDITO_EXTRACTO_PAGOS vw
        where [ID cliente] = CONVERT(nvarchar(50), @Codigo)
            and [Crédito N°] = @DocNum
            AND [Fecha Pago] IS NOT NULL
            and [Fecha Pago] =(
                select max([Fecha Pago])
                from VW_CREDITO_EXTRACTO_PAGOS vw1
                where vw.[Crédito N°] = vw1.[Crédito N°]
            )
        group by [Fecha solicitud de préstamo],
            [Crédito N°],
            [ID cliente],
            (cuotas),
            [Valor cuota USD],
            [Mora USD],
            [Fecha Pago]
    ) as query
UPDATE [Base_para_medir_efectividad_08-12-22]
SET Cuota_Pagada = @Cuota,
    Monto_Cancelado_cuota_mora = @MontoCancelado,
    Fecha_último_pago = @FechaUltimoPago
WHERE Código = @Codigo
    and DocNum = @DocNum -- RAISERROR(@MessageOutput,0,1) WITH NOWAIT
    FETCH NEXT
FROM Customer_Cursor INTO @DocNum,
    @Nombre,
    @Codigo
END CLOSE Customer_Cursor DEALLOCATE Customer_Cursor