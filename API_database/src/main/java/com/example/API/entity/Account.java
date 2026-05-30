package com.example.API.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Entity
@Table(name = "TAIKHOAN")
public class Account {
    @Id
    @Column(name = "MATK")
    private String id;

    @Column(name = "EMAIL_TK")
    private String email;

    @Column(name = "MATKHAU")
    private String password;

    @Column(name = "LOAI_TAIKHOAN")
    private String role;
    
    @Column(name = "MAKH")
    private String customerId;
}
