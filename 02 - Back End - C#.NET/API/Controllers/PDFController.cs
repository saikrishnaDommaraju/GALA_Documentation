using API.Data;
using API.DTOs;
using API.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace API.Controllers
{
  public class PDFController : BaseAPIController
  {
    private readonly DataContext _context;
    private readonly IConfiguration _config;

    public PDFController(DataContext context, IConfiguration config)
    {
      _config = config;
      _context = context;
    }

    /**
     * Get List of Drawings for a List Item
     *
     * @param int ListId
     * @return json
     **/
    [Authorize]
    [HttpGet("{listID}")]
    public async Task<ActionResult<List<DrwDto>>> GetDrwList(int ListId)
    {
      var pdfList = await _context.PDFList.FindAsync(ListId);
      if (EqualityComparer<PDFList>.Default.Equals(pdfList, default(PDFList)))
      {
        return BadRequest("List Not Found");
      }

      var drwList = await _context.Drawings.Where(x => x.List == pdfList).ToListAsync();

      var addSuffix = true;
      if (pdfList.Type == "Cut")
      {
        addSuffix = false;
      }

      return Ok(DRWToDto(drwList, addSuffix));
    }

    /**
     * Get List of Documents in the Project
     *
     * @param string projectNo
     * @return json
     **/
    [Authorize]
    [HttpGet("docList/{projectNo}")]
    public ActionResult<List<string>> GetDocList(string projectNo)
    {
      var path = _config["ProjectStore"] + "/" + projectNo + "/FILES";
      var listFiles = new List<string>(); 
      if (!System.IO.Directory.Exists(path))
      {
        return Ok(listFiles);
      }

      var fileList = System.IO.Directory.EnumerateFiles(path, "*.pdf");
      foreach (string fPath in fileList)
      {
        var fName = Path.GetFileNameWithoutExtension(fPath);
        listFiles.Add(fName);
      }
      return Ok(listFiles);
    }

    /**
     * Get the PDF of the list item
     *
     * @param int ListId
     * @return filestream
     **/
    [AllowAnonymous]
    [HttpHead("view/{id}")]
    [HttpGet("view/{id}")]
    public async Task<ActionResult> GetListPDF(int id)
    {

      var path = "";

      var listItem = await _context.PDFList
        .Include(p => p.Project)
        .SingleOrDefaultAsync(x => x.Id == id);

      if (EqualityComparer<PDFList>.Default.Equals(listItem, default(PDFList)))
      {
        path = _config["ProjectStore"] + "/Errors/FileNotFound.pdf";
      }
      else
      {

        path = _config["ProjectStore"] + "/" + listItem.Project.ProjectNo + "/" + listItem.Type + "/" + listItem.JobNumber + ".pdf";

        if (!System.IO.File.Exists(path))
        {
          path = _config["ProjectStore"] + "/Errors/FileNotFound.pdf";
        }
      }

      var stream = new FileStream(path, FileMode.Open);
      return new FileStreamResult(stream, "application/pdf");

    }

    /**
     * Get the PDF of the document file
     *
     * @param string projectNo
     * @param string fileName
     * @return filestream
     **/
    [AllowAnonymous]
    [HttpHead("viewdoc/{projectNo}/{fileName}")]
    [HttpGet("viewdoc/{projectNo}/{fileName}")]
    public ActionResult GetDocPDF(string projectNo, string fileName)
    {

      var path = _config["ProjectStore"] + "/" + projectNo + "/FILES/" + fileName + ".pdf";
      
      if (!System.IO.File.Exists(path))
      {
        path = _config["ProjectStore"] + "/Errors/FileNotFound.pdf";
      }      

      var stream = new FileStream(path, FileMode.Open);
      return new FileStreamResult(stream, "application/pdf");

    }

    /**
     * Function to convert List of Drawings to the DTO for return
     **/
    private List<DrwDto> DRWToDto(List<Drawing> listDrw, bool addSuffix)
    {
      if (listDrw != null)
      {
        var listd = new List<DrwDto>();
        foreach (var l in listDrw)
        {
          var lpDTO = new DrwDto
          {
            Id = l.Id,
            DrawNo = l.DrawNo,
            DrawTitle = l.DrawTitle,
            Suffix = l.Suffix,
            isComplete = l.isComplete
          };

          if (!addSuffix) { lpDTO.Suffix = -99; }

          listd.Add(lpDTO);
        };
        return listd;
      }
      return null;
    }

  }
}