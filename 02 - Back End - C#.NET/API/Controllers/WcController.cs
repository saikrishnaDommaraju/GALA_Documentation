using API.Data;
using API.DTOs;
using API.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace API.Controllers
{
  public class WcController : BaseAPIController
  {
    private readonly DataContext _context;

    public WcController(DataContext context)
    {
      _context = context;
    }

    /**
     * List the workcenters
     **/
    [Authorize(Policy = "ForAdmin")]
    [HttpGet]
    public async Task<IEnumerable<WcList>> GetWorkCenters()
    {
      return await _context.WorkCenters.OrderBy(w => w.order).ToListAsync();
    }

    /**
     * Add a new WorkCenter
     *
     * @param WcDto addDto
     * @return string 
     **/
    [Authorize(Policy = "ForAdmin")]
    [HttpPost]
    public async Task<ActionResult> AddWorkCenter(WcDto addDto)
    {
      //Check in the role exists
      var wcExists = await _context.WorkCenters.AnyAsync(x => x.tla == addDto.tla.ToUpper());
      if (wcExists) return BadRequest("Work Center already Exists");

      //Add in the Work Center
      var wc = new WcList
      {
        tla = addDto.tla.ToUpper(),
        name = addDto.name
      };

      var result = await _context.AddAsync(wc);
      if (await _context.SaveChangesAsync() > 0) return Created(addDto.tla + " created sucessfully", "");

      return BadRequest("Failed to Add Work Center");
    }
  }
}