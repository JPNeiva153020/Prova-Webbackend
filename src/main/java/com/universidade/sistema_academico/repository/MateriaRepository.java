package com.universidade.sistema_academico.repository;

import com.universidade.sistema_academico.entity.Materia;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MateriaRepository extends JpaRepository<Materia, String> {
}
