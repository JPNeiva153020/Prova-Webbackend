package com.universidade.sistema_academico.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

import java.util.LinkedHashSet;
import java.util.Set;
import java.util.stream.Collectors;

@Entity
@Table(name = "tb_turma")
public class Turma {
    @Id
    @Column(name = "codigo", length = 30)
    private String codigo;

    @Column(name = "curso", length = 120)
    private String curso;

    @Column(name = "periodo", length = 50)
    private String periodo;

    @Column(name = "turno", length = 50)
    private String turno;

    @Column(name = "campus", length = 120)
    private String campus;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "tb_turma_materia",
            joinColumns = @JoinColumn(name = "turma_codigo"),
            inverseJoinColumns = @JoinColumn(name = "materia_codigo")
    )
    private Set<Materia> materias = new LinkedHashSet<>();

    @Transient
    private String materiaCodigo;

    public Turma() {
    }

    public Turma(String codigo, String materiaCodigo) {
        this.codigo = codigo;
        setMateriaCodigo(materiaCodigo);
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getCurso() {
        return curso;
    }

    public void setCurso(String curso) {
        this.curso = curso;
    }

    public String getPeriodo() {
        return periodo;
    }

    public void setPeriodo(String periodo) {
        this.periodo = periodo;
    }

    public String getTurno() {
        return turno;
    }

    public void setTurno(String turno) {
        this.turno = turno;
    }

    public String getCampus() {
        return campus;
    }

    public void setCampus(String campus) {
        this.campus = campus;
    }

    public String getDescricao() {
        StringBuilder descricao = new StringBuilder(codigo);

        if (curso != null && !curso.isBlank()) {
            descricao.append(" - ").append(curso);
        }

        if (periodo != null && !periodo.isBlank()) {
            descricao.append(" - ").append(periodo);
        }

        if (turno != null && !turno.isBlank()) {
            descricao.append(" - ").append(turno);
        }

        return descricao.toString();
    }

    public String getMateriaCodigo() {
        if (materiaCodigo != null && !materiaCodigo.isBlank()) {
            return materiaCodigo;
        }

        return materias.stream()
                .findFirst()
                .map(Materia::getCodigo)
                .orElse(null);
    }

    public void setMateriaCodigo(String materiaCodigo) {
        this.materiaCodigo = materiaCodigo;
    }

    public String getMateriaEmenta() {
        return getMateriasResumo();
    }

    public void setMateriaEmenta(String materiaEmenta) {
    }

    public Set<Materia> getMaterias() {
        return materias;
    }

    public void setMaterias(Set<Materia> materias) {
        this.materias = materias;
    }

    public String getMateriasResumo() {
        if (materias == null || materias.isEmpty()) {
            return "Sem matérias vinculadas";
        }

        return materias.stream()
                .map(Materia::getResumo)
                .collect(Collectors.joining("; "));
    }

    public boolean possuiMateria(String materiaCodigo) {
        if (materiaCodigo == null) {
            return false;
        }

        return materias.stream().anyMatch(materia -> materiaCodigo.equals(materia.getCodigo()));
    }

    public void adicionarMateria(Materia materia) {
        materias.add(materia);
    }

    public void removerMateria(String materiaCodigo) {
        materias.removeIf(materia -> materia.getCodigo().equals(materiaCodigo));
    }
}
