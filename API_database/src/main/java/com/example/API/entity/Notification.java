package com.example.API.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "THONGBAO")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private Integer id;

    @Column(name = "MATK")
    private String maTk;

    @Column(name = "TIEUDE")
    private String title;

    @Column(name = "NOIDUNG")
    private String content;

    @Column(name = "LOAI")
    private String type;

    @Column(name = "DADOC")
    private Boolean read;

    @Column(name = "NGAYTAO")
    private LocalDateTime createdAt;

    @Column(name = "LINK")
    private String link;

    @Column(name = "MA_LIENQUAN")
    private String relatedId;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getMaTk() { return maTk; }
    public void setMaTk(String maTk) { this.maTk = maTk; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public Boolean getRead() { return read; }
    public void setRead(Boolean read) { this.read = read; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getLink() { return link; }
    public void setLink(String link) { this.link = link; }

    public String getRelatedId() { return relatedId; }
    public void setRelatedId(String relatedId) { this.relatedId = relatedId; }
}
