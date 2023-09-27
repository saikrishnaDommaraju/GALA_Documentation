using API.Data;
using API.DTOs;
using API.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace API.Controllers
{

  public class UsersController : BaseAPIController
  {
    private readonly DataContext _context;
    private readonly UserManager<AppUser> _userManager;

    public UsersController(DataContext context, UserManager<AppUser> userManager)
    {
      _userManager = userManager;
      _context = context;
    }

    /**
     * Gets a list of users for Admin
     *
     * @return json
     **/
    [Authorize(Roles = "Admin")]
    [HttpGet]
    public async Task<ActionResult> GetUsers()
    {
      var users = await _userManager.Users
        .Where(u => u.isDeleted == 0)
        .Include(r => r.UserRoles)
        .ThenInclude(r => r.Role)
        .Select(u => new
        {
          u.Id,
          Username = u.UserName,
          Usercode = u.UserCode,
          Name = u.Name,
          Email = u.Email,
          Role = u.UserRoles.Select(r => r.Role.Name).ToList()
        })
        .ToListAsync();

      return Ok(users);
    }

    /**
     * Gets the user details
     *
     * @param string username
     * @return json
     **/
    [Authorize(Roles = "Admin")]
    [HttpGet("{username}")]
    public async Task<ActionResult> GetUser(string username)
    {
      var user = await _userManager.Users
        .Include(r => r.UserRoles)
        .ThenInclude(r => r.Role)
        .Select(u => new
        {
          u.Id,
          Username = u.UserName,
          Name = u.Name,
          Email = u.Email,
          Role = u.UserRoles.Select(r => r.Role.Name).ToList()
        }).SingleOrDefaultAsync(u => u.Username == username.ToLower());

      return Ok(user);
    }

    /**
     * Add a new user from Admin
     *
     * @param UserAddDto addDto
     * @return string
     **/
    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<ActionResult> AddUser(UserAddDto addDto)
    {
      var userExists = await _userManager.Users.AnyAsync(x => x.UserName == addDto.username.ToLower());
      if (userExists)
      {
        var userExisting = await _userManager.Users
              .Where(u => u.UserName == addDto.username.ToLower() && u.Email.ToLower() == addDto.Email.ToLower() && u.isDeleted == 1)
              .SingleOrDefaultAsync();
        if (!EqualityComparer<AppUser>.Default.Equals(userExisting, default(AppUser)))
        {
          userExisting.isDeleted = 0;
          _context.Entry(userExisting).State = EntityState.Modified;
          await _context.SaveChangesAsync();
          return Created("User created successfully", "");
        }
        else
        {
          return BadRequest("Username is taken");
        }
      }

      var user = new AppUser
      {
        UserName = addDto.username.ToLower(),
        UserCode = addDto.Usercode.ToLower(),
        Email = addDto.Email.ToLower(),
        Name = addDto.Name
      };

      var result = await _userManager.CreateAsync(user, "Pa$$w0rd");
      if (!result.Succeeded) return BadRequest(result.Errors);
      var roleResult = await _userManager.AddToRoleAsync(user, addDto.Role.ToUpper());
      if (!roleResult.Succeeded) return BadRequest(result.Errors);

      return Created("User created successfully", "");
    }

    /**
     * Updates the user details
     *
     * @param UserAddDto updateDto
     * @return string
     **/
    [Authorize(Roles = "Admin")]
    [HttpPut]
    public async Task<ActionResult> UpdateUser(UserAddDto updateDto)
    {
      //var username = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
      var user = await _userManager.Users
          .Include(r => r.UserRoles)
          .ThenInclude(r => r.Role)
          .SingleOrDefaultAsync(u => u.UserName == updateDto.username.ToLower());

      user.Name = updateDto.Name;
      user.Email = updateDto.Email;
      user.UserCode = updateDto.Usercode;

      //Get the User Roles and then remove them and add the new roles back in
      var roles = user.UserRoles.Select(r => r.Role.Name).ToList();
      await _userManager.RemoveFromRolesAsync(user, roles);
      await _userManager.AddToRoleAsync(user, updateDto.Role);

      _context.Entry(user).State = EntityState.Modified;
      if (await _context.SaveChangesAsync() > 0) return Ok(updateDto.username + " updated sucessfully");

      return BadRequest("Failed to Update User");
    }

    /**
     * Deletes a User
     *
     * @param string username
     * @return string
     **/
    [Authorize(Roles = "Admin")]
    [HttpDelete("{username}")]
    public async Task<ActionResult> DeleteUser(string username)
    {
      //var username = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

      var user = await _userManager.Users.SingleOrDefaultAsync(u => u.UserName == username.ToLower());

      if (EqualityComparer<AppUser>.Default.Equals(user, default(AppUser)))
      {
        return BadRequest("User Does not Exist");
      }
      else
      {
        user.isDeleted = 1;

        _context.Entry(user).State = EntityState.Modified;
        if (await _context.SaveChangesAsync() > 0) return Ok(username + " Deleted");
      }

      return BadRequest("Failed to Delete User");
    }

    /**
     * Gets the Contact information from the front end footer
     *
     * AllowAnonymous since it is accessed before login
     *
     * @return string
     **/
    [AllowAnonymous]
    [HttpGet("contact")]
    public async Task<ActionResult> GetContact()
    {
      var contact = await _context.Params.Where(p => p.Name == "contact").Select(p => p.Value).FirstOrDefaultAsync();
      return Ok(contact);
    }

    /**
     * Gets the Parameter information
     *
     * @return string
     **/
    [Authorize(Roles = "Admin")]
    [HttpGet("params/{paramname}")]
    public async Task<ActionResult> GetParams(string paramname)
    {
      var param = await _context.Params.Where(p => p.Name == paramname).Select(p => p.Value).FirstOrDefaultAsync();
      return Ok(param);
    }

    /**
     * Updates the Contact details parameter
     *
     * @param ProjNoDto contactInfo - Reuse the DTO as a string
     * @return string
     **/
    [Authorize(Roles = "Admin")]
    [HttpPost("params")]
    public async Task<ActionResult> UpdateParams(WcDto paramInfo)
    {
      var param = await _context.Params.Where(p => p.Name == paramInfo.tla).SingleOrDefaultAsync();
      if (EqualityComparer<Params>.Default.Equals(param, default(Params)))
      {
        return BadRequest("Could not find param " + paramInfo.tla);
      }

      param.Value = paramInfo.name;
      _context.Entry(param).State = EntityState.Modified;
      await _context.SaveChangesAsync();

      var retDesc = paramInfo.tla;
      if (retDesc == "contact")
      {
        retDesc = "Contact Information";
      }
      else if (retDesc == "doc_email")
      {
        retDesc = "Documentation Email Information";
      }

      return Ok(retDesc + " Updated");
    }
  }
}