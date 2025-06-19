namespace OptimaRicetteWS.Models
{
    public class Ricette
    {
            public int Id { get; set; } // PRIMARY KEY IDENTITY
            public int IdUtente { get; set; } // INT NOT NULL
            public string Descrizione { get; set; } // NVARCHAR(MAX)
            public string Procedimento { get; set; } // NVARCHAR(MAX)
            public DateTime DataCreazione { get; set; } // DATETIME NOT NULL
            public DateTime? DataModifica { get; set; } // DATETIME NULL (nullable)

        public ICollection<RicettaTag> RicettaTag { get; set; } = new List<RicettaTag>();

    }

    public class RicettaTag
    {
        public int IdRicetta { get; set; }
        public Ricette Ricetta { get; set; }  // Navigazione alla Ricetta

        public int IdTagDettaglio { get; set; }
        public TagDettaglio TagDettaglio { get; set; } // Navigazione al TagDettaglio
    }


    public class CreaRicettaRequest
    {
        public int IdUtente { get; set; }
        public string NomeUtente { get; set; }
        public string Descrizione { get; set; }
        public Dictionary<string, string> Procedimento { get; set; }
        public List<IngredienteQuantita> Ingredienti { get; set; }

        // Cambia qui: usa TagRequest invece di TagDettaglio
        public List<TagRequest> Tags { get; set; }
    }

    public class IngredienteQuantita
    {
        public int IdIngrediente { get; set; }
        public double Qta { get; set; }
    }

}

