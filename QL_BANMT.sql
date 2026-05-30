/*==============================================================*/
/* DBMS name:      Microsoft SQL Server 2017                    */
/* Created on:     10/25/2025 2:29:49 PM                        */
/*==============================================================*/

create database QL_BANMT
USE QL_BANMT
if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('CHITIETHOADON') and o.name = 'FK_CHITIETH_CHITIETHO_SANPHAM')
alter table CHITIETHOADON
   drop constraint FK_CHITIETH_CHITIETHO_SANPHAM
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('CHITIETHOADON') and o.name = 'FK_CHITIETH_CHITIETHO_HOADON')
alter table CHITIETHOADON
   drop constraint FK_CHITIETH_CHITIETHO_HOADON
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('CT_KHUYENMAI') and o.name = 'FK_CT_KHUYE_CT_KHUYEN_SANPHAM')
alter table CT_KHUYENMAI
   drop constraint FK_CT_KHUYE_CT_KHUYEN_SANPHAM
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('CT_KHUYENMAI') and o.name = 'FK_CT_KHUYE_CT_KHUYEN_KHUYENMA')
alter table CT_KHUYENMAI
   drop constraint FK_CT_KHUYE_CT_KHUYEN_KHUYENMA
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('DANHSACHANH') and o.name = 'FK_DANHSACH_DSA_SANPH_SANPHAM')
alter table DANHSACHANH
   drop constraint FK_DANHSACH_DSA_SANPH_SANPHAM
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('HOADON') and o.name = 'FK_HOADON_HD_KH_KHACHHAN')
alter table HOADON
   drop constraint FK_HOADON_HD_KH_KHACHHAN
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('HOADON') and o.name = 'FK_HOADON_NV_HD_NHANVIEN')
alter table HOADON
   drop constraint FK_HOADON_NV_HD_NHANVIEN
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('KHACHHANG') and o.name = 'FK_KHACHHAN_TAIKHOAN__TAIKHOAN')
alter table KHACHHANG
   drop constraint FK_KHACHHAN_TAIKHOAN__TAIKHOAN
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('KHUYENMAI') and o.name = 'FK_KHUYENMA_KM_HD_HOADON')
alter table KHUYENMAI
   drop constraint FK_KHUYENMA_KM_HD_HOADON
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('MOTA') and o.name = 'FK_MOTA_MOTA_SANP_SANPHAM')
alter table MOTA
   drop constraint FK_MOTA_MOTA_SANP_SANPHAM
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('NHANVIEN') and o.name = 'FK_NHANVIEN_CHUCVU_NH_CHUCVU')
alter table NHANVIEN
   drop constraint FK_NHANVIEN_CHUCVU_NH_CHUCVU
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('NHANVIEN') and o.name = 'FK_NHANVIEN_TAIKHOAN__TAIKHOAN')
alter table NHANVIEN
   drop constraint FK_NHANVIEN_TAIKHOAN__TAIKHOAN
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('NHANVIEN_PNH') and o.name = 'FK_NHANVIEN_NHANVIEN__NHANVIEN')
alter table NHANVIEN_PNH
   drop constraint FK_NHANVIEN_NHANVIEN__NHANVIEN
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('NHANVIEN_PNH') and o.name = 'FK_NHANVIEN_NHANVIEN__PHIEUNHA')
alter table NHANVIEN_PNH
   drop constraint FK_NHANVIEN_NHANVIEN__PHIEUNHA
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('PHIEUNHAPHANG') and o.name = 'FK_PHIEUNHA_NCC_PNH_NHACUNGC')
alter table PHIEUNHAPHANG
   drop constraint FK_PHIEUNHA_NCC_PNH_NHACUNGC
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('SANPHAM') and o.name = 'FK_SANPHAM_CHITIETPH_PHIEUNHA')
alter table SANPHAM
   drop constraint FK_SANPHAM_CHITIETPH_PHIEUNHA
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('SANPHAM') and o.name = 'FK_SANPHAM_LOAISANPH_LOAISANP')
alter table SANPHAM
   drop constraint FK_SANPHAM_LOAISANPH_LOAISANP
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('SANPHAM') and o.name = 'FK_SANPHAM_NHACUNGCA_NHACUNGC')
alter table SANPHAM
   drop constraint FK_SANPHAM_NHACUNGCA_NHACUNGC
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('SANPHAM') and o.name = 'FK_SANPHAM_NHANSANXU_NHASANXU')
alter table SANPHAM
   drop constraint FK_SANPHAM_NHANSANXU_NHASANXU
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('SANPHAM') and o.name = 'FK_SANPHAM_SP_CNG_CAPNHATG')
alter table SANPHAM
   drop constraint FK_SANPHAM_SP_CNG_CAPNHATG
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('TAIKHOAN') and o.name = 'FK_TAIKHOAN_TAIKHOAN__KHACHHAN')
alter table TAIKHOAN
   drop constraint FK_TAIKHOAN_TAIKHOAN__KHACHHAN
go

if exists (select 1
   from sys.sysreferences r join sys.sysobjects o on (o.id = r.constid and o.type = 'F')
   where r.fkeyid = object_id('TAIKHOAN') and o.name = 'FK_TAIKHOAN_TAIKHOAN__NHANVIEN')
alter table TAIKHOAN
   drop constraint FK_TAIKHOAN_TAIKHOAN__NHANVIEN
go

if exists (select 1
            from  sysobjects
           where  id = object_id('CAPNHATGIA')
            and   type = 'U')
   drop table CAPNHATGIA
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('CHITIETHOADON')
            and   name  = 'CHITIETHOADON2_FK'
            and   indid > 0
            and   indid < 255)
   drop index CHITIETHOADON.CHITIETHOADON2_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('CHITIETHOADON')
            and   name  = 'CHITIETHOADON_FK'
            and   indid > 0
            and   indid < 255)
   drop index CHITIETHOADON.CHITIETHOADON_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('CHITIETHOADON')
            and   type = 'U')
   drop table CHITIETHOADON
go

if exists (select 1
            from  sysobjects
           where  id = object_id('CHUCVU')
            and   type = 'U')
   drop table CHUCVU
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('CT_KHUYENMAI')
            and   name  = 'CT_KHUYENMAI2_FK'
            and   indid > 0
            and   indid < 255)
   drop index CT_KHUYENMAI.CT_KHUYENMAI2_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('CT_KHUYENMAI')
            and   name  = 'CT_KHUYENMAI_FK'
            and   indid > 0
            and   indid < 255)
   drop index CT_KHUYENMAI.CT_KHUYENMAI_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('CT_KHUYENMAI')
            and   type = 'U')
   drop table CT_KHUYENMAI
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('DANHSACHANH')
            and   name  = 'DSA_SANPHAM_FK'
            and   indid > 0
            and   indid < 255)
   drop index DANHSACHANH.DSA_SANPHAM_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('DANHSACHANH')
            and   type = 'U')
   drop table DANHSACHANH
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('HOADON')
            and   name  = 'NV_HD_FK'
            and   indid > 0
            and   indid < 255)
   drop index HOADON.NV_HD_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('HOADON')
            and   name  = 'HD_KH_FK'
            and   indid > 0
            and   indid < 255)
   drop index HOADON.HD_KH_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('HOADON')
            and   type = 'U')
   drop table HOADON
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('KHACHHANG')
            and   name  = 'TAIKHOAN_KHACHHANG_FK'
            and   indid > 0
            and   indid < 255)
   drop index KHACHHANG.TAIKHOAN_KHACHHANG_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('KHACHHANG')
            and   type = 'U')
   drop table KHACHHANG
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('KHUYENMAI')
            and   name  = 'KM_HD_FK'
            and   indid > 0
            and   indid < 255)
   drop index KHUYENMAI.KM_HD_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('KHUYENMAI')
            and   type = 'U')
   drop table KHUYENMAI
go

if exists (select 1
            from  sysobjects
           where  id = object_id('LOAISANPHAM')
            and   type = 'U')
   drop table LOAISANPHAM
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('MOTA')
            and   name  = 'MOTA_SANPHAM_FK'
            and   indid > 0
            and   indid < 255)
   drop index MOTA.MOTA_SANPHAM_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('MOTA')
            and   type = 'U')
   drop table MOTA
go

if exists (select 1
            from  sysobjects
           where  id = object_id('NHACUNGCAP')
            and   type = 'U')
   drop table NHACUNGCAP
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('NHANVIEN')
            and   name  = 'TAIKHOAN_NHANVIEN_FK'
            and   indid > 0
            and   indid < 255)
   drop index NHANVIEN.TAIKHOAN_NHANVIEN_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('NHANVIEN')
            and   name  = 'CHUCVU_NHANVIEN_FK'
            and   indid > 0
            and   indid < 255)
   drop index NHANVIEN.CHUCVU_NHANVIEN_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('NHANVIEN')
            and   type = 'U')
   drop table NHANVIEN
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('NHANVIEN_PNH')
            and   name  = 'NHANVIEN_PNH2_FK'
            and   indid > 0
            and   indid < 255)
   drop index NHANVIEN_PNH.NHANVIEN_PNH2_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('NHANVIEN_PNH')
            and   name  = 'NHANVIEN_PNH_FK'
            and   indid > 0
            and   indid < 255)
   drop index NHANVIEN_PNH.NHANVIEN_PNH_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('NHANVIEN_PNH')
            and   type = 'U')
   drop table NHANVIEN_PNH
go

if exists (select 1
            from  sysobjects
           where  id = object_id('NHASANXUA')
            and   type = 'U')
   drop table NHASANXUA
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('PHIEUNHAPHANG')
            and   name  = 'NCC_PNH_FK'
            and   indid > 0
            and   indid < 255)
   drop index PHIEUNHAPHANG.NCC_PNH_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('PHIEUNHAPHANG')
            and   type = 'U')
   drop table PHIEUNHAPHANG
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('SANPHAM')
            and   name  = 'CHITIETPHIEUNHAPHANG_FK'
            and   indid > 0
            and   indid < 255)
   drop index SANPHAM.CHITIETPHIEUNHAPHANG_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('SANPHAM')
            and   name  = 'SP_CNG_FK'
            and   indid > 0
            and   indid < 255)
   drop index SANPHAM.SP_CNG_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('SANPHAM')
            and   name  = 'NHACUNGCAP_SANPHAM_FK'
            and   indid > 0
            and   indid < 255)
   drop index SANPHAM.NHACUNGCAP_SANPHAM_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('SANPHAM')
            and   name  = 'LOAISANPHAM_SANPHAM_FK'
            and   indid > 0
            and   indid < 255)
   drop index SANPHAM.LOAISANPHAM_SANPHAM_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('SANPHAM')
            and   name  = 'NHANSANXUAT_SANPHAM_FK'
            and   indid > 0
            and   indid < 255)
   drop index SANPHAM.NHANSANXUAT_SANPHAM_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('SANPHAM')
            and   type = 'U')
   drop table SANPHAM
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('TAIKHOAN')
            and   name  = 'TAIKHOAN_NHANVIEN2_FK'
            and   indid > 0
            and   indid < 255)
   drop index TAIKHOAN.TAIKHOAN_NHANVIEN2_FK
go

if exists (select 1
            from  sysindexes
           where  id    = object_id('TAIKHOAN')
            and   name  = 'TAIKHOAN_KHACHHANG2_FK'
            and   indid > 0
            and   indid < 255)
   drop index TAIKHOAN.TAIKHOAN_KHACHHANG2_FK
go

if exists (select 1
            from  sysobjects
           where  id = object_id('TAIKHOAN')
            and   type = 'U')
   drop table TAIKHOAN
go

/*==============================================================*/
/* Table: CAPNHATGIA                                            */
/*==============================================================*/
create table CAPNHATGIA (
   DONGIA_CN            money                null,
   NGAYCN               datetime             not null,
   constraint PK_CAPNHATGIA primary key (NGAYCN)
)
go

/*==============================================================*/
/* Table: CHITIETHOADON                                         */
/*==============================================================*/
create table CHITIETHOADON (
   MASP                 varchar(10)          not null,
   MAHD                 varchar(10)          not null,
   SOLUONGSP_HD         varchar(100)         null,
   THANHTIEN            money                null,
   constraint PK_CHITIETHOADON primary key (MASP, MAHD)
)
go

/*==============================================================*/
/* Index: CHITIETHOADON_FK                                      */
/*==============================================================*/




create nonclustered index CHITIETHOADON_FK on CHITIETHOADON (MASP ASC)
go

/*==============================================================*/
/* Index: CHITIETHOADON2_FK                                     */
/*==============================================================*/




create nonclustered index CHITIETHOADON2_FK on CHITIETHOADON (MAHD ASC)
go

/*==============================================================*/
/* Table: CHUCVU                                                */
/*==============================================================*/
create table CHUCVU (
   MACV                 varchar(10)          not null,
   TENCV                nvarchar(100)         null,
   constraint PK_CHUCVU primary key (MACV)
)
go

/*==============================================================*/
/* Table: CT_KHUYENMAI                                          */
/*==============================================================*/
create table CT_KHUYENMAI (
   MASP                 varchar(10)          not null,
   MAKM                 varchar(10)          not null,
   constraint PK_CT_KHUYENMAI primary key (MASP, MAKM)
)
go

/*==============================================================*/
/* Index: CT_KHUYENMAI_FK                                       */
/*==============================================================*/




create nonclustered index CT_KHUYENMAI_FK on CT_KHUYENMAI (MASP ASC)
go

/*==============================================================*/
/* Index: CT_KHUYENMAI2_FK                                      */
/*==============================================================*/




create nonclustered index CT_KHUYENMAI2_FK on CT_KHUYENMAI (MAKM ASC)
go

/*==============================================================*/
/* Table: DANHSACHANH                                           */
/*==============================================================*/
create table DANHSACHANH (
   MADSA                varchar(10)          not null,
   MASP                 varchar(10)          not null,
   TENANH               varchar(100)         null,
   constraint PK_DANHSACHANH primary key (MADSA)
)
go

/*==============================================================*/
/* Index: DSA_SANPHAM_FK                                        */
/*==============================================================*/




create nonclustered index DSA_SANPHAM_FK on DANHSACHANH (MASP ASC)
go

/*==============================================================*/
/* Table: HOADON                                                */
/*==============================================================*/
create table HOADON (
   MAHD                 varchar(10)          not null,
   MANV                 varchar(10)          null,
   MAKH                 varchar(10)          null,
   NGAYLAP              datetime             null,
   TRANGTHAITT          nvarchar(100)         null,
   TONGTIEN_HD          money                null,
   constraint PK_HOADON primary key (MAHD)
)
go

/*==============================================================*/
/* Index: HD_KH_FK                                              */
/*==============================================================*/




create nonclustered index HD_KH_FK on HOADON (MAKH ASC)
go

/*==============================================================*/
/* Index: NV_HD_FK                                              */
/*==============================================================*/




create nonclustered index NV_HD_FK on HOADON (MANV ASC)
go

/*==============================================================*/
/* Table: KHACHHANG                                             */
/*==============================================================*/
create table KHACHHANG (
   MAKH                 varchar(10)          not null,
   TENKH                nvarchar(100)         null,
   SDT_KH               varchar(100)         null,
   DIACHI_KH            nvarchar(100)         null,
   EMAIL_KH             varchar(100)         null,
   constraint PK_KHACHHANG primary key (MAKH)
)
go

/*==============================================================*/
/* Index: TAIKHOAN_KHACHHANG_FK                                 */
/*==============================================================*/





/*==============================================================*/
/* Table: KHUYENMAI                                             */
/*==============================================================*/
create table KHUYENMAI (
   MAKM                 varchar(10)          not null,
   MAHD                 varchar(10)          null,
   TENKM                nvarchar(100)         null,
   PHANTRAMKM           varchar(100)         null,
   SOTIENTOIDA_KM       money                null,
   SOTIENTOITHIEU_NHANKM money                null,
   NGAYBD               datetime             null,
   NGAYKT               datetime             null,
   constraint PK_KHUYENMAI primary key (MAKM)
)
go

/*==============================================================*/
/* Index: KM_HD_FK                                              */
/*==============================================================*/




create nonclustered index KM_HD_FK on KHUYENMAI (MAHD ASC)
go

/*==============================================================*/
/* Table: LOAISANPHAM                                           */
/*==============================================================*/
create table LOAISANPHAM (
   MALOAI               varchar(10)          not null,
   TENLOAI              nvarchar(100)         null,
   constraint PK_LOAISANPHAM primary key (MALOAI)
)
go

/*==============================================================*/
/* Table: MOTA                                                  */
/*==============================================================*/
create table MOTA (
   MAMT                 varchar(10)          not null,
   MASP                 varchar(10)          not null,
   RAM                  varchar(100)         null,
   CPU                  varchar(100)         null,
   ROM                  varchar(100)         null,
   MANHINH              nvarchar(100)         null,
   VGA                  varchar(100)         null,
   KHAC                 nvarchar(100)         null,
   constraint PK_MOTA primary key (MAMT)
)
go

/*==============================================================*/
/* Index: MOTA_SANPHAM_FK                                       */
/*==============================================================*/




create nonclustered index MOTA_SANPHAM_FK on MOTA (MASP ASC)
go

/*==============================================================*/
/* Table: NHACUNGCAP                                            */
/*==============================================================*/
create table NHACUNGCAP (
   MANCC                varchar(10)          not null,
   TENNCC               nvarchar(100)         null,
   DIACHI_NCC           nvarchar(100)         null,
   SDT_NCC              varchar(100)         null,
   constraint PK_NHACUNGCAP primary key (MANCC)
)
go

/*==============================================================*/
/* Table: NHANVIEN                                              */
/*==============================================================*/
create table NHANVIEN (
   MANV                 varchar(10)          not null,
   MACV                 varchar(10)          not null,
   TENNV                nvarchar(100)         null,
   SDT_NV               varchar(100)         null,
   DIACHI_NV            nvarchar(100)         null,
   EMAIL_NV             varchar(100)         null,
   constraint PK_NHANVIEN primary key (MANV)
)
go

/*==============================================================*/
/* Index: CHUCVU_NHANVIEN_FK                                    */
/*==============================================================*/




create nonclustered index CHUCVU_NHANVIEN_FK on NHANVIEN (MACV ASC)
go

/*==============================================================*/
/* Index: TAIKHOAN_NHANVIEN_FK                                  */
/*==============================================================*/





/*==============================================================*/
/* Table: NHANVIEN_PNH                                          */
/*==============================================================*/
create table NHANVIEN_PNH (
   MANV                 varchar(10)          not null,
   MAPNH                varchar(10)          not null,
   constraint PK_NHANVIEN_PNH primary key (MANV, MAPNH)
)
go

/*==============================================================*/
/* Index: NHANVIEN_PNH_FK                                       */
/*==============================================================*/




create nonclustered index NHANVIEN_PNH_FK on NHANVIEN_PNH (MANV ASC)
go

/*==============================================================*/
/* Index: NHANVIEN_PNH2_FK                                      */
/*==============================================================*/




create nonclustered index NHANVIEN_PNH2_FK on NHANVIEN_PNH (MAPNH ASC)
go

/*==============================================================*/
/* Table: NHASANXUA                                             */
/*==============================================================*/
create table NHASANXUA (
   MANSX                varchar(10)          not null,
   TENNSX               nvarchar(100)         null,
   constraint PK_NHASANXUA primary key (MANSX)
)
go

/*==============================================================*/
/* Table: PHIEUNHAPHANG                                         */
/*==============================================================*/
create table PHIEUNHAPHANG (
   MAPNH                varchar(10)          not null,
   MANCC                varchar(10)          not null,
   NGAYGIAO             datetime             null,
   NGAYNHAN             datetime             null,
   TRANGTHAI_THANHTOAN_NH varchar(100)         null,
   THUE_VAT             money                null,
   CHIETKHAU            money                null,
   TONGCONG_PNH         varchar(100)         null,
   constraint PK_PHIEUNHAPHANG primary key (MAPNH)
)
go

/*==============================================================*/
/* Index: NCC_PNH_FK                                            */
/*==============================================================*/




create nonclustered index NCC_PNH_FK on PHIEUNHAPHANG (MANCC ASC)
go

/*==============================================================*/
/* Table: SANPHAM                                               */
/*==============================================================*/
create table SANPHAM (
   MASP                 varchar(10)          not null,
   NGAYCN               datetime             not null,
   MANCC                varchar(10)          null,
   MALOAI               varchar(10)          not null,
   MANSX                varchar(10)          not null,
   MAPNH                varchar(10)          null,
   TENSP                nvarchar(100)         null,
   DONVT                nvarchar(100)         null,
   SOLUONGTON           int                  null,
   DONGIA_SP            money                null,
   constraint PK_SANPHAM primary key (MASP)
)
go

/*==============================================================*/
/* Index: NHANSANXUAT_SANPHAM_FK                                */
/*==============================================================*/




create nonclustered index NHANSANXUAT_SANPHAM_FK on SANPHAM (MANSX ASC)
go

/*==============================================================*/
/* Index: LOAISANPHAM_SANPHAM_FK                                */
/*==============================================================*/




create nonclustered index LOAISANPHAM_SANPHAM_FK on SANPHAM (MALOAI ASC)
go

/*==============================================================*/
/* Index: NHACUNGCAP_SANPHAM_FK                                 */
/*==============================================================*/




create nonclustered index NHACUNGCAP_SANPHAM_FK on SANPHAM (MANCC ASC)
go

/*==============================================================*/
/* Index: SP_CNG_FK                                             */
/*==============================================================*/




create nonclustered index SP_CNG_FK on SANPHAM (NGAYCN ASC)
go

/*==============================================================*/
/* Index: CHITIETPHIEUNHAPHANG_FK                               */
/*==============================================================*/




create nonclustered index CHITIETPHIEUNHAPHANG_FK on SANPHAM (MAPNH ASC)
go

/*==============================================================*/
/* Table: TAIKHOAN                                              */
/*==============================================================*/
create table TAIKHOAN (
   MATK                 varchar(10)          not null,
   MANV                 varchar(10)          null,
   MAKH                 varchar(10)          null,
   EMAIL_TK             varchar(100)         null,
   MATKHAU              varchar(100)         null,
   LOAI_TAIKHOAN        varchar(100)         null,
   constraint PK_TAIKHOAN primary key (MATK)
)
go

/*==============================================================*/
/* Index: TAIKHOAN_KHACHHANG2_FK                                */
/*==============================================================*/




create nonclustered index TAIKHOAN_KHACHHANG2_FK on TAIKHOAN (MAKH ASC)
go

/*==============================================================*/
/* Index: TAIKHOAN_NHANVIEN2_FK                                 */
/*==============================================================*/




create nonclustered index TAIKHOAN_NHANVIEN2_FK on TAIKHOAN (MANV ASC)
go

alter table CHITIETHOADON
   add constraint FK_CHITIETH_CHITIETHO_SANPHAM foreign key (MASP)
      references SANPHAM (MASP)
go

alter table CHITIETHOADON
   add constraint FK_CHITIETH_CHITIETHO_HOADON foreign key (MAHD)
      references HOADON (MAHD)
go

alter table CT_KHUYENMAI
   add constraint FK_CT_KHUYE_CT_KHUYEN_SANPHAM foreign key (MASP)
      references SANPHAM (MASP)
go

alter table CT_KHUYENMAI
   add constraint FK_CT_KHUYE_CT_KHUYEN_KHUYENMA foreign key (MAKM)
      references KHUYENMAI (MAKM)
go

alter table DANHSACHANH
   add constraint FK_DANHSACH_DSA_SANPH_SANPHAM foreign key (MASP)
      references SANPHAM (MASP)
go

alter table HOADON
   add constraint FK_HOADON_HD_KH_KHACHHAN foreign key (MAKH)
      references KHACHHANG (MAKH)
go

alter table HOADON
   add constraint FK_HOADON_NV_HD_NHANVIEN foreign key (MANV)
      references NHANVIEN (MANV)
go


alter table KHUYENMAI
   add constraint FK_KHUYENMA_KM_HD_HOADON foreign key (MAHD)
      references HOADON (MAHD)
go

alter table MOTA
   add constraint FK_MOTA_MOTA_SANP_SANPHAM foreign key (MASP)
      references SANPHAM (MASP)
go

alter table NHANVIEN
   add constraint FK_NHANVIEN_CHUCVU_NH_CHUCVU foreign key (MACV)
      references CHUCVU (MACV)
go



alter table NHANVIEN_PNH
   add constraint FK_NHANVIEN_NHANVIEN__NHANVIEN foreign key (MANV)
      references NHANVIEN (MANV)
go

alter table NHANVIEN_PNH
   add constraint FK_NHANVIEN_NHANVIEN__PHIEUNHA foreign key (MAPNH)
      references PHIEUNHAPHANG (MAPNH)
go

alter table PHIEUNHAPHANG
   add constraint FK_PHIEUNHA_NCC_PNH_NHACUNGC foreign key (MANCC)
      references NHACUNGCAP (MANCC)
go

alter table SANPHAM
   add constraint FK_SANPHAM_CHITIETPH_PHIEUNHA foreign key (MAPNH)
      references PHIEUNHAPHANG (MAPNH)
go

alter table SANPHAM
   add constraint FK_SANPHAM_LOAISANPH_LOAISANP foreign key (MALOAI)
      references LOAISANPHAM (MALOAI)
go

alter table SANPHAM
   add constraint FK_SANPHAM_NHACUNGCA_NHACUNGC foreign key (MANCC)
      references NHACUNGCAP (MANCC)
go

alter table SANPHAM
   add constraint FK_SANPHAM_NHANSANXU_NHASANXU foreign key (MANSX)
      references NHASANXUA (MANSX)
go

alter table SANPHAM
   add constraint FK_SANPHAM_SP_CNG_CAPNHATG foreign key (NGAYCN)
      references CAPNHATGIA (NGAYCN)
go

alter table TAIKHOAN
   add constraint FK_TAIKHOAN_TAIKHOAN__KHACHHAN foreign key (MAKH)
      references KHACHHANG (MAKH)
go

alter table TAIKHOAN
   add constraint FK_TAIKHOAN_TAIKHOAN__NHANVIEN foreign key (MANV)
      references NHANVIEN (MANV)
go
/*==============================================================*/
/* BẮT ĐẦU CHÈN DỮ LIỆU MẪU                                      */
/*==============================================================*/

-- BƯỚC 1: Chọn đúng database của bạn!


-- BƯỚC 2: Tạm thời TẮT 2 khóa ngoại tham chiếu vòng (do thiết kế CSDL)
-- Nếu 2 dòng này báo lỗi "does not exist", BẠN CỨ BỎ QUA và chạy tiếp code bên dưới.
ALTER TABLE TAIKHOAN NOCHECK CONSTRAINT FK_TAIKHOAN_TAIKHOAN__KHACHHAN;
ALTER TABLE TAIKHOAN NOCHECK CONSTRAINT FK_TAIKHOAN_TAIKHOAN__NHANVIEN;
GO

--Tạo bảng giỏ hàng
CREATE TABLE GIOHANG (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    MATK VARCHAR(10) NOT NULL, 
    MASP VARCHAR(10) NOT NULL, 
    SOLUONG INT DEFAULT 1,
    NGAYTHEM DATETIME DEFAULT GETDATE(),
    -- TẠO KHÓA NGOẠI (Rất quan trọng)
    -- 1. Liên kết với bảng TAIKHOAN
    CONSTRAINT FK_GIOHANG_TAIKHOAN FOREIGN KEY (MATK) REFERENCES TAIKHOAN(MATK),
    
    -- 2. Liên kết với bảng SANPHAM
    CONSTRAINT FK_GIOHANG_SANPHAM FOREIGN KEY (MASP) REFERENCES SANPHAM(MASP)
);
GO

IF OBJECT_ID('THONGBAO', 'U') IS NULL
BEGIN
    CREATE TABLE THONGBAO (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        MATK VARCHAR(10) NULL,
        TIEUDE NVARCHAR(150) NOT NULL,
        NOIDUNG NVARCHAR(500) NOT NULL,
        LOAI VARCHAR(30) NOT NULL DEFAULT 'SYSTEM',
        DADOC BIT NOT NULL DEFAULT 0,
        NGAYTAO DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        LINK NVARCHAR(255) NULL,
        MA_LIENQUAN VARCHAR(20) NULL,
        CONSTRAINT FK_THONGBAO_TAIKHOAN FOREIGN KEY (MATK) REFERENCES TAIKHOAN(MATK)
    );
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_THONGBAO_MATK_NGAYTAO'
      AND object_id = OBJECT_ID('THONGBAO')
)
BEGIN
    CREATE INDEX IX_THONGBAO_MATK_NGAYTAO
    ON THONGBAO(MATK, NGAYTAO DESC);
END
GO

/*==============================================================*/
/* Bảng không có khóa ngoại (Bảng cha)                           */
/*==============================================================*/

-- Table: CHUCVU (10)
PRINT 'Đang chèn CHUCVU...'
INSERT INTO CHUCVU (MACV, TENCV) VALUES
('CV001', N'Giám đốc'),
('CV002', N'Quản lý bán hàng'),
('CV003', N'Quản lý kho'),
('CV004', N'Nhân viên bán hàng'),
('CV005', N'Nhân viên thu ngân'),
('CV006', N'Kế toán'),
('CV007', N'Nhân viên giao hàng'),
('CV008', N'Nhân viên IT'),
('CV009', N'Chăm sóc khách hàng'),
('CV010', N'Bảo vệ');
GO

-- Table: LOAISANPHAM (10)
PRINT 'Đang chèn LOAISANPHAM...'
INSERT INTO LOAISANPHAM (MALOAI, TENLOAI) VALUES
('LSP001', N'Laptop'),
('LSP002', N'PC - Máy tính bộ'),
('LSP003', N'Màn hình'),
('LSP004', N'Bàn phím'),
('LSP005', N'Chuột'),
('LSP006', N'Tai nghe'),
('LSP007', N'RAM'),
('LSP008', N'Ổ cứng SSD'),
('LSP009', N'Mainboard - Bo mạch chủ'),
('LSP010', N'VGA - Card màn hình');
GO

-- Table: NHASANXUA (10)
PRINT 'Đang chèn NHASANXUA...'
INSERT INTO NHASANXUA (MANSX, TENNSX) VALUES
('NSX001', N'Apple'),
('NSX002', N'Dell'),
('NSX003', N'HP'),
('NSX004', N'Asus'),
('NSX005', N'Lenovo'),
('NSX006', N'Samsung'),
('NSX007', N'LG'),
('NSX008', N'Logitech'),
('NSX009', N'Kingston'),
('NSX010', N'Gigabyte');
GO

-- Table: NHACUNGCAP (10)
PRINT 'Đang chèn NHACUNGCAP...'
INSERT INTO NHACUNGCAP (MANCC, TENNCC, DIACHI_NCC, SDT_NCC) VALUES
('NCC001', N'FPT Synnex', N'Số 28, Đường 6, KCN VSIP, Bắc Ninh', '02473000911'),
('NCC002', N'Digiworld (DGW)', N'195-197 Nguyễn Thái Bình, Q. 1, TP. HCM', '02839141581'),
('NCC003', N'Petrosetco (PSD)', N'1-5 Lê Duẩn, Q. 1, TP. HCM', '02839117788'),
('NCC004', N'Viettel Distribution', N'Số 1, Giang Văn Minh, Ba Đình, Hà Nội', '19008067'),
('NCC005', N'ADG Distribution', N'Số 42-44 Ngụy Như Kon Tum, Thanh Xuân, Hà Nội', '02435553ADG'),
('NCC006', N'Công ty TNHH Ánh Minh', N'123 Hai Bà Trưng, Q. 3, TP. HCM', '02838123456'),
('NCC007', N'Công ty Tin học Sao Việt', N'456 Lý Thường Kiệt, Q. 10, TP. HCM', '02838654321'),
('NCC008', N'Công ty Máy tính An Phát', N'789 Lê Hồng Phong, Q. 5, TP. HCM', '02839234567'),
('NCC009', N'Công ty Vĩnh Xuân (SPC)', N'364 Cộng Hòa, Tân Bình, TP. HCM', '02838101111'),
('NCC010', N'Công ty Thuận Phát', N'987 Cách Mạng Tháng 8, Q. 3, TP. HCM', '02839876543');
GO

-- Table: CAPNHATGIA (10)
PRINT 'Đang chèn CAPNHATGIA...'
INSERT INTO CAPNHATGIA (DONGIA_CN, NGAYCN) VALUES
(18500000, '2025-01-10T09:00:00'),
(25000000, '2025-01-15T14:30:00'),
(8500000, '2025-02-01T08:00:00'),
(1200000, '2025-02-05T11:00:00'),
(800000, '2025-02-10T16:00:00'),
(5500000, '2025-03-01T09:30:00'),
(1500000, '2025-03-02T10:00:00'),
(2500000, '2025-03-03T11:00:00'),
(6500000, '2025-03-04T14:00:00'),
(12000000, '2025-03-05T15:00:00');
GO

/*==============================================================*/
/* Nhóm Tài khoản - Khách hàng - Nhân viên (Có tham chiếu vòng)  */
/*==============================================================*/

-- Table: TAIKHOAN (10 Khách hàng + 10 Nhân viên)
PRINT 'Đang chèn TAIKHOAN...'
INSERT INTO TAIKHOAN (MATK, MANV, MAKH, EMAIL_TK, MATKHAU, LOAI_TAIKHOAN) VALUES
-- 10 Khách hàng (MANV, MAKH để là NULL)
('TK_KH001', NULL, NULL, 'nnl8a1@gmail.com', '124BD1296BEC0D9D93C7B52A71AD8D5B', 'KhachHang'),
('TK_KH002', 'NV001', NULL, 'admin@gmail.com', '124BD1296BEC0D9D93C7B52A71AD8D5B', 'Admin'),
('TK_KH003', NULL, NULL, 'leminhc@yahoo.com', 'hashed_password3', 'KhachHang'),
('TK_KH004', NULL, NULL, 'phamvand@outlook.com', 'hashed_password4', 'KhachHang'),
('TK_KH005', NULL, NULL, 'huynhthie@gmail.com', 'hashed_password5', 'KhachHang'),
('TK_KH006', NULL, NULL, 'vovant@gmail.com', 'hashed_password6', 'KhachHang'),
('TK_KH007', NULL, NULL, 'dothig@yahoo.com', 'hashed_password7', 'KhachHang'),
('TK_KH008', NULL, NULL, 'phanminhh@gmail.com', 'hashed_password8', 'KhachHang'),
('TK_KH009', NULL, NULL, 'truongvank@gmail.com', 'hashed_password9', 'KhachHang'),
('TK_KH010', NULL, NULL, 'buihoangl@outlook.com', 'hashed_password10', 'KhachHang'),
-- 10 Nhân viên (MANV, MAKH để là NULL)
('TK_NV001', 'NV002', NULL, 'nhanvien1@phongvu.com', '124BD1296BEC0D9D93C7B52A71AD8D5B', 'NhanVien'),
('TK_NV002', NULL, NULL, 'qly.banhang@phongvu.com', 'admin_pass2', 'NhanVien'),
('TK_NV003', NULL, NULL, 'qly.kho@phongvu.com', 'admin_pass3', 'NhanVien'),
('TK_NV004', NULL, NULL, 'banhang01@phongvu.com', 'staff_pass4', 'NhanVien'),
('TK_NV005', NULL, NULL, 'thungan01@phongvu.com', 'staff_pass5', 'NhanVien'),
('TK_NV006', NULL, NULL, 'ketoan@phongvu.com', 'staff_pass6', 'NhanVien'),
('TK_NV007', NULL, NULL, 'giaohang01@phongvu.com', 'staff_pass7', 'NhanVien'),
('TK_NV008', NULL, NULL, 'it.support@phongvu.com', 'staff_pass8', 'NhanVien'),
('TK_NV009', NULL, NULL, 'cskh@phongvu.com', 'staff_pass9', 'NhanVien'),
('TK_NV010', NULL, NULL, 'baove@phongvu.com', 'staff_pass10', 'NhanVien');
GO

-- Table: KHACHHANG (10)
PRINT 'Đang chèn KHACHHANG...'
INSERT INTO KHACHHANG (MAKH, TENKH, SDT_KH, DIACHI_KH, EMAIL_KH) VALUES
('KH001',  N'Nguyễn Văn A', '0909123456', N'123 Lê Lợi, Q. 1, TP. HCM', 'nguyenvana@gmail.com'),
('KH002',  N'Trần Thị B', '0918765432', N'456 Nguyễn Trãi, Q. 5, TP. HCM', 'tranthib@gmail.com'),
('KH003',  N'Lê Minh C', '0988111222', N'789 Cách Mạng Tháng 8, Q. 3, TP. HCM', 'leminhc@yahoo.com'),
('KH004', N'Phạm Văn D', '0977333444', N'234 Cộng Hòa, Q. Tân Bình, TP. HCM', 'phamvand@outlook.com'),
('KH005',  N'Huỳnh Thị E', '0966555666', N'567 An Dương Vương, Q. 6, TP. HCM', 'huynhthie@gmail.com'),
('KH006',  N'Võ Văn T', '0955777888', N'890 Võ Văn Kiệt, Q. 8, TP. HCM', 'vovant@gmail.com'),
('KH007',  N'Đỗ Thị G', '0944999000', N'111 Điện Biên Phủ, Q. Bình Thạnh, TP. HCM', 'dothig@yahoo.com'),
('KH008',  N'Phan Minh H', '0933121212', N'222 Hoàng Diệu, Q. 4, TP. HCM', 'phanminhh@gmail.com'),
('KH009', N'Trương Văn K', '0922343434', N'333 Lê Văn Sỹ, Q. Phú Nhuận, TP. HCM', 'truongvank@gmail.com'),
('KH010',  N'Bùi Hoàng L', '0911565656', N'444 Lũy Bán Bích, Q. Tân Phú, TP. HCM', 'buihoangl@outlook.com');
GO

-- Table: NHANVIEN (10)
PRINT 'Đang chèn NHANVIEN...'
INSERT INTO NHANVIEN (MANV, MACV, TENNV, SDT_NV, DIACHI_NV, EMAIL_NV) VALUES
('NV001', 'CV001',  N'Nguyễn Ngân Lượng', '0903111111', N'1 Võ Văn Ngân, TP. Thủ Đức', 'admin@gmail.com'),
('NV002', 'CV002',  N'Trần Hữu Quản', '0903222222', N'2 Võ Văn Ngân, TP. Thủ Đức', 'qly.banhang@phongvu.com'),
('NV003', 'CV003',  N'Nguyễn Thị Kho', '0903333333', N'3 Võ Văn Ngân, TP. Thủ Đức', 'qly.kho@phongvu.com'),
('NV004', 'CV004',  N'Phạm Văn Bán', '0903444444', N'4 Võ Văn Ngân, TP. Thủ Đức', 'banhang01@phongvu.com'),
('NV005', 'CV005',  N'Võ Thị Ngân', '0903555555', N'5 Võ Văn Ngân, TP. Thủ Đức', 'thungan01@phongvu.com'),
('NV006', 'CV006',  N'Lý Thị Kế', '0903666666', N'6 Võ Văn Ngân, TP. Thủ Đức', 'ketoan@phongvu.com'),
('NV007', 'CV007',  N'Hồ Văn Giao', '0903777777', N'7 Võ Văn Ngân, TP. Thủ Đức', 'giaohang01@phongvu.com'),
('NV008', 'CV008',  N'Đinh Văn IT', '0903888888', N'8 Võ Văn Ngân, TP. Thủ Đức', 'it.support@phongvu.com'),
('NV009', 'CV009',  N'Mai Thị Chăm', '0903999999', N'9 Võ Văn Ngân, TP. Thủ Đức', 'cskh@phongvu.com'),
('NV010', 'CV010',  N'Bùi Văn Vệ', '0903000000', N'10 Võ Văn Ngân, TP. Thủ Đức', 'baove@phongvu.com');
GO

/*==============================================================*/
/* Nhóm Sản phẩm - Kho (Phụ thuộc các bảng cha)                   */
/*==============================================================*/

-- Table: PHIEUNHAPHANG (10)
PRINT 'Đang chèn PHIEUNHAPHANG...'
INSERT INTO PHIEUNHAPHANG (MAPNH, MANCC, NGAYGIAO, NGAYNHAN, TRANGTHAI_THANHTOAN_NH, THUE_VAT, CHIETKHAU, TONGCONG_PNH) VALUES
('PNH001', 'NCC001', '2025-01-05T14:00:00', '2025-01-06T09:00:00', N'Đã thanh toán', 5000000, 2000000, '53000000'),
('PNH002', 'NCC002', '2025-01-10T15:00:00', '2025-01-11T10:00:00', N'Đã thanh toán', 8000000, 3000000, '85000000'),
('PNH003', 'NCC003', '2025-01-15T10:00:00', '2025-01-16T08:00:00', N'Chưa thanh toán', 4000000, 1000000, '43000000'),
('PNH004', 'NCC004', '2025-02-01T11:00:00', '2025-02-02T14:00:00', N'Đã thanh toán', 12000000, 5000000, '127000000'),
('PNH005', 'NCC005', '2025-02-05T09:00:00', '2025-02-06T11:00:00', N'Đã thanh toán', 3000000, 1500000, '31500000'),
('PNH006', 'NCC001', '2025-02-10T16:00:00', '2025-02-11T09:00:00', N'Chưa thanh toán', 7000000, 2000000, '75000000'),
('PNH007', 'NCC002', '2025-02-15T14:00:00', '2025-02-16T10:00:00', N'Đã thanh toán', 6000000, 0, '66000000'),
('PNH008', 'NCC003', '2025-03-01T10:00:00', '2025-03-02T08:00:00', N'Đã thanh toán', 9000000, 4000000, '95000000'),
('PNH009', 'NCC004', '2025-03-05T11:00:00', '2025-03-06T14:00:00', N'Chưa thanh toán', 2000000, 500000, '21500000'),
('PNH010', 'NCC005', '2025-03-10T09:00:00', '2025-03-11T11:00:00', N'Đã thanh toán', 1000000, 0, '11000000');
GO

-- Table: SANPHAM (ĐÃ CẬP NHẬT)
PRINT 'Đang chèn SANPHAM (Đã cập nhật)...'
INSERT INTO SANPHAM (MASP, NGAYCN, MANCC, MALOAI, MANSX, MAPNH, TENSP, DONVT, SOLUONGTON, DONGIA_SP) VALUES
('SP001', '2025-01-10T09:00:00', 'NCC001', 'LSP003', 'NSX002', 'PNH001', N'Laptop Dell XPS 13 9320', N'Cái', 50, 28000000),
('SP002', '2025-01-15T14:30:00', 'NCC001', 'LSP010', 'NSX001', 'PNH001', N'MacBook Pro 14 inch M3', N'Cái', 30, 45000000),
('SP003', '2025-02-01T08:00:00', 'NCC002', 'LSP002', 'NSX004', 'PNH002', N'Laptop ASUS ROG Zephyrus G14', N'Cái', 100, 32000000),
('SP004', '2025-02-05T11:00:00', 'NCC003', 'LSP001', 'NSX003', 'PNH003', N'Laptop HP Pavilion 15', N'Cái', 200, 15000000),
('SP005', '2025-02-10T16:00:00', 'NCC004', 'LSP005', 'NSX005', 'PNH004', N'PC Lenovo IdeaCentre 3', N'Bộ', 300, 8500000),
('SP006', '2025-03-01T09:30:00', 'NCC005', 'LSP006', 'NSX004', 'PNH005', N'PC Gaming ASUS ROG Strix G15', N'Bộ', 50, 38000000),
('SP007', '2025-03-02T10:00:00', 'NCC001', 'LSP007', 'NSX003', 'PNH006', N'AIO HP 24-cb1011d', N'Bộ', 150, 14000000),
('SP008', '2025-03-03T11:00:00', 'NCC002', 'LSP004', 'NSX002', 'PNH007', N'Laptop Dell Precision 5570', N'Cái', 80, 52000000),
('SP009', '2025-03-04T14:00:00', 'NCC003', 'LSP008', 'NSX003', 'PNH008', N'PC Workstation HP Z2 G9', N'Bộ', 40, 43000000),
('SP010', '2025-03-05T15:00:00', 'NCC004', 'LSP002', 'NSX005', 'PNH009', N'Laptop Lenovo Legion 5 Pro', N'Cái', 20, 41000000);
GO

-- Table: DANHSACHANH (ĐÃ CẬP NHẬT)
PRINT 'Đang chèn DANHSACHANH (Đã cập nhật)...'
INSERT INTO DANHSACHANH (MADSA, MASP, TENANH) VALUES
('ANH001', 'SP001', 'dell_xps_9320_1.jpg'),
('ANH002', 'SP002', 'macbook_pro_14_m3_1.jpg'),
('ANH003', 'SP003', 'asus_zephyrus_g14_1.jpg'),
('ANH004', 'SP004', 'hp_pavilion_15_1.jpg'),
('ANH005', 'SP005', 'lenovo_ideacentre_3_1.jpg'),
('ANH006', 'SP006', 'asus_rog_strix_g15_1.jpg'),
('ANH007', 'SP007', 'aio_hp_24_1.jpg'),
('ANH008', 'SP008', 'dell_precision_5570_1.jpg'),
('ANH009', 'SP009', 'hp_z2_g9_1.jpg'),
('ANH010', 'SP010', 'lenovo_legion_5_pro_1.jpg');
GO

-- Table: MOTA (ĐÃ CẬP NHẬT)
PRINT 'Đang chèn MOTA (Đã cập nhật)...'
INSERT INTO MOTA (MAMT, MASP, RAM, CPU, ROM, MANHINH, VGA, KHAC) VALUES
('MT001', 'SP001', '16GB LPDDR5', 'Core i7 1360P', '1TB SSD', '13.4" 3.5K OLED', 'Intel Iris Xe', N'Vỏ nhôm, 1.2kg'),
('MT002', 'SP002', '18GB Unified', 'Apple M3 Pro', '512GB SSD', '14.2" Liquid Retina XDR', 'M3 Pro 14-core GPU', N'Space Black'),
('MT003', 'SP003', '16GB DDR5', 'Ryzen 9 7940HS', '1TB SSD', '14" QHD+ 165Hz', 'RTX 4060 8GB', N'AniMe Matrix'),
('MT004', 'SP004', '8GB DDR4', 'Core i5 1235U', '512GB SSD', '15.6" FHD IPS', 'Intel Iris Xe', N'Vỏ nhựa, 1.74kg'),
('MT005', 'SP005', '8GB DDR4', 'Core i3 12100', '256GB SSD', NULL, 'Intel UHD 730', N'Case SFF'),
('MT006', 'SP006', '16GB DDR4', 'Core i7 12700F', '1TB SSD', NULL, 'RTX 3070 8GB', N'Tản nhiệt khí, Case RGB'),
('MT007', 'SP007', '8GB DDR4', 'Core i5 1235U', '512GB SSD', '23.8" FHD IPS', 'Intel Iris Xe', N'Cảm ứng, có webcam'),
('MT008', 'SP008', '32GB DDR5', 'Core i7 12800H', '1TB SSD', '15.6" FHD+', 'NVIDIA RTX A2000 8GB', N'Chuyên đồ họa 3D'),
('MT009', 'SP009', '32GB DDR5', 'Core i9 13900K', '1TB SSD', NULL, 'NVIDIA Quadro T1000', N'Workstation chuyên dụng'),
('MT010', 'SP010', '32GB DDR5', 'Ryzen 7 7745HX', '1TB SSD', '16" WQXGA 240Hz', 'RTX 4070 8GB', N'Tản nhiệt Legion Coldfront 5.0');
GO

/*==============================================================*/
/* Nhóm Hóa đơn - Khuyến mãi (Phụ thuộc Sản phẩm, Khách hàng)   */
/*==============================================================*/

-- Table: HOADON (10)
PRINT 'Đang chèn HOADON...'
INSERT INTO HOADON (MAHD, MANV, MAKH, NGAYLAP, TRANGTHAITT, TONGTIEN_HD) VALUES
('HD001', 'NV004', 'KH001', '2025-02-01T10:00:00', N'Đã thanh toán', 28000000),
('HD002', 'NV004', 'KH002', '2025-02-03T11:30:00', N'Đã thanh toán', 47500000),
('HD003', 'NV005', 'KH003', '2025-02-05T14:00:00', N'Đã đặt', 12000000),
('HD004', 'NV005', 'KH001', '2025-02-10T09:00:00', N'Đã thanh toán', 3500000),
('HD005', 'NV004', 'KH004', '2025-02-15T16:00:00', N'Đã thanh toán', 2500000),
('HD006', 'NV004', 'KH005', '2025-03-01T10:30:00', N'Đã thanh toán', 4000000),
('HD007', 'NV005', 'KH006', '2025-03-05T11:00:00', N'Đã thanh toán', 7000000),
('HD008', 'NV004', 'KH007', '2025-03-10T14:30:00', N'Đã đặt', 22000000),
('HD009', 'NV005', 'KH008', '2025-03-12T15:00:00', N'Đã thanh toán', 48000000),
('HD010', 'NV004', 'KH002', '2025-03-15T17:00:00', N'Đã thanh toán', 8000000);
GO

-- Table: CHITIETHOADON (ĐÃ CẬP NHẬT)
PRINT 'Đang chèn CHITIETHOADON (Đã cập nhật)...'
INSERT INTO CHITIETHOADON (MASP, MAHD, SOLUONGSP_HD, THANHTIEN) VALUES
('SP001', 'HD001', '1', 28000000),
('SP002', 'HD002', '1', 45000000),
('SP003', 'HD003', '1', 32000000),
('SP004', 'HD004', '1', 15000000),
('SP005', 'HD005', '1', 8500000),
('SP006', 'HD006', '1', 38000000),
('SP007', 'HD007', '1', 14000000),
('SP008', 'HD008', '1', 52000000),
('SP009', 'HD009', '1', 43000000),
('SP010', 'HD010', '1', 41000000);
GO

-- Table: KHUYENMAI (10)
PRINT 'Đang chèn KHUYENMAI...'
INSERT INTO KHUYENMAI (MAKM, MAHD, TENKM, PHANTRAMKM, SOTIENTOIDA_KM, SOTIENTOITHIEU_NHANKM, NGAYBD, NGAYKT) VALUES
('KM001', 'HD002', N'Giảm giá tháng 2', '10%', 500000, 3000000, '2025-02-01T00:00:00', '2025-02-28T23:59:59'),
('KM002', 'HD004', N'Free ship', '0%', 40000, 500000, '2025-02-01T00:00:00', '2025-02-28T23:59:59'),
('KM003', 'HD007', N'Giảm giá 8/3', '15%', 1000000, 5000000, '2025-03-01T00:00:00', '2025-03-10T23:59:59'),
('KM004', NULL, N'Chào hè', '20%', 2000000, 10000000, '2025-04-01T00:00:00', '2025-04-30T23:59:59'),
('KM005', NULL, N'Black Friday', '50%', 10000000, 20000000, '2025-11-20T00:00:00', '2025-11-25T23:59:59'),
('KM006', NULL, N'Giảm giá khai trương', '10%', 500000, 1000000, '2025-01-01T00:00:00', '2025-01-10T23:59:59'),
('KM007', NULL, N'Tri ân khách hàng', '5%', 200000, 0, '2025-05-01T00:00:00', '2025-05-31T23:59:59'),
('KM008', NULL, N'Giảm giá Laptop tựu trường', '10%', 1500000, 15000000, '2025-08-01T00:00:00', '2025-08-31T23:59:59'),
('KM009', 'HD008', N'Flash Sale 3/3', '30%', 300000, 500000, '2025-03-03T10:00:00', '2025-03-03T12:00:00'),
('KM010', NULL, N'Giáng sinh an lành', '15%', 1000000, 5000000, '2025-12-20T00:00:00', '2025-12-25T23:59:59');
GO

-- Table: CT_KHUYENMAI (10)
PRINT 'Đang chèn CT_KHUYENMAI...'
INSERT INTO CT_KHUYENMAI (MASP, MAKM) VALUES
('SP001', 'KM008'),
('SP002', 'KM008'),
('SP003', 'KM001'),
('SP004', 'KM007'),
('SP005', 'KM007'),
('SP006', 'KM004'),
('SP007', 'KM004'),
('SP008', 'KM005'),
('SP009', 'KM005'),
('SP010', 'KM008');
GO

/*==============================================================*/
/* Bảng quan hệ N-N cuối cùng                                     */
/*==============================================================*/

-- Table: NHANVIEN_PNH (10)
PRINT 'Đang chèn NHANVIEN_PNH...'
INSERT INTO NHANVIEN_PNH (MANV, MAPNH) VALUES
('NV003', 'PNH001'),
('NV006', 'PNH001'),
('NV003', 'PNH002'),
('NV006', 'PNH002'),
('NV003', 'PNH003'),
('NV006', 'PNH004'),
('NV003', 'PNH005'),
('NV006', 'PNH006'),
('NV003', 'PNH007'),
('NV006', 'PNH008');
GO




/*==============================================================*/
/* BƯỚC 4: Bật lại 2 khóa ngoại đã tắt ở BƯỚC 2                 */
/*==============================================================*/
PRINT 'Đang bật lại khóa ngoại...'
ALTER TABLE TAIKHOAN CHECK CONSTRAINT FK_TAIKHOAN_TAIKHOAN__KHACHHAN;
ALTER TABLE TAIKHOAN CHECK CONSTRAINT FK_TAIKHOAN_TAIKHOAN__NHANVIEN;
GO

PRINT '*** CHÈN DỮ LIỆU MẪU THÀNH CÔNG! ***'
GO
select * from SANPHAM
select * from TAIKHOAN
select * from KHACHHANG
select * from SANPHAM
select * from HOADON
select * from CHUCVU
select * from CHITIETHOADON
select * from CAPNHATGIA
select * from DANHSACHANH
select * from MOTA
select * from LOAISANPHAM
select * from NHACUNGCAP
select * from NHANVIEN
select * from NHANVIEN_PNH
select * from PHIEUNHAPHANG
select * from NHASANXUA

--Back up and Restore
USE msdb;
GO

IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs WHERE name = N'Auto_Backup_Monday')
    EXEC msdb.dbo.sp_delete_job @job_name = N'Auto_Backup_Monday', @delete_unused_schedule=1;
GO

EXEC dbo.sp_add_job @job_name = N'Auto_Backup_Monday';
GO

EXEC sp_add_jobstep 
    @job_name = N'Auto_Backup_Monday', 
    @step_name = N'Backup_Step',
    @subsystem = N'TSQL', 
    @command = N'BACKUP DATABASE [QL_BANMT] TO DISK = ''D:\08_WebsiteMuaBanMayTinh\BackupData\QL_BANMT_Auto.bak'' WITH FORMAT', 
    @retry_attempts = 5;
GO

EXEC sp_add_schedule 
    @schedule_name = N'Monday_Schedule', 
    @freq_type = 8, 
    @freq_interval = 2, 
    @freq_recurrence_factor = 1, 
    @active_start_time = 000000;
GO

EXEC sp_attach_schedule @job_name = N'Auto_Backup_Monday', @schedule_name = N'Monday_Schedule';
GO
EXEC sp_add_jobserver @job_name = N'Auto_Backup_Monday';
GO
