using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using OptimaRicetteWS.Data;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace OptimaRicetteWS.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TagController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public TagController(ApplicationDbContext context)
        {
            _context = context;
        }

        [Authorize]
        [HttpPost("RicetteByTagDettaglio")]
        public async Task<IActionResult> GetRicetteByTagDettagli([FromBody] List<int> idTagDettaglio)
        {
            var ricette = await _context.ricette
                .Include(r => r.RicettaTag)
                    .ThenInclude(rt => rt.TagDettaglio) 
                .Where(r => r.RicettaTag
                    .Any(rt =>
                        idTagDettaglio.Contains(rt.IdTagDettaglio) &&
                        rt.TagDettaglio.IdTagTestata == 1
                    )
                )
                .ToListAsync();

            return Ok(ricette);
        }




    }
}
