using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using OptimaRicetteWS.Models;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace OptimaRicetteWS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ApportoCaloricoController : ControllerBase
    {
        //[Authorize]
        //[HttpPost("InserisciApportoSettimanale")]
        //public async Task<IActionResult> InserisciApportoSettimanale([FromBody] InserisciApportoRequest request)
        //{
        //    try
        //    {
        //        var settimanaFine = request.SettimanaInizio.AddDays(6); // settimana di 7 giorni (lunedì-domenica)

        //        var idUtenteParam = new SqlParameter("@idUtente", request.IdUtente);
        //        var settimanaInizioParam = new SqlParameter("@settimanaInizio", request.SettimanaInizio);
        //        var settimanaFineParam = new SqlParameter("@settimanaFine", settimanaFine);
        //        var calorieTotaliParam = new SqlParameter("@calorieTotali", request.CalorieTotali);
        //        var sessoParam = new SqlParameter("@sesso", request.Sesso);
        //        var altezzaParam = new SqlParameter("@altezza", request.Altezza);
        //        var pesoParam = new SqlParameter("@peso", request.Peso);
        //        var dataNascitaParam = new SqlParameter("@dataNascita", request.DataNascita);

        //        //await _context.Database.ExecuteSqlRawAsync(
        //        //    "EXEC InserisciApportoCaloricoSettimanale @idUtente, @settimanaInizio, @settimanaFine, @calorieTotali, @sesso, @altezza, @peso, @dataNascita",
        //        //    idUtenteParam, settimanaInizioParam, settimanaFineParam, calorieTotaliParam,
        //        //    sessoParam, altezzaParam, pesoParam, dataNascitaParam
        //        //);

        //        return Ok(new
        //        {
        //            Messaggio = "Apporto calorico inserito correttamente",
        //            SettimanaInizio = request.SettimanaInizio.ToShortDateString(),
        //            SettimanaFine = settimanaFine.ToShortDateString()
        //        });
        //    }
        //    catch (Exception ex)
        //    {
        //        return StatusCode(500, $"Errore durante l'inserimento: {ex.Message}");
        //    }
       // }

    }
}
