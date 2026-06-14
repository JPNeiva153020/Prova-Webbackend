package com.universidade.sistema_academico.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "tb_materia")
public class Materia {
    @Id
    @Column(name = "codigo", length = 30)
    private String codigo;

    @Column(name = "nome", length = 120)
    private String nome;

    @Column(name = "carga_horaria", length = 20)
    private String cargaHoraria;

    @Column(name = "ementa", nullable = false, columnDefinition = "TEXT")
    private String ementa;

    public Materia() {
    }

    public Materia(String codigo, String nome, String cargaHoraria, String ementa) {
        this.codigo = codigo;
        this.nome = nome;
        this.cargaHoraria = cargaHoraria;
        this.ementa = ementa;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getCargaHoraria() {
        return cargaHoraria;
    }

    public void setCargaHoraria(String cargaHoraria) {
        this.cargaHoraria = cargaHoraria;
    }

    public String getNomeExibicao() {
        if (nome != null && !nome.isBlank()) {
            return nome;
        }

        return ementa;
    }

    public String getResumo() {
        String texto = codigo + " - " + getNomeExibicao();

        if (cargaHoraria != null && !cargaHoraria.isBlank()) {
            return texto + " (" + cargaHoraria + ")";
        }

        return texto;
    }

    public String getEmenta() {
        return ementa;
    }

    public void setEmenta(String ementa) {
        this.ementa = ementa;
    }
}
