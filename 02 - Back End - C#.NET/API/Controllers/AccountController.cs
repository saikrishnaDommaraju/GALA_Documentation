using API.DTOs;
using API.Entities;
using API.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Novell.Directory.Ldap;

namespace API.Controllers
{
  public class AccountController : BaseAPIController
  {

    private readonly ITokenService _tokenService;
    private readonly UserManager<AppUser> _userManager;
    private readonly SignInManager<AppUser> _signInManager;

    public AccountController(UserManager<AppUser> userManager,
                             SignInManager<AppUser> signInManager,
                             ITokenService tokenService)
    {
      _signInManager = signInManager;
      _userManager = userManager;
      _tokenService = tokenService;
    }

    /**
     * Validates authorised user
     *
     * @params LoginDto loginDto
     * @return string Success or Failure
     **/
    [Authorize]
    [HttpGet("validate")]
    public ActionResult Validate()
    {
      return Ok("Logged in");
    }

    /**
     * Allows the users to login using password in DB
     *
     * @params LoginDto loginDto
     * @return string Success or Failure
     **/
    [AllowAnonymous]
    [HttpPost("login")]
    public async Task<ActionResult> Login(LoginDto loginDto)
    {
      var user = await _userManager.Users.SingleOrDefaultAsync(x => x.UserName == loginDto.Username.ToLower());
      if (user == null) return Unauthorized("Username or Password is invalid");

      var result = await _signInManager.CheckPasswordSignInAsync(user, loginDto.Password, false);
      if (!result.Succeeded) return Unauthorized("Username or Password is invalid");

      var token = await _tokenService.CreateToken(user);
      return Ok(token);
    }
    
    /**
     * Allows the users to login via ldap
     *
     * @params LoginDto loginDto
     * @return string Success or Failure
     **/
    [AllowAnonymous]
    [HttpPost("login-ldap")]
    public async Task<ActionResult> LoginLdap(LoginDto loginDto)
    {
      
      //Bypass LDAP for test account
      if (loginDto.Username.ToLower() == "test")
      {
        return await Login(loginDto);
      }

      var user = await _userManager.Users.SingleOrDefaultAsync(x => x.Email == loginDto.Username.ToLower());
      if (user == null) return Unauthorized("Username or Password is invalid");

      try
      {
        using (var connection = new LdapConnection { SecureSocketLayer = false })
        {
          connection.Connect("172.25.128.10", LdapConnection.DefaultPort);
          connection.Bind(loginDto.Username, loginDto.Password);
          if (connection.Bound)
          {
            var token = await _tokenService.CreateToken(user);
            return Ok(token);
          }
        }
      }
      catch (LdapException ex)
      {
        if (ex.Message == "Invalid Credentials")
        {
          return Unauthorized("Username or Password Invalid");
        }
        return BadRequest(ex.Message);
      }
      return Unauthorized("Username or Password Invalid");
    }


  }
}