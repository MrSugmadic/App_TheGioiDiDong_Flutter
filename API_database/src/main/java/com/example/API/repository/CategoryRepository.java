package com.example.API.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.API.entity.Category;

@Repository
public interface CategoryRepository extends JpaRepository<Category, String> {
}