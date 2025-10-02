package com.suza.id_link_sys.Service;


import com.suza.id_link_sys.DTO.ChangePasswordDTO;
import com.suza.id_link_sys.Model.Students;
import com.suza.id_link_sys.Repository.StudentsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class StudentService {
    @Autowired
    private StudentsRepository studentsRepository;

    PasswordEncoder passwordEncoder;

    public boolean changePassword(ChangePasswordDTO dto) {
        Students student = studentsRepository.findByRegNumber(dto.getRegNumber())
                .orElse(null);

        if (student == null) {
            return false; // Student not found
        }

        // verify current password
        if (!passwordEncoder.matches(dto.getCurrentPassword(), student.getPassword())) {
            return false; // current password incorrect
        }

        // update with new password
        student.setPassword(passwordEncoder.encode(dto.getNewPassword()));
        studentsRepository.save(student);
        return true;
    }

}
