package com.universidade.sistema_academico.controller;

import com.universidade.sistema_academico.dao.AlunoDAO;
import com.universidade.sistema_academico.entity.Aluno;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class AlunoController {

    private AlunoDAO alunoDAO;

    public AlunoController(AlunoDAO alunoDAO) {
        this.alunoDAO = alunoDAO;
    }

    @GetMapping("/alunos/novo")
    public String exibirFormularioCadastro(Model model) {
        model.addAttribute("aluno", new Aluno());
        return "form-aluno";
    }

    @PostMapping("/alunos/salvar")
    public String salvarAluno(Aluno aluno) {
        alunoDAO.salvar(aluno);
        return "redirect:/alunos/novo";
    }

    @GetMapping("/alunos")
    public String listarAlunos(Model model) {
        java.util.List<Aluno> lista = alunoDAO.listarTodos();
        model.addAttribute("listaAlunos", lista);
        return "lista-alunos";
    }

    @GetMapping("/alunos/deletar/{matricula}")
    public String deletarAluno(@PathVariable String matricula) {

        alunoDAO.deletar(matricula);

        return "redirect:/alunos";
        
    }
}