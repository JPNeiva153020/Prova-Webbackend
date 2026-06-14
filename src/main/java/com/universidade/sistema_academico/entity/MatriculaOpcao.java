package com.universidade.sistema_academico.entity;

public class MatriculaOpcao {
    private String valor;
    private String texto;

    public MatriculaOpcao(String valor, String texto) {
        this.valor = valor;
        this.texto = texto;
    }

    public String getValor() {
        return valor;
    }

    public void setValor(String valor) {
        this.valor = valor;
    }

    public String getTexto() {
        return texto;
    }

    public void setTexto(String texto) {
        this.texto = texto;
    }
}
