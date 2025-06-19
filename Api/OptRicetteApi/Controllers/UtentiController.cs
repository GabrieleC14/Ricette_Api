using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using OptRicetteApi.Data;
using OptRicetteApi.Models;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace OptRicetteApi.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class UtentiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public UtentiController(ApplicationDbContext context)
        { 
            _context = context;
        }

        //// GET: api/<Utenti>
        //[HttpGet]
        //public IEnumerable<string> Get()
        //{
        //    return new string[] { "value1", "value2" };
        //}

        //// GET api/<Utenti>/5
        //[HttpGet("{id}")]
        //public string Get(int id)
        //{
        //    return "value";
        //}

        [Authorize]
        [HttpGet("login")]
        public async Task<IActionResult> Login([FromQuery] string email, [FromQuery] string nomeUtente, [FromQuery] string password)
        {
            if (string.IsNullOrEmpty(password))
                return BadRequest("Password è richiesta");

            if (string.IsNullOrEmpty(email) && string.IsNullOrEmpty(nomeUtente))
                return BadRequest("Email o NomeUtente è richiesto");

            // Cerca l'utente che corrisponde a email o nomeUtente e password
            var user = await _context.utenti
                .FirstOrDefaultAsync(u =>
                    (u.Mail == email || u.NomeUtente == nomeUtente) &&
                    u.Password == password);

            if (user == null)
                return Unauthorized("Credenziali non valide");

            return Ok(new
            {
                Message = "Login effettuato con successo",
                UserId = user.Id,
                Username = user.NomeUtente,
                Email = user.Mail
            });
        }


        [Authorize]
        [HttpPost("crea")]
        public async Task<IActionResult> CreaUtente([FromBody] Utenti request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Esempio di chiamata a stored procedure con parametri
            var nomeUtenteParam = new SqlParameter("@nomeUtente", request.NomeUtente);
            var mailParam = new SqlParameter("@mail", request.Mail);
            var passwordParam = new SqlParameter("@password", request.Password);

            try
            {
                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC CreaUtente @nomeUtente, @mail, @password",
                    nomeUtenteParam, mailParam, passwordParam);

                return Ok("Utente creato con successo");
            }
            catch (Exception ex)
            {
                // Gestione errore, puoi loggare ex.Message
                return StatusCode(500, "Errore" + ex.Message);
            }
        }



        //// PUT api/<Utenti>/5
        //[HttpPut("{id}")]
        //public void Put(int id, [FromBody] string value)
        //{
        //}

        //// DELETE api/<Utenti>/5
        //[HttpDelete("{id}")]
        //public void Delete(int id)
        //{
        //}
    }
}