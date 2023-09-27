using System.Net.Mail;
using System.Security.Claims;
using System.Text.Json;
using API.Data;
using API.DTOs;
using API.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace API.Controllers
{
  public class ProjectsController : BaseAPIController
  {
    private readonly DataContext _context;
    private readonly IConfiguration _config;

    public ProjectsController(DataContext context, IConfiguration config)
    {
      _config = config;
      _context = context;
    }

    /**
     * List of Project for Admin
     *
     * @param string state - Archived or Avaialble
     * @return json
     **/
    [Authorize(Policy = "ForAdmin")]
    [HttpGet("adminlist/{state}")]
    public async Task<IEnumerable<Project>> GetProjects(string state)
    {
      if (state == "archived")
      {
        return await _context.Projects.Where(p => p.State == "archived").OrderBy(p => p.ProjectNo).ToListAsync();
      }
      else
      {
        return await _context.Projects.Where(p => p.State != "archived" && p.State != "deleted").OrderBy(p => p.ProjectNo).ToListAsync();
      }
    }

    /**
     * List of Ready Project for Project Selection Drop Down
     *
     * @return json
     **/
    [Authorize]
    [HttpGet("list")]
    public async Task<IEnumerable<Project>> GetProjectsList()
    {
      return await _context.Projects.Where(p => p.State == "ready").OrderBy(p => p.ProjectNo).ToListAsync();
    }

    /**
     * Get Project Level Notes
     *
     * @param string Project No
     * @return string
     **/
    [Authorize]
    [HttpGet("notes/{projectNo}")]
    public async Task<ActionResult<string>> GetProjectNotes(string projectNo)
    {
      var proj = await _context.Projects.SingleOrDefaultAsync(x => x.ProjectNo.ToLower() == projectNo.ToLower() && x.State == "ready");
      if (EqualityComparer<Project>.Default.Equals(proj, default(Project)))
      {
        return BadRequest("Project Not Found");
      }

      return Ok(proj.Notes);

    }

    /**
     * Get Project Lists for left menu
     *
     * @param string Project No
     * @return json
     **/
    [Authorize]
    [HttpGet("{projectNo}")]
    public async Task<ActionResult> GetProject(string projectNo)
    {
      var proj = await _context.Projects.SingleOrDefaultAsync(x => x.ProjectNo.ToLower() == projectNo.ToLower() && x.State == "ready");
      if (EqualityComparer<Project>.Default.Equals(proj, default(Project)))
      {
        return BadRequest("Project Not Found");
      }

      //Get the User Role
      var role = User.FindFirst(ClaimTypes.Role)?.Value;
      List<PDFList> listPDF;

      if (role != "Admin")
      {
        //Get the authorized items for the role
        var authItems = await _context.Roles
            .Where(r => r.Name == role)
            .Select(r => r.ListItems)
            .SingleOrDefaultAsync();
        var authItemsArr = authItems.Split(',').ToList();

        //Get the TLA fo the list
        var listItems = await _context.WorkCenters
            .Where(wc => authItemsArr.Contains(wc.Id.ToString()))
            .Select(wc => wc.tla.ToUpper())
            .ToListAsync();

        //Get the Authorized PDF Lists
        listPDF = await _context.PDFList
            .Where(x => x.Project == proj)
            .Where(x => listItems.Contains(x.JobNumber) || listItems.Contains(x.Type.ToUpper()))
            .ToListAsync();
      }
      else
      {
        listPDF = await _context.PDFList.Where(x => x.Project == proj).ToListAsync();
      }

      //Notes
      var countNotes = await _context.Notes
            .Where(n => n.Item == "pdf")
            .Join(_context.PDFList, n => n.Item_Id, p => p.Id, (n, p) => new { ItemId = n.Item_Id })
            .GroupBy(n => n.ItemId)
            .Select(g => new { item = g.Key, count = g.Count() })
            .ToListAsync();

      var listWC = await _context.WorkCenters.ToListAsync();
      var listJobs = await _context.Jobs.ToListAsync();
      bool hasCheckSheet = !string.IsNullOrWhiteSpace(proj.Checklist);

      //Check if there are files in the FILES folder
      var filesPath = _config["ProjectStore"] + "/" + projectNo + "/FILES";
      var hasFiles = false;
      if (System.IO.Directory.Exists(filesPath))
      {
        hasFiles = System.IO.Directory.EnumerateFiles(filesPath, "*.pdf").Count() > 0;
      }

      return Ok(PDFListToDto(listPDF, listWC, listJobs, countNotes, hasCheckSheet, hasFiles));

    }

    /**
     * Function to convert list data to DTO for return
     **/
    private List<PDFGroupDto> PDFListToDto(
        List<PDFList> listPDF,
        List<WcList> listWC,
        List<Jobs> listJobs,
        IEnumerable<dynamic> countNotes,
        bool hasCheckSheet,
        bool hasFiles
      )
    {

      if (listPDF == null) { return null; }

      IDictionary<string, List<PDFListDto>> gPDF = new Dictionary<string, List<PDFListDto>>();

      foreach (var l in listPDF)
      {
        //Push in the WC Name instead of the shortforms and replace them in the list
        var Clname = listWC
          .Where(x => x.tla == l.JobNumber)
          .Select(x => new { Name = x.name, Order = x.order }).ToList();
        var ClnameStr = l.JobNumber;
        var ClOrderStr = 0;
        if (Clname.Count > 0)
        {
          ClnameStr = Clname[0].Name;
          ClOrderStr = Clname[0].Order;
        }

        //Get the JobStatus and Job Name from the jobsList
        var jStat = "R";
        var jName = "";
        if (l.Type != "CUT")
        {
          var jobStat = listJobs
          .Where(x => x.Job == l.JobNumber)
          .Select(x => new { x.State, x.Name })
          .ToList();

          if (jobStat.Count > 0)
          {
            jStat = jobStat[0].State;
            jName = jobStat[0].Name;
          }
        }

        var noteCount = countNotes.Where(n => n.item == l.Id).Select(n => n.count).ToList();

        var lpDTO = new PDFListDto
        {
          Id = l.Id,
          Type = l.Type,
          Name = ClnameStr,
          JobNumber = l.JobNumber,
          JobState = jStat,
          JobName = jName,
          NoteCount = noteCount.Count > 0 ? noteCount[0] : 0,
          Order = ClOrderStr,
          isComplete = l.isComplete
        };

        if (!gPDF.ContainsKey(l.Type)) { gPDF.Add(l.Type, new List<PDFListDto>()); }
        gPDF[l.Type].Add(lpDTO);
      };

      //Sort the CutList based on Order
      if (gPDF.ContainsKey("CUT"))
      {
        gPDF["CUT"].Sort((x, y) => x.Order.CompareTo(y.Order));
      }

      //Convert the Dict into the PDFGroupDto with the names
      List<PDFGroupDto> groupPDF = new List<PDFGroupDto>();
      foreach (var kvp in gPDF)
      {
        var gName = listWC.Where(x => x.tla == kvp.Key.ToUpper())
            .Select(x => new { Name = x.name, Order = x.order }).ToList();
        var gNameStr = kvp.Key.ToUpper();
        var gOrderStr = 0;
        if (gName.Count > 0)
        {
          gNameStr = gName[0].Name;
          gOrderStr = gName[0].Order;
        }

        var groupPDFEl = new PDFGroupDto
        {
          Type = kvp.Key.ToUpper(),
          Name = gNameStr,
          Order = gOrderStr,
          PDFList = kvp.Value
        };

        groupPDF.Add(groupPDFEl);
      }

      //Add Checksheet element if it is there
      if (hasCheckSheet)
      {
        var groupPDFCheck = new PDFGroupDto
        {
          Type = "CHECK",
          Name = "Check Sheets",
          Order = 999,
          PDFList = new List<PDFListDto>()
        };
        groupPDF.Add(groupPDFCheck);
      }

      //Add Files Element if it there
      if (hasFiles)
      {
        var groupPDFFiles = new PDFGroupDto
        {
          Type = "FILES",
          Name = "Documents",
          Order = 1000,
          PDFList = new List<PDFListDto>()
        };
        groupPDF.Add(groupPDFFiles);
      }

      //Sort group based on the Order
      groupPDF.Sort((x, y) => x.Order.CompareTo(y.Order));

      return groupPDF;

    }

    /**
     * Adds a new project on Admin
     *
     * @param ProjNoDto addDto
     * @return string
     **/
    [Authorize(Policy = "ForAdmin")]
    [HttpPost]
    public async Task<ActionResult> AddProject(ProjNoDto addDto)
    {
      //Split the projects up
      var projNos = addDto.projectNo.Split(',').ToList();
      List<Project> outProj = new List<Project>();

      foreach (string projNo in projNos)
      {
        string projNoI = projNo.Trim().ToUpper();

        //If the number is <10 chars and starts with a alpha then pad with 0
        //Mainly for Spare parts starting with S
        if (projNoI.Length < 10 && !char.IsDigit(projNoI[0]))
        {
          projNoI = projNoI[0] + projNoI.Substring(1).PadLeft(9, '0');
        }

        //Check if the project already exists
        var projExists = await _context.Projects.AnyAsync(x => x.ProjectNo == projNoI);
        if (!projExists)
        {
          //Add in the project
          var project = new Project
          {
            ProjectNo = projNoI,
            State = "new",
            SubmittedBy = User.FindFirst(ClaimTypes.Name)?.Value,
            SubmittedDateTime = DateTime.Now
          };

          var result = await _context.AddAsync(project);
          outProj.Add(project);
        };
      }

      if (outProj.Count == 0)
      {
        return BadRequest("All Project numbers entered already exist");
      }

      if (await _context.SaveChangesAsync() > 0) return Created("Projects created sucessfully", outProj);

      return BadRequest("Failed to Create Project");
    }

    /**
     * Deletes a project on Admin
     *
     * @param int projectId
     * @return string
     **/
    [Authorize(Policy = "ForAdmin")]
    [HttpDelete("{projectId}")]
    public async Task<ActionResult> DeleteProject(int projectId)
    {
      var proj = await _context.Projects.SingleOrDefaultAsync(x => x.Id == projectId);
      if (EqualityComparer<Project>.Default.Equals(proj, default(Project)))
      {
        return BadRequest("Could not find project");
      }

      if (proj.State == "new" || proj.State == "error")
      {
        _context.Projects.Remove(proj);
        if (await _context.SaveChangesAsync() > 0) return Ok(proj.ProjectNo + " Deleted");
      }
      else
      {
        return BadRequest("Project can only be deleted if state is New Or Error");
      }

      return BadRequest("Failed to Delete Project");
    }

    /**
     * Adds in the checklist information on Admin
     *
     * @param ProjInfoDto projInfoDto
     * @return string
     **/
    [Authorize(Policy = "ForAdmin")]
    [HttpPut("checklist")]
    public async Task<ActionResult> updateChecklist(ProjInfoDto projInfoDto)
    {
      var proj = await _context.Projects.FindAsync(projInfoDto.Id);
      if (proj == null) { return BadRequest("Project Not Found"); }

      proj.Checklist = null;
      if (projInfoDto.CheckList != "") { proj.Checklist = projInfoDto.CheckList; }
      _context.Entry(proj).State = EntityState.Modified;
      await _context.SaveChangesAsync();

      return Ok();
    }

    /**
     * Adds in the project info on Admin
     *
     * @param ProjInfoDto projInfoDto
     * @return string
     **/
    [Authorize(Policy = "ForAdmin")]
    [HttpPut("projinfo")]
    public async Task<ActionResult> updateProjectInfo(ProjInfoDto projInfoDto)
    {
      var proj = await _context.Projects.FindAsync(projInfoDto.Id);
      if (proj == null) { return BadRequest("Project Not Found"); }

      proj.Notes = projInfoDto.Notes;
      proj.Notify = projInfoDto.Email;
      proj.MechEng = projInfoDto.MechEng;
      proj.ElecEng = projInfoDto.ElecEng;
      _context.Entry(proj).State = EntityState.Modified;
      await _context.SaveChangesAsync();

      return Ok();
    }

    /**
     * Checks if the queue is active. This is updated on the backend
     *
     * It is used to put in a notice on the front end if the backend processing queue is not live
     *
     * @return bool
     **/
    [Authorize(Policy = "ForAdmin")]
    [HttpGet("queue_active")]
    public async Task<bool> QueueActive()
    {
      var queueCheckin = await _context.Params.SingleOrDefaultAsync(p => p.Name == "queue_checkin");
      if (EqualityComparer<Params>.Default.Equals(queueCheckin, default(Params)))
      {
        return false;
      }

      try
      {
        var diffInSeconds = (DateTime.Now - DateTime.Parse(queueCheckin.Value)).TotalSeconds;
        if (diffInSeconds > 5 * 60) //If the last accessed time > 5 mins assume queue has stopped.
        {
          return false;
        }
        else
        {
          return true;
        }
      }
      catch
      {
        return false;
      }
    }

    /**
     * Process a project from the backend queue
     *
     * @return string
     **/
    [AllowAnonymous]
    [HttpGet("process/{projectNo}")]
    public async Task<ActionResult> ProcessProject(string projectNo)
    {
      //Get the ProjectID
      var proj = await _context.Projects.SingleOrDefaultAsync(x => x.ProjectNo.ToLower() == projectNo.ToLower());
      if (EqualityComparer<Project>.Default.Equals(proj, default(Project)))
      {
        return BadRequest("Could not find project");
      }

      //Check if the folder exists
      if (!System.IO.Directory.Exists(_config["ProjectStore"] + "/" + projectNo))
      {
        await setProjError(proj, "Folder does not exist");
        sendEmail(proj, proj.ProjectNo + " process Error", proj.ProjectNo + " processing as failed because<br /><br />Project Folder does not exist");
        return BadRequest("Folder does not exist");
      }

      //Process the Jobs
      var jobPath = _config["ProjectStore"] + "/" + projectNo + "/dataJobs.json";
      if (!System.IO.File.Exists(jobPath))
      {
        await setProjError(proj, "Job File " + jobPath + " not found");
        sendEmail(proj, proj.ProjectNo + " process Error", proj.ProjectNo + " processing as failed because<br /><br />Job File " + jobPath + " not found");
        return BadRequest("Job File " + jobPath + " not found");
      }

      try
      {
        //Get Data From File
        var jobsFile = await System.IO.File.ReadAllTextAsync(jobPath);
        var jobsAdd = JsonSerializer.Deserialize<List<Jobs>>(jobsFile);
        if (jobsAdd == null)
        {
          await setProjError(proj, "No Data in Jobs");
          sendEmail(proj, proj.ProjectNo + " process Error", proj.ProjectNo + " processing as failed because<br /><br />No Data in Jobs");
          return BadRequest("No Data in Jobs");
        }

        //Get Existing Jobs from DB
        var jobsExist = await _context.Jobs.Where(x => x.Project == proj).ToListAsync();

        //Add or Update Jobs if they exist
        foreach (var jA in jobsAdd)
        {
          var jE = jobsExist.Where(j => j.Job == jA.Job).SingleOrDefault();
          if (EqualityComparer<Jobs>.Default.Equals(jE, default(Jobs)))
          {
            jA.Project = proj;
            await _context.Jobs.AddAsync(jA);
          }
          else
          {
            jE.State = jA.State;
            jE.Name = jA.Name;
            _context.Entry(jE).State = EntityState.Modified;
          }
        }

        //Delete Jobs if they dont exist in the add list
        foreach (var jE in jobsExist)
        {
          if (!jobsAdd.Where(j => j.Job == jE.Job).Any()) { _context.Jobs.Remove(jE); }
        }

        await _context.SaveChangesAsync();
      }
      catch (Exception e)
      {
        await setProjError(proj, "Jobs Error: " + e.Message);
        sendEmail(proj, proj.ProjectNo + " process Error", proj.ProjectNo + " processing as failed because<br /><br />Jobs Error: " + e.Message);
        return BadRequest("Jobs Error: " + e.Message);
      }

      //Process the PDF List Reports
      var pdfPath = _config["ProjectStore"] + "/" + projectNo + "/dataList.json";
      if (!System.IO.File.Exists(pdfPath))
      {
        await setProjError(proj, "Report File " + pdfPath + " not found");
        sendEmail(proj, proj.ProjectNo + " process Error", proj.ProjectNo + " processing as failed because<br /><br />Report File " + pdfPath + " not found");
        return BadRequest("Report File " + pdfPath + " not found");
      }

      try
      {
        //Get Reports from File
        var pdfFile = await System.IO.File.ReadAllTextAsync(pdfPath);
        var pdfAdd = JsonSerializer.Deserialize<List<PDFList>>(pdfFile);
        if (pdfAdd == null)
        {
          await setProjError(proj, "No Data in Reports");
          sendEmail(proj, proj.ProjectNo + " process Error", proj.ProjectNo + " processing as failed because<br /><br />No Data in Reports");
          return BadRequest("No Data in Reports");
        }

        //Get Existing Reports from DB
        var pdfExists = await _context.PDFList.Where(x => x.Project == proj).ToListAsync();

        //Add or Update Reports
        foreach (var pA in pdfAdd)
        {
          if (!pdfExists.Where(p => p.Type == pA.Type && p.JobNumber == pA.JobNumber).Any())
          {
            pA.Project = proj;
            await _context.PDFList.AddAsync(pA);
          }
        }

        //Delete Reports
        foreach (var pE in pdfExists)
        {
          if (!pdfAdd.Where(p => p.Type == pE.Type && p.JobNumber == pE.JobNumber).Any())
          {
            //Delete connected drawings by ListID
            var drwDel = await _context.Drawings.Where(d => d.List == pE).ToListAsync();
            foreach (var dD in drwDel) { _context.Drawings.Remove(dD); }

            _context.PDFList.Remove(pE);
          }
        }

        await _context.SaveChangesAsync();
      }
      catch (Exception e)
      {
        await setProjError(proj, "Reports Error: " + e.Message);
        sendEmail(proj, proj.ProjectNo + " process Error", proj.ProjectNo + " processing as failed because<br /><br />Reports Error: " + e.Message);
        return BadRequest("Reports Error: " + e.Message);
      }

      //Process Drawings
      var drwPath = _config["ProjectStore"] + "/" + projectNo + "/dataDrw.json";
      if (!System.IO.File.Exists(drwPath))
      {
        await setProjError(proj, "Drawing File " + drwPath + " not found");
        sendEmail(proj, proj.ProjectNo + " process Error", proj.ProjectNo + " processing as failed because<br /><br />Drawing File " + drwPath + " not found");
        return BadRequest("Drawing File " + drwPath + " not found");
      }

      try
      {
        var drwFile = await System.IO.File.ReadAllTextAsync(drwPath);
        var drwAdd = JsonSerializer.Deserialize<List<Drawing>>(drwFile);
        if (drwAdd != null)
        {

          //Fetch Existing Data        
          var pdfExists = await _context.PDFList.Where(x => x.Project == proj).ToListAsync();
          var drwExists = await _context.Drawings.Where(x => x.Project == proj).ToListAsync();

          //Add or Update
          foreach (var dA in drwAdd)
          {
            var dB = drwExists.Where(d => d.DrawNo == dA.DrawNo && d.Parent == dA.Parent && d.Job == dA.Job && d.Suffix == dA.Suffix && d.ListStr == dA.ListStr).SingleOrDefault();
            if (EqualityComparer<Drawing>.Default.Equals(dB, default(Drawing)))
            {
              dA.Project = proj;
              dA.UpdateDateTime = DateTime.Now;
              var pE = pdfExists.Where(p => p.Type + " - " + p.JobNumber == dA.ListStr).SingleOrDefault();
              if (!EqualityComparer<PDFList>.Default.Equals(pE, default(PDFList))) { dA.List = pE; }
              await _context.Drawings.AddAsync(dA);
            }
            else
            {
              dB.DrawTitle = dA.DrawTitle;
              _context.Entry(dB).State = EntityState.Modified;
            }
          }

          //Delete
          foreach (var dE in drwExists)
          {
            var dB = drwAdd.Where(d => d.DrawNo == dE.DrawNo && d.Parent == dE.Parent && d.Job == dE.Job && d.Suffix == dE.Suffix && d.ListStr == dE.ListStr).Any();
            if (!dB) { _context.Drawings.Remove(dE); }
          }

          await _context.SaveChangesAsync();
        }
      }
      catch (Exception e)
      {
        await setProjError(proj, "Drawings Error: " + e.Message);
        sendEmail(proj, proj.ProjectNo + " process Error", proj.ProjectNo + " processing as failed because<br /><br />Drawings Error: " + e.Message);
        return BadRequest("Drawings Error: " + e.Message);
      }

      //Read the data from  the BOM List
      var bomPath = _config["ProjectStore"] + "/" + projectNo + "/dataBOM.json";
      if (System.IO.File.Exists(bomPath))
      {
        try
        {
          //Get BOM from File
          var bomData = await System.IO.File.ReadAllTextAsync(bomPath);
          var bomAdd = JsonSerializer.Deserialize<List<BillofMaterial>>(bomData);
          if (bomAdd != null)
          {

            //Get Existing BOM from DB
            var bomExists = await _context.BOM.Where(x => x.Project == proj).ToListAsync();

            //Add or Update
            foreach (var bA in bomAdd)
            {
              var bE = bomExists.Where(b => b.JobNumber == bA.JobNumber && b.Suffix == bA.Suffix && b.Parent == bA.Parent && b.Child == bA.Child && b.SeqNo == bA.SeqNo && b.WC == bA.WC).SingleOrDefault();
              if (EqualityComparer<BillofMaterial>.Default.Equals(bE, default(BillofMaterial)))
              {
                bA.Project = proj;
                await _context.BOM.AddAsync(bA);
              }
              else
              {
                bE.Qty = bA.Qty;
                bE.UM = bA.UM;
                bE.ChildDesc = bA.ChildDesc;
                bE.Picklist = bA.Picklist;
                bE.PQty = bA.PQty;
                bE.PLoc = bA.PLoc;
                _context.Entry(bE).State = EntityState.Modified;
              }
            }

            //Delete
            foreach (var bE in bomExists)
            {
              var bB = bomAdd.Where(b => b.JobNumber == bE.JobNumber && b.Suffix == bE.Suffix && b.Parent == bE.Parent && b.Child == bE.Child && b.SeqNo == bE.SeqNo && b.WC == bE.WC).Any();
              if (!bB) { _context.BOM.Remove(bE); }
            }

            await _context.SaveChangesAsync();
          }
        }
        catch (Exception e)
        {
          await setProjError(proj, "BOM Error: " + e.Message);
          sendEmail(proj, proj.ProjectNo + " process Error", proj.ProjectNo + " processing as failed because<br /><br />BOM Error: " + e.Message);
          return BadRequest("BOM Error: " + e.Message);
        }
      }

      //Get the Project Name from the ProjectName File
      var projNamePath = _config["ProjectStore"] + "/" + projectNo + "/ProjectName.txt";
      var projName = "";
      if (System.IO.File.Exists(projNamePath))
      {
        projName = await System.IO.File.ReadAllTextAsync(projNamePath);
      }

      //Mark the Project Pull as Complete
      proj.ProjectName = projName;
      proj.State = "ready";
      proj.UpdateDateTime = DateTime.Now;
      _context.Entry(proj).State = EntityState.Modified;

      await _context.SaveChangesAsync();

      //Send the completion email
      sendEmail(proj, proj.ProjectNo + " complete processing", proj.ProjectNo + " has completed processing and is ready to be used.");

      return Ok("Data Add Complete");
    }

    /**
     * Function to set the project error on processing
     **/
    private async Task setProjError(Project proj, string error)
    {
      proj.ProjectName = error;
      proj.State = "error";
      _context.Entry(proj).State = EntityState.Modified;
      await _context.SaveChangesAsync();
    }

    /**
     * Function to send emails on process success or failure
     **/
    private void sendEmail(Project proj, string subject, string body)
    {
      //Send email on completion
      try
      {
        if (proj.Notify != "")
        {
          var smtpClient = new SmtpClient("smtp.dovercorporation.com") { Port = 25 };
          var mailBody = body + "<br /><br /><em>MAAG TechDoc</em>";
          var mailMessage = new MailMessage
          {
            From = new MailAddress("maag.egr.techdocs@maag.com"),
            Subject = subject,
            Body = mailBody,
            IsBodyHtml = true,
          };
          mailMessage.To.Add(proj.Notify);

          smtpClient.Send(mailMessage);
        }
      }
      catch
      {
        //Nothing required to be done here. Just adding it in if the send email fails
      }
    }

    /**
     * Move the project to archive.
     *
     * Deletes the project artefacts and moves the project to archive state
     *
     * @param ProjNoDto projDto
     **/
    [Authorize(Policy = "ForAdmin")]
    [HttpPost("archive")]
    public async Task<ActionResult> ArchiveProject(ProjNoDto projDto)
    {

      var projectNo = projDto.projectNo;

      //Get the ProjectID
      var proj = await _context.Projects.SingleOrDefaultAsync(x => x.ProjectNo.ToLower() == projectNo.ToLower());
      if (EqualityComparer<Project>.Default.Equals(proj, default(Project)))
      {
        return BadRequest("Could not find project");
      }

      if (!System.IO.Directory.Exists(_config["ProjectStore"] + "/" + projectNo))
      {
        return BadRequest("Folder does not exist");
      }

      //Delete the project Directory
      Directory.Delete(_config["ProjectStore"] + "/" + projectNo, true);

      //Move the state to archived
      proj.State = "archived";
      _context.Entry(proj).State = EntityState.Modified;
      await _context.SaveChangesAsync();

      return Ok("Project Archived");
    }

    /**
     * Changes the project state from the backend queue
     **/
    [AllowAnonymous]
    [HttpPost("changestate")]
    public async Task<ActionResult> ChangeProjectState([FromForm] string ProjectNo, [FromForm] string state, [FromForm] string message)
    {

      //Validate that the state is correct
      if (state != "update" && state != "ready" && state != "inprogress" && state != "error" && state != "closed" && state != "deleted")
      {
        return BadRequest("State is not correct");
      }

      //Get the Project
      var proj = await _context.Projects.SingleOrDefaultAsync(x => x.ProjectNo == ProjectNo);
      if (EqualityComparer<Project>.Default.Equals(proj, default(Project)))
      {
        return BadRequest("Could not find project");
      }

      //If the state is update then update the submitted by as well
      if (state == "update")
      {
        proj.SubmittedBy = User.FindFirst(ClaimTypes.Name)?.Value;
        proj.SubmittedDateTime = DateTime.Now;
      }

      //Make changes
      proj.State = state;
      if (message != "" && message != null) { proj.ProjectName = message; }
      _context.Entry(proj).State = EntityState.Modified;

      await _context.SaveChangesAsync();

      return Ok("State changed successfully.");
    }

    /**
     * Gets the current project state
     *
     * Used by the backend queue to check the state before processing
     *
     * @param string projectNo
     * @return string Project State
     **/
    [AllowAnonymous]
    [HttpGet("getstate/{projectNo}")]
    public async Task<ActionResult> GetProjectState(string projectNo)
    {
      //Get the Project
      var proj = await _context.Projects.SingleOrDefaultAsync(x => x.ProjectNo == projectNo);
      if (EqualityComparer<Project>.Default.Equals(proj, default(Project)))
      {
        return BadRequest("Could not find project");
      }

      return Ok(proj.State);
    }

    /**
     * Gets the project process list, for use by backend queue
     *
     * @return json
     **/
    [AllowAnonymous]
    [HttpGet("processlist")]
    public async Task<ActionResult> ProjectProcessList()
    {
      Dictionary<string, List<string>> drwDict = new Dictionary<string, List<string>>();
      Dictionary<string, string> drwDictFinal = new Dictionary<string, string>();

      //Get InProgress Projects
      var projInp = await _context.Projects
          .Where(p => p.State == "inprogress" || p.State == "new" || p.State == "update")
          .Select(p => p.ProjectNo)
          .ToListAsync();

      //Get the Drawings that need to be updated
      var drwUpdate = await _context.Drawings
          .Include(d => d.Project)
          .Where(d => d.toUpdate == 1 || d.toUpdate == 2).ToListAsync();

      foreach (Drawing drw in drwUpdate)
      {
        if (drwDict.ContainsKey(drw.Project.ProjectNo))
        {
          drwDict[drw.Project.ProjectNo].Add(drw.DrawNo);
        }
        else
        {
          var tmpList = new List<String>();
          tmpList.Add(drw.DrawNo);
          drwDict.Add(drw.Project.ProjectNo, tmpList);
        }
      }

      foreach (KeyValuePair<string, List<string>> el in drwDict)
      {
        drwDictFinal.Add(el.Key, string.Join(",", el.Value));
      }

      //Output
      var outList = new
      {
        Projects = projInp,
        Drawings = drwDictFinal
      };

      //Store the last accessed time in Params
      var lastUpdate = await _context.Params.SingleOrDefaultAsync(u => u.Name == "queue_checkin");
      if (EqualityComparer<Params>.Default.Equals(lastUpdate, default(Params)))
      { //Add
        var param = new Params
        {
          Name = "queue_checkin",
          Value = DateTime.Now.ToString()
        };
        await _context.Params.AddAsync(param);
      }
      else
      { //Update
        lastUpdate.Value = DateTime.Now.ToString();
        _context.Entry(lastUpdate).State = EntityState.Modified;
      }
      await _context.SaveChangesAsync();

      return Ok(outList);
    }

  }
}