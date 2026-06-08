package com.universidade.sistema_academico.dao;

import com.universidade.sistema_academico.entity.Materia;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@Repository
public class MateriaDAO {

    private final DataSource dataSource;

    public MateriaDAO(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public void salvar(Materia materia) {
        String sql = "INSERT INTO tb_materia (codigo, ementa) VALUES (?, ?)";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, materia.getCodigo());
            pstmt.setString(2, materia.getEmenta());

            pstmt.executeUpdate();

            System.out.println("Sucesso: Matéria salva com sucesso!");

        } catch (SQLException e) {
            System.out.println("Erro ao salvar matéria: " + e.getMessage());
        }
    }

    public List<Materia> listarTodos() {
        List<Materia> materias = new ArrayList<>();

        String sql = "SELECT codigo, ementa FROM tb_materia ORDER BY codigo";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Materia materia = new Materia();

                materia.setCodigo(rs.getString("codigo"));
                materia.setEmenta(rs.getString("ementa"));

                materias.add(materia);
            }

        } catch (SQLException e) {
            System.out.println("Erro ao listar matérias: " + e.getMessage());
        }

        return materias;
    }

    public void deletar(String codigo) {
        String sql = "DELETE FROM tb_materia WHERE codigo = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, codigo);

            pstmt.executeUpdate();

            System.out.println("Sucesso: Matéria removida com sucesso!");

        } catch (SQLException e) {
            System.out.println("Erro ao deletar matéria: " + e.getMessage());
        }
    }
}