package com.example.API.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.example.API.entity.Notification;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Integer> {

    @Query("""
            select n from Notification n
            where (:maTk is null and n.maTk is null)
               or (:maTk is not null and (n.maTk = :maTk or n.maTk is null))
            order by n.createdAt desc
            """)
    List<Notification> findVisibleNotifications(@Param("maTk") String maTk);

    @Query("""
            select count(n) from Notification n
            where n.read = false
              and ((:maTk is null and n.maTk is null)
                   or (:maTk is not null and (n.maTk = :maTk or n.maTk is null)))
            """)
    long countUnread(@Param("maTk") String maTk);

    @Modifying
    @Query("""
            update Notification n
            set n.read = true
            where n.read = false
              and ((:maTk is null and n.maTk is null)
                   or (:maTk is not null and (n.maTk = :maTk or n.maTk is null)))
            """)
    int markAllRead(@Param("maTk") String maTk);
}
