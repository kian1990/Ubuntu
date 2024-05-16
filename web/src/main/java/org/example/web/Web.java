package org.example.web;
import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
public class Web {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer web_ranking;
    private Long web_id;
    private String web_url;
    private String web_type;
}