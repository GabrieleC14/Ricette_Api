namespace OptRicetteApi
{
    public class TokenStore
    {
        private readonly Dictionary<string, string> _refreshTokens = new();

        public void SaveRefreshToken(string username, string refreshToken)
        {
            _refreshTokens[username] = refreshToken;
        }

        public string? GetRefreshToken(string username)
        {
            _refreshTokens.TryGetValue(username, out var token);
            return token;
        }

        public void RemoveRefreshToken(string username)
        {
            _refreshTokens.Remove(username);
        }
    }

}
