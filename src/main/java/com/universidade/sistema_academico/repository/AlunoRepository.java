package com.universidade.sistema_academico.repository;

import com.universidade.sistema_academico.entity.Aluno;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AlunoRepository extends JpaRepository<Aluno, String> {
}
