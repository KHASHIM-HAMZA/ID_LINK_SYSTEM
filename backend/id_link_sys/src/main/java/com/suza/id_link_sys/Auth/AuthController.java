package com.suza.id_link_sys.Auth;

import com.suza.id_link_sys.Model.Students;
import com.suza.id_link_sys.Model.admin;
import com.suza.id_link_sys.Repository.AdminRepository;
import com.suza.id_link_sys.Repository.StudentsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    AdminRepository adminRepository;

    @Autowired
    StudentsRepository studentsRepository;

    //Api for add admin
    @PostMapping("/addmin")
    public admin addAdmin(@RequestBody admin Admin) {
        return adminRepository.save(Admin);
    }
//login
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody admin Admins) {
        // fetch admin from DB
        admin Admin = adminRepository.findByUsername(Admins.getUsername())
                .orElseThrow(() -> new RuntimeException("Invalid username"));

        // compare passwords (should use hashing in production)
        if (Admin.getPassword().equals(Admins.getPassword())) {
            // return JSON instead of plain text
            return ResponseEntity.ok(
                    Map.of(
                            "username", Admin.getUsername(),
                            "role", "admin",
                            "message", "Login successful"
                    )
            );
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                    Map.of("error", "Invalid password")
            );
        }
    }
    @GetMapping("/all-students")
    public List<Students> getAllStudents(){
        return studentsRepository.findAll();
    }

    //Managing Students
    @PostMapping("/add")
    public Students addStudent(@RequestBody Students students){
        return studentsRepository.save(students);
    }

    @DeleteMapping("/delete")
    public String deleteStudentByReg(@RequestParam String regNumber){
        int deleted = studentsRepository.deleteByRegNumber(regNumber);
        if (deleted > 0) {
            return "Deleted student with regNumber: " + regNumber;
        } else {
            return "No student found with regNumber: " + regNumber;
        }
    }
}
