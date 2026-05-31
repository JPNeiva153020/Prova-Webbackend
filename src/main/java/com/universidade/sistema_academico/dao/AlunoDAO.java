package com.universidade.sistema_academico.dao;

import com.universidade.sistema_academico.entity.Aluno;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@Repository
public class AlunoDAO {

    @Autowired
    private DataSource dataSource;

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

    public List<Aluno> listarTodos() {
        List<Aluno> alunos = new ArrayList<>();
        String sql = "SELECT * FROM tb_aluno";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {

                Aluno aluno = new Aluno();

                aluno.setMatricula(rs.getString("matricula"));
                aluno.setNome(rs.getString("nome"));
                aluno.setEndereco(rs.getString("endereco"));

                if (rs.getDate("data_ingresso") != null) {
                    aluno.setDataIngresso(rs.getDate("data_ingresso").toLocalDate());
                }

                alunos.add(aluno);
            }

        } catch (SQLException e) {
            System.err.println("Erro ao listar alunos: " + e.getMessage());
        }

        return alunos;
    }

    public void deletar(String matricula) {
        String sql = "DELETE FROM tb_aluno WHERE matricula = ?";

        try (Connection conn = dataSource.getConnection();
        PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, matricula);

            pstmt.executeUpdate();
            System.out.println("Sucesso: Aluno com matrícula " + matricula + " foi removido!");
        } catch (SQLException e) {
            System.out.println("Erro ao deletar aluno: " + e.getMessage());
        }
    }
}