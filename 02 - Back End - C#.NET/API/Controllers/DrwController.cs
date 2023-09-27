using API.Data;
using API.DTOs;
using API.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace API.Controllers
{
  public class DrwController : BaseAPIController
  {
    private readonly DataContext _context;
    private readonly IConfiguration _config;
    private IDictionary<string, string> _wcMap = new Dictionary<string, string>(){
        {"CUT", "CUT"},
        {"FAB", "ALL"},
        {"MGI", "MG"},
        {"MGF", "MG"},
        {"OUTI", "OUT"},
        {"OUTF", "OUT"},
        {"CUST", "ALL"},
        {"ORDV", "NONE"}
      };

    public DrwController(DataContext context, IConfiguration config)
    {
      _config = config;
      _context = context;
    }

    /**
     * Given drawing ID get the children for the right panel
     *
     * @params string DrawID
     * @return json - Parent info and Children info
     **/
    [Authorize]
    [HttpGet("{drawId}")]
    public async Task<ActionResult> GetDrwData(int drawId)
    {
      var listParent = await _context.Drawings
          .Include(p => p.Project)
          .SingleOrDefaultAsync(x => x.Id == drawId);

      if (listParent == null)
      {
        return BadRequest("Drawing Id " + drawId + "not found");
      }

      //Get the List Type and map to work centers
      var listType = (listParent.ListStr.Split('-'))[0].Trim();

      var filter = listType;
      if (_wcMap.ContainsKey(listType)) { filter = _wcMap[listType]; }

      var listChildren = new List<BillofMaterial>();

      if (filter == "ALL")
      {
        listChildren = await _context.BOM
        .Include(p => p.Project)
        .Where(x => x.Parent == listParent.DrawNo && x.Project == listParent.Project && x.JobNumber == listParent.Job && x.Suffix == listParent.Suffix && x.Child != "Complete")
        .OrderBy(x => x.WC).ThenBy(x => x.SeqNo)
        .ToListAsync();
      }
      else if (filter == "PICK")
      {
        listChildren = await _context.BOM
        .Include(p => p.Project)
        .Where(x => x.Parent == listParent.DrawNo && x.Project == listParent.Project && x.JobNumber == listParent.Job && x.Suffix == listParent.Suffix && x.Child != "Complete" && x.Picklist == true)
        .OrderBy(x => x.WC).ThenBy(x => x.SeqNo)
        .ToListAsync();
      }
      else if (filter == "CUT")
      {
        listChildren = await _context.BOM
        .Include(p => p.Project)
        .Where(x => x.Child == listParent.DrawNo && x.Parent == listParent.Parent && x.Project == listParent.Project && x.JobNumber == listParent.Job)
        .OrderBy(x => x.WC).ThenBy(x => x.SeqNo)
        .ToListAsync();
      }
      else if (filter != "NONE")
      {
        listChildren = await _context.BOM
        .Include(p => p.Project)
        .Where(x => x.Parent == listParent.DrawNo && x.Project == listParent.Project && x.JobNumber == listParent.Job && x.Suffix == listParent.Suffix && x.WC == filter)
        .OrderBy(x => x.WC).ThenBy(x => x.SeqNo)
        .ToListAsync();
      }

      var noteCount = await _context.Notes.CountAsync(n => n.Item == "drw" && n.Item_Id == drawId);

      var drwData = new DrwMapDto
      {
        Parent = DRWListToDto(listParent, noteCount),
        Children = BomListToDto(listChildren)
      };

      return Ok(drwData);
    }

    /**
     * Get the drawing PDF
     *
     * The PDFJS Express library we are using gets the HEAD first
     * and then gets the actual file, hence the 2 requests.
     *
     * @params string projNo
     * @params string drawing no
     * @return filestream
     **/
    [AllowAnonymous]
    [HttpHead("view/{projNo}/{drawNo}")]
    [HttpGet("view/{projNo}/{drawNo}")]
    public ActionResult GetDrwPDF(string projNo, string drawNo)
    {
      var path = _config["ProjectStore"] + "/" + projNo + "/Drawings/" + drawNo + ".pdf";

      if (!System.IO.File.Exists(path))
      {
        path = _config["ProjectStore"] + "/Errors/FileNotFound.pdf";
      }

      var stream = new FileStream(path, FileMode.Open);
      return new FileStreamResult(stream, "application/pdf");
    }

    /**
     * Mark a drawing for update, admins have access from front end
     *
     * @params BomSelDto selDrw - Reusing the DrawId and selected from DTO
     * @return string
     **/
    [Authorize]
    [HttpPut("mark-update")]
    public async Task<ActionResult> UpdateDrwNo(BomSelDto selDrw)
    {
      var drw = await _context.Drawings.SingleOrDefaultAsync(x => x.Id == selDrw.DrawId);
      if (EqualityComparer<Drawing>.Default.Equals(drw, default(Drawing)))
      {
        return BadRequest("Drawing Not Found");
      }

      drw.toUpdate = selDrw.selected ? 1 : 0;
      _context.Entry(drw).State = EntityState.Modified;
      await _context.SaveChangesAsync();
      return Ok("Marked for update");
    }

    /**
     * Update the drawing state when updated from the backend queue
     **/
    [AllowAnonymous]
    [HttpPost("changestate")]
    public async Task<ActionResult> ChangeDrawState([FromForm] string ProjectNo, [FromForm] string DrwList, [FromForm] int state)
    {

      var proj = await _context.Projects.SingleOrDefaultAsync(x => x.ProjectNo == ProjectNo);
      if (EqualityComparer<Project>.Default.Equals(proj, default(Project)))
      {
        return BadRequest("Project Not Found");
      }

      string[] drawings = DrwList.Split(",");

      //Update the state of each of the drawings
      foreach (string drwNo in drawings)
      {
        var drw = await _context.Drawings
          .Where(x => x.DrawNo == drwNo && x.Project == proj)
          .ToListAsync();

        foreach (Drawing d in drw)
        {
          d.toUpdate = state;
          if (state == 0)
          {
            d.UpdateDateTime = DateTime.Now;
          }
          _context.Entry(d).State = EntityState.Modified;
        }
      }

      await _context.SaveChangesAsync();
      return Ok("State updated");
    }

    /**
     * Gets the Parent Item stack
     *
     * Gets the Parent Item so that we can go to that on the front end
     *
     * @param int drawId
     * @return json
     **/
    [Authorize]
    [HttpGet("parent/{drawId}")]
    public async Task<ActionResult> GetDrwParent(int drawId)
    {
      var drw = await _context.Drawings.Include(d => d.Project).SingleOrDefaultAsync(x => x.Id == drawId);
      if (EqualityComparer<Drawing>.Default.Equals(drw, default(Drawing)))
      {
        return BadRequest("Drawing Not Found");
      }

      var drwParent = await _context.Drawings
                .Include(d => d.Project)
                .Include(d => d.List)
                .Where(x => x.DrawNo == drw.Parent && (x.ListStr.Contains("FAB") || x.ListStr.Contains("CUST")) && x.Project == drw.Project)
                .ToListAsync();

      if (drwParent.Count == 0)
      {
        return BadRequest("Drawing Parent Not Found for Draw ID = " + drw.Id);
      }

      return Ok(new {ListType = drwParent[0].List.Type, ListId = drwParent[0].List.Id, DrawId = drwParent[0].Id});
    }

    /**
     * Marks the BOM item as completed
     *
     * Also traverses the parents and marks them as completed as well if required
     *
     * @param BomSelDto selBom
     * @return json
     **/
    [Authorize]
    [HttpPut("select")]
    public async Task<ActionResult> SelectDrwNo(BomSelDto selBom)
    {
      int[] bomIdUpdate = new int[2];
      List<Array> drwIdUpdate = new List<Array>();
      List<Array> listIdUpdate = new List<Array>();

      var bom = await _context.BOM.Include(p => p.Project).SingleOrDefaultAsync(x => x.Id == selBom.BomId);
      if (EqualityComparer<BillofMaterial>.Default.Equals(bom, default(BillofMaterial)))
      {
        return BadRequest("BOM Item Not Found");
      }

      //Make the updates only if different
      if (bom.isComplete != selBom.selected)
      {
        var drwT = await _context.Drawings.SingleOrDefaultAsync(d => d.Id == selBom.DrawId);
        var listType = drwT.ListStr.Split('-')[0].Trim();

        var filter = listType;
        if (_wcMap.ContainsKey(listType)) { filter = _wcMap[listType]; }

        var bomNotCompletePre = false;

        if (filter == "ALL")
        {
          bomNotCompletePre = await _context.BOM
              .Where(x => x.Parent == bom.Parent && x.Project == bom.Project && x.JobNumber == drwT.Job && x.Suffix == drwT.Suffix && x.Child != "Complete" && x.isComplete == false)
              .AnyAsync();
        }
        else if (filter != "NONE")
        {
          bomNotCompletePre = await _context.BOM
              .Where(x => x.Parent == bom.Parent && x.Project == bom.Project && x.JobNumber == drwT.Job && x.Suffix == drwT.Suffix && x.WC == filter && x.isComplete == false)
              .AnyAsync();
        }

        bom.isComplete = selBom.selected;
        _context.Entry(bom).State = EntityState.Modified;
        bomIdUpdate[0] = bom.Id;
        bomIdUpdate[1] = bom.isComplete ? 1 : 0;
        await _context.SaveChangesAsync();

        var bomNotComplete = false;
        if (filter == "ALL")
        {
          bomNotComplete = await _context.BOM
              .Where(x => x.Parent == bom.Parent && x.Project == bom.Project && x.JobNumber == drwT.Job && x.Suffix == drwT.Suffix && x.Child != "Complete" && x.isComplete == false)
              .AnyAsync();
        }
        else if (filter != "NONE")
        {
          bomNotComplete = await _context.BOM
              .Where(x => x.Parent == bom.Parent && x.Project == bom.Project && x.JobNumber == drwT.Job && x.Suffix == drwT.Suffix && x.WC == filter && x.isComplete == false)
              .AnyAsync();
        }

        if (bomNotCompletePre != bomNotComplete)
        {
          List<Drawing> drw = await _context.Drawings
             .Include(d => d.List)
             .Where(x => x.DrawNo == bom.Parent && x.Job == bom.JobNumber && x.Suffix == bom.Suffix && x.Project == bom.Project)
             .Where(d => d.List.Type != "PICK")  //Picklist should not be checked for completion
             .ToListAsync();

          foreach (Drawing d in drw)
          {
            //Check for each of the drawings if the BOM is completed or not
            var iListType = d.ListStr.Split('-')[0].Trim();
            var iFilter = iListType;
            if (_wcMap.ContainsKey(iListType)) { iFilter = _wcMap[iListType]; }

            var iBomNotComplete = false;
            if (iFilter == "ALL")
            {
              iBomNotComplete = await _context.BOM
                .Where(x => x.Parent == d.DrawNo && x.Project == d.Project && x.JobNumber == d.Job && x.Suffix == d.Suffix && x.Child != "Complete" && x.isComplete == false)
                .AnyAsync();
            }
            else if (filter != "NONE")
            {
              iBomNotComplete = await _context.BOM
                .Where(x => x.Parent == d.DrawNo && x.Project == d.Project && x.JobNumber == d.Job && x.Suffix == d.Suffix && x.WC == iFilter && x.isComplete == false)
                .AnyAsync();
            }

            if (d.isComplete == iBomNotComplete)
            {

              var drwNotCompletePre = await _context.Drawings
                .Where(x => x.List.Id == d.List.Id && x.isComplete == false).AnyAsync();

              d.isComplete = !iBomNotComplete;
              _context.Entry(d).State = EntityState.Modified;
              await _context.SaveChangesAsync();

              var tmpArr = new int[2];
              tmpArr[0] = d.Id;
              tmpArr[1] = d.isComplete ? 1 : 0;
              drwIdUpdate.Add(tmpArr);

              var drwNotComplete = await _context.Drawings
                .Where(x => x.List.Id == d.List.Id && x.isComplete == false).AnyAsync();

              if (drwNotCompletePre != drwNotComplete)
              {
                var list = await _context.PDFList.Where(l => l.Id == d.List.Id).FirstAsync();
                list.isComplete = !drwNotComplete;
                _context.Entry(list).State = EntityState.Modified;
                var tmpArr2 = new int[2];
                tmpArr2[0] = list.Id;
                tmpArr2[1] = list.isComplete ? 1 : 0;
                listIdUpdate.Add(tmpArr2);
              }
            }
          }
        }

        await _context.SaveChangesAsync();
      }
      return Ok(new { bom = bomIdUpdate, draw = drwIdUpdate, list = listIdUpdate });
    }

    /**
     * Updates a picklist item
     *
     * @param IntStrDto pickItem
     * @return string
     **/
    [Authorize]
    [HttpPut("pickitemupdate")]
    public async Task<ActionResult> PickListItemUpdate(IntStrDto pickItem)
    {
      var bom = await _context.BOM.SingleOrDefaultAsync(x => x.Id == pickItem.Id);
      if (EqualityComparer<BillofMaterial>.Default.Equals(bom, default(BillofMaterial)))
      {
        return BadRequest("BOM Item Not Found");
      }

      bom.Picked = float.Parse(pickItem.Str);
      _context.Entry(bom).State = EntityState.Modified;
      if (await _context.SaveChangesAsync() > 0) return Ok("Updated sucessfully");

      return BadRequest("Pick Item update failed");
    }

    private DrwListDto DRWListToDto(Drawing l, int noteCnt)
    {
      if (l != null)
      {
        var pathParent = _config["ProjectStore"] + "/" + l.Project.ProjectNo + "/Drawings/" + l.Parent + ".pdf";
        var pathDrawing = _config["ProjectStore"] + "/" + l.Project.ProjectNo + "/Drawings/" + l.DrawNo + ".pdf";

        var lpDTO = new DrwListDto
        {
          Id = l.Id,
          Type = "Drawing",
          DrawNo = l.DrawNo,
          DrwExists = System.IO.File.Exists(pathDrawing),
          Parent = l.Parent,
          ParentType = l.ListStr.Split('-')[0].Trim(),
          ParentExists = System.IO.File.Exists(pathParent),
          List = l.ListStr,
          NoteCount = noteCnt,
          toUpdate = l.toUpdate,
          UpdateDateTime = l.UpdateDateTime
        };

        return lpDTO;
      }
      return null;
    }

    /**
     * Function to convert bomlist to a DTO format for return
     **/
    private List<BomListDto> BomListToDto(List<BillofMaterial> listBom)
    {
      if (listBom != null)
      {
        var listd = new List<BomListDto>();
        foreach (var l in listBom)
        {

          //Drawing Path
          var path = _config["ProjectStore"] + "/" + l.Project.ProjectNo + "/Drawings/" + l.Child + ".pdf";

          var lpDTO = new BomListDto
          {
            Id = l.Id,
            Parent = l.Parent,
            Child = l.Child,
            ChildDesc = l.ChildDesc,
            SeqNo = l.SeqNo,
            Qty = l.Qty,
            UM = l.UM,
            WC = l.WC,
            PQty = l.PQty,
            PLoc = l.PLoc,
            Picked = l.Picked,
            isComplete = l.isComplete,
            drwExists = System.IO.File.Exists(path)
          };
          listd.Add(lpDTO);
        };
        return listd;
      }
      return null;
    }
  }
}