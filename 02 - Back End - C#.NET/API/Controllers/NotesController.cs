using System.Security.Claims;
using API.Data;
using API.DTOs;
using API.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace API.Controllers
{
  public class NotesController : BaseAPIController
  {
    private readonly DataContext _context;

    public NotesController(DataContext context)
    {
      _context = context;
    }

    /**
     * Gets the notes for an Item and ID
     *
     * @param string item
     * @param int item_id
     * @return object
     **/
    [Authorize]
    [HttpGet("{item}/{item_id}")]
    public async Task<ActionResult> GetNotes(string item, int item_id)
    {
      //Validate if the Item exists
      if (item == "pdf")
      {
        var pdf = await _context.PDFList.SingleOrDefaultAsync(x => x.Id == item_id);
        if (EqualityComparer<PDFList>.Default.Equals(pdf, default(PDFList)))
        {
          return BadRequest("List Item Not Found");
        }
      }

      if (item == "drw")
      {
        var drw = await _context.Drawings.SingleOrDefaultAsync(x => x.Id == item_id);
        if (EqualityComparer<Drawing>.Default.Equals(drw, default(Drawing)))
        {
          return BadRequest("Drawing Not Found");
        }
      }

      var notesList = await _context.Notes.Where(n => n.Item == item && n.Item_Id == item_id).ToListAsync();

      return Ok(notesList);
    }

    /**
     * Add a new Note
     *
     * @param NotesDto itemNotes
     * @return object
     **/
    [Authorize]
    [HttpPost]
    public async Task<ActionResult> AddNotes(NotesDto itemNotes)
    {
      
      var proj = new Project();
      //Validate if the Item exists
      if (itemNotes.Item == "pdf")
      {
        var pdf = await _context.PDFList.Include(p => p.Project).SingleOrDefaultAsync(x => x.Id == itemNotes.Item_Id);
        if (EqualityComparer<PDFList>.Default.Equals(pdf, default(PDFList)))
        {
          return BadRequest("List Item Not Found");
        }

        proj = pdf.Project;
      }

      if (itemNotes.Item == "drw")
      {
        var drw = await _context.Drawings.Include(p => p.Project).SingleOrDefaultAsync(x => x.Id == itemNotes.Item_Id);
        if (EqualityComparer<Drawing>.Default.Equals(drw, default(Drawing)))
        {
          return BadRequest("Drawing Not Found");
        }

        proj = drw.Project;
      }

      if (itemNotes.Item.Contains("check"))
      {
        var projNo = itemNotes.Item.Split("-")[1];
        proj = await _context.Projects.Where(p => p.ProjectNo == projNo).SingleOrDefaultAsync();
      }

      //Add in the Note
      var note = new Notes
      {
        Project = proj,
        Item = itemNotes.Item,
        Item_Id = itemNotes.Item_Id,
        Note = itemNotes.Note,
        User = User.FindFirst(ClaimTypes.Name)?.Value,
        CreatedDateTime = DateTime.Now
      };

      var result = await _context.AddAsync(note);

      if (await _context.SaveChangesAsync() > 0) return Created("Note Added sucessfully", note);

      return BadRequest("Failed to Add Note");
    }

    /**
     * Delete a Note
     *
     * @param NotesDto itemNotes
     * @return object
     **/
    [Authorize]
    [HttpDelete("{Id}")]
    public async Task<ActionResult> DeleteNotes(int Id)
    {
        //Check if the note exists and that it was created by the logged in user
        var note = await _context.Notes.Where(n => n.Id == Id && n.User == User.FindFirst(ClaimTypes.Name).Value).SingleOrDefaultAsync();
        if (EqualityComparer<Notes>.Default.Equals(note, default(Notes)))
        {
            return BadRequest("Note was not created by you");
        }
        
        _context.Notes.Remove(note);
        if (await _context.SaveChangesAsync() > 0) return Ok("Note Deleted");

        return BadRequest("Failed to Delete Note");
    }

    /**
     * Delete a Note
     *
     * @param NotesDto itemNotes
     * @return object
     **/
    [Authorize]
    [HttpPatch]
    public async Task<ActionResult> UpdateNotes(NotesDto itemNotes)
    {
        //Check if the note exists and that it was created by the logged in user
        var note = await _context.Notes.Where(n => n.Id == itemNotes.Id && n.User == User.FindFirst(ClaimTypes.Name).Value).SingleOrDefaultAsync();
        if (EqualityComparer<Notes>.Default.Equals(note, default(Notes)))
        {
            return BadRequest("Note was not created by you");
        }
        
        note.Note = itemNotes.Note;
        _context.Entry(note).State = EntityState.Modified;

        await _context.SaveChangesAsync();

        return Ok("Note Updated Successfully");
    }


  }
}