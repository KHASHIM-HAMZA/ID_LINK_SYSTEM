package com.suza.id_link_sys.Repository;


import com.suza.id_link_sys.Model.StudentIDRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentIDRequestRepository  extends JpaRepository<StudentIDRequest, Long> {
    Optional<StudentIDRequest> findByRegNumber(String regNumber);
    List<StudentIDRequest> regNumber(String regNumber);
    @Modifying
    @Transactional
    @Query("DELETE FROM StudentIDRequest s WHERE s.regNumber = :regNumber")
    void deleteByRegNumber(@Param("regNumber") String regNumber);

    //This query retrieves only approved but unprinted ID requests.
    List<StudentIDRequest> findByStatusAndPrinted(String status, boolean printed);
    //fetch ids which are approved
    List<StudentIDRequest> findByStatus(String status);

}
