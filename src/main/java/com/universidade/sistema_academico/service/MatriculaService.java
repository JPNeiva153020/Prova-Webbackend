package com.universidade.sistema_academico.service;

import com.universidade.sistema_academico.entity.Aluno;
import com.universidade.sistema_academico.entity.Materia;
import com.universidade.sistema_academico.entity.MatriculaTurma;
import com.universidade.sistema_academico.entity.Turma;
import com.universidade.sistema_academico.repository.AlunoRepository;
import com.universidade.sistema_academico.repository.MateriaRepository;
import com.universidade.sistema_academico.repository.MatriculaTurmaRepository;
import com.universidade.sistema_academico.repository.TurmaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class MatriculaService {

    private final MatriculaTurmaRepository matriculaTurmaRepository;
    private final TurmaRepository turmaRepository;
    private final MateriaRepository materiaRepository;
    private final AlunoRepository alunoRepository;

    public MatriculaService(MatriculaTurmaRepository matriculaTurmaRepository,
                            TurmaRepository turmaRepository,
                            MateriaRepository materiaRepository,
                            AlunoRepository alunoRepository) {
        this.matriculaTurmaRepository = matriculaTurmaRepository;
        this.turmaRepository = turmaRepository;
        this.materiaRepository = materiaRepository;
        this.alunoRepository = alunoRepository;
    }

    public List<MatriculaTurma> listarTodos() {
        return matriculaTurmaRepository.findAllByOrderByTurma_CodigoAscMateria_CodigoAscAluno_NomeAsc();
    }

    public List<MatriculaTurma> listarPorTurma(String turmaCodigo) {
        return matriculaTurmaRepository.findByTurma_CodigoOrderByMateria_CodigoAscAluno_NomeAsc(turmaCodigo);
    }

    public List<MatriculaTurma> listarPorTurmaEMateria(String turmaCodigo, String materiaCodigo) {
        return matriculaTurmaRepository.findByTurma_CodigoAndMateria_CodigoOrderByAluno_Nome(turmaCodigo, materiaCodigo);
    }

    public List<MatriculaTurma> listarPorMateria(String materiaCodigo) {
        return matriculaTurmaRepository.findByMateria_CodigoOrderByTurma_CodigoAscAluno_NomeAsc(materiaCodigo);
    }

    public List<MatriculaTurma> listarPorAluno(String alunoMatricula) {
        return matriculaTurmaRepository.findByAluno_MatriculaOrderByTurma_CodigoAscMateria_CodigoAsc(alunoMatricula);
    }

    public List<MatriculaTurma> filtrar(String turmaCodigo, String materiaCodigo) {
        boolean temTurma = turmaCodigo != null && !turmaCodigo.isBlank();
        boolean temMateria = materiaCodigo != null && !materiaCodigo.isBlank();

        if (temTurma && temMateria) {
            return listarPorTurmaEMateria(turmaCodigo, materiaCodigo);
        }

        if (temTurma) {
            return listarPorTurma(turmaCodigo);
        }

        if (temMateria) {
            return listarPorMateria(materiaCodigo);
        }

        return listarTodos();
    }

    @Transactional
    public boolean salvarOuAtualizar(MatriculaTurma dados) {
        Turma turma = turmaRepository.findById(dados.getTurmaCodigo())
                .orElseThrow(() -> new IllegalArgumentException("Turma não encontrada: " + dados.getTurmaCodigo()));

        Materia materia = materiaRepository.findById(dados.getMateriaCodigo())
                .orElseThrow(() -> new IllegalArgumentException("Matéria não encontrada: " + dados.getMateriaCodigo()));

        Aluno aluno = alunoRepository.findById(dados.getAlunoMatricula())
                .orElseThrow(() -> new IllegalArgumentException("Aluno não encontrado: " + dados.getAlunoMatricula()));

        if (!turma.possuiMateria(materia.getCodigo())) {
            throw new IllegalArgumentException("A matéria " + materia.getCodigo() + " não está vinculada à turma " + turma.getCodigo());
        }

        MatriculaTurma matricula = matriculaTurmaRepository
                .findByTurma_CodigoAndMateria_CodigoAndAluno_Matricula(turma.getCodigo(), materia.getCodigo(), aluno.getMatricula())
                .orElseGet(MatriculaTurma::new);

        boolean nova = matricula.getId() == null;

        matricula.setTurma(turma);
        matricula.setMateria(materia);
        matricula.setAluno(aluno);
        matricula.setNota1(dados.getNota1());
        matricula.setNota2(dados.getNota2());
        matricula.setNota3(dados.getNota3());

        matriculaTurmaRepository.save(matricula);
        return nova;
    }

    public void remover(Integer id) {
        matriculaTurmaRepository.deleteById(id);
    }

    @Transactional
    public void removerPorMateria(String materiaCodigo) {
        matriculaTurmaRepository.deleteByMateria_Codigo(materiaCodigo);
    }

    @Transactional
    public void removerPorTurmaEMateria(String turmaCodigo, String materiaCodigo) {
        matriculaTurmaRepository.deleteByTurma_CodigoAndMateria_Codigo(turmaCodigo, materiaCodigo);
    }
}
