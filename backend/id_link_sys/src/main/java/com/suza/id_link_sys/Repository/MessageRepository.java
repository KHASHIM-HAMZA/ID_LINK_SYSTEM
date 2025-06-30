package com.suza.id_link_sys.Repository;

import com.suza.id_link_sys.Model.Message;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Long > {
    List<Message> findByRegNumber(String regNumber);
}
