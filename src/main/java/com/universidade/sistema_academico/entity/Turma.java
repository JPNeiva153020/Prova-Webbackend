package com.universidade.sistema_academico.entity;

public class Turma {
    private String codigo;
    private String materiaCodigo;
    private String materiaEmenta;

    public Turma() {
    }

    public Turma(String codigo, String materiaCodigo) {
        this.codigo = codigo;
        this.materiaCodigo = materiaCodigo;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getMateriaCodigo() {
        return materiaCodigo;
    }

    public void setMateriaCodigo(String materiaCodigo) {
        this.materiaCodigo = materiaCodigo;
    }

    public String getMateriaEmenta() {
        return materiaEmenta;
    }

    public void setMateriaEmenta(String materiaEmenta) {
        this.materiaEmenta = materiaEmenta;
    }
}