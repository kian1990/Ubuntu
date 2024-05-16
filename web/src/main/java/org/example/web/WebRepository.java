package org.example.web;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WebRepository extends JpaRepository<Web, Long> {
}