package com.suza.id_link_sys.Repository;

import com.suza.id_link_sys.Model.LossReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LossReportRepository extends JpaRepository<LossReport, Long> {
    // Optional: find by student regNumber
}
