package com.example.API.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.API.dto.NotificationMessage;
import com.example.API.entity.Notification;
import com.example.API.repository.NotificationRepository;
import com.example.API.websocket.NotificationWebSocketHandler;

@Service
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final NotificationWebSocketHandler webSocketHandler;

    public NotificationService(
            NotificationRepository notificationRepository,
            NotificationWebSocketHandler webSocketHandler) {
        this.notificationRepository = notificationRepository;
        this.webSocketHandler = webSocketHandler;
    }

    public List<NotificationMessage> getNotifications(String maTk) {
        return notificationRepository.findVisibleNotifications(normalize(maTk))
                .stream()
                .map(NotificationMessage::fromEntity)
                .toList();
    }

    @Transactional
    public NotificationMessage createNotification(Map<String, String> request) {
        Notification notification = new Notification();
        notification.setMaTk(normalize(request.get("maTk")));
        notification.setTitle(defaultValue(request.get("title"), "Thong bao moi"));
        notification.setContent(defaultValue(request.get("content"), "Ban co thong bao moi."));
        notification.setType(defaultValue(request.get("type"), "SYSTEM"));
        notification.setLink(normalize(request.get("link")));
        notification.setRelatedId(normalize(request.get("relatedId")));
        notification.setRead(false);
        notification.setCreatedAt(LocalDateTime.now());

        Notification saved = notificationRepository.save(notification);
        NotificationMessage message = NotificationMessage.fromEntity(saved);
        webSocketHandler.sendNotification(message);
        return message;
    }

    @Transactional
    public NotificationMessage markRead(Integer id) {
        Notification notification = notificationRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Khong tim thay thong bao"));
        notification.setRead(true);
        return NotificationMessage.fromEntity(notificationRepository.save(notification));
    }

    @Transactional
    public int markAllRead(String maTk) {
        return notificationRepository.markAllRead(normalize(maTk));
    }

    public long countUnread(String maTk) {
        return notificationRepository.countUnread(normalize(maTk));
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }

    private String defaultValue(String value, String fallback) {
        String normalized = normalize(value);
        return normalized == null ? fallback : normalized;
    }
}
