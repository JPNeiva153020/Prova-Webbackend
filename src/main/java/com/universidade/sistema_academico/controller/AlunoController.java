package com.universidade.sistema_academico.controller;

import com.universidade.sistema_academico.dao.AlunoDAO;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class AlunoController {

    private AlunoDAO alunoDAO;

    public AlunoController(AlunoDAO alunoDAO) {
        this.alunoDAO = alunoDAO;
    }

    @GetMapping("/cadastrar-aluno")
    public String cadastrarAluno(org.springframework.ui.Model model) {

        model.addAttribute("aluno", new com.universidade.sistema_academico.entity.Aluno());

        return "cadastrar-aluno";
    }
}
