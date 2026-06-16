package com.universidade.sistema_academico.dao;

import com.universidade.sistema_academico.entity.MatriculaTurma;
import com.universidade.sistema_academico.entity.Turma;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@Repository
public class TurmaDAO {

    private final DataSource dataSource;

    public TurmaDAO(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public void salvar(Turma turma) {
        String sql = "INSERT INTO tb_turma (codigo, materia_codigo) VALUES (?, ?)";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, turma.getCodigo());
            pstmt.setString(2, turma.getMateriaCodigo());

            pstmt.executeUpdate();

            System.out.println("Sucesso: Turma salva com sucesso!");

        } catch (SQLException e) {
            System.out.println("Erro ao salvar turma: " + e.getMessage());
        }
    }

    public List<Turma> listarTodos() {
        List<Turma> turmas = new ArrayList<>();

        String sql = """
                SELECT t.codigo, t.materia_codigo, m.ementa
                FROM tb_turma t
                LEFT JOIN tb_materia m ON m.codigo = t.materia_codigo
                ORDER BY t.codigo
                """;

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Turma turma = new Turma();

                turma.setCodigo(rs.getString("codigo"));
                turma.setMateriaCodigo(rs.getString("materia_codigo"));
                turma.setMateriaEmenta(rs.getString("ementa"));

                turmas.add(turma);
            }

        } catch (SQLException e) {
            System.out.println("Erro ao listar turmas: " + e.getMessage());
        }

        return turmas;
    }

    public void deletar(String codigo) {
        String sql = "DELETE FROM tb_turma WHERE codigo = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, codigo);

            pstmt.executeUpdate();

            System.out.println("Sucesso: Turma removida com sucesso!");

        } catch (SQLException e) {
            System.out.println("Erro ao deletar turma: " + e.getMessage());
        }
    }

    public void matricularAluno(MatriculaTurma matriculaTurma) {
        String sql = """
                INSERT INTO tb_turma_aluno_nota
                (turma_codigo, aluno_matricula, nota1, nota2, nota3)
                VALUES (?, ?, ?, ?, ?)
                """;

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, matriculaTurma.getTurmaCodigo());
            pstmt.setString(2, matriculaTurma.getAlunoMatricula());
            pstmt.setDouble(3, matriculaTurma.getNota1());
            pstmt.setDouble(4, matriculaTurma.getNota2());
            pstmt.setDouble(5, matriculaTurma.getNota3());

            pstmt.executeUpdate();

            System.out.println("Sucesso: Aluno matriculado na turma!");

        } catch (SQLException e) {
            System.out.println("Erro ao matricular aluno: " + e.getMessage());
        }
    }

    public List<MatriculaTurma> listarMatriculasPorTurma(String turmaCodigo) {
        List<MatriculaTurma> matriculas = new ArrayList<>();

        String sql = """
                SELECT tan.id,
                       tan.turma_codigo,
                       tan.aluno_matricula,
                       a.nome AS aluno_nome,
                       tan.nota1,
                       tan.nota2,
                       tan.nota3
                FROM tb_turma_aluno_nota tan
                INNER JOIN tb_aluno a ON a.matricula = tan.aluno_matricula
                WHERE tan.turma_codigo = ?
                ORDER BY a.nome
                """;

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, turmaCodigo);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    MatriculaTurma matriculaTurma = new MatriculaTurma();

                    matriculaTurma.setId(rs.getInt("id"));
                    matriculaTurma.setTurmaCodigo(rs.getString("turma_codigo"));
                    matriculaTurma.setAlunoMatricula(rs.getString("aluno_matricula"));
                    matriculaTurma.setAlunoNome(rs.getString("aluno_nome"));
                    matriculaTurma.setNota1(rs.getDouble("nota1"));
                    matriculaTurma.setNota2(rs.getDouble("nota2"));
                    matriculaTurma.setNota3(rs.getDouble("nota3"));

                    matriculas.add(matriculaTurma);
                }
            }

        } catch (SQLException e) {
            System.out.println("Erro ao listar matrículas da turma: " + e.getMessage());
        }

        return matriculas;
    }

    public void removerMatricula(Integer id) {
        String sql = "DELETE FROM tb_turma_aluno_nota WHERE id = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);

            pstmt.executeUpdate();

            System.out.println("Sucesso: Matrícula removida da turma!");

        } catch (SQLException e) {
            System.out.println("Erro ao remover matrícula da turma: " + e.getMessage());
        }
    }
}