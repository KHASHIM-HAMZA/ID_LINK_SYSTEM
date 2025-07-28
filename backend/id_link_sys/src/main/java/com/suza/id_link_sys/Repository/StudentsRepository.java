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

    // update info
    @Modifying
    @Transactional
    @Query("update Students s set s.email = :email, s.phoneNo = :phoneNo where s.regNumber = :regNumber")
    int updateEmailAndPhone(@Param("regNumber") String regNumber, @Param("email") String email, @Param("phoneNo") int phoneNo);

    //update photo
    @Modifying
    @Transactional
    @Query("update Students s set s.photoUrl = :photoUrl where s.regNumber = :regNumber")
    int updatePhoto(@Param("regNumber") String regNumber, @Param("photoUrl") String photoUrl);

//    String regNumber(String regNumber);
//    List<Students> deleteByRegNumber(String regNumber);
}
