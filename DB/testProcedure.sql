EXEC CreaUtente
    @nomeUtente = N'marioRossi',
    @mail = N'mario.rossi@example.com',
    @password = N'Passw0rd';

---------------------------------------------------

DECLARE @newId INT;

EXEC AggiungiRicetta --con il JSON
    @idUtente = 1,  -- idUtente valido
    @descrizione = N'Pasta al pomodoro',
    @procedimento = N'{                                             
        "STEP1": "Portare a bollore abbondante acqua salata.",
        "STEP2": "Cuocere la pasta per 8-10 minuti.",
        "STEP3": "Preparare il sugo di pomodoro in una padella.",
        "STEP4": "Scolare la pasta e unirla al sugo.",
        "STEP5": "Mescolare bene e servire caldo."
    }',
    @dataCreazione = NULL,
    @newId = @newId OUTPUT;

SELECT @newId AS NuovaRicettaId;

---------------------------------------------------

EXEC AggiungiIngredienteARicetta
    @nomeUtente = N'marioRossi',
    @idIngrediente = 2,
    @qta = 3,
	@idRicetta = 2;

-------------------------------------------------

    INSERT INTO Tag_Testata (codice, descrizione) VALUES
('TIPPIAT', 'Tipo piatto'),
('DIETA', 'Tipo di dieta'),
('REGIONE', 'Regione di origine');

-- Inserimento record in Tag_Dettaglio
INSERT INTO Tag_Dettaglio (dettaglio, idTag_Testata) VALUES
('Primo', 1),
('Secondo', 1),
('Frutta', 1),
('Vegetariana', 2),
('Vegana', 2),
('Senza glutine', 2),
('Lazio', 3),
('Campania', 3),
('Sicilia', 3);

EXEC AggiungiTagARicetta
    @nomeUtente = N'marioRossi',
    @nomeTestata = N'DIETA',
    @nomeDettaglio = N'Vegetariana';

    -----------------------------------------------
    EXEC EliminaIngredienteDaRicetta
    @nomeUtente = N'marioRossi',
    @idRicetta = 5,  
    @nomeIngrediente = N'Pomodoro';
----------------------------------------
EXEC EliminaTagDaRicetta
    @nomeUtente = N'marioRossi',
    @idRicetta = 5,  
    @nomeTestata = N'Categoria',
    @nomeDettaglio = N'Vegetariana';
----------------------------------------
EXEC ModificaRicetta
    @idRicetta = 5, 
    @descrizione = N'Pasta al pomodoro e basilico',
    @procedimento = N'Cuocere la pasta, preparare il sugo con basilico fresco, mescolare tutto.';
---------------------------------------
EXEC GestioneLike
    @idUtente = 1,  
    @idRicetta = 5; 
-------------------------------------
EXEC AggiungiNotaRicetta
    @idUtente = 1,   
    @idRicetta = 5,  
    @descrizione = N'Ricetta migliorata con un pizzico di peperoncino.';

-----------
EXEC InserisciApportoCaloricoSettimanale
    @idUtente = 1,
    @settimanaInizio = '2024-01-01',
    @settimanaFine = '2024-01-07',
    @calorieTotali = 2000.50,
    @sesso = 'M',
    @altezza = 175.00,
    @peso = 70.50,
    @dataNascita = '1990-05-15';
