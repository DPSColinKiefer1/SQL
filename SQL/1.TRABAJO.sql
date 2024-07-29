--1.- Mostrar todos los Clientes cuyo apellido com�n sea Diaz 
SELECT * FROM CLIENTES WHERE CLI_NOM LIKE '%diaz%';
 
--3.- Clientes cuyo apellido empiecen desde  D hasta la M 
SELECT *
FROM clientes
WHERE cli_nom LIKE '[D-H]%';

--4- Mostrar los cinco Clientes con mayor l�nea de cr�dito 
SELECT TOP 5 * FROM clientes ORDER BY cli_cre DESC ;

--5.- Mostrar la palabra Factura o Boleta en vez de la latra S o N en fac_igv
SELECT FAC_NUM, LEFT(FAC_FEC,10) FECHA, TIPO=CASE WHEN FAC_IGV='s' then 'Factura'
	else 'Boleta' end from fac_cabe;
--1ra forma; produce en "Mes DD AAAA"
SELECT FAC_NUM, convert(char(10),FAC_FEC,103) FECHA, TIPO=CASE WHEN FAC_IGV='s' then 'Factura'
	else 'Boleta' end from fac_cabe;
--2da forma; produce en "DD/MM/AAAA"

--6.- Mostrar  los tipos de tarjeta de acuerdo a l�nea de cr�dito
--Si es null sin tarjeta, menores a 1500 tarjeta simple, de 1500 a 4000 plateada
--Y mayor a 4000 dorada
 SELECT cli_cod, cli_nom, cli_cre, tipocre=case When cli_cre is null then 'vacio' 
										When cli_cre<=1500 then 'simple'
										when cli_cre<=4000 then 'plateada'
										else 'goku' end from clientes Order by tipocre desc;



--7.-Mostrar todas las ventas del vendedor 2 
SELECT FC.fac_num,FC.fac_fec,SUM(FD.art_can*A.art_pre)
FROM FAC_CABE FC JOIN FAC_DETA FD ON FC.fac_num = FD.fac_num
JOIN ARTICULOS A ON FD.art_cod = A.art_cod
WHERE FC.ven_cod = 2
GROUP BY FC.fac_num, FC.fac_fec
ORDER BY FC.fac_fec;

 

--8.- Mostrar que clientes no tienen e-mail 
 SELECT * FROM CLIENTES WHERE CLI_COR IS NULL;

--9.- Mostrar las facturas del cliente C0003 
 SELECT f.cli_cod, fac_fec, fac_num
FROM fac_cabe f
JOIN clientes c ON f.cli_cod = c.cli_cod
WHERE c.cli_cod = 'C0003';

--10.- Mostrar a todos los clientes cuya l�nea  de cr�dito se encuentre entre 1000 y 3000 
Select * from clientes where cli_cre between 1000 and 3000;
 
--11 Mostrar el precio m�s caro y barato de los art�culos 
SELECT MAX(art_pre) AS PrecioMasCaro, MIN(art_pre) AS PrecioMasBarato
FROM articulos;

--12.- Mostar a todos los clientes cuyo correo est�n en hotmail.com 
select * from clientes where cli_cor like '%hotmail.com';
 
--13.- Clientes que no tengan tel�fono 
select * from clientes where cli_tel is null;
 
--14.- Los art�culos cuyo precio este entre 150 y 450 
select * from articulos where art_pre between 150 and 450;
 
--15.- Art�culos cuyo nombre empiece con �M� y precio entre 50 y 200 
select * from articulos where art_nom like 'M%' and art_pre between 50 and 200;
 
--16.- Art�culos de stock valorizado entre 50 y 150 ordenados por nombre 
 select * from articulos where art_stk is not null and art_pre between 50 and 150 order by art_nom;

--empleando mas de una tabla: 
--17.- Por cada cliente mostrar sus facturas (codigo,nombre, Nfactura, fecha)
--Primera forma
select f.cli_cod, fac_fec, fac_num from fac_cabe f join clientes c on f.cli_cod=c.cli_cod order by c.cli_cod;
--Segunda forma
SELECT c.cli_cod, cli_nom, f.fac_num, CONVERT(char(10), f.fac_fec, 103)Fecha
FROM clientes c
JOIN fac_cabe f ON c.cli_cod = f.cli_cod
order by c.cli_cod;

--17.1- Por cada cliente mostrar sus facturas (codigo,nombre, Nfactura, fecha)
--y el nombre del vendedor
select c.cli_cod,cli_nom,fac_num,convert(char(10),fac_fec,103)fecha, ven_nom
from fac_cabe f,clientes c, vendedor v where f.cli_cod=c.cli_cod 
and f.ven_cod=v.ven_cod order by c.cli_cod;

--17.1- Por cada cliente mostrar sus facturas (codigo,nombre, Nfactura, fecha)
--y el nombre del vendedor. Todo dependiendo si esta en el a�o 2024 y el mes entre el 1 y 3
select c.cli_cod,cli_nom,fac_num,convert(char(10),fac_fec,103) fecha, ven_nom
from fac_cabe f join clientes c on f.cli_cod=c.cli_cod 
join vendedor v on f.ven_cod=v.ven_cod
where year(fac_fec)=2024 and month(fac_fec) between 1 and 3 order by c.cli_cod;

--mostrar el detalle de la factura F0002
--ART_COD, ART_NOM, ART_PRE, ART_CAN, TOTAL(SE CALCULA)
SELECT A.ART_COD, ART_PRE,ART_CAN,ART_CAN*ART_PRE AS TOTAL
FROM ARTICULOS A JOIN FAC_DETA D ON A.ART_COD=D.ART_COD
WHERE FAC_NUM='F0002';
 
--18.- Mostrar la cantidad vendida de cada articulo (Nombre_articulo y cantidad) 
select a.art_cod,art_nom,sum(art_can) as "Total cantidad"
from articulos a join fac_deta d on a.art_cod=d.art_cod
group by a.art_cod,art_nom;

--19.- Mostrar la cantidad facturas de cada cliente (nombre_cliente, telef y cantidad)
SELECT c.cli_cod, c.cli_nom, COUNT(f.fac_num) AS CantidadFacturas
FROM clientes c
JOIN fac_cabe f ON c.cli_cod = f.cli_cod
GROUP BY c.cli_cod, c.cli_nom;


--20.- Mostrar art�culos que no tengan ventas en el presente a�o (codigo, nombre del art�culo) 
  

--21 Mostrar la cantidad de facturas y el  Importe total por cada  Mes respecto al a�o 2023 
--      Mes, Cantidad y Total Importe
SELECT MONTH(FC.fac_fec)MES,COUNT(FC.fac_num)CANTIDAD_FACTURAS,SUM(FD.art_can * A.art_pre)IMPORTE
FROM FAC_CABE FC JOIN FAC_DETA FD ON FC.fac_num = FD.fac_num
JOIN ARTICULOS A ON FD.art_cod = A.art_cod
WHERE YEAR(FC.fac_fec) = 2023
GROUP BY MONTH(FC.fac_fec)
ORDER BY MES;

--22.-Mostrar  el monto de cada  factura(Nrofact, fecha, Importe_total)
SELECT FC.fac_num,FC.fac_fec,SUM(FD.art_can * A.art_pre) total
FROM fac_cabe FC JOIN fac_deta FD ON FC.fac_num = FD.fac_num
JOIN articulos A ON FD.art_cod = A.art_cod
GROUP BY FC.fac_num, FC.fac_fec;


--23.- Mostrar la cantidad de facturas realizado por cada empleado: 
--      Ven_cod, Ven_nom,  cantidad_facturas, Importe_total (totalizar estos dos ultimos) 

SELECT v.ven_nom,COUNT(FC.fac_num)CantFacturas,SUM(FD.art_can * A.art_pre)ImporteObtenido
FROM vendedor V JOIN fac_cabe FC ON V.ven_cod = FC.ven_cod
JOIN fac_deta FD ON FC.fac_num = FD.fac_num
JOIN articulos A ON FD.art_cod = A.art_cod
GROUP BY V.VEN_COD, Ven_nom;

--24.- Mostrar los tres articulos con mayor venta (c�digo, nombre y cantidad solo los tres primeros) 
SELECT TOP 3 A.ART_COD,ART_NOM,SUM(ART_CAN)TOTAL
FROM ARTICULOS A JOIN FAC_DETA D ON A.ART_COD=D.ART_COD
GROUP BY A.ART_COD,ART_NOM
ORDER BY TOTAL DESC;
 
--25.- El cliente que tenga la mayor cantidad de facturas 
select top 1 c.cli_cod, cli_nom, Count(f.fac_num) facturas
from clientes c
join fac_cabe f
on c.cli_cod=f.cli_cod
group by c.cli_cod, cli_nom order by facturas desc;

SELECT TOP 1 CLI_NOM, COUNT(*) CANTIDAD
FROM CLIENTES C JOIN FAC_CABE F ON C.cli_Cod=f.cli_cod
group by cli_nom order by 2 desc;
 
--26.- Mostrar el nro de factura y su fecha de la factura de mayor monto 
select top 1 f.fac_num,fac_Fec, sum(art_Can*art_pre)total
from articulos a join fac_deta d on a.art_cod=d.art_cod
join fac_cabe f on d.fac_num=f.fac_num
group by f.fac_num, fac_fec
order by total desc;
 
--27.- Los art�culos cuyo precio sea mayor al precio promedio 
select * from articulos where art_pre>(select avg(art_pre) from articulos);

--28.- Los clientes que no tengan facturas  en el presente a�o 
 select * from clientes where cli_cod not in (select cli_Cod from fac_cabe where
	year(fac_fec)=year(getdate()))

--29.- la cantidad de art�culos que no tienen ventas 
SELECT A.art_cod,A.art_nom
FROM ARTICULOS A
WHERE A.art_cod NOT IN (SELECT art_cod FROM FAC_DETA);

--30.- art�culos que no tienen ventas y cuyo precio es mayor a su stock

--31.- En que facturas y meses se vendieron �IMPRESORAS� 
 select f.fac_num,fac_fec
 from fac_cabe f join fac_deta d on f.fac_num=d.fac_num
 join articulos a on a.art_cod=d.art_cod
 where art_nom like '%impresora%'

--32.- Incrementar el precio de los art�culos en un 10% , si es que su precio es mayor a 100 
update articulos set art_pre=1.1*art_pre where art_pre>100;
 
--33.- Se desea obtener el porcentaje de las facturas emitidas por cada a�o 
SELECT YEAR(fac_fec)A�O,COUNT(*)FACTURAS, cOUNT(*) * 100.0 / (SELECT COUNT(*) FROM FAC_CABE)PORCENTAJE
FROM FAC_CABE GROUP BY YEAR(fac_fec);

--34.- Mostrar la cantidad de facturas por cada Mes respecto a un a�o (2020) 
SELECT 
    MONTH(fac_fec) AS MES,
    COUNT(*) AS CANTIDAD_FACTURAS
FROM 
    FAC_CABE
WHERE 
    YEAR(fac_fec) = 2020
GROUP BY 
    MONTH(fac_fec);


--35.- Inserte un vendedor�con�insert
