package com.example.API.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "GIOHANG")
public class Cart {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // Khớp với IDENTITY(1,1) trong SQL
    @Column(name = "ID")
    private Integer id;

    @Column(name = "MATK")
    private String maTk;

    @Column(name = "MASP")
    private String maSp;

    @Column(name = "SOLUONG")
    private Integer soLuong;

    // GETTER & SETTER
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getMaTk() { return maTk; }
    public void setMaTk(String maTk) { this.maTk = maTk; }

    public String getMaSp() { return maSp; }
    public void setMaSp(String maSp) { this.maSp = maSp; }

    public Integer getSoLuong() { return soLuong; }
    public void setSoLuong(Integer soLuong) { this.soLuong = soLuong; }
}