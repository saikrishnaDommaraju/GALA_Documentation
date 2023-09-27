using API.DTOs;
using API.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace API.Controllers
{
  public class RoleController : BaseAPIController
  {
    private readonly RoleManager<AppRole> _roleManager;
    public RoleController(RoleManager<AppRole> roleManager)
    {
      _roleManager = roleManager;
    }

    /**
     * Gets the list of roles
     *
     * @return json
     **/
    [Authorize(Roles = "Admin")]
    [HttpGet]
    public async Task<ActionResult> FetchRoles()
    {
      var roles = await _roleManager.Roles
      .Select(r => new
      {
        id = r.Id,
        name = r.Name,
        listItems = r.ListItems,
        readOnly = r.ReadOnly
      })
      .Where(r => r.name != "Admin")
      .ToListAsync();

      return Ok(roles);
    }

    /**
     * Adds a new role
     *
     * @param RoleAddDto roleDto
     * @return json
     **/
    [Authorize(Roles = "Admin")]
    [HttpPost]
    public async Task<ActionResult> AddRole(RoleAddDto roleDto)
    {
      var role = await _roleManager.Roles.SingleOrDefaultAsync(r => r.NormalizedName == roleDto.Name.ToUpper());
      if (EqualityComparer<AppRole>.Default.Equals(role, default(AppRole)))
      {
        var newRole = new AppRole { Name = roleDto.Name, ListItems = roleDto.WcList, ReadOnly = roleDto.ReadOnly };
        await _roleManager.CreateAsync(newRole);
        return Created("Created", new { Id = newRole.Id, Name = newRole.Name, ListItems = newRole.ListItems, ReadOnly = newRole.ReadOnly });
      }
      else
      {
        //Updated
        role.ListItems = roleDto.WcList;
        role.ReadOnly = roleDto.ReadOnly;
        await _roleManager.UpdateAsync(role);
        return Ok(new { Id = role.Id, Name = role.Name, ListItems = role.ListItems, ReadOnly = role.ReadOnly });
      }
    }
  }
}