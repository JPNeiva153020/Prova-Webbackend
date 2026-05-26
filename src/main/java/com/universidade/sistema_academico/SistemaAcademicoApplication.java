package com.universidade.sistema_academico;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.CommandLineRunner;
import com.universidade.sistema_academico.dao.AlunoDAO;
import com.universidade.sistema_academico.entity.Aluno;
import org.springframework.context.annotation.Bean;

import java.time.LocalDate;

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
     * [ ] 7. Criar a rota GET no Controller e a tela HTML (Thymeleaf) para o formulário de cadastro.
     * [ ] 8. Criar a rota POST no Controller para receber o formulário e salvar no banco.
	* [ ] 9. Criar tabela tb_materia (codigo, ementa).
	* [ ] 10. Criar Modelo, DAO e Controller para Matéria.
     * [ ] 11. Criar telas HTML para Matéria (Cadastro e Listagem).
	* [ ] 12. Criar tabela tb_turma (codigo).
	* [ ] 13. Criar tabela associativa para vincular Alunos, Turmas e Notas (3 notas).
     * [ ] 14. Criar Modelo, DAO e Controller para Turma e Notas.
     * [ ] 15. Criar telas HTML para Turma.
     * [ ] 16. Consulta de Aluno: Trazer matérias matriculadas e a média de notas.
     * [ ] 17. Consulta de Turma: Trazer alunos matriculados, as 3 notas e status (Aprovado >= 6).
	 */



