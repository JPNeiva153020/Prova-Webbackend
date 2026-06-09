package com.universidade.sistema_academico.controller;

import com.universidade.sistema_academico.dao.AlunoDAO;
import com.universidade.sistema_academico.dao.MateriaDAO;
import com.universidade.sistema_academico.dao.TurmaDAO;
import com.universidade.sistema_academico.entity.MatriculaTurma;
import com.universidade.sistema_academico.entity.Turma;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class TurmaController {

    private final TurmaDAO turmaDAO;
    private final MateriaDAO materiaDAO;
    private final AlunoDAO alunoDAO;

    public TurmaController(TurmaDAO turmaDAO, MateriaDAO materiaDAO, AlunoDAO alunoDAO) {
        this.turmaDAO = turmaDAO;
        this.materiaDAO = materiaDAO;
        this.alunoDAO = alunoDAO;
    }

    @GetMapping("/turmas/novo")
    public String exibirFormularioCadastro(Model model) {
        model.addAttribute("turma", new Turma());
        model.addAttribute("listaMaterias", materiaDAO.listarTodos());

        return "form-turma";
    }

    @PostMapping("/turmas/salvar")
    public String salvarTurma(Turma turma) {
        turmaDAO.salvar(turma);

        return "redirect:/turmas";
    }

    @GetMapping("/turmas")
    public String listarTurmas(Model model) {
        model.addAttribute("listaTurmas", turmaDAO.listarTodos());

        return "lista-turmas";
    }

    @GetMapping("/turmas/deletar/{codigo}")
    public String deletarTurma(@PathVariable String codigo) {
        turmaDAO.deletar(codigo);

        return "redirect:/turmas";
    }

    @GetMapping("/turmas/{codigo}/matriculas")
    public String exibirMatriculasDaTurma(@PathVariable String codigo, Model model) {
        MatriculaTurma novaMatricula = new MatriculaTurma();

        novaMatricula.setTurmaCodigo(codigo);

        model.addAttribute("turmaCodigo", codigo);
        model.addAttribute("matriculaTurma", novaMatricula);
        model.addAttribute("listaAlunos", alunoDAO.listarTodos());
        model.addAttribute("listaMatriculas", turmaDAO.listarMatriculasPorTurma(codigo));

        return "matriculas-turmas";
    }

    @PostMapping("/turmas/{codigo}/matriculas/salvar")
    public String matricularAluno(@PathVariable String codigo, MatriculaTurma matriculaTurma) {
        matriculaTurma.setTurmaCodigo(codigo);

        turmaDAO.matricularAluno(matriculaTurma);

        return "redirect:/turmas/" + codigo + "/matriculas";
    }

    @GetMapping("/turmas/{codigo}/matriculas/deletar/{id}")
    public String removerMatricula(@PathVariable String codigo, @PathVariable Integer id) {
        turmaDAO.removerMatricula(id);

        return "redirect:/turmas/" + codigo + "/matriculas";
    }
}