  --TRIGGER:      An SQL trigger allows you to specify SQL actions that should be executed automatically when 
  --a specific event occurs in the database.
  --funciona solo cuando se emplean:
  /*
  -Insert
  -Delete
  -update
  */

  --Estructura de un trigger:

  /*create or alter trigger <nombre>
    on <tabla> for [insert, delete, update]
    as
    begin
    --cuerpo de trigger
    end;
  */

  --1.- Al insertar un detalle que actualice su stock de la tabla articulo además
  --verifique que tenga stock
  select * from fac_deta order by fac_num
  select * from Articulos
  insert into fac_deta values ('F0001','A0004',5) 
  CREATE OR ALTER TRIGGER TG01 --se crea un trigger
  ON FAC_DETA FOR INSERT --este es propio de la tabla fac_deta al realizar acciones de tipo insert
  AS
  BEGIN
  DECLARE @CODA CHAR(5), @CAN INT --declara las variables a utilizar
  DECLARE @STK INT
  SELECT @CODA=ART_COD , @CAN=ART_CAN FROM INSERTED --se selecciona las columnos de los valores que se quieren insertar
  SELECT @STK=ART_STK FROM ARTICULOS WHERE ART_COD=@CODA --se selecciona el art_stk de la tabla articulos cuyo art_cod sea igual al
  --art_cod a insertar
  IF @CAN>@STK --si la cantidad de art_Can a insertar es mayor al stock de ese articulo
  BEGIN
  PRINT 'STOCK NO DISPONIBLE SOLO HAY '+LTRIM(@STK) --se imprime que no esta disponible, se pone ltrim para eliminar los espacios en
  --blanco
  ROLLBACK --se elimina el procesor de insercion y se hace como que no paso nada
  END --termina el if
  ELSE --si no, si la cantidad es menor al stock actual
  BEGIN
    UPDATE Articulos SET ART_STK=ART_STK - @CAN WHERE ART_COD=@CODA --se actualiza la tabla articulos restando la fila de art_Stk donde
    -- el art_cod sea igual al inserta, le resta - la cantidad a inserta en el fac_Deta
    PRINT 'TABLA ACTUALIZADA EN ARTICULOS' --se envia un mensaje dando a entender que la tabla fue actualizada
  END 
  END --termina el trigger

  DELETE FROM FAC_DETA WHERE FAC_NUM='F0001' AND ART_COD='A0004'

  --2.- Al borrar un registro de la tabla detalle reponer el stock
  CREATE OR ALTER TRIGGER TG02 --se crea un trigger
  ON FAC_DETA FOR DELETE --en la tabla fac_Deta para acciones de eliminado
  AS
  BEGIN
    DECLARE @CODA CHAR(5), @CAN INT --se crea las variables
    SELECT @CODA=ART_COD , @CAN=ART_CAN FROM DELETED --se asigna a @coda el art_cod y a @can el art_Can de la funcion a eliminar
    UPDATE ARTICULOS SET ART_STK=ART_STK +@CAN WHERE ART_COD=@CODA --se actualiza la tabla articulos sumando al art_Stk la cantidad
    --de los articulos a eliminar donde el art_cod es igual al art_cod de la fila a eliminar
    PRINT 'STOCK ACTUALIZADO '  --se imprime el mensaje
  END; --termina el trigger
  SELECT * FROM ARTICULOS 
  SELECT * FROM FAC_DETA ORDER BY FAC_NUM
  DELETE FROM FAC_DETA WHERE FAC_NUM='F0001' AND ART_COD='A0004'

  SP_HELPTRIGGER FAC_DETA


  END


  --3.- No insertar vendedores con el mismo nombre
  SELECT * FROM VENDEDOR 
  DELETE FROM VENDEDOR  WHERE VEN_COD=17

  CREATE OR ALTER TRIGGER TG03
  ON VENDEDOR FOR INSERT --en la tabla vendedor para funciones de insercion
  AS
  BEGIN
  DECLARE @NOM VARCHAR(30) 
  SELECT @NOM=VEN_NOM FROM INSERTED --de la insercion, darle el ven_nom a la variable @nom
  IF (SELECT COUNT(*) FROM VENDEDOR WHERE VEN_NOM LIKE @NOM)>1 --si existe una fila dentro de la tabla vendedor con ese nombre
  BEGIN
    PRINT 'NOMBRE YA EXISTE' --imprimir que ya existe
    ROLLBACK --deshacer la insercion
  END; --termina el if
  END; --termina el trigger
  SELECT  * FROM VENDEDOR
  INSERT INTO VENDEDOR VALUES('Diaz Bacilio, Eva',GETDATE())


  -- impedir el borrado de una tabla o modificarlo
  CREATE OR ALTER TRIGGER TGALTERA
  ON DATABASE FOR DROP_TABLE,ALTER_TABLE --trigger a nivel de tabla para la eliminacion de estas o modificacion(ambas)
  AS
  BEGIN
  DECLARE @NOM VARCHAR(30)
  SET @NOM=DB_NAME() --se el envia a la variable @nom el nombre de la db a eliminar o modificar
  PRINT 'NO PUEDE ELIMINAR TABLAS DE LA BASE '+@NOM --se imprime que no se puede
  ROLLBACK --deshace la eliminacion/ modificacion
  END; --termina trigger
  DROP TABLE VENDEDOR
  SELECT * INTO PRUEBA FROM ARTICULOS;
  SELECT * FROM PRUEBA;
  DROP TABLE PRUEBA 


  --4.- NO actualizar el precio de los artículos en mas del 50%
  SELECT * FROM ARTICULOS 
  UPDATE ARTICULOS SET ART_PRE=105 WHERE ART_COD='A0001'
  CREATE OR ALTER TRIGGER TG_ACTUALIZA 
  ON ARTICULOS FOR UPDATE --trigger en articulos para acciones de actualizacion
  AS
  BEGIN
  DECLARE @CODA CHAR(5),@PRENEW MONEY,@PREOLD MONEY
  SELECT @PREOLD=ART_PRE ,@CODA=ART_COD FROM DELETED --a la variable del precio viejo se le asigna el precio a borrar(si, en update se usa
  --tanto deleted como insert, deleted engloba todo a borrar y intert todo los nuevo a insertar), y @coda su art_Cod
  SELECT @PRENEW=ART_PRE FROM INSERTED --este tiene el nuevo precio en la variable @prenew
  IF @PRENEW>1.5*@PREOLD --si el prenew es mayor al 50%
  BEGIN
    PRINT 'PALACIOS NO PUEDES MODIFICAR LOS PRECIOS EN MAS DE 50%'
  --RAISERROR('NO PUEDES MODIFICAR LOS PRECIOS EN MAS DE 50',16,1)
    ROLLBACK --no se realiza la actualizacion
  END 
  END --termina el trigger
  SELECT * FROM ARTICULOS


  --5.- NO insertar productos entre las 10-11
  PRINT DATEPART(HOUR,GETDATE())
  CREATE OR ALTER TRIGGER  TG_HORA
  ON ARTICULOS FOR INSERT
  AS
  BEGIN
    --datepart() tiene de primer parametro lo que queremos de un date, en este caso, la hora, en el segundo es la hora, en este caso,
    --getdate() le da la hora actual, datepart() solo los divide para sacar lo pedido
  IF DATEPART(HOUR, GETDATE())=10 --si la hora actual es igual a 10 se reliza la siguiente operacion:
    BEGIN
      PRINT 'NO INSERTAR PRODUCTOS A LAS 10 '
      ROLLBACK --no se hace la operacion
    END 
  END --termina el trigger
  SELECT * FROM ARTICULOS
  INSERT INTO ARTICULOS Values('A3843','FOLDER','UNI',5,13);


  --6 Al insertar una factura cabecera validar que exista el codigo de cliente y el
  --codigo de vendedor si no existe no se podra insertar
  CREATE OR ALTER TRIGGER TG_VALIDA
  ON FAC_CABE FOR INSERT 
  AS
  BEGIN
    DECLARE @CODC CHAR(5),@CODV INT
    SELECT @CODC=CLI_COD ,@CODV =VEN_COD FROM INSERTED --se le asigna a las variables el codigo del cliente y vendedor de los datps
    --a insertar
    IF (SELECT COUNT(*) FROM CLIENTES WHERE CLI_COD=@CODC)>0 AND 
      (SELECT COUNT(*) FROM VENDEDOR WHERE VEN_COD=@CODV)>0
      --si tanto el cliente como el vendedor si tienen un codigo existe en fac_Cabe se realiza:
    BEGIN
      PRINT 'FACTURA INSERTADA'
    END
    ELSE --si no
    BEGIN
      PRINT 'CODIGO DE CLIENTE O VENDEDOR NO EXISTE'
      ROLLBACK -- no se hace la insercion
    END
  END
  -- EXISTS(SELECT CLI_NOM FROM CLIENTES WHERE CLI_COD='C0005') 
  SELECT * FROM FAC_CABE


  --7.-Al eliminar una factura que automaticamente elimine su detalle
  SELECT * FROM FAC_CABE
  SELECT * FROM FAC_DETA WHERE FAC_NUM='F0002'

  CREATE OR ALTER TRIGGER DEL_FAC
  ON FAC_CABE FOR DELETE
  AS
  BEGIN
    DECLARE @FAC CHAR(5),@CODA CHAR(5),@CAN INT
    SELECT @FAC=FAC_NUM FROM DELETED --se obtiene el fac_num a eliminar y se ele asigna a la variable @fac
    DECLARE  CUR1 CURSOR FOR SELECT ART_COD,ART_CAN FROM FAC_DETA WHERE FAC_NUM=@FAC --se declara un cur1 que tiene todo los art_Cod,
    --y art_can de la tabla fac_Deta con el fac_num igual al que se quiere eliminar
    OPEN CUR1 --se habre el cursor
    FETCH CUR1 INTO @CODA,@CAN --se lee la primera fila y se envia los datos de cur1 en las variables
    WHILE @@FETCH_STATUS=0 --incia el bucle
    BEGIN
      DELETE FROM FAC_DETA WHERE FAC_NUM=@FAC AND ART_COD=@CODA --elimina las filas de fac_deta donde tenga el fac_num y el art_cod
      --de la factura a eliminar
      UPDATE ARTICULOS SET ART_STK=ART_STK+@CAN WHERE ART_COD=@CODA; --se actualiza la tabla articulos sumandole al art_stk la cantidad
      --que se va eliminando del articulo en cuestion de la factura
      FETCH CUR1 INTO @CODA,@CAN --pasa a la siguiente fila
    END --termina el bucle
    CLOSE CUR1 --se cierra el cur1
    DEALLOCATE CUR1 --se desasigna el cur1
  END;


--8.--Al eliminar un cliente verique si tiene facturas
--9.- Cada vez que realice una venta un vendedor , llevar el control de la cantidad de factura y el total importe(crear una tabla de 
--ventas previamente codv,cantidad y total