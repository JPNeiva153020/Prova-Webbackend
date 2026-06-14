package com.universidade.sistema_academico.service;

import com.universidade.sistema_academico.entity.Aluno;
import com.universidade.sistema_academico.entity.BoletimAluno;
import com.universidade.sistema_academico.entity.MatriculaTurma;
import com.universidade.sistema_academico.repository.AlunoRepository;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class AlunoService {

    private final AlunoRepository alunoRepository;
    private final MatriculaService matriculaService;

    public AlunoService(AlunoRepository alunoRepository, MatriculaService matriculaService) {
        this.alunoRepository = alunoRepository;
        this.matriculaService = matriculaService;
    }

    public void salvar(Aluno aluno) {
        alunoRepository.save(aluno);
    }

    public List<Aluno> listarTodos() {
        return alunoRepository.findAll(Sort.by("matricula"));
    }

    public void deletar(String matricula) {
        alunoRepository.deleteById(matricula);
    }

    public Aluno buscarPorMatricula(String matricula) {
        return alunoRepository.findById(matricula)
                .orElseThrow(() -> new IllegalArgumentException("Aluno não encontrado: " + matricula));
    }

    public List<BoletimAluno> buscarBoletimDoAluno(String matricula) {
        List<MatriculaTurma> matriculas = matriculaService.listarPorAluno(matricula);

        List<BoletimAluno> boletim = new ArrayList<>();

        for (MatriculaTurma matriculaTurma : matriculas) {
            BoletimAluno boletimAluno = new BoletimAluno();

            boletimAluno.setTurma(matriculaTurma.getTurmaCodigo());
            boletimAluno.setMateriaCodigo(matriculaTurma.getMateriaCodigo());
            boletimAluno.setMateria(matriculaTurma.getMateriaNome());
            if (matriculaTurma.getMateria() != null) {
                boletimAluno.setCargaHoraria(matriculaTurma.getMateria().getCargaHoraria());
            }
            boletimAluno.setNota1(matriculaTurma.getNota1());
            boletimAluno.setNota2(matriculaTurma.getNota2());
            boletimAluno.setNota3(matriculaTurma.getNota3());

            boletim.add(boletimAluno);
        }

        return boletim;
    }

    public List<MatriculaTurma> listarMatriculasDoAluno(String matricula) {
        return matriculaService.listarPorAluno(matricula);
    }

    public boolean matricularEmMateria(MatriculaTurma matriculaTurma) {
        return matriculaService.salvarOuAtualizar(matriculaTurma);
    }
}
