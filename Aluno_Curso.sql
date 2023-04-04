CREATE DATABASE Testes
GO
USE Testes
Go

-- Tabelas
CREATE TABLE Aluno (
    RA CHAR(13) NOT NULL,
    Nome VARCHAR(50) NOT NULL,
    CPF CHAR(11) NOT NULL,
    Status CHAR NOT NULL,

    CONSTRAINT PK_Aluno PRIMARY KEY (RA)
)
GO

CREATE TABLE Disciplina (
    Codigo UNIQUEIDENTIFIER,
    Nome VARCHAR(30) NOT NULL,
    Carga_Horaria FLOAT NULL,

    CONSTRAINT PK_Disciplina PRIMARY KEY (Codigo)
)
GO

CREATE TABLE Matricula (
    Id UNIQUEIDENTIFIER,
    RA_Aluno CHAR(13) NOT NULL,
    Ano INT NOT NULL,
    Semestre INT NOT NULL,
    Status CHAR NOT NULL,

    CONSTRAINT PK_Matricula PRIMARY KEY (Id),
    CONSTRAINT FK_Matricula_Aluno FOREIGN KEY (RA_Aluno) REFERENCES Aluno (RA),
    CONSTRAINT UN_Matricula UNIQUE (Id, Ra_Aluno, Ano)
)
GO

CREATE TABLE Item_Matricula (
    Id_Matricula UNIQUEIDENTIFIER,
    Codigo_Disciplina UNIQUEIDENTIFIER,
    Nota1 FLOAT NULL,
    Nota2 FLOAT NULL,
    Substitutiva FLOAT NULL,
    Faltas INT NOT NULL DEFAULT (0),
    
    CONSTRAINT PK_Item_Matricula PRIMARY KEY (Id_Matricula, Codigo_Disciplina),
    CONSTRAINT FK_Item_Matricula_Matricula FOREIGN KEY (Id_Matricula) REFERENCES Matricula (Id),
    CONSTRAINT FK_Item_Matricula_Disciplina FOREIGN KEY (Codigo_Disciplina) REFERENCES Disciplina (Codigo)
)
GO

-- Procedures
CREATE OR ALTER PROC InserirNota @Id UNIQUEIDENTIFIER, @Disc UNIQUEIDENTIFIER, @Nota1 FLOAT, @Nota2 FLOAT, @Sub FLOAT AS 
    BEGIN
        INSERT INTO Item_Matricula (Id_Matricula, Codigo_Disciplina, Nota1, Nota2, Substitutiva) VALUES (@Id, @Disc, @Nota1, @Nota2, @Sub)
    END
GO

CREATE OR ALTER PROC VerificarNota @Id UNIQUEIDENTIFIER, @Disc UNIQUEIDENTIFIER AS 
    BEGIN
    DECLARE @Update FLOAT

    SELECT @Update = CASE 
            WHEN Substitutiva IS NULL OR Substitutiva = 0 THEN (Nota1 + Nota2)/2
            WHEN (Substitutiva > Nota1) AND (Nota1 < Nota2) THEN (Substitutiva + Nota2)/2
            ELSE (Nota1 + Substitutiva)/2
        END
        FROM Item_Matricula WHERE Id_Matricula = @Id AND Codigo_Disciplina = @Disc

        SELECT Codigo_Disciplina, Nota1, Nota2, Substitutiva, Faltas, @Update AS 'Media',
        CASE 
            WHEN @Update > 5 AND Faltas < 5 THEN 'Passou'
            ELSE 'DP'
        END AS 'Status' FROM Item_Matricula
    END
GO

CREATE OR ALTER PROC AlterarNota @Id UNIQUEIDENTIFIER, @Disc UNIQUEIDENTIFIER, @Nota1 FLOAT, @Nota2 FLOAT, @Sub Float AS 
    BEGIN
        UPDATE Item_Matricula SET Nota1 = @Nota1, Nota2 = @Nota2, Substitutiva = @Sub WHERE Id_Matricula = @Id AND Codigo_Disciplina = @Disc
    END
GO

-- Insercoes
/*
INSERT INTO [Aluno] ([RA], [NOME], [CPF], [Status]) VALUES ('0120120113000', 'Jubileu', '12312312300', 'C')
INSERT INTO [Disciplina] ([Codigo], [Nome], [Carga_Horaria]) VALUES (NEWID(), 'Natação', 20.7)
INSERT INTO [Matricula] ([Id], [RA_Aluno], [Ano], [Semestre], [Status]) VALUES (NEWID(), '0120120113000', 2020, 1, 'C')
*/

/*
SELECT * FROM Aluno
SELECT * FROM Matricula
SELECT * FROM Disciplina
SELECT * FROM Item_Matricula
*/

-- EXEC.InserirNota 'f2ec3f03-3bdc-4218-8aee-b3621d6ac159', '7871107c-67b6-453b-b875-c3d1f3d266d9', 10, 10, 0

-- EXEC.AlterarNota 'f2ec3f03-3bdc-4218-8aee-b3621d6ac159', '7871107c-67b6-453b-b875-c3d1f3d266d9', 8, 8, NULL

-- EXEC.VerificarNota 'f2ec3f03-3bdc-4218-8aee-b3621d6ac159', '7871107c-67b6-453b-b875-c3d1f3d266d9'