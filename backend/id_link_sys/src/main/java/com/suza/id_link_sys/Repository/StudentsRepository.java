package com.suza.id_link_sys.Repository;

import com.suza.id_link_sys.Model.Students;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
public interface StudentsRepository extends JpaRepository<Students, String> {
    Optional<Students> findByRegNumber(String regNumber);

    @Modifying
    @Transactional
    int deleteByRegNumber(String regNumber);

    @Modifying
    @Transactional
    @Query("UPDATE Students s SET s.email = :email, s.phoneNo = :phoneNo WHERE s.regNumber = :regNumber")
    int updateEmailAndPhone(@Param("regNumber") String regNumber, @Param("email") String email, @Param("phoneNo") int phoneNo);

    @Modifying
    @Transactional
    @Query("UPDATE Students s SET s.photoUrl = :photoUrl WHERE s.regNumber = :regNumber")
    int updatePhoto(@Param("regNumber") String regNumber, @Param("photoUrl") String photoUrl);

    @Query("SELECT s FROM Students s WHERE s.regNumber = :regNumber")
    Students getPhotoUrlByRegNumber(@Param("regNumber") String regNumber);

    boolean existsByRegNumber(String regNumber);
}