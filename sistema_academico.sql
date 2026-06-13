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
    ementa TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS tb_turma (
    codigo VARCHAR(30) PRIMARY KEY,
    materia_codigo VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS tb_turma_aluno_nota (
    id SERIAL PRIMARY KEY,
    turma_codigo VARCHAR(30) NOT NULL,
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
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_turma_materia'
    ) THEN
        ALTER TABLE tb_turma
            ADD CONSTRAINT fk_turma_materia
            FOREIGN KEY (materia_codigo)
            REFERENCES tb_materia(codigo)
            ON UPDATE CASCADE
            ON DELETE RESTRICT;
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
END $$;

INSERT INTO tb_admin (username, password)
VALUES ('admin', '$2a$10$Q7qGeub.epkRB0BGhgYQ..wWqkQX3z9rIaKVnfAdIdxqNSyS2GIWC')
ON CONFLICT (username) DO UPDATE
SET password = EXCLUDED.password;

