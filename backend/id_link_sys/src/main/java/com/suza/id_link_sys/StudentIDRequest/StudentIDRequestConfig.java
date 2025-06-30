package com.suza.id_link_sys.StudentIDRequest;


import com.suza.id_link_sys.Model.Message;
import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Repository.MessageRepository;
import com.suza.id_link_sys.Repository.StudentIDRequestRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.LocalDateTime;

@Configuration
public class StudentIDRequestConfig {
    @Autowired
    MessageRepository messageRepository;

    @Bean
    CommandLineRunner commandLineRunner(MessageRepository messageRepository) {
        return args -> {
           Message hashim = new Message(
                   true,
                   "RTY",
                   "LLLLLLLLLLLLLLLLLLLLLLLLLLLLLL",
                   "WWWWWWWWWWWWWWWWWWW",
                   0L

            );
            //requestRepository.save(hashim);
        };
    };





}
