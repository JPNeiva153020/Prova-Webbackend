package com.universidade.sistema_academico.controller;

import com.universidade.sistema_academico.dao.MateriaDAO;
import com.universidade.sistema_academico.entity.Materia;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class MateriaController {

    private final MateriaDAO materiaDAO;

    public MateriaController(MateriaDAO materiaDAO) {
        this.materiaDAO = materiaDAO;
    }

    @GetMapping("/materias/novo")
    public String exibirFormularioCadastro(Model model) {
        model.addAttribute("materia", new Materia());

        return "form-materia";
    }

    @PostMapping("/materias/salvar")
    public String salvarMateria(Materia materia) {
        materiaDAO.salvar(materia);

        return "redirect:/materias";
    }

    @GetMapping("/materias")
    public String listarMaterias(Model model) {
        model.addAttribute("listaMaterias", materiaDAO.listarTodos());

        return "lista-materias";
    }

    @GetMapping("/materias/deletar/{codigo}")
    public String deletarMateria(@PathVariable String codigo) {
        materiaDAO.deletar(codigo);

        return "redirect:/materias";
    }
}