using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using OptimaRicetteWS.Models;

namespace OptimaRicetteWS.Controllers
{
   

    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly TokenStore _tokenStore;
        private readonly string key;
        public AuthController(TokenStore tokenStore, JwtSettings jwtSettings)
        {
            _tokenStore = tokenStore;
            key = jwtSettings.SecretKey; // Usa la chiave fissa letta da config
        }

        //private readonly TokenStore _tokenStore;

        //// Chiave segreta lunga almeno 256 bit
        //private readonly string key;

        //public AuthController(TokenStore tokenStore)
        //{
        //    _tokenStore = tokenStore;
        //    key = GenerateSecureRandomKey(32); // 32 byte = 256 bit
        //}

        [HttpPost("login")]
        public IActionResult Login([FromBody] UserLogin request)
        {
            if (request.Username != "admin" || request.Password != "password")
                return Unauthorized();

            var accessToken = GenerateAccessToken(request.Username);
            var refreshToken = Guid.NewGuid().ToString();

            _tokenStore.SaveRefreshToken(request.Username, refreshToken);

            return Ok(new
            {
                accessToken,
                refreshToken
            });
        }

        [HttpPost("refresh")]
        public IActionResult Refresh([FromBody] RefreshRequest model)
        {
            var savedToken = _tokenStore.GetRefreshToken(model.Username);
            if (savedToken == null || savedToken != model.RefreshToken)
                return Unauthorized("Invalid refresh token");

            var newAccessToken = GenerateAccessToken(model.Username);
            return Ok(new { accessToken = newAccessToken });
        }

        private string GenerateAccessToken(string username)
        {
            var claims = new[]
            {
                new Claim(ClaimTypes.Name, username)
            };

            var keyBytes = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key));
            var creds = new SigningCredentials(keyBytes, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(15),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        // Metodo per generare una chiave segreta sicura e casuale
        private static string GenerateSecureRandomKey(int length)
        {
            using var rng = RandomNumberGenerator.Create();
            var bytes = new byte[length];
            rng.GetBytes(bytes);
            // Converti in base64 per ottenere una stringa utilizzabile
            return Convert.ToBase64String(bytes);
        }
    }
}

namespace OptimaRicetteWS.Models
{
    public class UserLogin
    {
        public string Username { get; set; }
        public string Password { get; set; }
    }
    
    public class RefreshRequest
    {
        public string Username { get; set; }
        public string RefreshToken { get; set; }
    }
}
