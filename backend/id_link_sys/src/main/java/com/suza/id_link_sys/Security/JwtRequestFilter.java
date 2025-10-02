package com.suza.id_link_sys.Security;

import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.logging.Logger;

@Component
public class JwtRequestFilter extends OncePerRequestFilter {

    private static final Logger LOGGER = Logger.getLogger(JwtRequestFilter.class.getName());

    @Autowired
    private UserDetailsServiceImpl userDetailsService;

    @Autowired
    private JwtUtil jwtUtil;


    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        return path.startsWith("/uploads/"); // ⬅️ skip static files
    }


    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {

        final String requestUri = request.getRequestURI();
        LOGGER.info("Processing request for: " + requestUri);

        // Skip filter for public endpoints
        if (requestUri.startsWith("/api/auth/") || requestUri.equals("/api/student/login")) {
            chain.doFilter(request, response);
            return;
        }

        // Validate Authorization header
        final String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            LOGGER.warning("Missing or invalid Authorization header");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Authorization header missing or invalid");
            return;
        }

        // Extract token
        final String jwt = authHeader.substring(7);
        String username;
        String role;

        try {
            username = jwtUtil.extractUsername(jwt);
            role = jwtUtil.extractRole(jwt);

            LOGGER.info("Authenticating user: " + username + " with role: " + role);

            if (username == null || role == null) {
                throw new JwtException("Invalid token claims");
            }

            // Validate token
            if (!jwtUtil.validateToken(jwt, username)) {
                LOGGER.warning("Token validation failed for user: " + username);
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid token");
                return;
            }

            // Load user details
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);
            LOGGER.info("User authorities: " + userDetails.getAuthorities());

            // Create authentication token
            UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(
                            userDetails,
                            null,
                            userDetails.getAuthorities()
                    );
            authentication.setDetails(
                    new WebAuthenticationDetailsSource().buildDetails(request)
            );

            // Set authentication in security context
            SecurityContextHolder.getContext().setAuthentication(authentication);
            LOGGER.info("Successfully authenticated user: " + username);

        } catch (JwtException | IllegalArgumentException e) {
            LOGGER.severe("JWT processing error: " + e.getMessage());
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid token");
            return;
        } catch (Exception e) {
            LOGGER.severe("Authentication error: " + e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Authentication failed");
            return;
        }

        chain.doFilter(request, response);
    }
}