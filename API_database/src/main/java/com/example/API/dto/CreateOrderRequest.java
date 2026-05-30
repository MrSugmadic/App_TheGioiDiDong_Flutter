package com.example.API.dto;

import java.util.List;

public class CreateOrderRequest {
    private String maTk;
    private String hoTen;
    private String soDienThoai;
    private String diaChi;
    private String phuongThucThanhToan;
    private String maGiamGia;
    private Double tongTien;
    private Double giamGia;
    private Double thanhTien;
    private List<OrderItemRequest> items;

    public String getMaTk() { return maTk; }
    public void setMaTk(String maTk) { this.maTk = maTk; }

    public String getHoTen() { return hoTen; }
    public void setHoTen(String hoTen) { this.hoTen = hoTen; }

    public String getSoDienThoai() { return soDienThoai; }
    public void setSoDienThoai(String soDienThoai) { this.soDienThoai = soDienThoai; }

    public String getDiaChi() { return diaChi; }
    public void setDiaChi(String diaChi) { this.diaChi = diaChi; }

    public String getPhuongThucThanhToan() { return phuongThucThanhToan; }
    public void setPhuongThucThanhToan(String phuongThucThanhToan) { this.phuongThucThanhToan = phuongThucThanhToan; }

    public String getMaGiamGia() { return maGiamGia; }
    public void setMaGiamGia(String maGiamGia) { this.maGiamGia = maGiamGia; }

    public Double getTongTien() { return tongTien; }
    public void setTongTien(Double tongTien) { this.tongTien = tongTien; }

    public Double getGiamGia() { return giamGia; }
    public void setGiamGia(Double giamGia) { this.giamGia = giamGia; }

    public Double getThanhTien() { return thanhTien; }
    public void setThanhTien(Double thanhTien) { this.thanhTien = thanhTien; }

    public List<OrderItemRequest> getItems() { return items; }
    public void setItems(List<OrderItemRequest> items) { this.items = items; }
}
