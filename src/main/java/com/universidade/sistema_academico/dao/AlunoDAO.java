package com.universidade.sistema_academico.dao;

import com.universidade.sistema_academico.entity.Aluno;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@Repository
public class AlunoDAO {
    @Autowired
    private final DataSource dataSource;

    public AlunoDAO(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public void salvar(Aluno aluno) {
        String sql = "INSERT INTO tb_aluno (matricula, nome, endereco, data_ingresso) VALUES (?, ?, ?, ?)";

        try (Connection conn = dataSource.getConnection();
        PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, aluno.getMatricula());
            pstmt.setString(2, aluno.getNome());
            pstmt.setString(3, aluno.getEndereco());

            pstmt.setDate(4, java.sql.Date.valueOf(aluno.getDataIngresso()));

            pstmt.executeUpdate();

            System.out.println("Sucesso: Aluno Salvo com sucesso!");
        } catch (SQLException e) {
            System.out.println("Erro ao salvar: " + e.getMessage());
        }
    }
}
