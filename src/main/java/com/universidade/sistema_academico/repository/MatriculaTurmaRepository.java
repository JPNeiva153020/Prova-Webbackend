package com.universidade.sistema_academico.repository;

import com.universidade.sistema_academico.entity.MatriculaTurma;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MatriculaTurmaRepository extends JpaRepository<MatriculaTurma, Integer> {
    List<MatriculaTurma> findAllByOrderByTurma_CodigoAscMateria_CodigoAscAluno_NomeAsc();

    List<MatriculaTurma> findByTurma_CodigoOrderByMateria_CodigoAscAluno_NomeAsc(String turmaCodigo);

    List<MatriculaTurma> findByTurma_CodigoAndMateria_CodigoOrderByAluno_Nome(String turmaCodigo, String materiaCodigo);

    List<MatriculaTurma> findByMateria_CodigoOrderByTurma_CodigoAscAluno_NomeAsc(String materiaCodigo);

    List<MatriculaTurma> findByAluno_MatriculaOrderByTurma_CodigoAscMateria_CodigoAsc(String alunoMatricula);

    Optional<MatriculaTurma> findByTurma_CodigoAndMateria_CodigoAndAluno_Matricula(
            String turmaCodigo,
            String materiaCodigo,
            String alunoMatricula
    );

    void deleteByMateria_Codigo(String materiaCodigo);

    void deleteByTurma_CodigoAndMateria_Codigo(String turmaCodigo, String materiaCodigo);
}
