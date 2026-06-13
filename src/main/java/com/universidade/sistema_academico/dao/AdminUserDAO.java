package com.universidade.sistema_academico.dao;

import com.universidade.sistema_academico.entity.AdminUser;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Optional;

@Repository
public class AdminUserDAO {

    private final DataSource dataSource;

    public AdminUserDAO(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public Optional<AdminUser> buscarPorUsername(String username) {
        String sql = "SELECT id, username, password FROM tb_admin WHERE username = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, username);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    AdminUser user = new AdminUser();
                    user.setId(rs.getLong("id"));
                    user.setUsername(rs.getString("username"));
                    user.setPassword(rs.getString("password"));
                    return Optional.of(user);
                }
            }

        } catch (SQLException e) {
            System.err.println("Erro ao buscar administrador: " + e.getMessage());
        }

        return Optional.empty();
    }
}
