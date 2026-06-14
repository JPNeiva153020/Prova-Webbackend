package com.universidade.sistema_academico.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDate;

@Entity
@Table(name = "tb_aluno")
public class Aluno {
    @Id
    @Column(name = "matricula", length = 30)
    private String matricula;

    @Column(name = "nome", nullable = false, length = 120)
    private String nome;

    @Column(name = "endereco", nullable = false, length = 180)
    private String endereco;

    @Column(name = "data_ingresso", nullable = false)
    private LocalDate dataIngresso;

    public Aluno() {
    }

    public Aluno(String matricula, String nome, String endereco, LocalDate dataIngresso) {
        this.matricula = matricula;
        this.nome = nome;
        this.endereco = endereco;
        this.dataIngresso = dataIngresso;
    }

    public String getMatricula() {
        return matricula;
    }

    public void setMatricula(String matricula) {
        this.matricula = matricula;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getEndereco() {
        return endereco;
    }

    public void setEndereco(String endereco) {
        this.endereco = endereco;
    }

    public LocalDate getDataIngresso() {
        return dataIngresso;
    }

    public void setDataIngresso(LocalDate dataIngresso) {
        this.dataIngresso = dataIngresso;
    }
}
