package com.example.API.controller;

import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.API.dto.NotificationMessage;
import com.example.API.service.NotificationService;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {

    private final NotificationService notificationService;

    public NotificationController(NotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping
    public List<NotificationMessage> getNotifications(@RequestParam(required = false) String maTk) {
        return notificationService.getNotifications(maTk);
    }

    @PostMapping
    public NotificationMessage createNotification(@RequestBody Map<String, String> request) {
        return notificationService.createNotification(request);
    }

    @PostMapping("/demo")
    public NotificationMessage createDemoNotification(@RequestBody(required = false) Map<String, String> request) {
        Map<String, String> body = request == null ? Map.of() : request;
        return notificationService.createNotification(body);
    }

    @PatchMapping("/{id}/read")
    public ResponseEntity<?> markRead(@PathVariable Integer id) {
        try {
            return ResponseEntity.ok(notificationService.markRead(id));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PatchMapping("/read-all")
    public Map<String, Integer> markAllRead(@RequestParam(required = false) String maTk) {
        return Map.of("updated", notificationService.markAllRead(maTk));
    }

    @GetMapping("/unread-count")
    public Map<String, Long> countUnread(@RequestParam(required = false) String maTk) {
        return Map.of("count", notificationService.countUnread(maTk));
    }
}
