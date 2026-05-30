package com.example.API.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "LOAISANPHAM") // Đổi thành LOAISANPHAM
public class Category {
    
    @Id
    @Column(name = "MALOAI") // Đổi thành MALOAI
    private String maLoai;

    @Column(name = "TENLOAI") // Đổi thành TENLOAI
    private String tenLoai;

    // Getter và Setter
    public String getMaLoai() { return maLoai; }
    public void setMaLoai(String maLoai) { this.maLoai = maLoai; }

    public String getTenLoai() { return tenLoai; }
    public void setTenLoai(String tenLoai) { this.tenLoai = tenLoai; }
}