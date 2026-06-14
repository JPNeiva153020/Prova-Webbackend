package com.universidade.sistema_academico.controller;

import com.universidade.sistema_academico.entity.Materia;
import com.universidade.sistema_academico.service.MateriaService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class MateriaController {

    private final MateriaService materiaService;

    public MateriaController(MateriaService materiaService) {
        this.materiaService = materiaService;
    }

    @GetMapping("/materias/novo")
    public String exibirFormularioCadastro(Model model) {
        model.addAttribute("materia", new Materia());

        return "form-materia";
    }

    @PostMapping("/materias/salvar")
    public String salvarMateria(Materia materia, RedirectAttributes redirectAttributes) {
        materiaService.salvar(materia);
        redirectAttributes.addFlashAttribute("sucesso", "Matéria salva com sucesso.");

        return "redirect:/materias";
    }

    @GetMapping("/materias")
    public String listarMaterias(Model model) {
        model.addAttribute("listaMaterias", materiaService.listarTodos());

        return "lista-materias";
    }

    @GetMapping("/materias/deletar/{codigo}")
    public String deletarMateria(@PathVariable String codigo, RedirectAttributes redirectAttributes) {
        materiaService.deletar(codigo);
        redirectAttributes.addFlashAttribute("sucesso", "Matéria removida. Turmas e alunos foram mantidos.");

        return "redirect:/materias";
    }

    @GetMapping("/materias/{codigo}/detalhes")
    public String detalhesMateria(@PathVariable String codigo, Model model) {
        model.addAttribute("materia", materiaService.buscarPorCodigo(codigo));
        model.addAttribute("listaTurmas", materiaService.listarTurmasDaMateria(codigo));
        model.addAttribute("listaMatriculas", materiaService.listarAlunosDaMateria(codigo));

        return "detalhes-materia";
    }
}
