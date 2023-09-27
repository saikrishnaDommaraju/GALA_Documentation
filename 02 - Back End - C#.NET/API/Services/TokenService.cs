using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using API.Data;
using API.Entities;
using API.Interfaces;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace API.Services
{
  public class TokenService : ITokenService
  {
    private readonly SymmetricSecurityKey _key;
    private readonly UserManager<AppUser> _userManager;
    public DataContext _context { get; }

    public TokenService(IConfiguration config, UserManager<AppUser> userManager, DataContext context)
    {
      _userManager = userManager;
      _context = context;
      _key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(config["TokenKey"]));
    }

    public async Task<string> CreateToken(AppUser user)
    {
      var claims = new List<Claim>
      {
          new Claim(JwtRegisteredClaimNames.NameId, user.Id.ToString()),
          new Claim(JwtRegisteredClaimNames.UniqueName, user.UserName)
      };

      var roles = await _userManager.GetRolesAsync(user);
      claims.AddRange(roles.Select(role => new Claim(ClaimTypes.Role, role)));

      //Check if the role is readonly
      var roleData = await _context.Roles
        .Where(r => r.NormalizedName == roles[0].ToUpper())
        .FirstOrDefaultAsync();
      claims.Add(new Claim("readOnly", roleData.ReadOnly.ToString(), ClaimValueTypes.Boolean));

      //If the user is an Admin, then add in the isAdmin Claim
      if (roles[0] == "Admin" || roles[0].StartsWith("Admin"))
      {
        if (roles[0] == "Admin")
        {
          claims.Add(new Claim("Admin", "true", ClaimValueTypes.Boolean));
        }
        else
        {
          var wcListArr = roleData.ListItems.Split(',').ToList();
          var listItems = await _context.WorkCenters
              .Where(wc => wcListArr.Contains(wc.Id.ToString()))
              .Where(wc => wc.order > 1000)
              .Select(wc => wc.order)
              .ToListAsync();
          if (listItems.Count > 0)
          {
            claims.Add(new Claim("Admin", String.Join(',', listItems)));
          }
        }
      }

      var creds = new SigningCredentials(_key, SecurityAlgorithms.HmacSha256Signature);
      var tokenDesc = new SecurityTokenDescriptor
      {
        Subject = new ClaimsIdentity(claims),
        Expires = DateTime.Now.AddDays(7),
        SigningCredentials = creds
      };

      var tokenHandler = new JwtSecurityTokenHandler();
      var token = tokenHandler.CreateToken(tokenDesc);

      return tokenHandler.WriteToken(token);
    }
  }
}