package org.example.web;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
public class WebController {
    @Autowired
    private WebRepository webRepository;

    @GetMapping("/web")
    public List<Web> getAllWebs() {
        return webRepository.findAll();
    }

}
