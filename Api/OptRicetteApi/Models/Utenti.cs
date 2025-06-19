using System.ComponentModel.DataAnnotations;

namespace OptRicetteApi.Models
{
    public class Utenti
    {
        public int Id { get; set; } // PRIMARY KEY IDENTITY

        [Required]
        [MaxLength(100)]
        public string NomeUtente { get; set; } // NVARCHAR(100) NOT NULL

        public string Password { get; set; }

        [Required]
        [MaxLength(255)]
        [EmailAddress]
        public string Mail { get; set; } // NVARCHAR(255) UNIQUE NOT NULL

    }
}
