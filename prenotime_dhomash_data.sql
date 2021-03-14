/* Insert data into PrenotimeDhomash */

go

create procedure mbush_prenotime_dhomash

as
begin

declare @numer_prenotimesh int;
set @numer_prenotimesh = (
    select count(*) from dbo.Prenotim
    where KlientId in (
        select KlientId from dbo.Klient
        where IAkomoduar = 1
        and KlientId in (
            select KlientId from dbo.Prenotim
            where datediff(day, PrenotimDateFillimi, '2021-03-03') >= 0
        )
    )
);

declare @index int = 0;
declare @prenotim_id int;
declare @dhoma_id int;

while @index < @numer_prenotimesh

begin
    set @prenotim_id = (
        select PrenotimId from (
            select PrenotimId, row_number() over(order by PrenotimId) as row_num
            from dbo.Prenotim P inner join dbo.Klient K
            on P.KlientId = K.KlientId
            where K.IAkomoduar = 1
        ) as p
        where p.row_num = @index + 1
    );

    set @dhoma_id = (
        select top 1 D.DhomaId from dbo.Dhoma D inner join dbo.CmimDhome C
        on D.CmimDhomeId = C.CmimDhomeId
        where C.Cmim = 25
        group by D.DhomaId 
        order by NewId()
    );

    insert into dbo.PrenotimeDhomash (
        PrenotimId,
        DhomaId
    ) values (
        @prenotim_id,
        @dhoma_id
    );

    set @index += 1;
end;

end;

go

exec dbo.mbush_prenotime_dhomash;
select * from dbo.PrenotimeDhomash;

-- delete from dbo.PrenotimeDhomash;
-- drop procedure mbush_prenotime_dhomash;
-- DBCC CHECKIDENT (PrenotimeDhomash, RESEED, 0);
