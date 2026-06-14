package com.universidade.sistema_academico.service;

import com.universidade.sistema_academico.entity.Materia;
import com.universidade.sistema_academico.entity.MatriculaTurma;
import com.universidade.sistema_academico.entity.Turma;
import com.universidade.sistema_academico.repository.MateriaRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class MateriaService {

    private final MateriaRepository materiaRepository;
    private final TurmaService turmaService;
    private final MatriculaService matriculaService;

    public MateriaService(MateriaRepository materiaRepository, TurmaService turmaService, MatriculaService matriculaService) {
        this.materiaRepository = materiaRepository;
        this.turmaService = turmaService;
        this.matriculaService = matriculaService;
    }

    public void salvar(Materia materia) {
        materiaRepository.save(materia);
    }

    public List<Materia> listarTodos() {
        return materiaRepository.findAll(Sort.by("codigo"));
    }

    public Materia buscarPorCodigo(String codigo) {
        return materiaRepository.findById(codigo)
                .orElseThrow(() -> new IllegalArgumentException("Matéria não encontrada: " + codigo));
    }

    public List<Turma> listarTurmasDaMateria(String codigo) {
        return turmaService.listarPorMateria(codigo);
    }

    public List<MatriculaTurma> listarAlunosDaMateria(String codigo) {
        return matriculaService.listarPorMateria(codigo);
    }

    @Transactional
    public void deletar(String codigo) {
        List<Turma> turmas = turmaService.listarPorMateria(codigo);

        matriculaService.removerPorMateria(codigo);
        for (Turma turma : turmas) {
            turma.removerMateria(codigo);
        }

        materiaRepository.deleteById(codigo);
    }
}
