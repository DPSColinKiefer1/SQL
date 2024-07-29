--1.- Pasando un numero de cuenta devolver el numero de movimiento
create or alter function fmovin(@cta char(6))
returns int
as
begin
declare @ct int
select @ct=isnull(max(nro_mov),0)+1 from movimiento where
nro_cta=@cta;
return @ct
end
print dbo.fmovin('100001')
--2.- Generar el numero de cuenta , si la tabla esta vacia generalo a partir de
--100001
select * from cuenta
create or alter function fcuenta()
returns char(6)
as
begin 
declare @ct int
select @ct=isnull(max(nro_cta),100000)+1 from cuenta;
return ltrim(@ct)
end
print dbo.fcuenta()
--3.- Pasando su numero de cuenta devolver su saldo
create or alter function fsaldo(@cta char(6))
returns money
as
begin
declare @sal money
if(select count(*) from cuenta where nro_cta=@cta)=0
	begin
	set @sal=0
	end
else
	select @sal=saldo_cta from cuenta where nro_cta=@cta;
	return @sal
	end
print dbo.fsaldo('101002')
--pasando una cuenta devolver el ultimo registro de movimiento
create or alter function fmovincon(@cta	char(6))
returns table
as
return
select top 1 nro_mov,tipo_mov,monto_mov from movimiento
where nro_cta=@cta order by nro_mov desc
--probar
select * from dbo.fmovincon('100001')
--4.- Generar el código código del Cliente a partir de C0001
--5.- Pasando el apellido y nombre del cliente generar su correo electrónico ed utp
--Por ejemplo :Donayre Castillo, Juan su correo :jdonayrec@utp.edu.pe
--El primer carácter es del nombre el segundo es el paterno y el ultimo el primer
--carácter del materno
--Los procedimientos almacenados:
--6.-adicionar nuevas cuentas pasando un código de cliente , el tipo de moneda y el
--saldo, al insertar una cuenta se genera por defecto el primer movimiento como
--deposito ,con respecto al saldo de apertura y la fecha del sistema
--7.- Pasando un numero de cuenta que muestre todas sus operaciones de dicha
--cuenta y mostrar de forma explicita la operación deposito o retiro
--8.- Al insertar un movimiento se debe pasar el numero de cuenta, el monto de
--operación y el tipo (deposito o Retiro) , antes de insertar el movimiento se debe
--verificar que haya saldo disponible de lo contrario no se procederá con la
--operación devolviendo el mensaje “transacción realizada” o “saldo no disponible”
--9.- un procedimiento que elimine una cuenta pero si tiene movimientos impedir su
--borrado
--10.- Pasando los primeros caraecteres de un apellido que muestre todos los
--clientes que tengan esa coincidencia y la cantidad de cuentas que posee.