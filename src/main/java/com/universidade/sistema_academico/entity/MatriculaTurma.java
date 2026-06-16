package com.universidade.sistema_academico.entity;

public class MatriculaTurma {
    private Integer id;
    private String turmaCodigo;
    private String alunoMatricula;
    private String alunoNome;
    private Double nota1;
    private Double nota2;
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
        return turmaCodigo;
    }

    public void setTurmaCodigo(String turmaCodigo) {
        this.turmaCodigo = turmaCodigo;
    }

    public String getAlunoMatricula() {
        return alunoMatricula;
    }

    public void setAlunoMatricula(String alunoMatricula) {
        this.alunoMatricula = alunoMatricula;
    }

    public String getAlunoNome() {
        return alunoNome;
    }

    public void setAlunoNome(String alunoNome) {
        this.alunoNome = alunoNome;
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
}