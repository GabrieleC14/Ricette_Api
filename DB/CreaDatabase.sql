-- Utenti
CREATE TABLE utenti (
    id INT PRIMARY KEY IDENTITY,
    nomeUtente NVARCHAR(100) NOT NULL,
    mail NVARCHAR(255) UNIQUE NOT NULL,
    password NVARCHAR(255) NOT NULL
);

-- Ricette
CREATE TABLE ricette (
    id INT PRIMARY KEY IDENTITY,
    idUtente INT NOT NULL,
    descrizione NVARCHAR(MAX),
    procedimento NVARCHAR(MAX),
    dataCreazione DATETIME NOT NULL,
    dataModifica DATETIME,
    FOREIGN KEY (idUtente) REFERENCES utenti(id)
);

-- Immagini
CREATE TABLE immagini (
    id INT PRIMARY KEY IDENTITY,
    idRicetta INT NOT NULL,
    img IMAGE,
    FOREIGN KEY (idRicetta) REFERENCES ricette(id)
);

-- Anagrafica Unità di Misura
CREATE TABLE Anagrafica_UnitaDiMisura (
    id INT PRIMARY KEY IDENTITY,
    descrizione NVARCHAR(50) NOT NULL
);

-- Anagrafica Ingredienti
CREATE TABLE Anagrafica_Ingredienti (
    id INT PRIMARY KEY IDENTITY,
    descrizione NVARCHAR(100) NOT NULL,
    idUnitaDiMisura INT NOT NULL,
    FOREIGN KEY (idUnitaDiMisura) REFERENCES Anagrafica_UnitaDiMisura(id)
);

-- Ricette Ingredienti
CREATE TABLE ricette_ingredienti (
    idRicetta INT NOT NULL,
    idIngrediente INT NOT NULL,
    qta FLOAT NOT NULL,
    PRIMARY KEY (idRicetta, idIngrediente),
    FOREIGN KEY (idRicetta) REFERENCES ricette(id),
    FOREIGN KEY (idIngrediente) REFERENCES Anagrafica_Ingredienti(id)
);

-- Tag Testata
CREATE TABLE Tag_Testata (
    id INT PRIMARY KEY IDENTITY,
    codice NVARCHAR(50) NOT NULL,
    descrizione NVARCHAR(100) NOT NULL
);

-- Tag Dettaglio
CREATE TABLE Tag_Dettaglio (
    id INT PRIMARY KEY IDENTITY,
    dettaglio NVARCHAR(100) NOT NULL,
    idTag_Testata INT NOT NULL,
    FOREIGN KEY (idTag_Testata) REFERENCES Tag_Testata(id)
);

-- Ricette Tag
CREATE TABLE ricette_Tag (
    idRicetta INT NOT NULL,
    idTag_Dettaglio INT NOT NULL,
    PRIMARY KEY (idRicetta, idTag_Dettaglio),
    FOREIGN KEY (idRicetta) REFERENCES ricette(id),
    FOREIGN KEY (idTag_Dettaglio) REFERENCES Tag_Dettaglio(id)
);

-- Valutazioni
CREATE TABLE valutazioni (
    id INT PRIMARY KEY,
    descrizione NVARCHAR(50)
);

-- Commenti
CREATE TABLE commenti (
    id INT PRIMARY KEY IDENTITY,
    idUtente INT NOT NULL,
    idRicetta INT NOT NULL,
    descrizione NVARCHAR(MAX),
    data DATETIME NOT NULL,
    idValutazione INT,
    FOREIGN KEY (idUtente) REFERENCES utenti(id),
    FOREIGN KEY (idRicetta) REFERENCES ricette(id),
    FOREIGN KEY (idValutazione) REFERENCES valutazioni(id)
);

-- Likes
CREATE TABLE Likes (
    id INT PRIMARY KEY IDENTITY,
    idUtente INT NOT NULL,
    idRicetta INT NOT NULL,
    FOREIGN KEY (idUtente) REFERENCES utenti(id),
    FOREIGN KEY (idRicetta) REFERENCES ricette(id)
);

-- Valori Nutrizionali
CREATE TABLE ValoriNutrizionali (
    id INT PRIMARY KEY IDENTITY,
    idRicetta INT NOT NULL,
    valore FLOAT NOT NULL,
    FOREIGN KEY (idRicetta) REFERENCES ricette(id)
);

-- Note Ricetta
CREATE TABLE noteRicetta (
    id INT PRIMARY KEY IDENTITY,
    idRicetta INT NOT NULL,
    idUtente INT NOT NULL,
    descrizione NVARCHAR(MAX),
    FOREIGN KEY (idRicetta) REFERENCES ricette(id),
    FOREIGN KEY (idUtente) REFERENCES utenti(id)
);
--per l'apporto calorico
CREATE TABLE ApportoCaloricoSettimanale (
    id INT PRIMARY KEY IDENTITY,
    idUtente INT NOT NULL,
    settimanaInizio DATE NOT NULL,
    settimanaFine DATE NOT NULL,
    calorieTotali FLOAT NOT NULL,
    sesso NVARCHAR(10) NOT NULL,
	altezza DECIMAL(5, 2),
	peso DECIMAL(5, 2),
	dataNascita DATE,
    FOREIGN KEY (idUtente) REFERENCES utenti(id),
    UNIQUE (idUtente, settimanaInizio, settimanaFine)
);

INSERT INTO Anagrafica_UnitaDiMisura (descrizione) VALUES
('grammi'),
('chilogrammi'),
('millilitri'),
('litri'),
('cucchiai')

INSERT INTO valutazioni (id, descrizione) VALUES
(1, 'Pessimo'),
(2, 'Scarso'),
(3, 'Discreto'),
(4, 'Buono'),
(5, 'Eccellente');

--Function per il login dell'utente --non serve è solo una select 

-- CREATE FUNCTION dbo.LoginUtente (
--     @mail NVARCHAR(255),
--     @password NVARCHAR(255)
-- )
-- RETURNS TABLE
-- AS
-- RETURN
-- (
--     SELECT id, nomeUtente, mail
--     FROM utenti
--     WHERE mail = @mail AND password = @password
-- );

--////////////////_________________Procedure per creare un utente

CREATE PROCEDURE CreaUtente
    @nomeUtente NVARCHAR(100),
    @mail NVARCHAR(255),
    @password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Verifica lunghezza minima 8 caratteri
    IF LEN(@password) < 8
    BEGIN
        RAISERROR('La password deve contenere almeno 8 caratteri.', 16, 1);
        RETURN -3;
    END

    -- Verifica presenza almeno un numero
    IF @password NOT LIKE '%[0-9]%'
    BEGIN
        RAISERROR('La password deve contenere almeno un numero.', 16, 1);
        RETURN -4;
    END

    -- Verifica presenza almeno una lettera maiuscola
    IF @password NOT LIKE '%[A-Z]%'
    BEGIN
        RAISERROR('La password deve contenere almeno una lettera maiuscola.', 16, 1);
        RETURN -5;
    END

    -- Verifica presenza almeno una lettera minuscola
    IF @password NOT LIKE '%[a-z]%'
    BEGIN
        RAISERROR('La password deve contenere almeno una lettera minuscola.', 16, 1);
        RETURN -6;
    END

    -- Controllo se mail o nomeUtente già esistono
    IF EXISTS (SELECT 1 FROM utenti WHERE mail = @mail)
    BEGIN
        RAISERROR('Email già registrata.', 16, 1);
        RETURN -1;
    END

    IF EXISTS (SELECT 1 FROM utenti WHERE nomeUtente = @nomeUtente)
    BEGIN
        RAISERROR('Nome utente già usato.', 16, 1);
        RETURN -2;
    END

    -- Inserimento utente
    INSERT INTO utenti (nomeUtente, mail, password)
    VALUES (@nomeUtente, @mail, @password);

    RETURN 0; -- successo
END;

--////////////////_________________Procedure per cercare una ricetta
CREATE PROCEDURE AggiungiRicetta
    @idUtente INT,
    @descrizione NVARCHAR(MAX),
    @procedimento NVARCHAR(MAX),
    @dataCreazione DATETIME = NULL,
    @newId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @dataCreazione IS NULL
        SET @dataCreazione = GETDATE();

    INSERT INTO ricette (idUtente, descrizione, procedimento, dataCreazione) --dataModifica sarà NULL, verrà poi popolato se modificato
    VALUES (@idUtente, @descrizione, @procedimento, @dataCreazione);

    SET @newId = SCOPE_IDENTITY();
END;

--///////////////_________________Aggiungi ingredienti ad una ricetta (verrà eseguita in loop per ogni ingrediente)

CREATE PROCEDURE AggiungiIngredienteARicetta
    @nomeUtente NVARCHAR(100),
  --  @nomeIngrediente NVARCHAR(100),
    @qta FLOAT,
    @idIngrediente INT,
	@idRicetta INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idUtente INT;-- @idIngrediente INT;

    -- Recupera l'ID dell'utente
    SELECT @idUtente = id
    FROM utenti
    WHERE nomeUtente = @nomeUtente;

    IF @idUtente IS NULL
    BEGIN
        RAISERROR('Utente non trovato: %s', 16, 1, @nomeUtente);
        RETURN;
    END

    -- Recupera l’ID dell’ultima ricetta dell’utente
    --SELECT TOP 1 @idRicetta = id
    --FROM ricette
    --WHERE idUtente = @idUtente
    --ORDER BY dataCreazione DESC;

    IF @idRicetta IS NULL
    BEGIN
        RAISERROR('Nessuna ricetta trovata per utente: %s', 16, 1, @nomeUtente);
        RETURN;
    END

    -- Recupera l'ID dell'ingrediente
    -- SELECT @idIngrediente = id
    -- FROM Anagrafica_Ingredienti
    -- WHERE descrizione = @nomeIngrediente;

    --IF @idIngrediente IS NULL
    --BEGIN
    --    RAISERROR('Ingrediente non trovato: %s', 16, 1, @nomeIngrediente);
    --    RETURN;
    --END

    -- Verifica se l'ingrediente è già presente nella ricetta
    IF EXISTS (
        SELECT 1 FROM ricette_ingredienti
        WHERE idRicetta = @idRicetta AND idIngrediente = @idIngrediente
    )
    BEGIN
        RAISERROR('Ingrediente già presente nella ricetta.', 16, 1);
        RETURN;
    END

    -- Inserisce l’ingrediente nella ricetta
    INSERT INTO ricette_ingredienti (idRicetta, idIngrediente, qta)
    VALUES (@idRicetta, @idIngrediente, @qta);
END;

--///////////////_________________procedure per la creazione dei tag  (verrà eseguita in loop per ogni tag)

CREATE PROCEDURE AggiungiTagARicetta
    @nomeUtente NVARCHAR(100),
    @nomeTestata NVARCHAR(100),
    @nomeDettaglio NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idTestata INT, @idTagDettaglio INT, @idRicetta INT, @idUtente INT;

    -- Recupera ID utente dal nome
    SELECT @idUtente = id
    FROM utenti
    WHERE nomeUtente = @nomeUtente;

    IF @idUtente IS NULL
    BEGIN
        RAISERROR('Utente non trovato: %s', 16, 1, @nomeUtente);
        RETURN;
    END

    -- Recupera l'ID della testata tag
    SELECT @idTestata = id
    FROM Tag_Testata
    WHERE codice = @nomeTestata OR descrizione = @nomeTestata;

    IF @idTestata IS NULL
    BEGIN
        RAISERROR('Tag testata non trovata: %s', 16, 1, @nomeTestata);
        RETURN;
    END

    -- Recupera l'ID del dettaglio tag
    SELECT @idTagDettaglio = id
    FROM Tag_Dettaglio
    WHERE dettaglio = @nomeDettaglio AND idTag_Testata = @idTestata;

    IF @idTagDettaglio IS NULL
    BEGIN
        RAISERROR('Tag dettaglio non trovato: %s - %s', 16, 1, @nomeTestata, @nomeDettaglio);
        RETURN;
    END

    -- Recupera la ricetta più recente dell’utente
    SELECT TOP 1 @idRicetta = id
    FROM Ricette
    WHERE idUtente = @idUtente
    ORDER BY dataCreazione DESC;

    IF @idRicetta IS NULL
    BEGIN
        RAISERROR('Nessuna ricetta trovata per utente: %s', 16, 1, @nomeUtente);
        RETURN;
    END

    -- Inserisce il tag nella ricetta
    INSERT INTO ricette_Tag (idRicetta, idTag_Dettaglio)
    VALUES (@idRicetta, @idTagDettaglio);
END;

--//////////////__________________elimina ingrediente

CREATE PROCEDURE EliminaIngredienteDaRicetta
    @nomeUtente NVARCHAR(100),
    @idRicetta INT,
    @nomeIngrediente NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idUtente INT,
            @idIngrediente INT;

    -- Recupera ID utente
    SELECT @idUtente = id FROM utenti WHERE nomeUtente = @nomeUtente;
    IF @idUtente IS NULL
    BEGIN
        RAISERROR('Utente non trovato: %s', 16, 1, @nomeUtente);
        RETURN;
    END

    -- Verifica proprietà ricetta
    IF NOT EXISTS (SELECT 1 FROM ricette WHERE id = @idRicetta AND idUtente = @idUtente)
    BEGIN
        RAISERROR('Ricetta non trovata o non di proprietà dell''utente.', 16, 1);
        RETURN;
    END

    -- Recupera ID ingrediente
    SELECT @idIngrediente = id FROM Anagrafica_Ingredienti WHERE descrizione = @nomeIngrediente;
    IF @idIngrediente IS NULL
    BEGIN
        RAISERROR('Ingrediente non trovato: %s', 16, 1, @nomeIngrediente);
        RETURN;
    END

    -- Verifica che l'ingrediente sia associato alla ricetta
    IF NOT EXISTS (SELECT 1 FROM ricette_ingredienti WHERE idRicetta = @idRicetta AND idIngrediente = @idIngrediente)
    BEGIN
        RAISERROR('Ingrediente non associato alla ricetta.', 16, 1);
        RETURN;
    END

    -- Elimina associazione ingrediente-ricetta
    DELETE FROM ricette_ingredienti WHERE idRicetta = @idRicetta AND idIngrediente = @idIngrediente;
END;


--//////////////__________________elimina tag

CREATE PROCEDURE EliminaTagDaRicetta
    @nomeUtente NVARCHAR(100),
    @idRicetta INT,
    @nomeTestata NVARCHAR(100),
    @nomeDettaglio NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @idUtente INT,
            @idTestata INT,
            @idTagDettaglio INT;

    -- Recupera ID utente
    SELECT @idUtente = id FROM utenti WHERE nomeUtente = @nomeUtente;
    IF @idUtente IS NULL
    BEGIN
        RAISERROR('Utente non trovato: %s', 16, 1, @nomeUtente);
        RETURN;
    END

    -- Verifica proprietà ricetta
    IF NOT EXISTS (SELECT 1 FROM ricette WHERE id = @idRicetta AND idUtente = @idUtente)
    BEGIN
        RAISERROR('Ricetta non trovata o non di proprietà dell''utente.', 16, 1);
        RETURN;
    END

    -- Recupera ID tag testata
    SELECT @idTestata = id FROM Tag_Testata WHERE codice = @nomeTestata OR descrizione = @nomeTestata;
    IF @idTestata IS NULL
    BEGIN
        RAISERROR('Tag testata non trovato: %s', 16, 1, @nomeTestata);
        RETURN;
    END

    -- Recupera ID tag dettaglio
    SELECT @idTagDettaglio = id FROM Tag_Dettaglio WHERE dettaglio = @nomeDettaglio AND idTag_Testata = @idTestata;
    IF @idTagDettaglio IS NULL
    BEGIN
        RAISERROR('Tag dettaglio non trovato: %s - %s', 16, 1, @nomeTestata, @nomeDettaglio);
        RETURN;
    END

    -- Verifica che il tag sia associato alla ricetta
    IF NOT EXISTS (SELECT 1 FROM ricette_Tag WHERE idRicetta = @idRicetta AND idTag_Dettaglio = @idTagDettaglio)
    BEGIN
        RAISERROR('Tag non associato alla ricetta.', 16, 1);
        RETURN;
    END

    -- Elimina associazione tag-ricetta
    DELETE FROM ricette_Tag WHERE idRicetta = @idRicetta AND idTag_Dettaglio = @idTagDettaglio;
END;


--//////////////__________________procedure per la modifica di una ricetta

CREATE PROCEDURE ModificaRicetta
    @idRicetta INT,
    @descrizione NVARCHAR(MAX),
    @procedimento NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ricette
    SET 
        descrizione = @descrizione,
        procedimento = @procedimento,
        dataModifica = GETDATE()
    WHERE id = @idRicetta;
    
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('Ricetta non trovata o nessuna modifica effettuata.', 16, 1);
    END
END;

--PROCEDURE PER TOGLIERE / ELIMINARE UN LIKE 

CREATE PROCEDURE GestioneLike
    @idUtente INT,
    @idRicetta INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM Likes WHERE idUtente = @idUtente AND idRicetta = @idRicetta
    )
    BEGIN
        -- Like presente: lo rimuove
        DELETE FROM Likes
        WHERE idUtente = @idUtente AND idRicetta = @idRicetta;

        PRINT 'Like rimosso.';
    END
    ELSE
    BEGIN
        -- Like assente: lo aggiunge
        INSERT INTO Likes (idUtente, idRicetta)
        VALUES (@idUtente, @idRicetta);

        PRINT 'Like aggiunto.';
    END
END;

--//////////////////////:________________ procedure per inserire una nota personale ad una ricetta

CREATE PROCEDURE AggiungiNotaRicetta
    @idUtente INT,
    @idRicetta INT,
    @descrizione NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    -- Verifica che la ricetta appartenga all'utente
    IF NOT EXISTS (
        SELECT 1 FROM ricette
        WHERE id = @idRicetta AND idUtente = @idUtente
    )
    BEGIN
        RAISERROR('Ricetta non trovata o non di proprietà dell''utente.', 16, 1);
        RETURN;
    END

    -- Inserisce la nota
    INSERT INTO noteRicetta (idRicetta, idUtente, descrizione)
    VALUES (@idRicetta, @idUtente, @descrizione);
END;

 --------------------------------------------------- procedure per aggiungere un commento alla ricetta

 CREATE PROCEDURE AggiungiCommentoRicetta
    @idUtente INT,
    @idRicetta INT,
    @descrizione NVARCHAR(MAX),
    @idValutazione INT 
AS
BEGIN
    SET NOCOUNT ON;

    -- Verifica che l'utente esista
    IF NOT EXISTS (SELECT 1 FROM utenti WHERE id = @idUtente)
    BEGIN
        RAISERROR('Utente non trovato.', 16, 1);
        RETURN;
    END

    -- Verifica che la ricetta esista
    IF NOT EXISTS (SELECT 1 FROM ricette WHERE id = @idRicetta)
    BEGIN
        RAISERROR('Ricetta non trovata.', 16, 1);
        RETURN;
    END

    -- Se viene fornito un idValutazione, verifica che sia valido
    IF @idValutazione IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM valutazioni WHERE id = @idValutazione)
    BEGIN
        RAISERROR('Valutazione non valida.', 16, 1);
        RETURN;
    END

    -- Inserisce il commento
    INSERT INTO commenti (idUtente, idRicetta, descrizione, data, idValutazione)
    VALUES (@idUtente, @idRicetta, @descrizione, GETDATE(), @idValutazione);
END;
-----------------------------//////////////////



CREATE PROCEDURE InserisciApportoCaloricoSettimanale (
    @idUtente INT,
    @settimanaInizio DATE,
    @settimanaFine DATE,
    @calorieTotali FLOAT,
    @sesso NVARCHAR(10),
    @altezza DECIMAL(5, 2),
    @peso DECIMAL(5, 2),
    @dataNascita DATE
)
AS
BEGIN
    -- Inserisci i dati nella tabella ApportoCaloricoSettimanale
    INSERT INTO ApportoCaloricoSettimanale (
        idUtente,
        settimanaInizio,
        settimanaFine,
        calorieTotali,
        sesso,
        altezza,
        peso,
        dataNascita
    )
    VALUES (
        @idUtente,
        @settimanaInizio,
        @settimanaFine,
        @calorieTotali,
        @sesso,
        @altezza,
        @peso,
        @dataNascita
    );
END;
GO