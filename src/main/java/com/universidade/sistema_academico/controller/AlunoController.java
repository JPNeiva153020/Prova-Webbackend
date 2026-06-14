package com.universidade.sistema_academico.controller;

import com.universidade.sistema_academico.entity.Aluno;
import com.universidade.sistema_academico.entity.MatriculaTurma;
import com.universidade.sistema_academico.service.AlunoService;
import com.universidade.sistema_academico.service.TurmaService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class AlunoController {

    private final AlunoService alunoService;
    private final TurmaService turmaService;

    public AlunoController(AlunoService alunoService, TurmaService turmaService) {
        this.alunoService = alunoService;
        this.turmaService = turmaService;
    }

    @GetMapping("/alunos/novo")
    public String exibirFormularioCadastro(Model model) {
        model.addAttribute("aluno", new Aluno());
        return "form-aluno";
    }

    @PostMapping("/alunos/salvar")
    public String salvarAluno(Aluno aluno, RedirectAttributes redirectAttributes) {
        alunoService.salvar(aluno);
        redirectAttributes.addFlashAttribute("sucesso", "Aluno salvo com sucesso.");
        return "redirect:/alunos/novo";
    }

    @GetMapping("/alunos")
    public String listarAlunos(Model model) {
        java.util.List<Aluno> lista = alunoService.listarTodos();
        model.addAttribute("listaAlunos", lista);
        return "lista-alunos";
    }

    @GetMapping("/alunos/deletar/{matricula}")
    public String deletarAluno(@PathVariable String matricula, RedirectAttributes redirectAttributes) {

        alunoService.deletar(matricula);
        redirectAttributes.addFlashAttribute("sucesso", "Aluno removido com sucesso.");

        return "redirect:/alunos";
        
    }

    @GetMapping("/alunos/{matricula}/boletim")
    public String verBoletim(@PathVariable String matricula, Model model) {
        model.addAttribute("matricula", matricula);
        model.addAttribute("boletim", alunoService.buscarBoletimDoAluno(matricula));
        return "boletim-aluno";
    }

    @GetMapping("/alunos/{matricula}/matricular")
    public String exibirMatriculaPorAluno(@PathVariable String matricula, Model model) {
        MatriculaTurma novaMatricula = new MatriculaTurma();
        novaMatricula.setAlunoMatricula(matricula);

        model.addAttribute("aluno", alunoService.buscarPorMatricula(matricula));
        model.addAttribute("matriculaTurma", novaMatricula);
        model.addAttribute("opcoesMatricula", turmaService.listarOpcoesMatricula());
        model.addAttribute("listaMatriculas", alunoService.listarMatriculasDoAluno(matricula));

        return "matricular-aluno";
    }

    @PostMapping("/alunos/{matricula}/matricular/salvar")
    public String salvarMatriculaPorAluno(@PathVariable String matricula,
                                          MatriculaTurma matriculaTurma,
                                          RedirectAttributes redirectAttributes) {
        matriculaTurma.setAlunoMatricula(matricula);

        try {
            boolean nova = alunoService.matricularEmMateria(matriculaTurma);
            redirectAttributes.addFlashAttribute("sucesso", nova ? "Aluno matriculado com sucesso." : "Notas atualizadas com sucesso.");
        } catch (IllegalArgumentException ex) {
            redirectAttributes.addFlashAttribute("erro", ex.getMessage());
        }

        return "redirect:/alunos/" + matricula + "/matricular";
    }
}
