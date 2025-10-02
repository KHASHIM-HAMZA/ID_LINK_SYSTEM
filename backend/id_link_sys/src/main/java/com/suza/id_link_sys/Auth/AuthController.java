package com.suza.id_link_sys.Auth;

import com.suza.id_link_sys.Model.LossReport;
import com.suza.id_link_sys.Model.Students;
import com.suza.id_link_sys.Model.admin;
import com.suza.id_link_sys.Repository.AdminRepository;
import com.suza.id_link_sys.Repository.LossReportRepository;
import com.suza.id_link_sys.Repository.StudentsRepository;
import com.suza.id_link_sys.Security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    AdminRepository adminRepository;

    @Autowired
    StudentsRepository studentsRepository;

    @Autowired
    private JwtUtil jwtUtil;


    @Autowired
    private LossReportRepository repository;

    @GetMapping("/loss-reports")
    public List<LossReport> getAllReports() {
        return repository.findAll();
    }

    // Add admin (unprotected for setup; secure later if needed)
    @PostMapping("/addmin")
    public admin addAdmin(@RequestBody admin Admin) {
        return adminRepository.save(Admin);
    }

    // Admin login
    @PostMapping("/admin-login")
    public ResponseEntity<?> adminLogin(@RequestBody admin Admins) {
        Optional<admin> dbAdmin = adminRepository.findByUsername(Admins.getUsername());

        if (dbAdmin.isPresent() && dbAdmin.get().getPassword().equals(Admins.getPassword())) {
            String token = jwtUtil.generateToken(dbAdmin.get().getUsername(), "ADMIN");

            return ResponseEntity.ok(
                    Map.of(
                            "username", dbAdmin.get().getUsername(),
                            "role", "ROLE_ADMIN",
                            "token", token,
                            "message", "Login successful"
                    )
            );
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                    Map.of("error", "Invalid credentials")
            );
        }
    }

    @GetMapping("/all-students")
    public List<Students> getAllStudents() {
        return studentsRepository.findAll();
    }

    @GetMapping("/list-admin")
    public List<admin> getAllAdmin() {
        return adminRepository.findAll();
    }

    @PostMapping("/add")
    public Students addStudent(@RequestBody Students students) {
        return studentsRepository.save(students);
    }

    @DeleteMapping("/delete")
    public String deleteStudentByReg(@RequestParam String regNumber) {
        int deleted = studentsRepository.deleteByRegNumber(regNumber);
        if (deleted > 0) {
            return "Deleted student with regNumber: " + regNumber;
        } else {
            return "No student found with regNumber: " + regNumber;
        }
    }
}