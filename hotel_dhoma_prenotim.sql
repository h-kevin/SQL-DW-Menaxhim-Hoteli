/* Databaza hotel_dhoma_prenotim */

-- Krijo databazen

create database hotel_dhoma_prenotim;

-- Akseso databazen

use hotel_dhoma_prenotim;

-- Krijo tabelat

create table Klient (
    KlientId int identity(1, 1) primary key,
    KlientEmri varchar(255) not null,
    KlientMbiemri varchar(255) not null,
    KlientDatelindje date not null,
    KlientAdreseRruga varchar(255) not null,
    KlientAdreseQyteti varchar(255) not null,
    KlientAdreseShteti varchar(255) not null,
    KlientAdreseZip varchar(255) not null,
    KlientTelefonShtepie varchar(255) not null,
    KlientTelefonPune varchar(255) not null,
    KlientEmail varchar(255) not null,
);

create table Prenotim (
    PrenotimId int identity(1, 1) primary key,
    KlientId int not null,
    PrenotimDate date not null,
    PrenotimOre time not null,
    PrenotimDateFillimi date not null,
    PrenotimDateMbarimi date not null,
    PrenotimDatePagimi date not null,
    PrenotimPagesaTotale money not null,
    PrenotimDatePaguar date,
    PrenotimKomente text,
    constraint fk_klient_prenotim foreign key (KlientId)
    references Klient(KlientId),
);

create table TipDhome (
    TipDhomeId int identity(1, 1) primary key,
    TipDhomeEmer varchar(255) not null,
);

create table CmimDhome (
    CmimDhomeId int identity(1, 1) primary key,
    Cmim money not null,
);

create table Dhoma (
    DhomaId int identity(1, 1) primary key,
    TipDhomeId int not null,
    CmimDhomeId int not null,
    Kat varchar(255) not null,
    Shenime text,
    constraint fk_dhoma_tip foreign key (TipDhomeId)
    references TipDhome(TipDhomeId),
    constraint fk_dhoma_cmim foreign key (CmimDhomeId)
    references CmimDhome(CmimDhomeId),
);

create table TeAkomoduar (
    IAkomoduarId int identity(1, 1) primary key,
    IAkomoduarEmer varchar(255) not null,
    IAkomoduarMbiemer varchar(255) not null,
    IAkomoduarDatelindje date not null,
    IAkomoduarAdreseRruga varchar(255) not null,
    IAkomoduarAdreseQyteti varchar(255) not null,
    IAkomoduarAdreseShteti varchar(255) not null,
    IAkomoduarAdreseZip varchar(255) not null,
    IAkomoduarNumerKontakti varchar(255) not null,
);

create table Paisje (
    PaisjeId int identity(1, 1) primary key,
    PaisjePershkrim varchar(255) not null,
);

create table MetodePagese (
    MetodePageseId int identity(1, 1) primary key,
    MetodePagesePershkrim varchar(255) not null,
);

create table Pagesa (
    PagesaId int identity(1, 1) primary key,
    PrenotimId int not null,
    KlientId int not null,
    MetodePageseId int not null,
    Shuma money not null,
    PagesaKomente text,
    constraint fk_pagesa_prenotim foreign key (PrenotimId)
    references Prenotim(PrenotimId),
    constraint fk_pagesa_klient foreign key (KlientId)
    references Klient(KlientId),
    constraint fk_pagesa_metode foreign key (MetodePageseId)
    references MetodePagese(MetodePageseId),
);

create table PaisjeDhome (
    DhomaId int not null,
    PaisjeId int not null,
    Detaje text,
    constraint fk_dhoma foreign key (DhomaId)
    references Dhoma(DhomaId),
    constraint fk_paisje foreign key (PaisjeId)
    references Paisje(PaisjeId),
    constraint pk_paisje_dhoma primary key (DhomaId, PaisjeId),
);

create table PrenotimeDhomash (
    PrenotimId int not null,
    DhomaId int not null,
    IAkomoduarId int not null,
    constraint fk_prenotim foreign key (PrenotimId)
    references Prenotim(PrenotimId),
    constraint fk_prenotime_dhoma foreign key (DhomaId)
    references Dhoma(DhomaId),
    constraint fk_akomoduar foreign key (IAkomoduarId)
    references TeAkomoduar(IAkomoduarId),
    constraint pj_prenotime_dhomash primary key (PrenotimId, DhomaId, IAkomoduarId),
);
