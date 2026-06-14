package com.universidade.sistema_academico.controller;

import com.universidade.sistema_academico.entity.MatriculaTurma;
import com.universidade.sistema_academico.entity.Turma;
import com.universidade.sistema_academico.service.AlunoService;
import com.universidade.sistema_academico.service.MateriaService;
import com.universidade.sistema_academico.service.TurmaService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class TurmaController {

    private final TurmaService turmaService;
    private final MateriaService materiaService;
    private final AlunoService alunoService;

    public TurmaController(TurmaService turmaService, MateriaService materiaService, AlunoService alunoService) {
        this.turmaService = turmaService;
        this.materiaService = materiaService;
        this.alunoService = alunoService;
    }

    @GetMapping("/turmas/novo")
    public String exibirFormularioCadastro(Model model) {
        model.addAttribute("turma", new Turma());
        model.addAttribute("listaMaterias", materiaService.listarTodos());

        return "form-turma";
    }

    @PostMapping("/turmas/salvar")
    public String salvarTurma(Turma turma, RedirectAttributes redirectAttributes) {
        turmaService.salvar(turma);
        redirectAttributes.addFlashAttribute("sucesso", "Turma salva com sucesso.");

        return "redirect:/turmas";
    }

    @GetMapping("/turmas")
    public String listarTurmas(Model model) {
        model.addAttribute("listaTurmas", turmaService.listarTodos());

        return "lista-turmas";
    }

    @GetMapping("/turmas/notas")
    public String consultarNotas(@RequestParam(required = false) String turmaCodigo,
                                 @RequestParam(required = false) String materiaCodigo,
                                 Model model) {
        boolean turmaSelecionada = turmaCodigo != null && !turmaCodigo.isBlank();

        model.addAttribute("listaTurmas", turmaService.listarTodos());
        model.addAttribute("listaMaterias", turmaSelecionada
                ? turmaService.listarMateriasDaTurma(turmaCodigo)
                : materiaService.listarTodos());
        model.addAttribute("turmaCodigo", turmaCodigo);
        model.addAttribute("materiaCodigo", materiaCodigo);
        model.addAttribute("listaMatriculas", turmaService.filtrarMatriculas(turmaCodigo, materiaCodigo));

        return "consulta-notas";
    }

    @GetMapping("/turmas/deletar/{codigo}")
    public String deletarTurma(@PathVariable String codigo, RedirectAttributes redirectAttributes) {
        turmaService.deletar(codigo);
        redirectAttributes.addFlashAttribute("sucesso", "Turma removida. Alunos e matérias foram mantidos.");

        return "redirect:/turmas";
    }

    @GetMapping("/turmas/{codigo}/matriculas")
    public String exibirMatriculasDaTurma(@PathVariable String codigo, Model model) {
        MatriculaTurma novaMatricula = new MatriculaTurma();

        novaMatricula.setTurmaCodigo(codigo);

        model.addAttribute("turmaCodigo", codigo);
        model.addAttribute("matriculaTurma", novaMatricula);
        model.addAttribute("listaAlunos", alunoService.listarTodos());
        model.addAttribute("listaMaterias", turmaService.listarMateriasDaTurma(codigo));
        model.addAttribute("listaMatriculas", turmaService.listarMatriculasPorTurma(codigo));

        return "matriculas-turmas";
    }

    @PostMapping("/turmas/{codigo}/matriculas/salvar")
    public String matricularAluno(@PathVariable String codigo, MatriculaTurma matriculaTurma, RedirectAttributes redirectAttributes) {
        matriculaTurma.setTurmaCodigo(codigo);

        try {
            boolean nova = turmaService.matricularAluno(matriculaTurma);
            redirectAttributes.addFlashAttribute("sucesso", nova ? "Aluno matriculado com sucesso." : "Notas atualizadas com sucesso.");
        } catch (IllegalArgumentException ex) {
            redirectAttributes.addFlashAttribute("erro", ex.getMessage());
        }

        return "redirect:/turmas/" + codigo + "/matriculas";
    }

    @GetMapping("/turmas/{codigo}/matriculas/deletar/{id}")
    public String removerMatricula(@PathVariable String codigo, @PathVariable Integer id, RedirectAttributes redirectAttributes) {
        turmaService.removerMatricula(id);
        redirectAttributes.addFlashAttribute("sucesso", "Matrícula removida com sucesso.");

        return "redirect:/turmas/" + codigo + "/matriculas";
    }

    @GetMapping("/turmas/{codigo}/materias")
    public String detalhesMateriasDaTurma(@PathVariable String codigo, Model model) {
        model.addAttribute("turma", turmaService.buscarPorCodigo(codigo));
        model.addAttribute("listaMaterias", turmaService.listarMateriasDaTurma(codigo));
        model.addAttribute("todasMaterias", materiaService.listarTodos());
        model.addAttribute("listaMatriculas", turmaService.listarMatriculasPorTurma(codigo));

        return "materias-turma";
    }

    @PostMapping("/turmas/{codigo}/materias/vincular")
    public String vincularMateria(@PathVariable String codigo, String materiaCodigo, RedirectAttributes redirectAttributes) {
        try {
            turmaService.vincularMateria(codigo, materiaCodigo);
            redirectAttributes.addFlashAttribute("sucesso", "Matéria vinculada à turma.");
        } catch (IllegalArgumentException ex) {
            redirectAttributes.addFlashAttribute("erro", ex.getMessage());
        }

        return "redirect:/turmas/" + codigo + "/materias";
    }

    @GetMapping("/turmas/{codigo}/materias/remover/{materiaCodigo}")
    public String desvincularMateria(@PathVariable String codigo,
                                     @PathVariable String materiaCodigo,
                                     RedirectAttributes redirectAttributes) {
        turmaService.desvincularMateria(codigo, materiaCodigo);
        redirectAttributes.addFlashAttribute("sucesso", "Matéria removida da turma. Alunos e turma foram mantidos.");

        return "redirect:/turmas/" + codigo + "/materias";
    }
}
