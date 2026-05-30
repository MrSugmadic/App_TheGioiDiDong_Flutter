package com.example.API.dto;

import com.example.API.entity.Notification;

public record NotificationMessage(
        Integer id,
        String maTk,
        String title,
        String content,
        String type,
        String createdAt,
        boolean read,
        String link,
        String relatedId) {

    public static NotificationMessage fromEntity(Notification notification) {
        return new NotificationMessage(
                notification.getId(),
                notification.getMaTk(),
                notification.getTitle(),
                notification.getContent(),
                notification.getType(),
                notification.getCreatedAt() == null ? null : notification.getCreatedAt().toString(),
                Boolean.TRUE.equals(notification.getRead()),
                notification.getLink(),
                notification.getRelatedId());
    }
}
