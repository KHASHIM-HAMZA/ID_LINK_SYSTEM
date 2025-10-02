package com.suza.id_link_sys.Repository;

import com.suza.id_link_sys.Model.StudentIDRequest;
import com.suza.id_link_sys.Model.Students;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentIDRequestRepository extends JpaRepository<StudentIDRequest, Long> {
    @Query("SELECT r FROM StudentIDRequest r WHERE r.student.regNumber = :regNumber AND r.student IS NOT NULL")
    List<StudentIDRequest> findByStudentRegNumber(String regNumber);

    @Query("SELECT r FROM StudentIDRequest r WHERE r.status = :status AND r.student IS NOT NULL")
    List<StudentIDRequest> findByStatus(String status);

    @Query("SELECT r FROM StudentIDRequest r WHERE r.status = :status AND r.printed = :printed AND r.student IS NOT NULL")
    List<StudentIDRequest> findByStatusAndPrinted(String status, boolean printed);

    Optional<StudentIDRequest> findTopByStudentOrderByRequestDateDesc(Students student);
}