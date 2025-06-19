using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using OptimaRicetteWS.Data;
using OptimaRicetteWS.Models;
using System.Text.Json;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace OptimaRicetteWS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RicetteController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public RicetteController(ApplicationDbContext context)
        {
            _context = context;
        }


        [Authorize]
        [HttpPost("crea")]
        public async Task<IActionResult> CreaRicetta([FromBody] CreaRicettaRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var procedimentoJson = JsonSerializer.Serialize(request.Procedimento);

                var idUtenteParam = new SqlParameter("@idUtente", request.IdUtente);
                var descrizioneParam = new SqlParameter("@descrizione", request.Descrizione);
                var procedimentoParam = new SqlParameter("@procedimento", procedimentoJson);
                var dataCreazioneParam = new SqlParameter("@dataCreazione", DBNull.Value);

                var newIdParam = new SqlParameter
                {
                    ParameterName = "@newId",
                    SqlDbType = System.Data.SqlDbType.Int,
                    Direction = System.Data.ParameterDirection.Output
                };

                await _context.Database.ExecuteSqlRawAsync(
                    "EXEC AggiungiRicetta @idUtente, @descrizione, @procedimento, @dataCreazione, @newId OUTPUT",
                    idUtenteParam, descrizioneParam, procedimentoParam, dataCreazioneParam, newIdParam
                );

                var nuovaRicettaId = (int)newIdParam.Value;

                var nomeUtente = User.Identity?.Name;
                if (string.IsNullOrEmpty(nomeUtente))
                    return Unauthorized("Utente non autenticato.");

                // Aggiungi Ingredienti
                foreach (var ingrediente in request.Ingredienti)
                {
                    var nomeUtenteParam = new SqlParameter("@nomeUtente", request.NomeUtente);
                    var idIngredienteParam = new SqlParameter("@idIngrediente", ingrediente.IdIngrediente);
                    var qtaParam = new SqlParameter("@qta", ingrediente.Qta);
                    var idRicettaParam = new SqlParameter("@idRicetta", nuovaRicettaId);

                    await _context.Database.ExecuteSqlRawAsync(
                        "EXEC AggiungiIngredienteARicetta @nomeUtente, @idIngrediente, @qta, @idRicetta",
                        nomeUtenteParam, idIngredienteParam, qtaParam, idRicettaParam);
                }

                foreach (var tag in request.Tags)
                {
                    var nomeUtenteParam = new SqlParameter("@nomeUtente", request.NomeUtente);
                    var nomeTestataParam = new SqlParameter("@nomeTestata", tag.NomeTestata);
                    var nomeDettaglioParam = new SqlParameter("@nomeDettaglio", tag.NomeDettaglio);

                    await _context.Database.ExecuteSqlRawAsync(
                        "EXEC AggiungiTagARicetta @nomeUtente, @nomeTestata, @nomeDettaglio",
                        nomeUtenteParam, nomeTestataParam, nomeDettaglioParam);
                }

                return Ok(new
                {
                    Messaggio = "Ricetta creata con successo",
                    RicettaId = nuovaRicettaId
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Errore durante la creazione: {ex.Message}");
            }
        }

        [Authorize]
        [HttpGet("Cerca")]
        public async Task<IActionResult> CercaRicette([FromQuery] string? nomeRicetta, [FromQuery] List<int>? tagIds)
        {
            if (string.IsNullOrWhiteSpace(nomeRicetta) || tagIds == null)
            {
                var ricette = from r in _context.ricette
                              select r;
                return Ok(ricette);
            }
            else
            {
                var ricette = from r in _context.ricette
                              join rt in _context.ricetteTag on r.Id equals rt.IdRicetta into ricettaTags
                              from rt in ricettaTags.DefaultIfEmpty()
                              select new { Ricetta = r, TagId = rt.IdTagDettaglio };

                if (!string.IsNullOrWhiteSpace(nomeRicetta))
                {
                    ricette = ricette.Where(x => x.Ricetta.Descrizione.Contains(nomeRicetta));
                }

                if (tagIds != null && tagIds.Any())
                {
                    ricette = ricette.Where(x => tagIds.Contains(x.TagId));
                }

                var grouped = await ricette
                    .GroupBy(x => x.Ricetta)
                    .Where(g => tagIds == null || !tagIds.Any() || tagIds.All(t => g.Select(x => x.TagId).Contains(t)))
                    .Select(g => g.Key)
                    .ToListAsync();

                return Ok(grouped);
            }
           

           
        }




        //// GET: api/<Ricette>
        //[HttpGet]
        //public IEnumerable<string> Get()
        //{
        //    return new string[] { "value1", "value2" };
        //}

        //// GET api/<Ricette>/5
        //[HttpGet("{id}")]
        //public string Get(int id)
        //{
        //    return "value";
        //}

        //// POST api/<Ricette>
        //[HttpPost]
        //public void Post([FromBody] string value)
        //{
        //}

        //// PUT api/<Ricette>/5
        //[HttpPut("{id}")]
        //public void Put(int id, [FromBody] string value)
        //{
        //}

        //// DELETE api/<Ricette>/5
        //[HttpDelete("{id}")]
        //public void Delete(int id)
        //{
        //}
    }
}
