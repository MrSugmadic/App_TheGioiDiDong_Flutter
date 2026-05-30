package com.example.API.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "SANPHAM")
public class Product {
    
    @Id
    @Column(name = "MASP")
    private String maSp;

    @Column(name = "TENSP")
    private String tenSp;

    @Column(name = "DONGIA_SP")
    private Double donGia;

    @Column(name = "MALOAI")
    private String maLoai;

    // 👉 THÊM 2 TRƯỜNG NÀY VÀO CHO ĐỒNG BỘ NÀY:
    @Column(name = "DONVT")
    private String donVt;

    @Column(name = "SOLUONGTON")
    private Integer soLuongTon;

    // ================= GETTER VÀ SETTER =================

    public String getMaSp() { return maSp; }
    public void setMaSp(String maSp) { this.maSp = maSp; }

    public String getTenSp() { return tenSp; }
    public void setTenSp(String tenSp) { this.tenSp = tenSp; }

    public Double getDonGia() { return donGia; }
    public void setDonGia(Double donGia) { this.donGia = donGia; }

    public String getMaLoai() { return maLoai; }
    public void setMaLoai(String maLoai) { this.maLoai = maLoai; }

    public String getDonVt() { return donVt; }
    public void setDonVt(String donVt) { this.donVt = donVt; }

    public Integer getSoLuongTon() { return soLuongTon; }
    public void setSoLuongTon(Integer soLuongTon) { this.soLuongTon = soLuongTon; }
}