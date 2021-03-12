/* DataWarehouse hotel_dhoma_prenotim_dw */

-- Krijo databazen

create database hotel_dhoma_prenotim_dw;

-- Akseso databazen

use hotel_dhoma_prenotim_dw;

-- Krijo dimensionin Pagesa

create table Pagesa(
    id int identity(1,1) primary key,

	id_total int,
	total varchar(255),

	id_klient int,
	klient_emer varchar(255),
    klient_burim int, 

	id_prenotim int,
	data_paguar date,
	prenotim_burim int,

	id_shuma int,
	shuma money,
	pagesa_burim int,
);

-- Procedura per mbushjen e dimensionit Pagesa

go

create procedure mbush_dim_pagesa

as
begin

-- mbush nivelin Total
insert into dbo.Pagesa(total) values ('Totali Pagesa');

update dbo.Pagesa set id_total = id;

-- mbush nivelin Klient
insert into dbo.Pagesa(id_total, total, klient_emer, klient_burim)
select P.id_total, P.total, Klient.emri_klientit, Klient.KlientId
from dbo.Pagesa P
cross join (
    select KlientEmri + ' ' + KlientMbiemri as emri_klientit, KlientId 
    from hotel_dhoma_prenotim.dbo.Klient
	where KlientId in (select distinct KlientId from hotel_dhoma_prenotim.dbo.Prenotim)
) as Klient;

update dbo.Pagesa set id_klient = id where klient_burim is not null;

-- mbush nivelin Prenotim 
insert into dbo.Pagesa(id_total, total, id_klient, klient_emer, klient_burim, data_paguar, prenotim_burim)
select P.id_total, P.total, P.id_klient, P.klient_emer, P.klient_burim, Prenotim.PrenotimDatePaguar, Prenotim.PrenotimId 
from dbo.Pagesa P
cross join hotel_dhoma_prenotim.dbo.Prenotim
where Prenotim.KlientId = P.klient_burim
order by P.id_klient;

update dbo.Pagesa set id_prenotim = id where prenotim_burim is not null;

-- mbush nivelin Pagesa
insert into dbo.Pagesa(id_total, total, id_klient, klient_emer, klient_burim, id_prenotim, prenotim_burim, shuma, pagesa_burim)
select P.id_total, P.total, P.id_klient, P.klient_emer, P.klient_burim, P.id_prenotim, P.prenotim_burim, Pagesa.Shuma, Pagesa.PagesaId
from dbo.Pagesa P
cross join hotel_dhoma_prenotim.dbo.Pagesa
where Pagesa.KlientId = P.klient_burim and Pagesa.PrenotimId = P.prenotim_burim
order by P.id_klient, P.id_prenotim;

update dbo.Pagesa set id_shuma = id where pagesa_burim is not null;

end;

-- end procedura

go

exec dbo.mbush_dim_pagesa
select * from dbo.Pagesa;

-- delete from Pagesa;
-- drop procedure mbush_dim_pagesa;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Krijo dimensionin PrenotimeDhomash

create table PrenotimeDhomash(
    id int identity(1,1) primary key,

	id_total int,
	total varchar(255),

	i_akomoduar_id int,
    i_akomoduar_burim int, 

	dhoma_id int,
	dhoma_burim int,
);

-- Procedura per mbushjen e dimensionit PrenotimeDhomash

go

create procedure mbush_dim_prenotime_dhomash

as
begin

-- mbush nivelin Total
insert into dbo.PrenotimeDhomash(total) values ('Totali PrenotimeDhomash');

update dbo.PrenotimeDhomash set id_total = id;

-- mbush nivelin IAkomoduar
insert into dbo.PrenotimeDhomash(id_total, total, i_akomoduar_burim)
select PD.id_total, PD.total, PrenotimeDhomash.IAkomoduarId
from dbo.PrenotimeDhomash PD
cross join (
    select IAkomoduarId
    from hotel_dhoma_prenotim.dbo.PrenotimeDhomash
) as PrenotimeDhomash;

update dbo.PrenotimeDhomash set i_akomoduar_id = id where i_akomoduar_burim is not null;

-- mbush nivelin Dhoma 
insert into dbo.PrenotimeDhomash(id_total, total, i_akomoduar_id, i_akomoduar_burim, dhoma_burim)
select PD.id_total, PD.total, PD.i_akomoduar_id, PD.i_akomoduar_burim, PrenotimeDhomash.DhomaId
from dbo.PrenotimeDhomash PD
cross join (
    select DhomaId
    from hotel_dhoma_prenotim.dbo.PrenotimeDhomash
) as PrenotimeDhomash
order by PD.i_akomoduar_id;

update dbo.PrenotimeDhomash set dhoma_id = id where dhoma_burim is not null;

end;

-- end procedura

go

exec dbo.mbush_dim_prenotime_dhomash
select * from dbo.PrenotimeDhomash;


-- delete from PrenotimeDhomash;
-- drop procedure mbush_dim_prenotime_dhomash;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

create table Koha(
	id int identity(1,1) primary key,

	id_total int,
	total varchar(255),

	id_vit int,
	vit int,

	id_muaj int,
	muaj varchar(255),
);

-- Procedura per mbushjen e dimensionit Koha

go

create procedure dbo.mbush_dim_koha

as
begin

-- mbush nivelin Total 
insert into Koha(total) values('Totali Koha')

update Koha set id_total = id

-- mbush nivelin Vit 
declare @vit int
set @vit = 2020

while @vit <= 2021

begin
	insert into Koha(id_total, total, vit)
	select id_total, total, @vit
	from Koha where vit is null
	
	set @vit = @vit + 1
end

update Koha set id_vit = id where vit is not null

-- mbush nivelin Muaj
set @vit = 2020

while @vit <= 2021

begin
	declare @muaj int
	set @muaj = 1
	
	while @muaj <= 12
	
	begin
		insert into Koha(id_total, total, id_vit, vit, muaj)
		select distinct id_total, total, id_vit, vit,
		case @muaj
			when 1 then 'Janar' 
			when 2 then 'Shkurt' 
			when 3 then 'Mars' 
			when 4 then 'Prill' 
			when 5 then 'Maj' 
			when 6 then 'Qershor' 
			when 7 then 'Korrik' 
			when 8 then 'Gusht' 
			when 9 then 'Shtator' 
			when 10 then 'Tetor' 
			when 11 then 'Nentor' 
			when 12 then 'Dhjetor'
	end

	from Koha where vit = @vit and muaj is null
	set @muaj = @muaj + 1
end

set @vit = @vit + 1
end

update Koha set id_muaj = id where muaj is not null
end;

-- end procedura

go

exec dbo.mbush_dim_koha;
select * from Koha;

-- delete from Koha;
-- drop procedure mbush_dim_koha;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

create table Pagesat(

	pagesa int,
	koha int,

	max_shuma money, 
	shume_total money,

	constraint fk_pagesa foreign key(pagesa) references Pagesa(id),
	constraint fk_koha foreign key(koha) references Koha(id)
);

-- Procedura per mbushjen e faktit Pagesat

go

create procedure mbush_fakt_pagesat

as
begin

insert into Pagesat
select distinct dw_p.id, dw_k.id, max(pa.Shuma) as max_shuma, sum(pa.Shuma) as shuma_total
from hotel_dhoma_prenotim.dbo.Prenotim pr
inner join hotel_dhoma_prenotim.dbo.Pagesa pa
on pr.PrenotimId = pa.PrenotimId
inner join dbo.Pagesa dw_p
on dw_p.data_paguar = pr.PrenotimDatePaguar
inner join dbo.Koha dw_k
on dw_k.vit = year(pr.PrenotimDatePaguar)
where dw_k.vit is not null
and pr.PrenotimDatePaguar is not null
and pa.Shuma is not null
group by dw_p.id, dw_k.id, pa.Shuma

end;

go

exec dbo.mbush_fakt_pagesat;
select * from Pagesat;

delete from Pagesat;
drop procedure mbush_fakt_pagesat;
