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
    Codigo INT IDENTITY,
    Nome VARCHAR(30) NOT NULL,
    Carga_Horaria FLOAT NULL,

    CONSTRAINT PK_Disciplina PRIMARY KEY (Codigo)
)
GO

CREATE TABLE Matricula (
    Id INT IDENTITY,
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
    Id_Matricula INT,
    Codigo_Disciplina INT,
    Nota1 FLOAT NULL,
    Nota2 FLOAT NULL,
    Substitutiva FLOAT NULL,
    Media FLOAT NULL,
    Faltas INT NOT NULL DEFAULT (0),
    
    CONSTRAINT PK_Item_Matricula PRIMARY KEY (Id_Matricula, Codigo_Disciplina),
    CONSTRAINT FK_Item_Matricula_Matricula FOREIGN KEY (Id_Matricula) REFERENCES Matricula (Id),
    CONSTRAINT FK_Item_Matricula_Disciplina FOREIGN KEY (Codigo_Disciplina) REFERENCES Disciplina (Codigo)
)
GO
-- Trigger
CREATE OR ALTER TRIGGER TGR_Media_Insert ON Item_Matricula AFTER INSERT AS
    BEGIN
        DECLARE @Update FLOAT, @Id INT, @Disc INT

        SELECT @Id = Id_Matricula, @Disc = Codigo_Disciplina, @Update = CASE 
            WHEN Substitutiva IS NULL OR Substitutiva = 0 THEN (Nota1 + Nota2)/2
            WHEN (Substitutiva > Nota1) AND (Nota1 < Nota2) THEN (Substitutiva + Nota2)/2
            WHEN (Substitutiva > Nota2) AND (Nota2 < Nota1) THEN (Substitutiva + Nota1)/2
            ELSE (Nota1 + Nota2)/2
        END
        FROM INSERTED

        UPDATE Item_Matricula SET Media = @Update WHERE Id_Matricula = @Id AND Codigo_Disciplina = @Disc
    END
GO

CREATE OR ALTER TRIGGER TGR_Media_Update ON Item_Matricula FOR UPDATE AS
    BEGIN
        DECLARE @Update FLOAT, @Id INT, @Disc INT

        SELECT @Id = Id_Matricula, @Disc = Codigo_Disciplina, @Update = CASE 
            WHEN Substitutiva IS NULL OR Substitutiva = 0 THEN (Nota1 + Nota2)/2
            WHEN (Substitutiva > Nota1) AND (Nota1 < Nota2) THEN (Substitutiva + Nota2)/2
            WHEN (Substitutiva > Nota2) AND (Nota2 < Nota1) THEN (Substitutiva + Nota1)/2
            ELSE (Nota1 + Nota2)/2
        END
        FROM INSERTED

        UPDATE Item_Matricula SET Media = @Update WHERE Id_Matricula = @Id AND Codigo_Disciplina = @Disc
    END
GO

-- Procedures
CREATE OR ALTER PROC InserirNota @Id INT, @Disc INT, @Nota1 FLOAT, @Nota2 FLOAT, @Sub FLOAT AS 
    BEGIN
        INSERT INTO Item_Matricula (Id_Matricula, Codigo_Disciplina, Nota1, Nota2, Substitutiva) VALUES (@Id, @Disc, @Nota1, @Nota2, @Sub)
    END
GO

CREATE OR ALTER PROC VerificarNota AS 
    BEGIN
        SELECT Id_Matricula, Disciplina.Nome AS 'Nome Disciplina', Nota1, Nota2, Substitutiva, Faltas, Disciplina.Carga_Horaria, Media,
        CASE 
            WHEN Media >= 5 AND Faltas < (Disciplina.Carga_Horaria/2) THEN 'Passou'
            ELSE 'DP'
        END AS 'Status' FROM Item_Matricula JOIN Disciplina ON Item_Matricula.Codigo_Disciplina = Disciplina.Codigo
    END
GO

CREATE OR ALTER PROC AlterarNota @Id INT, @Disc INT, @Nota1 FLOAT, @Nota2 FLOAT, @Sub Float AS 
    BEGIN
        UPDATE Item_Matricula SET Nota1 = @Nota1, Nota2 = @Nota2, Substitutiva = @Sub WHERE Id_Matricula = @Id AND Codigo_Disciplina = @Disc
    END
GO

-- Insercoes
/*
INSERT INTO [Aluno] ([RA], [NOME], [CPF], [Status]) VALUES ('0120120113000', 'Jubileu', '12312312300', 'C')
INSERT INTO [Disciplina] ([Nome], [Carga_Horaria]) VALUES ('Natação', 100)
INSERT INTO [Matricula] ([RA_Aluno], [Ano], [Semestre], [Status]) VALUES ('0120120113000', 2020, 1, 'C')
*/

/*
SELECT * FROM Aluno
SELECT * FROM Matricula
SELECT * FROM Disciplina
SELECT * FROM Item_Matricula
*/

/*
DELETE Item_Matricula
DELETE Matricula
DELETE Aluno
DELETE Disciplina
*/

-- EXEC.InserirNota 2, 2, 10, 10, 0

-- EXEC.AlterarNota 2, 2, 2, 8, 8

--  UPDATE Item_Matricula SET Faltas = 120 WHERE Id_Matricula = 2 AND Codigo_Disciplina = 2

EXEC.VerificarNota
