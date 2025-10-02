package com.suza.id_link_sys.Security;

import com.suza.id_link_sys.Repository.AdminRepository;
import com.suza.id_link_sys.Repository.StudentsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.logging.Logger;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    private static final Logger LOGGER = Logger.getLogger(UserDetailsServiceImpl.class.getName());

    @Autowired
    private AdminRepository adminRepository;

    @Autowired
    private StudentsRepository studentsRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // Check if admin
        return adminRepository.findByUsername(username)
                .map(admin -> {
                    LOGGER.info("Loading ADMIN user: " + username);
                    List<GrantedAuthority> authorities = Collections.singletonList(
                            new SimpleGrantedAuthority("ROLE_ADMIN") // Updated to include ROLE_ prefix
                    );
                    return new User(
                            admin.getUsername(),
                            admin.getPassword(),
                            true, true, true, true, // enabled, accountNonExpired, credentialsNonExpired, accountNonLocked
                            authorities
                    );
                })
                // Check if student
                .orElseGet(() -> studentsRepository.findByRegNumber(username)
                        .map(student -> {
                            LOGGER.info("Loading STUDENT user: " + username);
                            List<GrantedAuthority> authorities = Collections.singletonList(
                                    new SimpleGrantedAuthority("ROLE_STUDENT") // Updated to include ROLE_ prefix
                            );
                            return new User(
                                    student.getRegNumber(),
                                    student.getPassword(),
                                    true, true, true, true,
                                    authorities
                            );
                        })
                        .orElseThrow(() -> {
                            LOGGER.severe("User not found: " + username);
                            return new UsernameNotFoundException("User not found: " + username);
                        })
                );
    }
}