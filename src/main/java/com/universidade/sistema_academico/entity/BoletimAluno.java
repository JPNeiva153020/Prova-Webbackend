package com.universidade.sistema_academico.entity;

public class BoletimAluno {
    private String materia;
    private Double nota1;
    private Double nota2;
    private Double nota3;

    public BoletimAluno() {}

    public Double getMedia() {
        if (nota1 == null || nota2 == null || nota3 == null) {
            return null;
        }
        return (nota1 + nota2 + nota3) / 3;
    }

    public String getMateria() {return materia;}
    public void setMateria(String materia) {this.materia = materia;}
    public Double getNota1() {return nota1;}
    public void setNota1(Double nota1) {this.nota1 = nota1;}
    public Double getNota2() {return nota2;}
    public void setNota2(Double nota2) {this.nota2 = nota2;}
    public Double getNota3() {return nota3;}
    public void setNota3(Double nota3) {this.nota3 = nota3;}
}
