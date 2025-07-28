package com.suza.id_link_sys.Repository;

import com.suza.id_link_sys.Model.admin;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
@Repository
public interface AdminRepository extends JpaRepository<admin,Long> {
    Optional<admin> findByUsername(String username);
}
