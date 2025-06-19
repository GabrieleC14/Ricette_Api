namespace OptRicetteApi.Models
{
    public class Tag
    {
    }

    public class TagRequest
    {
        public string NomeTestata { get; set; }
        public string NomeDettaglio { get; set; }
    }


    public class TagTestata
    {
        public int Id { get; set; }          // corrisponde a "id"
        public string Codice { get; set; }   // corrisponde a "codice"
        public string Descrizione { get; set; }  // corrisponde a "descrizione"

        // Navigazione: un TagTestata ha molti TagDettaglio
        public ICollection<TagDettaglio> TagDettagli { get; set; } = new List<TagDettaglio>();
    }

    public class TagDettaglio
    {
        public int Id { get; set; }            // corrisponde a "id"
        public string Dettaglio { get; set; }  // corrisponde a "dettaglio"

        public int IdTagTestata { get; set; }  // corrisponde a "idTag_Testata" (foreign key)

        // Navigazione: ogni TagDettaglio ha un TagTestata
        public TagTestata TagTestata { get; set; }
    }

}
