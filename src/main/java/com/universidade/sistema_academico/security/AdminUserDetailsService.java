package com.universidade.sistema_academico.security;

import com.universidade.sistema_academico.dao.AdminUserDAO;
import com.universidade.sistema_academico.entity.AdminUser;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class AdminUserDetailsService implements UserDetailsService {

    private final AdminUserDAO adminUserDAO;

    public AdminUserDetailsService(AdminUserDAO adminUserDAO) {
        this.adminUserDAO = adminUserDAO;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        AdminUser admin = adminUserDAO.buscarPorUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("Administrador não encontrado: " + username));

        return User.builder()
                .username(admin.getUsername())
                .password(admin.getPassword())   // já está criptografado (BCrypt) no banco
                .roles("ADMIN")
                .build();
    }
}
