package com.example.API.websocket;

import java.io.IOException;
import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import com.example.API.dto.NotificationMessage;
import tools.jackson.databind.ObjectMapper;

@Component
public class NotificationWebSocketHandler extends TextWebSocketHandler {

    private final ObjectMapper objectMapper;
    private final Map<String, WebSocketSession> sessions = new ConcurrentHashMap<>();

    public NotificationWebSocketHandler(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        sessions.put(session.getId(), session);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        sessions.remove(session.getId());
    }

    public void sendNotification(NotificationMessage notification) {
        try {
            TextMessage message = new TextMessage(objectMapper.writeValueAsString(notification));
            for (WebSocketSession session : sessions.values()) {
                if (session.isOpen() && canReceive(session, notification.maTk())) {
                    session.sendMessage(message);
                }
            }
        } catch (IOException e) {
            throw new IllegalStateException("Khong gui duoc thong bao realtime", e);
        }
    }

    private boolean canReceive(WebSocketSession session, String notificationMaTk) {
        if (notificationMaTk == null || notificationMaTk.isBlank()) {
            return true;
        }

        String sessionMaTk = getQueryParam(session.getUri(), "maTk");
        return notificationMaTk.equals(sessionMaTk);
    }

    private String getQueryParam(URI uri, String key) {
        if (uri == null || uri.getQuery() == null) {
            return null;
        }

        for (String pair : uri.getQuery().split("&")) {
            String[] parts = pair.split("=", 2);
            if (parts.length == 2 && key.equals(parts[0])) {
                return URLDecoder.decode(parts[1], StandardCharsets.UTF_8);
            }
        }
        return null;
    }
}
