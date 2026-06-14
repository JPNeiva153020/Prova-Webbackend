-- ============================================================
-- Sistema Academico - script unico do banco
-- Execute no DBeaver conectado ao banco "sistema_academico".
-- Login padrao do sistema: admin / admin123
-- ============================================================

CREATE TABLE IF NOT EXISTS tb_aluno (
    matricula VARCHAR(30) PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    endereco VARCHAR(180) NOT NULL,
    data_ingresso DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS tb_materia (
    codigo VARCHAR(30) PRIMARY KEY,
    nome VARCHAR(120),
    carga_horaria VARCHAR(20),
    ementa TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS tb_turma (
    codigo VARCHAR(30) PRIMARY KEY,
    curso VARCHAR(120),
    periodo VARCHAR(50),
    turno VARCHAR(50),
    campus VARCHAR(120)
);

CREATE TABLE IF NOT EXISTS tb_turma_materia (
    turma_codigo VARCHAR(30) NOT NULL,
    materia_codigo VARCHAR(30) NOT NULL,
    PRIMARY KEY (turma_codigo, materia_codigo)
);

CREATE TABLE IF NOT EXISTS tb_turma_aluno_nota (
    id SERIAL PRIMARY KEY,
    turma_codigo VARCHAR(30) NOT NULL,
    materia_codigo VARCHAR(30),
    aluno_matricula VARCHAR(30) NOT NULL,
    nota1 NUMERIC(4,2) NOT NULL,
    nota2 NUMERIC(4,2) NOT NULL,
    nota3 NUMERIC(4,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS tb_admin (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'tb_materia'
          AND column_name = 'nome'
    ) THEN
        ALTER TABLE tb_materia ADD COLUMN nome VARCHAR(120);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'tb_materia'
          AND column_name = 'carga_horaria'
    ) THEN
        ALTER TABLE tb_materia ADD COLUMN carga_horaria VARCHAR(20);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'tb_turma'
          AND column_name = 'curso'
    ) THEN
        ALTER TABLE tb_turma ADD COLUMN curso VARCHAR(120);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'tb_turma'
          AND column_name = 'periodo'
    ) THEN
        ALTER TABLE tb_turma ADD COLUMN periodo VARCHAR(50);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'tb_turma'
          AND column_name = 'turno'
    ) THEN
        ALTER TABLE tb_turma ADD COLUMN turno VARCHAR(50);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'tb_turma'
          AND column_name = 'campus'
    ) THEN
        ALTER TABLE tb_turma ADD COLUMN campus VARCHAR(120);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'tb_turma_aluno_nota'
          AND column_name = 'materia_codigo'
    ) THEN
        ALTER TABLE tb_turma_aluno_nota
            ADD COLUMN materia_codigo VARCHAR(30);
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'tb_turma'
          AND column_name = 'materia_codigo'
    ) THEN
        INSERT INTO tb_turma_materia (turma_codigo, materia_codigo)
        SELECT codigo, materia_codigo
        FROM tb_turma
        WHERE materia_codigo IS NOT NULL
        ON CONFLICT DO NOTHING;

        UPDATE tb_turma_aluno_nota tan
        SET materia_codigo = t.materia_codigo
        FROM tb_turma t
        WHERE tan.turma_codigo = t.codigo
          AND tan.materia_codigo IS NULL;
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_turma_materia'
    ) THEN
        ALTER TABLE tb_turma DROP CONSTRAINT fk_turma_materia;
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'uk_turma_aluno'
    ) THEN
        ALTER TABLE tb_turma_aluno_nota DROP CONSTRAINT uk_turma_aluno;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'tb_turma'
          AND column_name = 'materia_codigo'
    ) THEN
        ALTER TABLE tb_turma DROP COLUMN materia_codigo;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_turma_materia_turma'
    ) THEN
        ALTER TABLE tb_turma_materia
            ADD CONSTRAINT fk_turma_materia_turma
            FOREIGN KEY (turma_codigo)
            REFERENCES tb_turma(codigo)
            ON UPDATE CASCADE
            ON DELETE CASCADE;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_turma_materia_materia'
    ) THEN
        ALTER TABLE tb_turma_materia
            ADD CONSTRAINT fk_turma_materia_materia
            FOREIGN KEY (materia_codigo)
            REFERENCES tb_materia(codigo)
            ON UPDATE CASCADE
            ON DELETE CASCADE;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_matricula_turma'
    ) THEN
        ALTER TABLE tb_turma_aluno_nota
            ADD CONSTRAINT fk_matricula_turma
            FOREIGN KEY (turma_codigo)
            REFERENCES tb_turma(codigo)
            ON UPDATE CASCADE
            ON DELETE CASCADE;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_matricula_aluno'
    ) THEN
        ALTER TABLE tb_turma_aluno_nota
            ADD CONSTRAINT fk_matricula_aluno
            FOREIGN KEY (aluno_matricula)
            REFERENCES tb_aluno(matricula)
            ON UPDATE CASCADE
            ON DELETE CASCADE;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_matricula_materia'
    ) THEN
        ALTER TABLE tb_turma_aluno_nota
            ADD CONSTRAINT fk_matricula_materia
            FOREIGN KEY (materia_codigo)
            REFERENCES tb_materia(codigo)
            ON UPDATE CASCADE
            ON DELETE CASCADE;
    END IF;

    UPDATE tb_turma_aluno_nota tan
    SET materia_codigo = tm.materia_codigo
    FROM tb_turma_materia tm
    WHERE tan.turma_codigo = tm.turma_codigo
      AND tan.materia_codigo IS NULL;

    IF EXISTS (
        SELECT 1
        FROM tb_turma_aluno_nota
        WHERE materia_codigo IS NULL
    ) THEN
        RAISE NOTICE 'Existem matriculas antigas sem materia. Ajuste manualmente antes de exigir NOT NULL.';
    ELSE
        ALTER TABLE tb_turma_aluno_nota
            ALTER COLUMN materia_codigo SET NOT NULL;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'ck_notas_entre_zero_e_dez'
    ) THEN
        ALTER TABLE tb_turma_aluno_nota
            ADD CONSTRAINT ck_notas_entre_zero_e_dez
            CHECK (
                nota1 BETWEEN 0 AND 10
                AND nota2 BETWEEN 0 AND 10
                AND nota3 BETWEEN 0 AND 10
            );
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'uk_matricula_aluno_turma_materia'
    ) THEN
        ALTER TABLE tb_turma_aluno_nota
            ADD CONSTRAINT uk_matricula_aluno_turma_materia
            UNIQUE (turma_codigo, materia_codigo, aluno_matricula);
    END IF;
END $$;

INSERT INTO tb_admin (username, password)
VALUES ('admin', '$2a$10$Q7qGeub.epkRB0BGhgYQ..wWqkQX3z9rIaKVnfAdIdxqNSyS2GIWC')
ON CONFLICT (username) DO UPDATE
SET password = EXCLUDED.password;

-- ============================================================
-- Dados simulados importados de dados_universidade_simulados_2026.txt
-- Este bloco permite simular o arquivo inteiro sem criar módulos extras.
-- Total esperado: 5 materias, 4 turmas, 120 alunos e 600 notas.
-- ============================================================

INSERT INTO tb_materia (codigo, nome, carga_horaria, ementa) VALUES
    ('CCO-101', 'Algoritmos e Lógica de Programação', '80h', 'Introdução à lógica computacional, construção de algoritmos, variáveis, tipos de dados, estruturas condicionais, estruturas de repetição, vetores, matrizes, funções e resolução de problemas usando raciocínio lógico.'),
    ('CCO-102', 'Fundamentos de Banco de Dados', '80h', 'Conceitos fundamentais de banco de dados, modelagem conceitual, modelo entidade-relacionamento, modelo relacional, normalização, linguagem SQL, consultas, inserção, atualização e exclusão de dados.'),
    ('CCO-103', 'Engenharia de Software', '60h', 'Processos de desenvolvimento de software, levantamento de requisitos, análise e projeto de sistemas, documentação, metodologias ágeis, versionamento, qualidade de software e práticas de manutenção.'),
    ('CCO-104', 'Programação Orientada a Objetos', '80h', 'Princípios da programação orientada a objetos, classes, objetos, atributos, métodos, encapsulamento, herança, polimorfismo, abstração, interfaces, tratamento de exceções e boas práticas de desenvolvimento.'),
    ('CCO-105', 'Sistemas Web', '80h', 'Fundamentos de aplicações web, arquitetura cliente-servidor, HTML, CSS, JavaScript, consumo de APIs, rotas, autenticação, integração com banco de dados e implantação de aplicações web.')
ON CONFLICT (codigo) DO UPDATE SET
    nome = EXCLUDED.nome,
    carga_horaria = EXCLUDED.carga_horaria,
    ementa = EXCLUDED.ementa;

INSERT INTO tb_turma (codigo, curso, periodo, turno, campus) VALUES
    ('CCO-2026-1A', 'Ciência da Computação', '1º Período', 'Manhã', 'Campus Farolândia'),
    ('ADS-2026-1B', 'Análise e Desenvolvimento de Sistemas', '1º Período', 'Noite', 'Campus Farolândia'),
    ('ESW-2026-3A', 'Engenharia de Software', '3º Período', 'Manhã', 'Campus Centro'),
    ('SI-2026-2B', 'Sistemas de Informação', '2º Período', 'Noite', 'Campus Farolândia')
ON CONFLICT (codigo) DO UPDATE SET
    curso = EXCLUDED.curso,
    periodo = EXCLUDED.periodo,
    turno = EXCLUDED.turno,
    campus = EXCLUDED.campus;

INSERT INTO tb_turma_materia (turma_codigo, materia_codigo) VALUES
    ('CCO-2026-1A', 'CCO-101'),
    ('CCO-2026-1A', 'CCO-102'),
    ('CCO-2026-1A', 'CCO-103'),
    ('CCO-2026-1A', 'CCO-104'),
    ('CCO-2026-1A', 'CCO-105'),
    ('ADS-2026-1B', 'CCO-101'),
    ('ADS-2026-1B', 'CCO-102'),
    ('ADS-2026-1B', 'CCO-103'),
    ('ADS-2026-1B', 'CCO-104'),
    ('ADS-2026-1B', 'CCO-105'),
    ('ESW-2026-3A', 'CCO-101'),
    ('ESW-2026-3A', 'CCO-102'),
    ('ESW-2026-3A', 'CCO-103'),
    ('ESW-2026-3A', 'CCO-104'),
    ('ESW-2026-3A', 'CCO-105'),
    ('SI-2026-2B', 'CCO-101'),
    ('SI-2026-2B', 'CCO-102'),
    ('SI-2026-2B', 'CCO-103'),
    ('SI-2026-2B', 'CCO-104'),
    ('SI-2026-2B', 'CCO-105')
ON CONFLICT DO NOTHING;

INSERT INTO tb_aluno (matricula, nome, endereco, data_ingresso) VALUES
    ('2026000001', 'Laura Santos Ribeiro', 'Travessa Doutor Carlos Menezes, nº 1900, Fundos - Bairro Siqueira Campos, Estância/SE, CEP 49664-872', '2023-02-22'),
    ('2026000002', 'Igor Souza Andrade', 'Rua Antônio Carlos, nº 2275, Residencial Atlântico - Bairro Centro, Nossa Senhora do Socorro/SE, CEP 49880-893', '2023-02-23'),
    ('2026000003', 'Leonardo Nascimento Oliveira', 'Alameda Esperança, nº 1591, Fundos - Bairro Coroa do Meio, Lagarto/SE, CEP 49734-376', '2025-08-08'),
    ('2026000004', 'Nicolas Silva Monteiro', 'Avenida Rio Branco, nº 1203, Casa - Bairro Bugio, Nossa Senhora do Socorro/SE, CEP 49591-956', '2024-02-08'),
    ('2026000005', 'Igor Andrade Vieira', 'Rua das Acácias, nº 1522 - Bairro Suíssa, Estância/SE, CEP 49668-223', '2023-02-16'),
    ('2026000006', 'Beatriz Santos Batista', 'Rua Nossa Senhora Aparecida, nº 412, Residencial Atlântico - Bairro Coroa do Meio, Itabaiana/SE, CEP 49429-189', '2023-02-08'),
    ('2026000007', 'Daniela Farias Martins', 'Travessa Boa Vista, nº 583, Casa - Bairro Atalaia, São Cristóvão/SE, CEP 49848-310', '2023-02-20'),
    ('2026000008', 'Rafaela Nascimento Cardoso', 'Avenida Acadêmico Silvio Romero, nº 1967, Condomínio Primavera - Bairro Atalaia, Itabaiana/SE, CEP 49736-854', '2024-08-13'),
    ('2026000009', 'Mateus Campos Araújo', 'Travessa Monte Alegre, nº 1687, Fundos - Bairro Ponto Novo, Lagarto/SE, CEP 49290-235', '2024-08-23'),
    ('2026000010', 'Sofia Ribeiro Silva', 'Rua Aroeiras, nº 1304, Bloco B - Bairro Luzia, São Cristóvão/SE, CEP 49489-914', '2025-08-24'),
    ('2026000011', 'Laura Farias Teixeira', 'Rua Esperança, nº 2013, Apto 201 - Bairro Industrial, Itabaiana/SE, CEP 49339-495', '2024-02-17'),
    ('2026000012', 'Giovanna Silva Batista', 'Alameda Esperança, nº 547, Casa - Bairro Farolândia, Nossa Senhora do Socorro/SE, CEP 49233-169', '2024-08-08'),
    ('2026000013', 'Mariana Oliveira Campos', 'Alameda das Acácias, nº 1178, Apto 304 - Bairro Rosa Elze, São Cristóvão/SE, CEP 49897-582', '2023-02-17'),
    ('2026000014', 'Helena Barbosa Monteiro', 'Avenida Boa Vista, nº 1933, Casa - Bairro Atalaia, Aracaju/SE, CEP 49592-607', '2025-02-05'),
    ('2026000015', 'Sofia Monteiro Correia', 'Alameda Boa Vista, nº 1927, Apto 304 - Bairro Aruana, Lagarto/SE, CEP 49410-548', '2026-02-16'),
    ('2026000016', 'Cauã Barbosa Batista', 'Rua Santa Luzia, nº 63, Condomínio Primavera - Bairro Aruana, Barra dos Coqueiros/SE, CEP 49482-319', '2024-08-22'),
    ('2026000017', 'Helena Vieira Rodrigues', 'Rua Sete de Setembro, nº 190, Apto 304 - Bairro Ponto Novo, São Cristóvão/SE, CEP 49454-973', '2026-02-02'),
    ('2026000018', 'Victor Teixeira Araújo', 'Avenida São Cristóvão, nº 2278, Apto 201 - Bairro Luzia, Nossa Senhora do Socorro/SE, CEP 49664-585', '2025-02-10'),
    ('2026000019', 'Clara Araújo Gomes', 'Alameda Santa Luzia, nº 711, Casa - Bairro Santo Antônio, Nossa Senhora do Socorro/SE, CEP 49223-640', '2023-08-13'),
    ('2026000020', 'Sofia Ribeiro Santos', 'Alameda Liberdade, nº 357, Casa - Bairro Coroa do Meio, Barra dos Coqueiros/SE, CEP 49816-361', '2026-02-09'),
    ('2026000021', 'Renan Melo Farias', 'Alameda Professor José Andrade, nº 613, Residencial Atlântico - Bairro Rosa Elze, Lagarto/SE, CEP 49365-336', '2023-02-13'),
    ('2026000022', 'André Carvalho Correia', 'Travessa Antônio Carlos, nº 767, Bloco B - Bairro Aruana, Aracaju/SE, CEP 49939-118', '2025-08-20'),
    ('2026000023', 'Daniela Lima Moura', 'Alameda Estudante José Freire, nº 750 - Bairro Rosa Elze, Estância/SE, CEP 49423-369', '2024-08-15'),
    ('2026000024', 'Eduardo Campos Nascimento', 'Alameda Dom Pedro II, nº 1517, Apto 304 - Bairro Grageru, Barra dos Coqueiros/SE, CEP 49599-204', '2024-08-15'),
    ('2026000025', 'Igor Nascimento Pereira', 'Rua João Ribeiro, nº 452, Casa - Bairro Inácio Barbosa, Aracaju/SE, CEP 49583-205', '2025-08-09'),
    ('2026000026', 'Patrícia Rodrigues Farias', 'Alameda Santa Luzia, nº 171, Apto 304 - Bairro Suíssa, Estância/SE, CEP 49329-657', '2025-02-12'),
    ('2026000027', 'Olívia Gomes Andrade', 'Travessa Liberdade, nº 776, Condomínio Primavera - Bairro Grageru, Barra dos Coqueiros/SE, CEP 49307-675', '2024-08-17'),
    ('2026000028', 'Ana Almeida Correia', 'Travessa Monte Alegre, nº 1301, Bloco B - Bairro Atalaia, Lagarto/SE, CEP 49686-717', '2025-02-16'),
    ('2026000029', 'Samuel Souza Vieira', 'Alameda Professor José Andrade, nº 1629, Apto 304 - Bairro São Conrado, Estância/SE, CEP 49485-768', '2023-02-14'),
    ('2026000030', 'Bianca Farias Moura', 'Avenida São Cristóvão, nº 2017, Fundos - Bairro Jardins, Itabaiana/SE, CEP 49725-115', '2024-02-07'),
    ('2026000031', 'Patrícia Ribeiro Moura', 'Rua dos Ipês, nº 2320, Residencial Atlântico - Bairro Jardins, São Cristóvão/SE, CEP 49378-866', '2023-02-10'),
    ('2026000032', 'Thiago Monteiro Correia', 'Alameda Sete de Setembro, nº 541, Fundos - Bairro Luzia, Aracaju/SE, CEP 49545-978', '2023-02-21'),
    ('2026000033', 'Clara Correia Cardoso', 'Travessa Professor José Andrade, nº 1022, Residencial Atlântico - Bairro Jardins, Itabaiana/SE, CEP 49507-605', '2025-08-23'),
    ('2026000034', 'Giovanna Farias Souza', 'Rua Estudante José Freire, nº 772, Apto 304 - Bairro Coroa do Meio, Itabaiana/SE, CEP 49648-710', '2023-08-22'),
    ('2026000035', 'Patrícia Araújo Pereira', 'Alameda João Ribeiro, nº 1217, Fundos - Bairro Atalaia, Itabaiana/SE, CEP 49146-603', '2026-02-02'),
    ('2026000036', 'Luana Cardoso Monteiro', 'Rua Jardim das Flores, nº 2124, Casa - Bairro Siqueira Campos, Barra dos Coqueiros/SE, CEP 49274-935', '2024-02-25'),
    ('2026000037', 'Ana Oliveira Farias', 'Travessa Aroeiras, nº 1881 - Bairro Ponto Novo, Lagarto/SE, CEP 49122-353', '2025-08-18'),
    ('2026000038', 'Camila Rodrigues Ferreira', 'Rua Dom Pedro II, nº 576, Fundos - Bairro Ponto Novo, Lagarto/SE, CEP 49941-264', '2023-02-24'),
    ('2026000039', 'Igor Moura Araújo', 'Travessa Aroeiras, nº 1841 - Bairro Centro, Barra dos Coqueiros/SE, CEP 49258-955', '2026-02-17'),
    ('2026000040', 'Davi Melo Cardoso', 'Avenida Novo Horizonte, nº 301 - Bairro Grageru, Barra dos Coqueiros/SE, CEP 49681-671', '2024-08-23'),
    ('2026000041', 'Sofia Correia Almeida', 'Travessa Professor José Andrade, nº 871, Apto 304 - Bairro Siqueira Campos, Nossa Senhora do Socorro/SE, CEP 49748-773', '2026-02-06'),
    ('2026000042', 'Daniela Dias Barbosa', 'Avenida Liberdade, nº 1572, Fundos - Bairro Farolândia, Itabaiana/SE, CEP 49121-855', '2023-08-14'),
    ('2026000043', 'André Oliveira Gomes', 'Alameda Antônio Carlos, nº 1047 - Bairro Grageru, Estância/SE, CEP 49715-475', '2023-08-27'),
    ('2026000044', 'Gustavo Ribeiro Martins', 'Alameda Nossa Senhora Aparecida, nº 1521, Apto 304 - Bairro 13 de Julho, Estância/SE, CEP 49435-534', '2025-08-23'),
    ('2026000045', 'Victor Lima Farias', 'Travessa Aroeiras, nº 131, Fundos - Bairro Siqueira Campos, Estância/SE, CEP 49616-264', '2024-02-19'),
    ('2026000046', 'Samuel Batista Nascimento', 'Travessa Dom Pedro II, nº 40, Casa - Bairro Coroa do Meio, Nossa Senhora do Socorro/SE, CEP 49330-189', '2023-08-12'),
    ('2026000047', 'Yasmin Moura Silva', 'Rua Liberdade, nº 353, Casa - Bairro Atalaia, Lagarto/SE, CEP 49124-902', '2025-08-06'),
    ('2026000048', 'Ana Almeida Batista', 'Alameda São José, nº 1791, Apto 201 - Bairro Centro, Estância/SE, CEP 49889-785', '2025-02-11'),
    ('2026000049', 'Thiago Pereira Gomes', 'Rua Acadêmico Silvio Romero, nº 2373, Apto 304 - Bairro Rosa Elze, Lagarto/SE, CEP 49778-289', '2023-02-15'),
    ('2026000050', 'Henrique Cardoso Araújo', 'Rua Esperança, nº 744, Condomínio Primavera - Bairro Grageru, São Cristóvão/SE, CEP 49223-607', '2024-02-07'),
    ('2026000051', 'Laura Moura Correia', 'Rua dos Ipês, nº 354, Bloco B - Bairro Siqueira Campos, Estância/SE, CEP 49876-244', '2023-02-09'),
    ('2026000052', 'Giovanna Barbosa Ferreira', 'Avenida Padre Cícero, nº 2291, Residencial Atlântico - Bairro Jardins, Itabaiana/SE, CEP 49130-745', '2024-02-13'),
    ('2026000053', 'Isabela Teixeira Carvalho', 'Alameda Jardim das Flores, nº 2174, Bloco B - Bairro Aruana, Estância/SE, CEP 49284-595', '2026-02-10'),
    ('2026000054', 'Rafaela Teixeira Monteiro', 'Rua Monte Alegre, nº 2324, Apto 304 - Bairro Atalaia, Lagarto/SE, CEP 49367-396', '2025-02-05'),
    ('2026000055', 'Eduardo Correia Gomes', 'Alameda Aroeiras, nº 1794, Apto 304 - Bairro Ponto Novo, Estância/SE, CEP 49422-554', '2025-08-07'),
    ('2026000056', 'Lucas Ferreira Carvalho', 'Rua Rio Branco, nº 1767, Condomínio Primavera - Bairro Aruana, Estância/SE, CEP 49591-181', '2023-08-26'),
    ('2026000057', 'Gustavo Cardoso Oliveira', 'Alameda Jardim das Flores, nº 1739, Bloco B - Bairro Industrial, Lagarto/SE, CEP 49543-218', '2023-02-20'),
    ('2026000058', 'Emanuelle Ferreira Lima', 'Rua Sete de Setembro, nº 1492, Residencial Atlântico - Bairro Centro, Nossa Senhora do Socorro/SE, CEP 49518-984', '2024-02-05'),
    ('2026000059', 'Igor Moura Campos', 'Travessa das Acácias, nº 1471 - Bairro Atalaia, Nossa Senhora do Socorro/SE, CEP 49186-600', '2023-08-22'),
    ('2026000060', 'Amanda Nascimento Rodrigues', 'Alameda Padre Cícero, nº 2428, Bloco B - Bairro Siqueira Campos, Lagarto/SE, CEP 49653-624', '2026-02-04'),
    ('2026000061', 'Helena Andrade Ferreira', 'Alameda João Ribeiro, nº 1978, Bloco B - Bairro Industrial, Aracaju/SE, CEP 49464-158', '2023-08-16'),
    ('2026000062', 'Beatriz Souza Moura', 'Travessa Jardim das Flores, nº 780, Apto 201 - Bairro Rosa Elze, Aracaju/SE, CEP 49642-563', '2025-08-19'),
    ('2026000063', 'Thiago Silva Lima', 'Alameda Castelo Branco, nº 2043, Bloco B - Bairro Rosa Elze, Itabaiana/SE, CEP 49373-748', '2025-08-10'),
    ('2026000064', 'Thiago Monteiro Correia', 'Avenida Doutor Carlos Menezes, nº 540, Apto 304 - Bairro Luzia, Nossa Senhora do Socorro/SE, CEP 49930-376', '2024-08-13'),
    ('2026000065', 'Rafaela Costa Monteiro', 'Travessa Monte Alegre, nº 2060, Bloco B - Bairro Coroa do Meio, São Cristóvão/SE, CEP 49814-313', '2023-08-13'),
    ('2026000066', 'Pedro Andrade Ferreira', 'Travessa das Acácias, nº 1672 - Bairro Suíssa, Nossa Senhora do Socorro/SE, CEP 49620-557', '2023-08-27'),
    ('2026000067', 'Carolina Monteiro Pereira', 'Travessa Acadêmico Silvio Romero, nº 602, Casa - Bairro Inácio Barbosa, Aracaju/SE, CEP 49493-410', '2026-02-18'),
    ('2026000068', 'Emanuelle Monteiro Gomes', 'Travessa Castelo Branco, nº 918, Apto 201 - Bairro São Conrado, São Cristóvão/SE, CEP 49889-974', '2023-02-06'),
    ('2026000069', 'Gabriel Souza Almeida', 'Avenida Rio Branco, nº 1778, Apto 304 - Bairro Jardins, Barra dos Coqueiros/SE, CEP 49536-352', '2023-02-15'),
    ('2026000070', 'Ana Ribeiro Campos', 'Travessa Aroeiras, nº 2393, Residencial Atlântico - Bairro Suíssa, Lagarto/SE, CEP 49250-265', '2023-08-11'),
    ('2026000071', 'Pedro Ferreira Oliveira', 'Travessa João Ribeiro, nº 73, Apto 304 - Bairro Rosa Elze, Barra dos Coqueiros/SE, CEP 49347-917', '2024-08-14'),
    ('2026000072', 'Emanuelle Rodrigues Monteiro', 'Alameda Dom Pedro II, nº 1323, Apto 201 - Bairro Santo Antônio, Barra dos Coqueiros/SE, CEP 49405-867', '2026-02-04'),
    ('2026000073', 'Daniel Andrade Carvalho', 'Rua Esperança, nº 1196, Bloco B - Bairro Inácio Barbosa, Itabaiana/SE, CEP 49103-136', '2025-02-18'),
    ('2026000074', 'João Nascimento Batista', 'Travessa Rio Branco, nº 528, Fundos - Bairro Coroa do Meio, São Cristóvão/SE, CEP 49400-575', '2023-02-08'),
    ('2026000075', 'Júlia Gomes Silva', 'Travessa Padre Cícero, nº 629, Casa - Bairro 13 de Julho, Aracaju/SE, CEP 49468-895', '2026-02-21'),
    ('2026000076', 'Bernardo Ribeiro Batista', 'Alameda Marechal Deodoro, nº 1801, Condomínio Primavera - Bairro 13 de Julho, Itabaiana/SE, CEP 49287-512', '2023-08-17'),
    ('2026000077', 'Bianca Dias Monteiro', 'Travessa das Acácias, nº 1667, Casa - Bairro Industrial, Aracaju/SE, CEP 49283-927', '2024-08-10'),
    ('2026000078', 'Gustavo Souza Farias', 'Rua Professor José Andrade, nº 2091, Condomínio Primavera - Bairro Aruana, São Cristóvão/SE, CEP 49127-483', '2025-08-07'),
    ('2026000079', 'Larissa Cardoso Monteiro', 'Avenida Nossa Senhora Aparecida, nº 1446, Residencial Atlântico - Bairro Suíssa, Barra dos Coqueiros/SE, CEP 49334-771', '2025-08-14'),
    ('2026000080', 'Fernanda Moura Dias', 'Alameda Antônio Carlos, nº 1478, Residencial Atlântico - Bairro Inácio Barbosa, São Cristóvão/SE, CEP 49901-535', '2024-02-24'),
    ('2026000081', 'Helena Santos Nascimento', 'Travessa Sete de Setembro, nº 1350, Casa - Bairro Luzia, Aracaju/SE, CEP 49555-269', '2025-08-24'),
    ('2026000082', 'Pedro Pereira Ferreira', 'Travessa João Ribeiro, nº 379, Residencial Atlântico - Bairro São Conrado, São Cristóvão/SE, CEP 49306-543', '2025-02-23'),
    ('2026000083', 'Lucas Batista Melo', 'Travessa João Ribeiro, nº 915, Apto 201 - Bairro Bugio, Lagarto/SE, CEP 49356-613', '2024-02-13'),
    ('2026000084', 'Henrique Nascimento Souza', 'Rua Padre Cícero, nº 1849, Fundos - Bairro Jardins, Lagarto/SE, CEP 49752-612', '2023-08-07'),
    ('2026000085', 'Mateus Batista Cardoso', 'Avenida Santa Luzia, nº 719 - Bairro Siqueira Campos, Aracaju/SE, CEP 49796-997', '2026-02-05'),
    ('2026000086', 'Eduardo Souza Ferreira', 'Travessa Esperança, nº 1790, Bloco B - Bairro São Conrado, Aracaju/SE, CEP 49945-171', '2025-02-17'),
    ('2026000087', 'Natália Andrade Moura', 'Rua Padre Cícero, nº 1975, Fundos - Bairro Bugio, Itabaiana/SE, CEP 49583-117', '2025-02-11'),
    ('2026000088', 'Camila Gomes Cardoso', 'Rua Castelo Branco, nº 62, Fundos - Bairro Grageru, Aracaju/SE, CEP 49356-942', '2024-02-24'),
    ('2026000089', 'Bernardo Ferreira Monteiro', 'Avenida dos Ipês, nº 1711, Fundos - Bairro Suíssa, Itabaiana/SE, CEP 49297-464', '2024-02-16'),
    ('2026000090', 'Leonardo Ferreira Barbosa', 'Alameda Boa Vista, nº 1795, Casa - Bairro Suíssa, Estância/SE, CEP 49529-534', '2026-02-12'),
    ('2026000091', 'Bianca Farias Vieira', 'Rua dos Ipês, nº 460, Fundos - Bairro Bugio, Nossa Senhora do Socorro/SE, CEP 49915-684', '2025-02-22'),
    ('2026000092', 'Thiago Barbosa Martins', 'Avenida dos Ipês, nº 2363, Fundos - Bairro Siqueira Campos, Itabaiana/SE, CEP 49306-110', '2023-02-16'),
    ('2026000093', 'Ana Andrade Monteiro', 'Alameda Boa Vista, nº 1472 - Bairro Luzia, Barra dos Coqueiros/SE, CEP 49671-584', '2023-02-12'),
    ('2026000094', 'Arthur Pereira Batista', 'Rua Monte Alegre, nº 1791 - Bairro Atalaia, Estância/SE, CEP 49708-121', '2025-02-19'),
    ('2026000095', 'Beatriz Costa Dias', 'Avenida Monte Alegre, nº 1836, Residencial Atlântico - Bairro 13 de Julho, Lagarto/SE, CEP 49527-472', '2025-02-05'),
    ('2026000096', 'Olívia Costa Ribeiro', 'Rua Antônio Carlos, nº 1020, Apto 201 - Bairro Jardins, Barra dos Coqueiros/SE, CEP 49913-346', '2024-08-09'),
    ('2026000097', 'Renan Souza Moura', 'Avenida João Ribeiro, nº 1590, Casa - Bairro Coroa do Meio, São Cristóvão/SE, CEP 49837-687', '2025-08-11'),
    ('2026000098', 'Ana Costa Monteiro', 'Rua das Acácias, nº 1944 - Bairro Inácio Barbosa, Nossa Senhora do Socorro/SE, CEP 49129-741', '2025-08-05'),
    ('2026000099', 'Luana Ferreira Costa', 'Rua Aroeiras, nº 1744, Apto 201 - Bairro Farolândia, Nossa Senhora do Socorro/SE, CEP 49777-287', '2026-02-09'),
    ('2026000100', 'Bianca Nascimento Melo', 'Rua Nossa Senhora Aparecida, nº 928, Residencial Atlântico - Bairro Jardins, Estância/SE, CEP 49777-213', '2026-02-09'),
    ('2026000101', 'Júlia Moura Pereira', 'Avenida Estudante José Freire, nº 1592, Residencial Atlântico - Bairro Grageru, Nossa Senhora do Socorro/SE, CEP 49199-713', '2025-02-09'),
    ('2026000102', 'Amanda Farias Rodrigues', 'Rua Estudante José Freire, nº 2030, Condomínio Primavera - Bairro Atalaia, São Cristóvão/SE, CEP 49559-322', '2023-02-25'),
    ('2026000103', 'Daniel Ribeiro Souza', 'Travessa Marechal Deodoro, nº 1615, Apto 304 - Bairro Coroa do Meio, Aracaju/SE, CEP 49824-620', '2025-08-08'),
    ('2026000104', 'Fernanda Farias Carvalho', 'Travessa Rio Branco, nº 814, Apto 201 - Bairro Inácio Barbosa, Nossa Senhora do Socorro/SE, CEP 49306-207', '2024-08-06'),
    ('2026000105', 'Júlia Almeida Barbosa', 'Alameda das Acácias, nº 489, Apto 201 - Bairro Farolândia, Lagarto/SE, CEP 49212-514', '2023-08-21'),
    ('2026000106', 'Daniela Melo Andrade', 'Avenida Professor José Andrade, nº 414, Fundos - Bairro Farolândia, Lagarto/SE, CEP 49870-727', '2024-08-11'),
    ('2026000107', 'Natália Andrade Correia', 'Avenida Universitária, nº 1355, Fundos - Bairro São Conrado, Itabaiana/SE, CEP 49974-762', '2025-08-23'),
    ('2026000108', 'Pedro Teixeira Andrade', 'Avenida Rio Branco, nº 272, Condomínio Primavera - Bairro Grageru, Barra dos Coqueiros/SE, CEP 49923-848', '2025-02-23'),
    ('2026000109', 'Murilo Ferreira Oliveira', 'Avenida João Ribeiro, nº 291, Residencial Atlântico - Bairro Atalaia, Barra dos Coqueiros/SE, CEP 49835-800', '2024-08-22'),
    ('2026000110', 'Victor Pereira Correia', 'Rua dos Ipês, nº 1040, Apto 304 - Bairro Coroa do Meio, Estância/SE, CEP 49623-259', '2025-02-20'),
    ('2026000111', 'Patrícia Almeida Lima', 'Rua Aroeiras, nº 2153 - Bairro Centro, Estância/SE, CEP 49109-343', '2026-02-18'),
    ('2026000112', 'Mateus Araújo Martins', 'Rua Jardim das Flores, nº 2277, Apto 201 - Bairro Suíssa, Aracaju/SE, CEP 49155-468', '2023-02-21'),
    ('2026000113', 'Clara Rodrigues Andrade', 'Travessa Universitária, nº 45, Apto 304 - Bairro Jardins, Barra dos Coqueiros/SE, CEP 49290-364', '2024-02-22'),
    ('2026000114', 'Emanuelle Silva Correia', 'Rua Doutor Carlos Menezes, nº 1524 - Bairro Coroa do Meio, Barra dos Coqueiros/SE, CEP 49388-852', '2024-02-16'),
    ('2026000115', 'Rafaela Barbosa Rodrigues', 'Alameda Antônio Carlos, nº 402, Bloco B - Bairro Aruana, Barra dos Coqueiros/SE, CEP 49381-933', '2023-08-17'),
    ('2026000116', 'Gabriel Santos Nascimento', 'Alameda Esperança, nº 1273, Apto 201 - Bairro Jardins, São Cristóvão/SE, CEP 49753-327', '2024-08-06'),
    ('2026000117', 'João Lima Batista', 'Rua dos Ipês, nº 1006, Apto 201 - Bairro Rosa Elze, Barra dos Coqueiros/SE, CEP 49436-210', '2023-02-23'),
    ('2026000118', 'Giovanna Melo Batista', 'Alameda São José, nº 1057, Apto 304 - Bairro 13 de Julho, São Cristóvão/SE, CEP 49316-405', '2024-02-25'),
    ('2026000119', 'Emanuelle Moura Gomes', 'Rua Estudante José Freire, nº 1171, Apto 304 - Bairro Santo Antônio, Nossa Senhora do Socorro/SE, CEP 49852-107', '2026-02-13'),
    ('2026000120', 'André Farias Monteiro', 'Rua Padre Cícero, nº 1943, Condomínio Primavera - Bairro Farolândia, Barra dos Coqueiros/SE, CEP 49685-605', '2024-02-20')
ON CONFLICT (matricula) DO UPDATE SET
    nome = EXCLUDED.nome,
    endereco = EXCLUDED.endereco,
    data_ingresso = EXCLUDED.data_ingresso;

INSERT INTO tb_turma_aluno_nota (turma_codigo, materia_codigo, aluno_matricula, nota1, nota2, nota3) VALUES
    ('CCO-2026-1A', 'CCO-101', '2026000001', 7.4, 8.2, 6.3),
    ('CCO-2026-1A', 'CCO-102', '2026000001', 8.0, 7.3, 6.8),
    ('CCO-2026-1A', 'CCO-103', '2026000001', 6.3, 2.7, 5.7),
    ('CCO-2026-1A', 'CCO-104', '2026000001', 4.6, 5.4, 4.8),
    ('CCO-2026-1A', 'CCO-105', '2026000001', 2.7, 3.6, 3.0),
    ('CCO-2026-1A', 'CCO-101', '2026000002', 4.4, 4.5, 5.5),
    ('CCO-2026-1A', 'CCO-102', '2026000002', 8.8, 5.8, 5.9),
    ('CCO-2026-1A', 'CCO-103', '2026000002', 8.9, 7.3, 10.0),
    ('CCO-2026-1A', 'CCO-104', '2026000002', 9.0, 9.5, 9.9),
    ('CCO-2026-1A', 'CCO-105', '2026000002', 8.8, 5.6, 7.2),
    ('CCO-2026-1A', 'CCO-101', '2026000003', 10.0, 10.0, 7.8),
    ('CCO-2026-1A', 'CCO-102', '2026000003', 7.4, 7.6, 9.9),
    ('CCO-2026-1A', 'CCO-103', '2026000003', 7.3, 7.2, 5.8),
    ('CCO-2026-1A', 'CCO-104', '2026000003', 9.1, 8.1, 6.9),
    ('CCO-2026-1A', 'CCO-105', '2026000003', 8.8, 8.1, 9.6),
    ('CCO-2026-1A', 'CCO-101', '2026000004', 7.6, 4.8, 4.6),
    ('CCO-2026-1A', 'CCO-102', '2026000004', 7.6, 10.0, 10.0),
    ('CCO-2026-1A', 'CCO-103', '2026000004', 5.6, 4.4, 4.3),
    ('CCO-2026-1A', 'CCO-104', '2026000004', 10.0, 7.5, 8.5),
    ('CCO-2026-1A', 'CCO-105', '2026000004', 7.0, 5.6, 9.3),
    ('CCO-2026-1A', 'CCO-101', '2026000005', 5.7, 7.5, 6.5),
    ('CCO-2026-1A', 'CCO-102', '2026000005', 4.9, 4.5, 4.6),
    ('CCO-2026-1A', 'CCO-103', '2026000005', 6.0, 5.0, 8.1),
    ('CCO-2026-1A', 'CCO-104', '2026000005', 7.3, 6.3, 7.4),
    ('CCO-2026-1A', 'CCO-105', '2026000005', 9.5, 7.6, 8.6),
    ('CCO-2026-1A', 'CCO-101', '2026000006', 5.8, 4.6, 7.2),
    ('CCO-2026-1A', 'CCO-102', '2026000006', 7.5, 6.9, 7.7),
    ('CCO-2026-1A', 'CCO-103', '2026000006', 7.5, 8.5, 9.9),
    ('CCO-2026-1A', 'CCO-104', '2026000006', 6.1, 5.2, 3.8),
    ('CCO-2026-1A', 'CCO-105', '2026000006', 7.8, 5.9, 5.3),
    ('CCO-2026-1A', 'CCO-101', '2026000007', 5.6, 8.7, 5.1),
    ('CCO-2026-1A', 'CCO-102', '2026000007', 6.0, 9.1, 6.0),
    ('CCO-2026-1A', 'CCO-103', '2026000007', 6.1, 6.8, 7.1),
    ('CCO-2026-1A', 'CCO-104', '2026000007', 4.1, 4.1, 4.5),
    ('CCO-2026-1A', 'CCO-105', '2026000007', 4.8, 6.2, 7.0),
    ('CCO-2026-1A', 'CCO-101', '2026000008', 5.6, 6.3, 3.8),
    ('CCO-2026-1A', 'CCO-102', '2026000008', 8.8, 9.2, 8.3),
    ('CCO-2026-1A', 'CCO-103', '2026000008', 5.0, 6.6, 4.6),
    ('CCO-2026-1A', 'CCO-104', '2026000008', 4.2, 4.2, 6.0),
    ('CCO-2026-1A', 'CCO-105', '2026000008', 2.0, 3.5, 3.8),
    ('CCO-2026-1A', 'CCO-101', '2026000009', 5.5, 7.5, 5.7),
    ('CCO-2026-1A', 'CCO-102', '2026000009', 6.9, 5.2, 7.8),
    ('CCO-2026-1A', 'CCO-103', '2026000009', 4.7, 4.0, 3.5),
    ('CCO-2026-1A', 'CCO-104', '2026000009', 2.6, 3.9, 2.8),
    ('CCO-2026-1A', 'CCO-105', '2026000009', 4.5, 5.1, 5.5),
    ('CCO-2026-1A', 'CCO-101', '2026000010', 9.8, 10.0, 9.9),
    ('CCO-2026-1A', 'CCO-102', '2026000010', 6.2, 7.8, 7.9),
    ('CCO-2026-1A', 'CCO-103', '2026000010', 7.1, 9.6, 7.2),
    ('CCO-2026-1A', 'CCO-104', '2026000010', 5.9, 3.6, 3.9),
    ('CCO-2026-1A', 'CCO-105', '2026000010', 5.3, 7.0, 4.4),
    ('CCO-2026-1A', 'CCO-101', '2026000011', 8.3, 10.0, 10.0),
    ('CCO-2026-1A', 'CCO-102', '2026000011', 6.8, 6.5, 8.1),
    ('CCO-2026-1A', 'CCO-103', '2026000011', 5.9, 2.3, 5.7),
    ('CCO-2026-1A', 'CCO-104', '2026000011', 6.7, 5.1, 5.2),
    ('CCO-2026-1A', 'CCO-105', '2026000011', 6.5, 4.1, 7.2),
    ('CCO-2026-1A', 'CCO-101', '2026000012', 8.0, 7.1, 7.1),
    ('CCO-2026-1A', 'CCO-102', '2026000012', 6.5, 6.0, 4.7),
    ('CCO-2026-1A', 'CCO-103', '2026000012', 9.6, 9.3, 10.0),
    ('CCO-2026-1A', 'CCO-104', '2026000012', 6.3, 3.3, 6.0),
    ('CCO-2026-1A', 'CCO-105', '2026000012', 4.6, 2.9, 4.5),
    ('CCO-2026-1A', 'CCO-101', '2026000013', 2.7, 3.1, 3.2),
    ('CCO-2026-1A', 'CCO-102', '2026000013', 3.8, 3.6, 4.0),
    ('CCO-2026-1A', 'CCO-103', '2026000013', 9.9, 10.0, 7.6),
    ('CCO-2026-1A', 'CCO-104', '2026000013', 6.1, 6.3, 6.5),
    ('CCO-2026-1A', 'CCO-105', '2026000013', 4.5, 4.9, 5.9),
    ('CCO-2026-1A', 'CCO-101', '2026000014', 4.1, 7.0, 5.0),
    ('CCO-2026-1A', 'CCO-102', '2026000014', 8.8, 8.1, 10.0),
    ('CCO-2026-1A', 'CCO-103', '2026000014', 3.8, 3.4, 6.4),
    ('CCO-2026-1A', 'CCO-104', '2026000014', 4.4, 5.8, 4.1),
    ('CCO-2026-1A', 'CCO-105', '2026000014', 6.5, 6.8, 4.9),
    ('CCO-2026-1A', 'CCO-101', '2026000015', 8.9, 10.0, 8.7),
    ('CCO-2026-1A', 'CCO-102', '2026000015', 7.5, 7.5, 9.9),
    ('CCO-2026-1A', 'CCO-103', '2026000015', 7.4, 10.0, 7.5),
    ('CCO-2026-1A', 'CCO-104', '2026000015', 6.6, 3.5, 5.9),
    ('CCO-2026-1A', 'CCO-105', '2026000015', 4.7, 7.6, 4.7),
    ('CCO-2026-1A', 'CCO-101', '2026000016', 9.5, 10.0, 8.0),
    ('CCO-2026-1A', 'CCO-102', '2026000016', 4.1, 5.0, 4.0),
    ('CCO-2026-1A', 'CCO-103', '2026000016', 7.7, 6.3, 6.3),
    ('CCO-2026-1A', 'CCO-104', '2026000016', 5.5, 5.1, 5.6),
    ('CCO-2026-1A', 'CCO-105', '2026000016', 3.3, 2.4, 2.1),
    ('CCO-2026-1A', 'CCO-101', '2026000017', 8.3, 4.9, 7.6),
    ('CCO-2026-1A', 'CCO-102', '2026000017', 8.8, 8.9, 5.7),
    ('CCO-2026-1A', 'CCO-103', '2026000017', 6.7, 7.7, 7.6),
    ('CCO-2026-1A', 'CCO-104', '2026000017', 7.4, 8.0, 8.5),
    ('CCO-2026-1A', 'CCO-105', '2026000017', 4.8, 2.5, 2.7),
    ('CCO-2026-1A', 'CCO-101', '2026000018', 4.0, 5.2, 2.7),
    ('CCO-2026-1A', 'CCO-102', '2026000018', 8.4, 7.1, 9.4),
    ('CCO-2026-1A', 'CCO-103', '2026000018', 7.0, 7.4, 7.6),
    ('CCO-2026-1A', 'CCO-104', '2026000018', 4.0, 4.8, 5.0),
    ('CCO-2026-1A', 'CCO-105', '2026000018', 7.5, 9.0, 9.0),
    ('CCO-2026-1A', 'CCO-101', '2026000019', 7.7, 9.1, 7.4),
    ('CCO-2026-1A', 'CCO-102', '2026000019', 7.7, 8.8, 7.9),
    ('CCO-2026-1A', 'CCO-103', '2026000019', 4.7, 5.9, 7.5),
    ('CCO-2026-1A', 'CCO-104', '2026000019', 6.4, 8.2, 7.6),
    ('CCO-2026-1A', 'CCO-105', '2026000019', 5.8, 7.2, 5.8),
    ('CCO-2026-1A', 'CCO-101', '2026000020', 10.0, 9.8, 7.2),
    ('CCO-2026-1A', 'CCO-102', '2026000020', 2.9, 5.6, 3.5),
    ('CCO-2026-1A', 'CCO-103', '2026000020', 4.2, 5.5, 4.2),
    ('CCO-2026-1A', 'CCO-104', '2026000020', 4.0, 3.8, 4.2),
    ('CCO-2026-1A', 'CCO-105', '2026000020', 6.3, 2.8, 5.8),
    ('CCO-2026-1A', 'CCO-101', '2026000021', 5.8, 5.8, 6.1),
    ('CCO-2026-1A', 'CCO-102', '2026000021', 10.0, 9.1, 9.1),
    ('CCO-2026-1A', 'CCO-103', '2026000021', 6.6, 8.0, 6.7),
    ('CCO-2026-1A', 'CCO-104', '2026000021', 7.8, 8.8, 7.1),
    ('CCO-2026-1A', 'CCO-105', '2026000021', 4.6, 4.1, 7.2),
    ('CCO-2026-1A', 'CCO-101', '2026000022', 2.8, 4.6, 3.1),
    ('CCO-2026-1A', 'CCO-102', '2026000022', 6.9, 7.4, 6.3),
    ('CCO-2026-1A', 'CCO-103', '2026000022', 4.7, 6.0, 5.2),
    ('CCO-2026-1A', 'CCO-104', '2026000022', 8.8, 10.0, 8.0),
    ('CCO-2026-1A', 'CCO-105', '2026000022', 10.0, 10.0, 8.9),
    ('CCO-2026-1A', 'CCO-101', '2026000023', 10.0, 7.1, 9.7),
    ('CCO-2026-1A', 'CCO-102', '2026000023', 9.1, 7.4, 8.7),
    ('CCO-2026-1A', 'CCO-103', '2026000023', 9.4, 6.9, 8.7),
    ('CCO-2026-1A', 'CCO-104', '2026000023', 6.9, 6.7, 3.2),
    ('CCO-2026-1A', 'CCO-105', '2026000023', 8.0, 7.0, 7.8),
    ('CCO-2026-1A', 'CCO-101', '2026000024', 9.2, 7.0, 6.7),
    ('CCO-2026-1A', 'CCO-102', '2026000024', 7.6, 8.6, 6.3),
    ('CCO-2026-1A', 'CCO-103', '2026000024', 6.2, 7.5, 6.8),
    ('CCO-2026-1A', 'CCO-104', '2026000024', 6.7, 8.3, 8.2),
    ('CCO-2026-1A', 'CCO-105', '2026000024', 6.9, 7.0, 7.1),
    ('CCO-2026-1A', 'CCO-101', '2026000025', 8.4, 10.0, 8.5),
    ('CCO-2026-1A', 'CCO-102', '2026000025', 9.4, 9.5, 9.2),
    ('CCO-2026-1A', 'CCO-103', '2026000025', 3.6, 3.7, 5.7),
    ('CCO-2026-1A', 'CCO-104', '2026000025', 3.7, 4.1, 2.7),
    ('CCO-2026-1A', 'CCO-105', '2026000025', 10.0, 8.4, 7.4),
    ('CCO-2026-1A', 'CCO-101', '2026000026', 7.1, 7.2, 5.2),
    ('CCO-2026-1A', 'CCO-102', '2026000026', 7.7, 7.6, 5.3),
    ('CCO-2026-1A', 'CCO-103', '2026000026', 8.0, 9.1, 10.0),
    ('CCO-2026-1A', 'CCO-104', '2026000026', 7.0, 7.4, 8.0),
    ('CCO-2026-1A', 'CCO-105', '2026000026', 4.8, 3.4, 5.4),
    ('CCO-2026-1A', 'CCO-101', '2026000027', 7.6, 6.0, 5.4),
    ('CCO-2026-1A', 'CCO-102', '2026000027', 6.5, 8.6, 8.7),
    ('CCO-2026-1A', 'CCO-103', '2026000027', 6.3, 7.6, 8.7),
    ('CCO-2026-1A', 'CCO-104', '2026000027', 4.6, 3.2, 3.6),
    ('CCO-2026-1A', 'CCO-105', '2026000027', 4.3, 2.3, 2.3),
    ('CCO-2026-1A', 'CCO-101', '2026000028', 8.9, 8.4, 7.7),
    ('CCO-2026-1A', 'CCO-102', '2026000028', 5.4, 5.8, 6.7),
    ('CCO-2026-1A', 'CCO-103', '2026000028', 3.6, 3.7, 3.9),
    ('CCO-2026-1A', 'CCO-104', '2026000028', 4.1, 2.3, 5.0),
    ('CCO-2026-1A', 'CCO-105', '2026000028', 9.7, 8.1, 9.8),
    ('CCO-2026-1A', 'CCO-101', '2026000029', 6.0, 7.6, 8.0),
    ('CCO-2026-1A', 'CCO-102', '2026000029', 7.7, 8.9, 8.7),
    ('CCO-2026-1A', 'CCO-103', '2026000029', 7.5, 9.2, 9.2),
    ('CCO-2026-1A', 'CCO-104', '2026000029', 7.6, 5.4, 5.7),
    ('CCO-2026-1A', 'CCO-105', '2026000029', 8.3, 9.1, 7.9),
    ('CCO-2026-1A', 'CCO-101', '2026000030', 5.9, 7.1, 6.7),
    ('CCO-2026-1A', 'CCO-102', '2026000030', 7.6, 10.0, 10.0),
    ('CCO-2026-1A', 'CCO-103', '2026000030', 5.1, 5.2, 6.9),
    ('CCO-2026-1A', 'CCO-104', '2026000030', 7.5, 7.8, 8.1),
    ('CCO-2026-1A', 'CCO-105', '2026000030', 9.6, 7.7, 9.4),
    ('ADS-2026-1B', 'CCO-101', '2026000031', 6.2, 7.6, 5.0),
    ('ADS-2026-1B', 'CCO-102', '2026000031', 10.0, 9.8, 7.4),
    ('ADS-2026-1B', 'CCO-103', '2026000031', 3.6, 6.4, 5.9),
    ('ADS-2026-1B', 'CCO-104', '2026000031', 3.3, 3.5, 6.1),
    ('ADS-2026-1B', 'CCO-105', '2026000031', 3.8, 4.5, 4.8),
    ('ADS-2026-1B', 'CCO-101', '2026000032', 7.0, 5.8, 6.3),
    ('ADS-2026-1B', 'CCO-102', '2026000032', 6.1, 6.9, 6.3),
    ('ADS-2026-1B', 'CCO-103', '2026000032', 8.4, 7.0, 9.4),
    ('ADS-2026-1B', 'CCO-104', '2026000032', 3.8, 3.3, 4.1),
    ('ADS-2026-1B', 'CCO-105', '2026000032', 5.7, 5.6, 2.5),
    ('ADS-2026-1B', 'CCO-101', '2026000033', 6.7, 5.6, 6.0),
    ('ADS-2026-1B', 'CCO-102', '2026000033', 6.9, 6.2, 8.8),
    ('ADS-2026-1B', 'CCO-103', '2026000033', 8.1, 7.2, 6.0),
    ('ADS-2026-1B', 'CCO-104', '2026000033', 3.2, 6.0, 4.9),
    ('ADS-2026-1B', 'CCO-105', '2026000033', 6.9, 8.5, 10.0),
    ('ADS-2026-1B', 'CCO-101', '2026000034', 3.5, 3.0, 2.1),
    ('ADS-2026-1B', 'CCO-102', '2026000034', 7.3, 6.6, 8.4),
    ('ADS-2026-1B', 'CCO-103', '2026000034', 8.0, 8.0, 5.3),
    ('ADS-2026-1B', 'CCO-104', '2026000034', 2.8, 2.1, 4.7),
    ('ADS-2026-1B', 'CCO-105', '2026000034', 4.5, 3.6, 2.4),
    ('ADS-2026-1B', 'CCO-101', '2026000035', 3.4, 2.5, 4.5),
    ('ADS-2026-1B', 'CCO-102', '2026000035', 10.0, 9.4, 7.2),
    ('ADS-2026-1B', 'CCO-103', '2026000035', 2.5, 4.9, 4.6),
    ('ADS-2026-1B', 'CCO-104', '2026000035', 6.2, 6.3, 4.9),
    ('ADS-2026-1B', 'CCO-105', '2026000035', 5.6, 2.0, 5.4),
    ('ADS-2026-1B', 'CCO-101', '2026000036', 4.3, 4.7, 5.9),
    ('ADS-2026-1B', 'CCO-102', '2026000036', 7.5, 7.2, 9.4),
    ('ADS-2026-1B', 'CCO-103', '2026000036', 5.7, 6.3, 3.6),
    ('ADS-2026-1B', 'CCO-104', '2026000036', 5.7, 7.1, 6.7),
    ('ADS-2026-1B', 'CCO-105', '2026000036', 7.6, 5.5, 6.0),
    ('ADS-2026-1B', 'CCO-101', '2026000037', 5.9, 5.2, 4.6),
    ('ADS-2026-1B', 'CCO-102', '2026000037', 7.6, 7.1, 5.8),
    ('ADS-2026-1B', 'CCO-103', '2026000037', 3.5, 3.4, 2.1),
    ('ADS-2026-1B', 'CCO-104', '2026000037', 10.0, 8.0, 6.1),
    ('ADS-2026-1B', 'CCO-105', '2026000037', 4.0, 6.0, 3.9),
    ('ADS-2026-1B', 'CCO-101', '2026000038', 7.9, 7.1, 6.3),
    ('ADS-2026-1B', 'CCO-102', '2026000038', 8.4, 8.4, 8.4),
    ('ADS-2026-1B', 'CCO-103', '2026000038', 7.5, 8.3, 8.7),
    ('ADS-2026-1B', 'CCO-104', '2026000038', 5.9, 3.3, 3.1),
    ('ADS-2026-1B', 'CCO-105', '2026000038', 2.4, 3.0, 3.2),
    ('ADS-2026-1B', 'CCO-101', '2026000039', 8.1, 6.9, 8.6),
    ('ADS-2026-1B', 'CCO-102', '2026000039', 7.9, 6.3, 8.0),
    ('ADS-2026-1B', 'CCO-103', '2026000039', 6.4, 8.1, 9.0),
    ('ADS-2026-1B', 'CCO-104', '2026000039', 3.8, 3.2, 6.0),
    ('ADS-2026-1B', 'CCO-105', '2026000039', 7.7, 10.0, 10.0),
    ('ADS-2026-1B', 'CCO-101', '2026000040', 6.9, 6.2, 3.3),
    ('ADS-2026-1B', 'CCO-102', '2026000040', 8.3, 8.4, 8.9),
    ('ADS-2026-1B', 'CCO-103', '2026000040', 7.2, 4.5, 5.9),
    ('ADS-2026-1B', 'CCO-104', '2026000040', 6.2, 8.8, 7.3),
    ('ADS-2026-1B', 'CCO-105', '2026000040', 8.0, 7.9, 8.6),
    ('ADS-2026-1B', 'CCO-101', '2026000041', 8.0, 8.6, 6.7),
    ('ADS-2026-1B', 'CCO-102', '2026000041', 8.3, 6.8, 8.6),
    ('ADS-2026-1B', 'CCO-103', '2026000041', 8.9, 6.7, 7.9),
    ('ADS-2026-1B', 'CCO-104', '2026000041', 8.3, 5.8, 9.3),
    ('ADS-2026-1B', 'CCO-105', '2026000041', 5.5, 4.2, 4.4),
    ('ADS-2026-1B', 'CCO-101', '2026000042', 8.7, 7.1, 7.5),
    ('ADS-2026-1B', 'CCO-102', '2026000042', 9.8, 8.4, 10.0),
    ('ADS-2026-1B', 'CCO-103', '2026000042', 10.0, 10.0, 7.4),
    ('ADS-2026-1B', 'CCO-104', '2026000042', 5.6, 6.6, 5.4),
    ('ADS-2026-1B', 'CCO-105', '2026000042', 7.3, 6.6, 5.1),
    ('ADS-2026-1B', 'CCO-101', '2026000043', 7.8, 8.0, 8.0),
    ('ADS-2026-1B', 'CCO-102', '2026000043', 9.6, 10.0, 6.7),
    ('ADS-2026-1B', 'CCO-103', '2026000043', 7.5, 5.7, 9.2),
    ('ADS-2026-1B', 'CCO-104', '2026000043', 6.8, 8.1, 8.8),
    ('ADS-2026-1B', 'CCO-105', '2026000043', 2.6, 5.7, 4.0),
    ('ADS-2026-1B', 'CCO-101', '2026000044', 7.9, 5.6, 7.7),
    ('ADS-2026-1B', 'CCO-102', '2026000044', 5.6, 4.5, 3.0),
    ('ADS-2026-1B', 'CCO-103', '2026000044', 6.9, 5.7, 7.3),
    ('ADS-2026-1B', 'CCO-104', '2026000044', 2.1, 2.5, 4.7),
    ('ADS-2026-1B', 'CCO-105', '2026000044', 8.1, 4.6, 7.8),
    ('ADS-2026-1B', 'CCO-101', '2026000045', 9.7, 6.5, 7.8),
    ('ADS-2026-1B', 'CCO-102', '2026000045', 7.7, 4.5, 6.0),
    ('ADS-2026-1B', 'CCO-103', '2026000045', 4.3, 7.0, 6.8),
    ('ADS-2026-1B', 'CCO-104', '2026000045', 7.6, 9.3, 7.3),
    ('ADS-2026-1B', 'CCO-105', '2026000045', 7.2, 6.9, 5.4),
    ('ADS-2026-1B', 'CCO-101', '2026000046', 4.7, 6.5, 6.9),
    ('ADS-2026-1B', 'CCO-102', '2026000046', 4.8, 2.5, 2.8),
    ('ADS-2026-1B', 'CCO-103', '2026000046', 8.1, 6.7, 9.6),
    ('ADS-2026-1B', 'CCO-104', '2026000046', 6.7, 6.2, 4.0),
    ('ADS-2026-1B', 'CCO-105', '2026000046', 8.8, 9.3, 8.3),
    ('ADS-2026-1B', 'CCO-101', '2026000047', 5.1, 7.3, 6.1),
    ('ADS-2026-1B', 'CCO-102', '2026000047', 7.0, 8.1, 6.3),
    ('ADS-2026-1B', 'CCO-103', '2026000047', 7.5, 5.2, 5.4),
    ('ADS-2026-1B', 'CCO-104', '2026000047', 5.3, 7.7, 8.4),
    ('ADS-2026-1B', 'CCO-105', '2026000047', 7.1, 7.1, 10.0),
    ('ADS-2026-1B', 'CCO-101', '2026000048', 4.9, 5.1, 5.2),
    ('ADS-2026-1B', 'CCO-102', '2026000048', 8.3, 8.1, 7.2),
    ('ADS-2026-1B', 'CCO-103', '2026000048', 5.5, 2.6, 3.5),
    ('ADS-2026-1B', 'CCO-104', '2026000048', 9.0, 10.0, 7.4),
    ('ADS-2026-1B', 'CCO-105', '2026000048', 6.8, 5.8, 6.1),
    ('ADS-2026-1B', 'CCO-101', '2026000049', 2.1, 2.2, 3.4),
    ('ADS-2026-1B', 'CCO-102', '2026000049', 4.6, 6.4, 3.5),
    ('ADS-2026-1B', 'CCO-103', '2026000049', 3.1, 6.3, 5.3),
    ('ADS-2026-1B', 'CCO-104', '2026000049', 7.3, 6.1, 6.1),
    ('ADS-2026-1B', 'CCO-105', '2026000049', 5.8, 4.4, 6.9),
    ('ADS-2026-1B', 'CCO-101', '2026000050', 7.0, 5.8, 3.9),
    ('ADS-2026-1B', 'CCO-102', '2026000050', 6.3, 7.0, 6.2),
    ('ADS-2026-1B', 'CCO-103', '2026000050', 10.0, 7.1, 9.8),
    ('ADS-2026-1B', 'CCO-104', '2026000050', 4.3, 6.0, 4.7),
    ('ADS-2026-1B', 'CCO-105', '2026000050', 8.1, 8.6, 7.4),
    ('ADS-2026-1B', 'CCO-101', '2026000051', 10.0, 8.6, 8.5),
    ('ADS-2026-1B', 'CCO-102', '2026000051', 9.3, 8.2, 6.5),
    ('ADS-2026-1B', 'CCO-103', '2026000051', 7.0, 8.3, 9.8),
    ('ADS-2026-1B', 'CCO-104', '2026000051', 6.7, 9.0, 6.4),
    ('ADS-2026-1B', 'CCO-105', '2026000051', 3.2, 3.6, 3.7),
    ('ADS-2026-1B', 'CCO-101', '2026000052', 7.3, 8.9, 9.6),
    ('ADS-2026-1B', 'CCO-102', '2026000052', 6.5, 6.0, 4.7),
    ('ADS-2026-1B', 'CCO-103', '2026000052', 8.1, 6.1, 7.0),
    ('ADS-2026-1B', 'CCO-104', '2026000052', 2.8, 6.0, 4.0),
    ('ADS-2026-1B', 'CCO-105', '2026000052', 4.3, 4.1, 3.2),
    ('ADS-2026-1B', 'CCO-101', '2026000053', 9.2, 7.4, 9.3),
    ('ADS-2026-1B', 'CCO-102', '2026000053', 3.1, 2.3, 3.5),
    ('ADS-2026-1B', 'CCO-103', '2026000053', 6.8, 6.2, 8.0),
    ('ADS-2026-1B', 'CCO-104', '2026000053', 7.2, 4.3, 6.3),
    ('ADS-2026-1B', 'CCO-105', '2026000053', 5.6, 7.9, 4.9),
    ('ADS-2026-1B', 'CCO-101', '2026000054', 6.8, 5.9, 6.3),
    ('ADS-2026-1B', 'CCO-102', '2026000054', 8.8, 7.7, 7.0),
    ('ADS-2026-1B', 'CCO-103', '2026000054', 4.2, 2.7, 3.9),
    ('ADS-2026-1B', 'CCO-104', '2026000054', 5.6, 3.1, 4.5),
    ('ADS-2026-1B', 'CCO-105', '2026000054', 6.3, 3.5, 3.4),
    ('ADS-2026-1B', 'CCO-101', '2026000055', 9.4, 6.7, 7.1),
    ('ADS-2026-1B', 'CCO-102', '2026000055', 6.0, 7.7, 5.2),
    ('ADS-2026-1B', 'CCO-103', '2026000055', 8.7, 6.2, 7.1),
    ('ADS-2026-1B', 'CCO-104', '2026000055', 3.6, 6.9, 5.7),
    ('ADS-2026-1B', 'CCO-105', '2026000055', 7.0, 7.3, 6.9),
    ('ADS-2026-1B', 'CCO-101', '2026000056', 9.9, 7.0, 6.3),
    ('ADS-2026-1B', 'CCO-102', '2026000056', 4.3, 6.5, 3.5),
    ('ADS-2026-1B', 'CCO-103', '2026000056', 4.5, 7.0, 5.6),
    ('ADS-2026-1B', 'CCO-104', '2026000056', 6.7, 8.6, 7.7),
    ('ADS-2026-1B', 'CCO-105', '2026000056', 6.2, 6.6, 7.0),
    ('ADS-2026-1B', 'CCO-101', '2026000057', 10.0, 8.7, 9.6),
    ('ADS-2026-1B', 'CCO-102', '2026000057', 10.0, 10.0, 10.0),
    ('ADS-2026-1B', 'CCO-103', '2026000057', 8.1, 10.0, 8.3),
    ('ADS-2026-1B', 'CCO-104', '2026000057', 2.9, 5.9, 6.5),
    ('ADS-2026-1B', 'CCO-105', '2026000057', 3.0, 6.3, 6.3),
    ('ADS-2026-1B', 'CCO-101', '2026000058', 7.8, 7.8, 5.7),
    ('ADS-2026-1B', 'CCO-102', '2026000058', 8.9, 8.0, 7.7),
    ('ADS-2026-1B', 'CCO-103', '2026000058', 9.0, 10.0, 9.5),
    ('ADS-2026-1B', 'CCO-104', '2026000058', 9.2, 9.7, 7.7),
    ('ADS-2026-1B', 'CCO-105', '2026000058', 4.0, 5.8, 4.4),
    ('ADS-2026-1B', 'CCO-101', '2026000059', 4.1, 3.8, 4.8),
    ('ADS-2026-1B', 'CCO-102', '2026000059', 3.4, 2.9, 4.3),
    ('ADS-2026-1B', 'CCO-103', '2026000059', 6.6, 9.1, 6.0),
    ('ADS-2026-1B', 'CCO-104', '2026000059', 5.2, 5.1, 5.9),
    ('ADS-2026-1B', 'CCO-105', '2026000059', 9.6, 6.8, 7.6),
    ('ADS-2026-1B', 'CCO-101', '2026000060', 9.4, 9.1, 10.0),
    ('ADS-2026-1B', 'CCO-102', '2026000060', 5.2, 6.6, 7.6),
    ('ADS-2026-1B', 'CCO-103', '2026000060', 4.9, 4.5, 4.5),
    ('ADS-2026-1B', 'CCO-104', '2026000060', 7.1, 8.9, 7.9),
    ('ADS-2026-1B', 'CCO-105', '2026000060', 7.5, 9.4, 7.1),
    ('ESW-2026-3A', 'CCO-101', '2026000061', 2.6, 3.8, 4.0),
    ('ESW-2026-3A', 'CCO-102', '2026000061', 8.3, 7.0, 10.0),
    ('ESW-2026-3A', 'CCO-103', '2026000061', 8.4, 9.6, 9.4),
    ('ESW-2026-3A', 'CCO-104', '2026000061', 6.9, 7.5, 8.6),
    ('ESW-2026-3A', 'CCO-105', '2026000061', 3.7, 6.4, 4.6),
    ('ESW-2026-3A', 'CCO-101', '2026000062', 3.8, 4.3, 3.7),
    ('ESW-2026-3A', 'CCO-102', '2026000062', 9.5, 7.8, 7.2),
    ('ESW-2026-3A', 'CCO-103', '2026000062', 10.0, 10.0, 7.0),
    ('ESW-2026-3A', 'CCO-104', '2026000062', 7.6, 8.4, 9.1),
    ('ESW-2026-3A', 'CCO-105', '2026000062', 2.5, 5.0, 3.8),
    ('ESW-2026-3A', 'CCO-101', '2026000063', 3.6, 6.3, 5.2),
    ('ESW-2026-3A', 'CCO-102', '2026000063', 5.1, 6.9, 5.5),
    ('ESW-2026-3A', 'CCO-103', '2026000063', 8.1, 8.2, 8.7),
    ('ESW-2026-3A', 'CCO-104', '2026000063', 5.5, 5.6, 4.9),
    ('ESW-2026-3A', 'CCO-105', '2026000063', 6.6, 6.8, 4.8),
    ('ESW-2026-3A', 'CCO-101', '2026000064', 7.5, 8.8, 9.5),
    ('ESW-2026-3A', 'CCO-102', '2026000064', 5.9, 3.5, 5.2),
    ('ESW-2026-3A', 'CCO-103', '2026000064', 6.8, 4.5, 4.0),
    ('ESW-2026-3A', 'CCO-104', '2026000064', 3.7, 6.1, 6.6),
    ('ESW-2026-3A', 'CCO-105', '2026000064', 6.6, 5.8, 6.8),
    ('ESW-2026-3A', 'CCO-101', '2026000065', 8.5, 7.8, 9.1),
    ('ESW-2026-3A', 'CCO-102', '2026000065', 4.5, 7.0, 4.9),
    ('ESW-2026-3A', 'CCO-103', '2026000065', 8.3, 7.8, 8.0),
    ('ESW-2026-3A', 'CCO-104', '2026000065', 8.4, 4.7, 8.2),
    ('ESW-2026-3A', 'CCO-105', '2026000065', 6.6, 3.7, 6.2),
    ('ESW-2026-3A', 'CCO-101', '2026000066', 8.7, 7.0, 5.2),
    ('ESW-2026-3A', 'CCO-102', '2026000066', 6.5, 5.9, 5.9),
    ('ESW-2026-3A', 'CCO-103', '2026000066', 5.9, 6.6, 7.0),
    ('ESW-2026-3A', 'CCO-104', '2026000066', 5.9, 5.5, 4.3),
    ('ESW-2026-3A', 'CCO-105', '2026000066', 7.6, 7.4, 6.7),
    ('ESW-2026-3A', 'CCO-101', '2026000067', 3.7, 4.6, 7.3),
    ('ESW-2026-3A', 'CCO-102', '2026000067', 4.5, 2.2, 3.6),
    ('ESW-2026-3A', 'CCO-103', '2026000067', 7.2, 6.6, 4.3),
    ('ESW-2026-3A', 'CCO-104', '2026000067', 3.3, 3.8, 3.4),
    ('ESW-2026-3A', 'CCO-105', '2026000067', 4.6, 2.5, 3.5),
    ('ESW-2026-3A', 'CCO-101', '2026000068', 9.3, 9.1, 8.4),
    ('ESW-2026-3A', 'CCO-102', '2026000068', 5.7, 5.8, 7.2),
    ('ESW-2026-3A', 'CCO-103', '2026000068', 4.5, 2.9, 3.4),
    ('ESW-2026-3A', 'CCO-104', '2026000068', 5.9, 3.0, 3.1),
    ('ESW-2026-3A', 'CCO-105', '2026000068', 4.0, 5.0, 3.4),
    ('ESW-2026-3A', 'CCO-101', '2026000069', 8.7, 9.6, 10.0),
    ('ESW-2026-3A', 'CCO-102', '2026000069', 8.0, 8.4, 10.0),
    ('ESW-2026-3A', 'CCO-103', '2026000069', 7.6, 7.7, 6.7),
    ('ESW-2026-3A', 'CCO-104', '2026000069', 6.6, 6.3, 5.6),
    ('ESW-2026-3A', 'CCO-105', '2026000069', 2.4, 3.5, 6.0),
    ('ESW-2026-3A', 'CCO-101', '2026000070', 3.7, 6.2, 4.8),
    ('ESW-2026-3A', 'CCO-102', '2026000070', 7.1, 4.5, 5.1),
    ('ESW-2026-3A', 'CCO-103', '2026000070', 7.6, 10.0, 8.3),
    ('ESW-2026-3A', 'CCO-104', '2026000070', 3.0, 5.2, 5.3),
    ('ESW-2026-3A', 'CCO-105', '2026000070', 4.2, 7.0, 5.0),
    ('ESW-2026-3A', 'CCO-101', '2026000071', 7.7, 6.8, 6.8),
    ('ESW-2026-3A', 'CCO-102', '2026000071', 7.7, 8.9, 9.7),
    ('ESW-2026-3A', 'CCO-103', '2026000071', 4.0, 5.1, 4.2),
    ('ESW-2026-3A', 'CCO-104', '2026000071', 7.5, 5.2, 4.1),
    ('ESW-2026-3A', 'CCO-105', '2026000071', 4.0, 5.4, 3.3),
    ('ESW-2026-3A', 'CCO-101', '2026000072', 6.2, 7.0, 8.0),
    ('ESW-2026-3A', 'CCO-102', '2026000072', 6.5, 10.0, 8.5),
    ('ESW-2026-3A', 'CCO-103', '2026000072', 4.9, 5.6, 5.7),
    ('ESW-2026-3A', 'CCO-104', '2026000072', 3.6, 6.1, 3.8),
    ('ESW-2026-3A', 'CCO-105', '2026000072', 5.8, 2.5, 4.2),
    ('ESW-2026-3A', 'CCO-101', '2026000073', 3.4, 6.8, 5.0),
    ('ESW-2026-3A', 'CCO-102', '2026000073', 6.6, 3.8, 6.2),
    ('ESW-2026-3A', 'CCO-103', '2026000073', 6.3, 7.1, 7.3),
    ('ESW-2026-3A', 'CCO-104', '2026000073', 7.3, 7.5, 6.2),
    ('ESW-2026-3A', 'CCO-105', '2026000073', 6.5, 7.0, 8.0),
    ('ESW-2026-3A', 'CCO-101', '2026000074', 5.5, 5.4, 5.9),
    ('ESW-2026-3A', 'CCO-102', '2026000074', 5.2, 3.7, 6.4),
    ('ESW-2026-3A', 'CCO-103', '2026000074', 7.9, 8.9, 6.8),
    ('ESW-2026-3A', 'CCO-104', '2026000074', 4.5, 4.1, 5.1),
    ('ESW-2026-3A', 'CCO-105', '2026000074', 7.8, 8.2, 9.6),
    ('ESW-2026-3A', 'CCO-101', '2026000075', 7.8, 9.7, 8.1),
    ('ESW-2026-3A', 'CCO-102', '2026000075', 5.7, 5.2, 6.1),
    ('ESW-2026-3A', 'CCO-103', '2026000075', 3.9, 4.3, 2.1),
    ('ESW-2026-3A', 'CCO-104', '2026000075', 6.3, 5.1, 6.5),
    ('ESW-2026-3A', 'CCO-105', '2026000075', 8.3, 5.5, 7.2),
    ('ESW-2026-3A', 'CCO-101', '2026000076', 8.3, 6.9, 8.9),
    ('ESW-2026-3A', 'CCO-102', '2026000076', 6.3, 3.7, 5.1),
    ('ESW-2026-3A', 'CCO-103', '2026000076', 10.0, 9.1, 8.5),
    ('ESW-2026-3A', 'CCO-104', '2026000076', 8.9, 8.4, 7.9),
    ('ESW-2026-3A', 'CCO-105', '2026000076', 2.7, 1.9, 5.1),
    ('ESW-2026-3A', 'CCO-101', '2026000077', 8.0, 6.2, 6.8),
    ('ESW-2026-3A', 'CCO-102', '2026000077', 5.4, 8.6, 6.1),
    ('ESW-2026-3A', 'CCO-103', '2026000077', 8.2, 8.9, 8.9),
    ('ESW-2026-3A', 'CCO-104', '2026000077', 8.2, 7.6, 9.9),
    ('ESW-2026-3A', 'CCO-105', '2026000077', 2.6, 3.2, 2.5),
    ('ESW-2026-3A', 'CCO-101', '2026000078', 8.6, 6.4, 8.8),
    ('ESW-2026-3A', 'CCO-102', '2026000078', 5.9, 3.8, 4.3),
    ('ESW-2026-3A', 'CCO-103', '2026000078', 6.8, 5.4, 5.5),
    ('ESW-2026-3A', 'CCO-104', '2026000078', 5.9, 7.3, 7.1),
    ('ESW-2026-3A', 'CCO-105', '2026000078', 5.8, 5.2, 5.3),
    ('ESW-2026-3A', 'CCO-101', '2026000079', 5.1, 7.6, 5.9),
    ('ESW-2026-3A', 'CCO-102', '2026000079', 8.1, 10.0, 9.3),
    ('ESW-2026-3A', 'CCO-103', '2026000079', 4.5, 3.6, 4.4),
    ('ESW-2026-3A', 'CCO-104', '2026000079', 6.6, 5.0, 6.5),
    ('ESW-2026-3A', 'CCO-105', '2026000079', 5.1, 5.7, 7.1),
    ('ESW-2026-3A', 'CCO-101', '2026000080', 5.8, 6.5, 8.5),
    ('ESW-2026-3A', 'CCO-102', '2026000080', 6.0, 4.7, 6.6),
    ('ESW-2026-3A', 'CCO-103', '2026000080', 10.0, 10.0, 7.7),
    ('ESW-2026-3A', 'CCO-104', '2026000080', 4.8, 6.8, 5.4),
    ('ESW-2026-3A', 'CCO-105', '2026000080', 8.7, 8.9, 8.7),
    ('ESW-2026-3A', 'CCO-101', '2026000081', 4.6, 4.4, 5.3),
    ('ESW-2026-3A', 'CCO-102', '2026000081', 7.6, 5.7, 7.8),
    ('ESW-2026-3A', 'CCO-103', '2026000081', 9.9, 8.9, 9.9),
    ('ESW-2026-3A', 'CCO-104', '2026000081', 3.8, 5.2, 5.3),
    ('ESW-2026-3A', 'CCO-105', '2026000081', 6.2, 5.7, 2.9),
    ('ESW-2026-3A', 'CCO-101', '2026000082', 6.9, 6.6, 8.7),
    ('ESW-2026-3A', 'CCO-102', '2026000082', 7.4, 8.7, 8.9),
    ('ESW-2026-3A', 'CCO-103', '2026000082', 6.2, 5.2, 5.5),
    ('ESW-2026-3A', 'CCO-104', '2026000082', 5.0, 5.4, 5.9),
    ('ESW-2026-3A', 'CCO-105', '2026000082', 8.7, 8.6, 9.3),
    ('ESW-2026-3A', 'CCO-101', '2026000083', 5.8, 7.0, 6.6),
    ('ESW-2026-3A', 'CCO-102', '2026000083', 5.1, 6.0, 6.5),
    ('ESW-2026-3A', 'CCO-103', '2026000083', 7.2, 4.4, 7.3),
    ('ESW-2026-3A', 'CCO-104', '2026000083', 6.6, 6.0, 4.8),
    ('ESW-2026-3A', 'CCO-105', '2026000083', 7.2, 8.9, 7.3),
    ('ESW-2026-3A', 'CCO-101', '2026000084', 3.9, 4.0, 5.3),
    ('ESW-2026-3A', 'CCO-102', '2026000084', 4.7, 4.3, 6.0),
    ('ESW-2026-3A', 'CCO-103', '2026000084', 5.8, 5.2, 4.0),
    ('ESW-2026-3A', 'CCO-104', '2026000084', 5.9, 6.8, 6.5),
    ('ESW-2026-3A', 'CCO-105', '2026000084', 8.2, 7.1, 8.3),
    ('ESW-2026-3A', 'CCO-101', '2026000085', 5.3, 4.5, 4.3),
    ('ESW-2026-3A', 'CCO-102', '2026000085', 7.4, 5.0, 7.3),
    ('ESW-2026-3A', 'CCO-103', '2026000085', 10.0, 6.7, 10.0),
    ('ESW-2026-3A', 'CCO-104', '2026000085', 3.6, 4.5, 5.8),
    ('ESW-2026-3A', 'CCO-105', '2026000085', 3.6, 6.4, 6.2),
    ('ESW-2026-3A', 'CCO-101', '2026000086', 4.2, 3.9, 5.1),
    ('ESW-2026-3A', 'CCO-102', '2026000086', 7.9, 6.3, 8.6),
    ('ESW-2026-3A', 'CCO-103', '2026000086', 7.4, 6.3, 4.6),
    ('ESW-2026-3A', 'CCO-104', '2026000086', 2.2, 4.3, 5.3),
    ('ESW-2026-3A', 'CCO-105', '2026000086', 6.1, 9.0, 7.0),
    ('ESW-2026-3A', 'CCO-101', '2026000087', 3.4, 5.2, 3.4),
    ('ESW-2026-3A', 'CCO-102', '2026000087', 5.1, 4.6, 7.7),
    ('ESW-2026-3A', 'CCO-103', '2026000087', 6.9, 4.9, 6.5),
    ('ESW-2026-3A', 'CCO-104', '2026000087', 2.9, 6.3, 2.8),
    ('ESW-2026-3A', 'CCO-105', '2026000087', 4.3, 6.4, 5.4),
    ('ESW-2026-3A', 'CCO-101', '2026000088', 7.8, 7.1, 7.8),
    ('ESW-2026-3A', 'CCO-102', '2026000088', 4.1, 5.9, 2.6),
    ('ESW-2026-3A', 'CCO-103', '2026000088', 10.0, 9.6, 10.0),
    ('ESW-2026-3A', 'CCO-104', '2026000088', 8.0, 6.7, 5.9),
    ('ESW-2026-3A', 'CCO-105', '2026000088', 10.0, 8.5, 8.2),
    ('ESW-2026-3A', 'CCO-101', '2026000089', 9.4, 9.3, 10.0),
    ('ESW-2026-3A', 'CCO-102', '2026000089', 8.0, 7.4, 7.9),
    ('ESW-2026-3A', 'CCO-103', '2026000089', 3.0, 6.6, 3.1),
    ('ESW-2026-3A', 'CCO-104', '2026000089', 9.3, 9.3, 6.7),
    ('ESW-2026-3A', 'CCO-105', '2026000089', 5.4, 6.8, 4.8),
    ('ESW-2026-3A', 'CCO-101', '2026000090', 7.9, 8.3, 6.8),
    ('ESW-2026-3A', 'CCO-102', '2026000090', 8.8, 9.7, 8.3),
    ('ESW-2026-3A', 'CCO-103', '2026000090', 7.7, 8.1, 7.1),
    ('ESW-2026-3A', 'CCO-104', '2026000090', 6.0, 7.1, 9.1),
    ('ESW-2026-3A', 'CCO-105', '2026000090', 10.0, 8.3, 8.5),
    ('SI-2026-2B', 'CCO-101', '2026000091', 3.8, 4.7, 5.1),
    ('SI-2026-2B', 'CCO-102', '2026000091', 7.3, 8.8, 7.3),
    ('SI-2026-2B', 'CCO-103', '2026000091', 4.2, 7.3, 6.1),
    ('SI-2026-2B', 'CCO-104', '2026000091', 5.9, 7.0, 4.3),
    ('SI-2026-2B', 'CCO-105', '2026000091', 3.4, 4.8, 3.8),
    ('SI-2026-2B', 'CCO-101', '2026000092', 8.6, 10.0, 7.7),
    ('SI-2026-2B', 'CCO-102', '2026000092', 3.7, 3.6, 3.6),
    ('SI-2026-2B', 'CCO-103', '2026000092', 10.0, 8.5, 10.0),
    ('SI-2026-2B', 'CCO-104', '2026000092', 8.0, 9.2, 8.7),
    ('SI-2026-2B', 'CCO-105', '2026000092', 6.0, 6.5, 5.7),
    ('SI-2026-2B', 'CCO-101', '2026000093', 4.5, 4.7, 6.2),
    ('SI-2026-2B', 'CCO-102', '2026000093', 5.5, 4.0, 3.6),
    ('SI-2026-2B', 'CCO-103', '2026000093', 9.3, 7.1, 5.6),
    ('SI-2026-2B', 'CCO-104', '2026000093', 6.6, 5.8, 7.0),
    ('SI-2026-2B', 'CCO-105', '2026000093', 7.4, 5.2, 7.2),
    ('SI-2026-2B', 'CCO-101', '2026000094', 7.9, 7.3, 7.9),
    ('SI-2026-2B', 'CCO-102', '2026000094', 2.6, 5.5, 4.3),
    ('SI-2026-2B', 'CCO-103', '2026000094', 8.8, 10.0, 10.0),
    ('SI-2026-2B', 'CCO-104', '2026000094', 4.3, 4.5, 2.1),
    ('SI-2026-2B', 'CCO-105', '2026000094', 7.4, 7.5, 8.5),
    ('SI-2026-2B', 'CCO-101', '2026000095', 9.3, 9.8, 7.6),
    ('SI-2026-2B', 'CCO-102', '2026000095', 3.1, 5.3, 4.5),
    ('SI-2026-2B', 'CCO-103', '2026000095', 6.1, 8.6, 5.5),
    ('SI-2026-2B', 'CCO-104', '2026000095', 5.9, 6.6, 6.9),
    ('SI-2026-2B', 'CCO-105', '2026000095', 5.8, 6.7, 7.2),
    ('SI-2026-2B', 'CCO-101', '2026000096', 6.2, 6.7, 7.9),
    ('SI-2026-2B', 'CCO-102', '2026000096', 6.0, 5.5, 5.7),
    ('SI-2026-2B', 'CCO-103', '2026000096', 5.9, 5.2, 5.6),
    ('SI-2026-2B', 'CCO-104', '2026000096', 6.3, 4.3, 5.8),
    ('SI-2026-2B', 'CCO-105', '2026000096', 8.0, 6.6, 6.4),
    ('SI-2026-2B', 'CCO-101', '2026000097', 5.6, 8.1, 5.9),
    ('SI-2026-2B', 'CCO-102', '2026000097', 4.4, 4.3, 4.6),
    ('SI-2026-2B', 'CCO-103', '2026000097', 8.3, 7.8, 7.6),
    ('SI-2026-2B', 'CCO-104', '2026000097', 5.3, 5.4, 8.0),
    ('SI-2026-2B', 'CCO-105', '2026000097', 9.2, 7.2, 10.0),
    ('SI-2026-2B', 'CCO-101', '2026000098', 6.7, 9.3, 9.8),
    ('SI-2026-2B', 'CCO-102', '2026000098', 8.5, 6.6, 8.1),
    ('SI-2026-2B', 'CCO-103', '2026000098', 5.1, 5.8, 6.1),
    ('SI-2026-2B', 'CCO-104', '2026000098', 8.8, 6.1, 7.2),
    ('SI-2026-2B', 'CCO-105', '2026000098', 7.7, 10.0, 8.9),
    ('SI-2026-2B', 'CCO-101', '2026000099', 6.1, 5.6, 4.4),
    ('SI-2026-2B', 'CCO-102', '2026000099', 5.2, 8.8, 8.8),
    ('SI-2026-2B', 'CCO-103', '2026000099', 6.8, 5.0, 4.9),
    ('SI-2026-2B', 'CCO-104', '2026000099', 5.5, 5.4, 4.9),
    ('SI-2026-2B', 'CCO-105', '2026000099', 9.8, 8.7, 7.6),
    ('SI-2026-2B', 'CCO-101', '2026000100', 6.3, 7.1, 10.0),
    ('SI-2026-2B', 'CCO-102', '2026000100', 7.1, 5.2, 5.1),
    ('SI-2026-2B', 'CCO-103', '2026000100', 8.3, 10.0, 10.0),
    ('SI-2026-2B', 'CCO-104', '2026000100', 10.0, 8.9, 8.4),
    ('SI-2026-2B', 'CCO-105', '2026000100', 4.1, 4.2, 3.7),
    ('SI-2026-2B', 'CCO-101', '2026000101', 5.7, 4.4, 3.8),
    ('SI-2026-2B', 'CCO-102', '2026000101', 4.9, 5.3, 7.3),
    ('SI-2026-2B', 'CCO-103', '2026000101', 4.3, 4.9, 5.9),
    ('SI-2026-2B', 'CCO-104', '2026000101', 6.4, 9.4, 7.1),
    ('SI-2026-2B', 'CCO-105', '2026000101', 9.6, 8.6, 10.0),
    ('SI-2026-2B', 'CCO-101', '2026000102', 9.4, 9.4, 10.0),
    ('SI-2026-2B', 'CCO-102', '2026000102', 3.3, 2.6, 4.6),
    ('SI-2026-2B', 'CCO-103', '2026000102', 8.9, 10.0, 9.7),
    ('SI-2026-2B', 'CCO-104', '2026000102', 8.9, 7.2, 5.8),
    ('SI-2026-2B', 'CCO-105', '2026000102', 5.9, 5.8, 3.5),
    ('SI-2026-2B', 'CCO-101', '2026000103', 8.8, 8.1, 8.6),
    ('SI-2026-2B', 'CCO-102', '2026000103', 3.2, 5.7, 2.2),
    ('SI-2026-2B', 'CCO-103', '2026000103', 9.9, 9.6, 8.2),
    ('SI-2026-2B', 'CCO-104', '2026000103', 5.9, 7.1, 8.7),
    ('SI-2026-2B', 'CCO-105', '2026000103', 8.3, 7.5, 4.8),
    ('SI-2026-2B', 'CCO-101', '2026000104', 7.7, 7.5, 8.6),
    ('SI-2026-2B', 'CCO-102', '2026000104', 3.3, 4.0, 3.4),
    ('SI-2026-2B', 'CCO-103', '2026000104', 8.6, 7.7, 7.4),
    ('SI-2026-2B', 'CCO-104', '2026000104', 2.8, 4.5, 5.4),
    ('SI-2026-2B', 'CCO-105', '2026000104', 6.0, 7.4, 4.5),
    ('SI-2026-2B', 'CCO-101', '2026000105', 6.6, 5.7, 3.5),
    ('SI-2026-2B', 'CCO-102', '2026000105', 4.0, 6.6, 5.8),
    ('SI-2026-2B', 'CCO-103', '2026000105', 8.5, 6.3, 5.6),
    ('SI-2026-2B', 'CCO-104', '2026000105', 9.8, 6.5, 7.1),
    ('SI-2026-2B', 'CCO-105', '2026000105', 10.0, 8.0, 10.0),
    ('SI-2026-2B', 'CCO-101', '2026000106', 8.3, 7.9, 6.2),
    ('SI-2026-2B', 'CCO-102', '2026000106', 9.4, 9.3, 7.9),
    ('SI-2026-2B', 'CCO-103', '2026000106', 5.6, 3.4, 7.3),
    ('SI-2026-2B', 'CCO-104', '2026000106', 6.9, 8.6, 8.2),
    ('SI-2026-2B', 'CCO-105', '2026000106', 2.3, 5.4, 5.2),
    ('SI-2026-2B', 'CCO-101', '2026000107', 4.9, 3.1, 3.0),
    ('SI-2026-2B', 'CCO-102', '2026000107', 6.1, 5.7, 3.5),
    ('SI-2026-2B', 'CCO-103', '2026000107', 3.9, 3.1, 5.9),
    ('SI-2026-2B', 'CCO-104', '2026000107', 6.8, 7.2, 6.9),
    ('SI-2026-2B', 'CCO-105', '2026000107', 7.5, 3.6, 6.7),
    ('SI-2026-2B', 'CCO-101', '2026000108', 6.1, 8.1, 5.9),
    ('SI-2026-2B', 'CCO-102', '2026000108', 3.7, 5.1, 5.1),
    ('SI-2026-2B', 'CCO-103', '2026000108', 7.5, 7.4, 9.3),
    ('SI-2026-2B', 'CCO-104', '2026000108', 7.5, 10.0, 8.6),
    ('SI-2026-2B', 'CCO-105', '2026000108', 8.1, 9.2, 6.0),
    ('SI-2026-2B', 'CCO-101', '2026000109', 3.5, 4.5, 1.9),
    ('SI-2026-2B', 'CCO-102', '2026000109', 5.3, 3.7, 4.3),
    ('SI-2026-2B', 'CCO-103', '2026000109', 5.5, 7.9, 8.8),
    ('SI-2026-2B', 'CCO-104', '2026000109', 9.5, 6.0, 7.3),
    ('SI-2026-2B', 'CCO-105', '2026000109', 8.7, 8.6, 5.9),
    ('SI-2026-2B', 'CCO-101', '2026000110', 9.2, 7.9, 9.0),
    ('SI-2026-2B', 'CCO-102', '2026000110', 9.9, 7.3, 7.7),
    ('SI-2026-2B', 'CCO-103', '2026000110', 7.4, 9.5, 9.2),
    ('SI-2026-2B', 'CCO-104', '2026000110', 6.6, 8.6, 6.7),
    ('SI-2026-2B', 'CCO-105', '2026000110', 5.1, 5.1, 6.1),
    ('SI-2026-2B', 'CCO-101', '2026000111', 7.4, 5.9, 8.5),
    ('SI-2026-2B', 'CCO-102', '2026000111', 5.3, 5.5, 3.6),
    ('SI-2026-2B', 'CCO-103', '2026000111', 5.9, 6.6, 8.8),
    ('SI-2026-2B', 'CCO-104', '2026000111', 7.2, 9.4, 10.0),
    ('SI-2026-2B', 'CCO-105', '2026000111', 3.5, 6.1, 4.4),
    ('SI-2026-2B', 'CCO-101', '2026000112', 9.2, 8.6, 5.9),
    ('SI-2026-2B', 'CCO-102', '2026000112', 3.6, 5.8, 6.5),
    ('SI-2026-2B', 'CCO-103', '2026000112', 4.5, 7.0, 6.2),
    ('SI-2026-2B', 'CCO-104', '2026000112', 10.0, 9.6, 10.0),
    ('SI-2026-2B', 'CCO-105', '2026000112', 7.2, 4.7, 5.8),
    ('SI-2026-2B', 'CCO-101', '2026000113', 5.8, 5.5, 5.1),
    ('SI-2026-2B', 'CCO-102', '2026000113', 6.3, 5.0, 3.3),
    ('SI-2026-2B', 'CCO-103', '2026000113', 4.3, 7.0, 5.8),
    ('SI-2026-2B', 'CCO-104', '2026000113', 6.8, 6.9, 7.1),
    ('SI-2026-2B', 'CCO-105', '2026000113', 6.7, 6.7, 4.6),
    ('SI-2026-2B', 'CCO-101', '2026000114', 8.7, 10.0, 8.2),
    ('SI-2026-2B', 'CCO-102', '2026000114', 3.9, 3.8, 4.7),
    ('SI-2026-2B', 'CCO-103', '2026000114', 10.0, 10.0, 7.6),
    ('SI-2026-2B', 'CCO-104', '2026000114', 5.1, 5.0, 4.6),
    ('SI-2026-2B', 'CCO-105', '2026000114', 8.7, 6.3, 8.9),
    ('SI-2026-2B', 'CCO-101', '2026000115', 9.0, 7.7, 7.9),
    ('SI-2026-2B', 'CCO-102', '2026000115', 8.7, 9.7, 7.1),
    ('SI-2026-2B', 'CCO-103', '2026000115', 7.5, 7.3, 8.2),
    ('SI-2026-2B', 'CCO-104', '2026000115', 7.5, 6.4, 8.9),
    ('SI-2026-2B', 'CCO-105', '2026000115', 6.8, 6.0, 6.6),
    ('SI-2026-2B', 'CCO-101', '2026000116', 7.4, 8.2, 10.0),
    ('SI-2026-2B', 'CCO-102', '2026000116', 7.0, 6.8, 4.5),
    ('SI-2026-2B', 'CCO-103', '2026000116', 8.7, 5.8, 6.7),
    ('SI-2026-2B', 'CCO-104', '2026000116', 10.0, 8.0, 8.5),
    ('SI-2026-2B', 'CCO-105', '2026000116', 3.6, 4.1, 5.5),
    ('SI-2026-2B', 'CCO-101', '2026000117', 10.0, 9.8, 6.9),
    ('SI-2026-2B', 'CCO-102', '2026000117', 7.9, 7.7, 8.7),
    ('SI-2026-2B', 'CCO-103', '2026000117', 8.4, 6.4, 7.3),
    ('SI-2026-2B', 'CCO-104', '2026000117', 8.5, 10.0, 9.4),
    ('SI-2026-2B', 'CCO-105', '2026000117', 3.4, 4.0, 4.5),
    ('SI-2026-2B', 'CCO-101', '2026000118', 3.5, 5.6, 2.3),
    ('SI-2026-2B', 'CCO-102', '2026000118', 6.1, 5.9, 7.5),
    ('SI-2026-2B', 'CCO-103', '2026000118', 6.0, 4.6, 4.8),
    ('SI-2026-2B', 'CCO-104', '2026000118', 7.9, 6.0, 8.1),
    ('SI-2026-2B', 'CCO-105', '2026000118', 6.6, 7.4, 6.9),
    ('SI-2026-2B', 'CCO-101', '2026000119', 7.2, 9.7, 9.5),
    ('SI-2026-2B', 'CCO-102', '2026000119', 10.0, 8.7, 10.0),
    ('SI-2026-2B', 'CCO-103', '2026000119', 7.0, 10.0, 7.9),
    ('SI-2026-2B', 'CCO-104', '2026000119', 8.2, 9.3, 9.0),
    ('SI-2026-2B', 'CCO-105', '2026000119', 5.5, 5.4, 6.5),
    ('SI-2026-2B', 'CCO-101', '2026000120', 7.9, 8.0, 7.5),
    ('SI-2026-2B', 'CCO-102', '2026000120', 8.2, 8.6, 7.3),
    ('SI-2026-2B', 'CCO-103', '2026000120', 10.0, 9.8, 7.9),
    ('SI-2026-2B', 'CCO-104', '2026000120', 10.0, 10.0, 7.3),
    ('SI-2026-2B', 'CCO-105', '2026000120', 6.0, 5.6, 5.0)
ON CONFLICT ON CONSTRAINT uk_matricula_aluno_turma_materia DO UPDATE SET
    nota1 = EXCLUDED.nota1,
    nota2 = EXCLUDED.nota2,
    nota3 = EXCLUDED.nota3;

-- Conferencia: materias=5, turmas=4, alunos=120, notas=600.
