package com.universidade.sistema_academico;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SistemaAcademicoApplication {

	public static void main(String[] args) {
		SpringApplication.run(SistemaAcademicoApplication.class, args);
	}
}


	/*	Lógica do projeto
	[OK] 1. Configurar banco de dados PostgreSQL (Criar banco sistema_academico)
	* [OK] 2. Configurar o application.properties (Conexão JDBC)
	* [OK] 3. Criar tabela tb_aluno no banco de dados.
	* [OK] 4. Criar a classe Aluno (matricula, nome, endereco, dataIngresso).
	* [OK] 5. Criar a classe AlunoDAO.
	* [OK] 6. Criar a classe AlunoController.
     * [OK] 7. Criar a rota GET no Controller e a tela HTML (Thymeleaf) para o formulário de cadastro.
     * [OK] 8. Criar a rota POST no Controller para receber o formulário e salvar no banco.
	* [OK] 9. Criar tabela tb_materia (codigo, ementa).
	* [OK] 10. Criar Entidade, DAO e Controller para Matéria.
     * [OK] 11. Criar telas HTML para Matéria (Cadastro e Listagem).
	* [OK] 12. Criar tabela tb_turma (codigo).
	* [OK] 13. Criar tabela associativa para vincular Alunos, Turmas e Notas (3 notas).
     * [OK] 14. Criar Entidade, DAO e Controller para Turma e Notas.
     * [OK] 15. Criar telas HTML para Turma.
     * [OK] 16. Consulta de Aluno: Trazer matérias matriculadas e a média de notas.
     * [OK] 17. Consulta de Turma: Trazer alunos matriculados, as 3 notas e status (Aprovado >= 6).
	 */
	/*
		O projeto deverá “simular” o ambiente de uma universidade, neste deveremos ter:
	- Módulo para cadastro e consulta de Alunos (através da matrícula)
	Um aluno deverá possuir, ao menos, nome, endereço, matrícula e data de ingresso.
	A consulta deverá trazer quais matérias ele está matriculado e sua média.
	- Módulo para cadastro e consulta de Matérias (através do código da matéria)
	Uma matéria deve possuir, ao menos, uma ementa (conteúdo, pode gerar no ChatGPT) e um código.
	- Módulo para cadastro e consulta de Turmas (através do código da turma)
	Uma turma deverá ter, ao menos, um código.
	A consulta de turmas deverá trazer os alunos matriculados, suas notas (três notas) e se foi aprovado ou não (nota superior ou igual à 6).

	 */

