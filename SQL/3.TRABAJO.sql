--aumentar la linea de credito de acuerdo a su rango <=1000 en un 15% <1000 y <=2500 20%, >2500 30%
--al final muestre cuantas personas no tiene linea de credito
create or alter procedure spact_cre --sea crea un procedmiento sin parametros, osea, solo se ejecuta
AS 
BEGIN   --comienza
DECLARE cur1 cursor for select cli_cod, cli_cre from clientes --crea un cursor de nombre cur1 que
--selecciona los campos de cli_cod o cli_cre para para usarlos
/*Un cursor en SQL es una herramienta que permite realizar operaciones sobre un conjunto de filas, 
una a una, de manera controlada. A diferencia de una consulta SQL tradicional, que opera sobre todas 
las filas a la vez, un cursor permite procesar filas individualmente, lo cual es útil en ciertos
escenarios donde se necesita un control más granular sobre los datos. */
DECLARE @cod char(5), @cre numeric(8,1) --crea variables que almacenaran el codigo obtenido y creditos
DECLARE @con int --variable para contar el número de clientes sin línea de crédito
set @con=0 --lo incializa con 0 de valor
open cur1 --abre el cursor para comenzar a trabajar con el
fetch cur1 into @cod, @cre --asigna los valores seleccionados por el cursor y se los asigna a las
--variable para ir usandolos fila por fila de cada variable recien asignada
while @@FETCH_STATUS=0 --MIENTRAS EL CURSOR TENGA DATOS, osea, mientras que no de error, se ejecutara
--esta operacion. El que tenga datos quiere decir que sigue habiendo fila
begin --comienza
    if @cre is null --si el usuario de la fila no tiene credito o es nulo su fila, entonces
        set @con=@con+1 --se le envia a la variable que cuenta uno mas, asi con todos los que no tengan
    else if @cre <=1000 --si no, si la linea de credito que tiene esa fila es menor o igual a 1000
        update clientes set cli_cre=cli_Cre*1.15 where cli_Cod=@cod --se le actualiza la tabla clientes
        --enviandole a la columna cli_Cre de esa fila un incremento del 15% respecto a su valor original
        --siempre y cuando su cli_Cod sea igual al de la variable @cod
    else if @cre <=2500
        update clientes set cli_cre=cli_Cre*1.2 where cli_Cod=@cod
    else
        update clientes set cli_cre=cli_Cre*1.3 where cli_Cod=@cod
    fetch cur1 into @cod, @cre --esta linea obtiene la siguiente fila del cur1, esto se repite hasta
END --terminar el while, osea, hasta que no hay filas
    print 'numero de registos sin incremento'+ltrim(@con)
-- Imprime el número de clientes que no tienen línea de crédito, eliminando los espacios en blanco a 
--la izquierda del valor de @con
    close cur1 --se cierra el cursor una vez ya obtenido y hecho el proceso
    deallocate cur1 -- Desasigna el cursor cur1 para liberar los recursos
end --termina el procedmiento

execute spact_cre --ejecuta el procedimiento
select * from clientes

--realizar la boleta vista en la tarea de "ejercicios_cursores" de la semana 11
create or alter procedure sp_cur1(@fac char(5)) --se ingresa una factura como paratro para el procedure
AS
begin
DECLARE @nomc varchar(30),@fec date --se crea variables para almacenar el nombre del clientes y la fecha
DECLARE @nomar varchar(30),@pre decimal(8,1),@can int,@tot decimal(8,1) --nombre del articulo, su precio
--y el total de todo
if(select count(*) from fac_cabe where fac_num=@fac)>0 --si existe boleta con ese numero entonces
begin --comienza un procedimiento
    select @nomc=cli_nom,@fec=fac_fec from fac_cabe f join clientes c --se le asigna a la variable 
    --@nomc los datos de la columna cli_nom y a @ec los datos de la columna fac_Fec
    --de las tablas fac_Fec y clientes
    on f.cli_Cod=c.cli_Cod where fac_num=@fac --si vincula con el cli_cod de ambas donde el fac_num es
    --igual al del parametro @fac
    print 'cliente :'+@nomc --se imprimere el nombre del cliente con esa factura
    print 'fecha de factura '+convert(char(12),@fec) --la fecha de facturacion convertidad en dd/mm/aa
    declare cur2 cursor for select art_nom,art_pre,art_Can,art_pre*art_Can --se crea un cursor que tiene
    --dentro las columnas art_nom,art_pre,art_Can,art_pre*art_Can
    from articulos a join fac_deta d on a.art_cod=d.art_cod --de 2 tablas con art_cod en comun
    where fac_num=@fac; --donde el fac_num es igual al @fac
    print 'descripcion      precio      cantidad        total' 
    print '=================================================='
    open cur2 --se habre el cur2
    fetch cur2 into @nomar,@pre,@can,@tot --se mete a las variables las columnas seleccionadas para el cur2
    while @@FETCH_STATUS=0 --mientras que haya filas para usar
        begin
        print convert(char(25),@nomar)+convert(char(10),@pre)+convert(char(10),@can)+
        convert(char(10),@tot)
        --imprime en caracter todas las filas una por una de las variables con el valor necesitado
        fetch cur2 into @nomar,@pre,@can,@tot --pasa a la siguiente fila y continua el bucle
    end --termina el bucle
    close cur2 --cierre el cur2
    deallocate cur2 --lo desasigna
end --termina el if
else --si no existe factura con el valor del @fac
    print'no existe factura' --se imprime
end;--termina el procedimiento

exec sp_cur1 'F0002'


create or alter procedure sp_cur1(@fac char(5))--crea un procedimiento con un parametro para facturas
as
begin
declare @nomc varchar(30),@fec date,@cigv char(1) --declara variables para almacenar el nombre del cli
declare @nomar varchar(30),@pre decimal(8,1),@can int,@tot decimal(8,1)--y demas
DECLARE @subtot money,@igv money,@total money
if (select count(*) from fac_cabe where fac_num=@fac)>0 --si existe una factura con ese nombre se hace:
begin
    select @nomc=cli_nom ,@fec=fac_fec,@cigv=fac_igv from fac_cabe f join clientes c --se da a las
--variables las columnas de donde sacar los datos a usar de ambas tablas que se unen con cli_cod en
--comun donde el fac_num sea igual al del parametro
    on f.cli_cod=c.cli_cod where fac_num=@fac
    print 'cliente  :'+@nomc --se imprime el nombre del cliente almacenado
    print ' fecha de factura '+convert(char(12) , @fec) --la fecha de la factura almacenado
    set @subtot=0 --se incializa el subtotal con un valor de 0 para comenzar
    declare cur2 cursor for select art_nom,art_pre,art_can, --se declara el cur2 con datos de las colum
    --del art_nom,art_pre,art_can y art_pre*art_can donde el fac_num sea igual al del parametro
    art_pre*art_can from articulos a join fac_deta d on a.art_cod=d.art_cod
    where fac_num=@fac; 
    print 'descripcion     precio   cantidad    total'
    print '========================================'
    open cur2 --se abre el cur2
    fetch cur2 into @nomar,@pre,@can,@tot --se lee la primera fila del cur2 que envia los valores del cur2 en las variables
    while @@FETCH_STATUS=0
    begin
        print convert(char(25),@nomar)+convert(char(10),@pre)+convert(char(10),@can)+convert(char(10) ,@tot)
        --imprime fila por fila los datos convertidos en caracteres de cada variable con datos en especificos
        fetch cur2 into @nomar,@pre,@can,@tot --recorre las siguiente fila
        set @subtot=@subtot+@tot --suma el valor del @tot de turno a la variable @subtot
    end --se termina el procedmiento del cursor
    close cur2 --se cierra el cursor
    deallocate cur2 --se desasigna el cur2
    if @cigv='S' --si el igv de la factura es igual 'S' se hace:
        set @igv=@subtot*0.18 --se multiplica el subtotal para tener el 18% de el que sera el igv a pagar
    else --si no
        set @igv=0 --el igv sera igual a 0, no paga nada
    set @total=@subtot+@igv --se envia a la variable @total la suma del igv y del subtotal en conjunto
    print '========================='
    print 'subtotal factura '+ltrim(@subtotal) --lo imprime con ltrim para que no de espacios en blanco
    print 'igv 18% '+ltrim(@igv) 
    print 'total factura '+ltrim(@total)
end --termina el if principal
else --si no hay factura:
  print 'no existe factura'
end; --termina el procedmiento creado

exec sp_cur1 'F0002'


SET DATEFORMAT DMY; --se usa para especificar el formato d fecha a usar, DMY es eñ formato dia/mes/año
GO
CREATE OR ALTER PROCEDURE SP_REP1(@FEC DATE) --se crea un procedimiento que recoge un fecha
AS
BEGIN
DECLARE CUR1 CURSOR FOR SELECT C.CLI_COD,CLI_NOM FROM CLIENTES C --se crea un cursor con los datos de las columnas cli_cod y cli_nom
JOIN FAC_CABE F ON C.CLI_COD=F.CLI_COD WHERE FAC_FEC>=@FEC; --de la tabla fac_Cabe y clientes unidos por sus cli_cod donde la fecha
--es igual o mayor a la entregada
DECLARE @CODC CHAR(5),@NOMC VARCHAR(30); --se crea variables que almacenara los datos a usar
DECLARE @FAC CHAR(5),@FECHA DATE,@TOTAL MONEY,@TOTG MONEY;
OPEN CUR1 --se abre el cursor
FETCH CUR1 INTO @CODC,@NOMC --se incia mandando los datos de las columnas del cur1 en las variables que las copiaran
WHILE @@FETCH_STATUS=0  --y va leendo linea por linea hasta la ultima de ellas
BEGIN
    PRINT 'CLIENTE '+@NOMC --imprime el los clientes que tienen facturas en esa fecha o posterior
    DECLARE CUR2 CURSOR FOR SELECT F.FAC_NUM, FAC_FEC,SUM(ART_PRE*ART_CAN) TOTAL --se crea un nuevo cursor que tiene las columnas
    --FAC_NUM, FAC_FEC,SUM(ART_PRE*ART_CAN) TOTAL de la tabla fac_cabe y la fac_Deta con el fac_num uniendolas
    FROM FAC_CABE F JOIN FAC_DETA D ON F.FAC_NUM=D.FAC_NUM JOIN ARTICULOS A --al igual que la tabla articulos con art_cod
    ON A.ART_COD=D.ART_COD WHERE CLI_COD=@CODC GROUP BY F.FAC_NUM, FAC_FEC ; --columnas donde el cli_cod es igual al que esta leendo el
    --cur1 en la actual fila.
    PRINT 'FACTURA   FECHA    TOTAL'
    PRINT '========================='
    SET @TOTG=0 --se le envia a la variable totg un valor de 0 para incializarlo
    OPEN CUR2 --se abre el cur2
    FETCH CUR2 INTO @FAC,@FECHA,@TOTAL --se copia los valores de las columnas en las variables nuevas
    WHILE @@FETCH_STATUS=0 --inicia el bucle 2
    BEGIN
        PRINT CONVERT(CHAR(10),@FAC)+CONVERT(CHAR(15),@FECHA)+CONVERT(CHAR(10),@TOTAL) --impre los datos fila por fila
        SET @TOTG=@TOTG+@TOTAL
        FETCH CUR2 INTO @FAC,@FECHA,@TOTAL
    END
    PRINT 'TOTAL COMPRA '+LTRIM(@TOTG)
    PRINT '---------------------------'
        CLOSE CUR2
    DEALLOCATE CUR2
    FETCH CUR1 INTO @CODC,@NOMC
END;
 CLOSE CUR1;
 DEALLOCATE CUR1;
END;
SET DATEFORMAT DMY
EXEC SP_REP1 '12/05/2023'


SELECT * FROM FAC_CABE



CREATE OR ALTER PROCEDURE SP_REPALU(@NOME VARCHAR(30)) --SE CREA EL PROCEDIMIENTO CON UN PARAMETRO QUE SERA UN NOMBRE
AS
BEGIN
DECLARE CUR1 CURSOR FOR SELECT IDALUMNO,APELUMNO+','+NOMALUMNO NOMBRE --SE CREA EL CUR1 CON DATOS DE LAS COLUMNAS IDALUMNO,
-- y APELUMNO+','+NOMALUMNO NOMBRE
FROM ALUMNO A JOIN ESPECIALIDAD E ON A.IDESP=E.IDESP WHERE NOMESP LIKE '%'+TRIM(@NOME)+'%'; --estos nombres tambien deben estar en
--la tabla especialidad siempre y cuando el nombre de la especialidad tenga en alguna parte el parametro que escribimos
DECLARE @CODA CHAR(5),@NOMA VARCHAR(30) --se crea las variables a utilizar
OPEN CUR1 --se abre el cur1
FETCH CUR1 INTO @CODA,@NOMA; --se lee la primera fila y se copia los valores de cur1 en las variables
WHILE @@FETCH_STATUS=0 --inicia el bucle
BEGIN
    PRINT @CODA+' '+@NOMA --se imprime el primer codigo del alumno y su nombre
    FETCH CUR1 INTO @CODA,@NOMA; --pasa a la siguiente fila
END --termina el bucle
CLOSE CUR1 -- se cierra el cursor
DEALLOCATE CUR1 --se desasigna
END; --termina el procedimiento
EXEC SP_REPALU 'eduta'