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
	where KlientId in (
		select distinct KlientId from hotel_dhoma_prenotim.dbo.Prenotim
		where PrenotimDatePaguar is not null
	)
) as Klient;

update dbo.Pagesa set id_klient = id where klient_burim is not null;

-- mbush nivelin Prenotim 
insert into dbo.Pagesa(id_total, total, id_klient, klient_emer, klient_burim, data_paguar, prenotim_burim)
select P.id_total, P.total, P.id_klient, P.klient_emer, P.klient_burim, Prenotim.PrenotimDatePaguar, Prenotim.PrenotimId 
from dbo.Pagesa P
cross join hotel_dhoma_prenotim.dbo.Prenotim
where Prenotim.KlientId = P.klient_burim
and Prenotim.PrenotimDatePaguar is not null
order by P.id_klient;

update dbo.Pagesa set id_prenotim = id where prenotim_burim is not null;

-- mbush nivelin Pagesa
insert into dbo.Pagesa(id_total, total, id_klient, klient_emer, klient_burim, id_prenotim, data_paguar, prenotim_burim, shuma, pagesa_burim)
select P.id_total, P.total, P.id_klient, P.klient_emer, P.klient_burim, P.id_prenotim, P.data_paguar, P.prenotim_burim, Pagesa.Shuma, Pagesa.PagesaId
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
-- DBCC CHECKIDENT (Pagesa, RESEED, 0);

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Krijo dimensionin Akomodime

create table Akomodime(
    id int identity(1,1) primary key,

	id_total int,
	total varchar(255),

	i_akomoduar_id int,
	date_fillimi date,
    i_akomoduar_burim int, 

	dhoma_id int,
	dhoma_burim int,
);

-- Procedura per mbushjen e dimensionit Akomodime

go

create procedure mbush_dim_akomodime

as
begin

-- mbush nivelin Total
insert into dbo.Akomodime(total) values ('Totali Akomodime');

update dbo.Akomodime set id_total = id;

-- mbush nivelin IAkomoduar
insert into dbo.Akomodime(id_total, total, date_fillimi, i_akomoduar_burim)
select A.id_total, A.total, Prenotim.PrenotimDateFillimi, Prenotim.PrenotimId
from dbo.Akomodime A
cross join (
    select P.PrenotimDateFillimi, P.PrenotimId
    from hotel_dhoma_prenotim.dbo.Prenotim P inner join hotel_dhoma_prenotim.dbo.Klient K
	on P.KlientId = K.KlientId
	where K.IAkomoduar = 1
	and K.KlientId in (
		select KlientId from hotel_dhoma_prenotim.dbo.Prenotim
		where datediff(day, PrenotimDateFillimi, '2021-03-03') >= 0
	)
) as Prenotim;

update dbo.Akomodime set i_akomoduar_id = id where i_akomoduar_burim is not null;

-- mbush nivelin Dhoma 
insert into dbo.Akomodime(id_total, total, i_akomoduar_id, date_fillimi, i_akomoduar_burim, dhoma_burim)
select A.id_total, A.total, A.i_akomoduar_id, A.date_fillimi, A.i_akomoduar_burim, PrenotimeDhomash.DhomaId
from dbo.Akomodime A
inner join hotel_dhoma_prenotim.dbo.PrenotimeDhomash
on PrenotimId = A.i_akomoduar_burim

update dbo.Akomodime set dhoma_id = id where dhoma_burim is not null;

end;

-- end procedura

go

exec dbo.mbush_dim_akomodime
select * from dbo.Akomodime;

-- delete from Akomodime;
-- drop procedure mbush_dim_akomodime;
-- DBCC CHECKIDENT (Akomodime, RESEED, 0);

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
-- DBCC CHECKIDENT (Koha, RESEED, 0);

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

create table Fakt1(
	koha_id int,

	totali_vjetor_pagesat money,
	totali_vjetor_te_akomoduar int,

	constraint fk_koha foreign key(koha_id) references Koha(id)
);

-- Procedura per mbushjen e faktit Pagesat

go

create procedure mbush_fakt_1

as
begin

insert into Fakt1
select
	t.koha_id,
	sum(t.totali_vjetor_pagesat) as totali_vjetor_pagesat,
	sum(t.totali_vjetor_te_akomoduar) as totali_vjetor_te_akomoduar
from (
	select
		dw_k.id as koha_id,
		sum(dw_p.shuma) as totali_vjetor_pagesat,
		0 as totali_vjetor_te_akomoduar
	from dbo.Koha dw_k
	join Pagesa dw_p
	on dw_k.vit = year(dw_p.data_paguar)
	where dw_k.vit is not null
	and dw_k.id_muaj is null
	and dw_p.shuma is not null
	group by dw_k.id

	union

	select 
		dw_k.id as koha_id,
		0 as totali_vjetor_pagesat,
		count(dw_a.i_akomoduar_id) as totali_vjetor_te_akomoduar
	from dbo.Koha dw_k
	join dbo.Akomodime dw_a
	on dw_k.vit = year(dw_a.date_fillimi)
	where dw_k.vit is not null
	and dw_k.id_muaj is null
	and dw_a.dhoma_id is not null
	group by dw_k.id
) t
group by t.koha_id;

end;

go

exec dbo.mbush_fakt_1;
select * from Fakt1;

-- delete from Fakt1;
-- drop procedure mbush_fakt_1;
-- DBCC CHECKIDENT (Fakt1, RESEED, 0);
