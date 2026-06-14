package com.universidade.sistema_academico.service;

import com.universidade.sistema_academico.entity.Aluno;
import com.universidade.sistema_academico.entity.Materia;
import com.universidade.sistema_academico.entity.MatriculaOpcao;
import com.universidade.sistema_academico.entity.MatriculaTurma;
import com.universidade.sistema_academico.entity.Turma;
import com.universidade.sistema_academico.repository.MateriaRepository;
import com.universidade.sistema_academico.repository.TurmaRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import java.util.ArrayList;

@Service
public class TurmaService {

    private final TurmaRepository turmaRepository;
    private final MateriaRepository materiaRepository;
    private final MatriculaService matriculaService;

    public TurmaService(TurmaRepository turmaRepository,
                        MateriaRepository materiaRepository,
                        MatriculaService matriculaService) {
        this.turmaRepository = turmaRepository;
        this.materiaRepository = materiaRepository;
        this.matriculaService = matriculaService;
    }

    @Transactional
    public void salvar(Turma turma) {
        String materiaCodigo = turma.getMateriaCodigo();
        if (materiaCodigo != null && !materiaCodigo.isBlank()) {
            Materia materia = materiaRepository.findById(materiaCodigo)
                    .orElseThrow(() -> new IllegalArgumentException("Matéria não encontrada: " + materiaCodigo));
            turma.adicionarMateria(materia);
        }
        turmaRepository.save(turma);
    }

    public List<Turma> listarTodos() {
        return turmaRepository.findAll(Sort.by("codigo"));
    }

    public List<MatriculaOpcao> listarOpcoesMatricula() {
        List<MatriculaOpcao> opcoes = new ArrayList<>();

        for (Turma turma : listarTodos()) {
            for (Materia materia : turma.getMaterias()) {
                opcoes.add(new MatriculaOpcao(
                        turma.getCodigo() + "|" + materia.getCodigo(),
                        turma.getCodigo() + " - " + materia.getResumo()
                ));
            }
        }

        return opcoes;
    }

    public void deletar(String codigo) {
        turmaRepository.deleteById(codigo);
    }

    public Turma buscarPorCodigo(String codigo) {
        return turmaRepository.findById(codigo)
                .orElseThrow(() -> new IllegalArgumentException("Turma não encontrada: " + codigo));
    }

    public Set<Materia> listarMateriasDaTurma(String turmaCodigo) {
        return buscarPorCodigo(turmaCodigo).getMaterias();
    }

    public List<Turma> listarPorMateria(String materiaCodigo) {
        return turmaRepository.findDistinctByMaterias_CodigoOrderByCodigo(materiaCodigo);
    }

    public List<MatriculaTurma> listarMatriculasPorTurma(String turmaCodigo) {
        return matriculaService.listarPorTurma(turmaCodigo);
    }

    public List<MatriculaTurma> listarMatriculasPorTurmaEMateria(String turmaCodigo, String materiaCodigo) {
        return matriculaService.listarPorTurmaEMateria(turmaCodigo, materiaCodigo);
    }

    public List<MatriculaTurma> filtrarMatriculas(String turmaCodigo, String materiaCodigo) {
        return matriculaService.filtrar(turmaCodigo, materiaCodigo);
    }

    @Transactional
    public void vincularMateria(String turmaCodigo, String materiaCodigo) {
        Turma turma = buscarPorCodigo(turmaCodigo);
        Materia materia = materiaRepository.findById(materiaCodigo)
                .orElseThrow(() -> new IllegalArgumentException("Matéria não encontrada: " + materiaCodigo));

        turma.adicionarMateria(materia);
        turmaRepository.save(turma);
    }

    @Transactional
    public void desvincularMateria(String turmaCodigo, String materiaCodigo) {
        Turma turma = buscarPorCodigo(turmaCodigo);

        matriculaService.removerPorTurmaEMateria(turmaCodigo, materiaCodigo);
        turma.removerMateria(materiaCodigo);
        turmaRepository.save(turma);
    }

    public boolean matricularAluno(MatriculaTurma matriculaTurma) {
        return matriculaService.salvarOuAtualizar(matriculaTurma);
    }

    public void removerMatricula(Integer id) {
        matriculaService.remover(id);
    }
}
