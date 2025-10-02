package com.suza.id_link_sys.Repository;

import com.suza.id_link_sys.Model.Message;
import com.suza.id_link_sys.Model.Students;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface MessageRepository extends JpaRepository<Message, Long > {

    List<Message> findByStudent(Students student);
}
