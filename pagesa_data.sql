/* Insert data into Pagesa */

insert into dbo.Pagesa (
    PrenotimId,
    KlientId,
    MetodePageseId,
    Shuma
)

select

distinct
PrenotimId,
KlientId,
abs(
    checksum(newid())
) % 5 + 1
as MetodePageseId,
PrenotimPagesaTotale

from dbo.Prenotim

where PrenotimDatePaguar is not null;

select * from dbo.Pagesa;
