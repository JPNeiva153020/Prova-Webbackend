package com.universidade.sistema_academico.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

@Entity
@Table(name = "tb_turma_aluno_nota")
public class MatriculaTurma {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "turma_codigo", nullable = false)
    private Turma turma;

    @ManyToOne
    @JoinColumn(name = "aluno_matricula", nullable = false)
    private Aluno aluno;

    @ManyToOne
    @JoinColumn(name = "materia_codigo", nullable = false)
    private Materia materia;

    @Transient
    private String turmaCodigo;

    @Transient
    private String alunoMatricula;

    @Transient
    private String alunoNome;

    @Transient
    private String materiaCodigo;

    @Transient
    private String materiaEmenta;

    @Transient
    private String materiaNome;

    @Transient
    private String turmaMateria;

    @Column(name = "nota1", nullable = false)
    private Double nota1;

    @Column(name = "nota2", nullable = false)
    private Double nota2;

    @Column(name = "nota3", nullable = false)
    private Double nota3;

    public MatriculaTurma() {
    }

    public Double getMedia() {
        if (nota1 == null || nota2 == null || nota3 == null) {
            return null;
        }

        return (nota1 + nota2 + nota3) / 3.0;
    }

    public String getStatus() {
        Double media = getMedia();

        if (media == null) {
            return "Sem notas";
        }

        return media >= 6.0 ? "Aprovado" : "Reprovado";
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getTurmaCodigo() {
        if (turma != null) {
            return turma.getCodigo();
        }

        return turmaCodigo;
    }

    public void setTurmaCodigo(String turmaCodigo) {
        this.turmaCodigo = turmaCodigo;
    }

    public String getAlunoMatricula() {
        if (aluno != null) {
            return aluno.getMatricula();
        }

        return alunoMatricula;
    }

    public void setAlunoMatricula(String alunoMatricula) {
        this.alunoMatricula = alunoMatricula;
    }

    public String getAlunoNome() {
        if (aluno != null) {
            return aluno.getNome();
        }

        return alunoNome;
    }

    public void setAlunoNome(String alunoNome) {
        this.alunoNome = alunoNome;
    }

    public String getMateriaCodigo() {
        if (materia != null) {
            return materia.getCodigo();
        }

        return materiaCodigo;
    }

    public void setMateriaCodigo(String materiaCodigo) {
        this.materiaCodigo = materiaCodigo;
    }

    public String getMateriaEmenta() {
        if (materia != null) {
            return materia.getEmenta();
        }

        return materiaEmenta;
    }

    public void setMateriaEmenta(String materiaEmenta) {
        this.materiaEmenta = materiaEmenta;
    }

    public String getMateriaNome() {
        if (materia != null) {
            return materia.getNomeExibicao();
        }

        return materiaNome;
    }

    public void setMateriaNome(String materiaNome) {
        this.materiaNome = materiaNome;
    }

    public String getMateriaResumo() {
        if (materia != null) {
            return materia.getResumo();
        }

        if (getMateriaCodigo() != null && getMateriaNome() != null) {
            return getMateriaCodigo() + " - " + getMateriaNome();
        }

        return getMateriaCodigo();
    }

    public String getTurmaMateria() {
        if (turmaMateria != null && !turmaMateria.isBlank()) {
            return turmaMateria;
        }

        if (getTurmaCodigo() != null && getMateriaCodigo() != null) {
            return getTurmaCodigo() + "|" + getMateriaCodigo();
        }

        return null;
    }

    public void setTurmaMateria(String turmaMateria) {
        this.turmaMateria = turmaMateria;

        if (turmaMateria == null || !turmaMateria.contains("|")) {
            return;
        }

        String[] partes = turmaMateria.split("\\|", 2);
        setTurmaCodigo(partes[0]);
        setMateriaCodigo(partes[1]);
    }

    public Double getNota1() {
        return nota1;
    }

    public void setNota1(Double nota1) {
        this.nota1 = nota1;
    }

    public Double getNota2() {
        return nota2;
    }

    public void setNota2(Double nota2) {
        this.nota2 = nota2;
    }

    public Double getNota3() {
        return nota3;
    }

    public void setNota3(Double nota3) {
        this.nota3 = nota3;
    }

    public Turma getTurma() {
        return turma;
    }

    public void setTurma(Turma turma) {
        this.turma = turma;
    }

    public Aluno getAluno() {
        return aluno;
    }

    public void setAluno(Aluno aluno) {
        this.aluno = aluno;
    }

    public Materia getMateria() {
        return materia;
    }

    public void setMateria(Materia materia) {
        this.materia = materia;
    }
}
