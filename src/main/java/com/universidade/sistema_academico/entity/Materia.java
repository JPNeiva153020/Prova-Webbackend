package com.universidade.sistema_academico.entity;

public class Materia {
    private String codigo;
    private String ementa;

    public Materia() {
    }

    public Materia(String codigo, String ementa) {
        this.codigo = codigo;
        this.ementa = ementa;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getEmenta() {
        return ementa;
    }

    public void setEmenta(String ementa) {
        this.ementa = ementa;
    }
}