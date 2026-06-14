package com.universidade.sistema_academico.repository;

import com.universidade.sistema_academico.entity.Turma;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TurmaRepository extends JpaRepository<Turma, String> {
    List<Turma> findDistinctByMaterias_CodigoOrderByCodigo(String materiaCodigo);
}
