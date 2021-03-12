/* Insert data into TeAkomoduar */

insert into dbo.TeAkomoduar (
    IAkomoduarEmer,
    IAkomoduarMbiemer,
    IAkomoduarDatelindje,
    IAkomoduarAdreseRruga,
    IAkomoduarAdreseQyteti,
    IAkomoduarAdreseShteti,
    IAkomoduarAdreseZip,
    IAkomoduarNumerKontakti
) 

select

KlientEmri,
KlientMbiemri,
KlientDatelindje,
KlientAdreseRruga,
KlientAdreseQyteti,
KlientAdreseShteti,
KlientAdreseZip,
KlientTelefonPune 

from dbo.Klient

where KlientId in (
    select distinct KlientId from dbo.Prenotim
    where 
        datediff(day, PrenotimDateFillimi, '2021-03-12') >= 0
        and datediff(day, PrenotimDateMbarimi, '2021-03-12') < 0
);

select * from dbo.TeAkomoduar;
