using System.Net.Mail;
using System.Security.Claims;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using System.Text.RegularExpressions;
using API.Data;
using API.DTOs;
using API.Entities;
using API.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace API.Controllers
{
  public class ChecklistController : BaseAPIController
  {
    private readonly DataContext _context;
    private readonly IDocumentService _docService;

    public ChecklistController(DataContext context, IDocumentService docService)
    {
      _docService = docService;
      _context = context;
    }

    /**
     * Provides the list of checklists
     *
     * This is used on both the Checklist page and the Project Admin page
     * For the checklist page, we check if a version bump is needed
     * For the projects, we pull the list and see if we need to provide an older answered checklist version 
     *
     * @params string ProjectNumber
     * @return json
     **/
    [Authorize(Policy = "ForAdmin")]
    [HttpGet("{projNo}")]
    public async Task<List<dynamic>> GetCheckListNames(string projNo)
    {
      var checkLists = await _context.Checklist.Where(c => c.LastIteration == true).OrderBy(c => c.Name).ToListAsync();
      var cList = new List<dynamic>();

      //If the project does not exist, then pull all the latest checklists
      if (projNo != "latest")
      {
        var proj = await _context.Projects.Where(p => p.Id.ToString() == projNo).SingleOrDefaultAsync();

        //If the proj does not exist, pull the latest
        if (EqualityComparer<Project>.Default.Equals(proj, default(Project)))
        {
          projNo = "latest";
        }

        //If the proj exists but does not have any checklists assigned, pull the latest
        if (String.IsNullOrEmpty(proj.Checklist))
        {
          projNo = "latest";
        }
      }

      if (projNo == "latest")
      {
        foreach (Checklist cL in checkLists)
        {
          //Check if the survey has a reponse to determine if a change in the checklist needs a version bump
          bool checklistResp = await _context.ChecklistResponse.AnyAsync(c => c.CheckList == cL);

          cList.Add(new
          {
            Id = cL.Id,
            Name = cL.Name,
            Ver = cL.Version,
            RespExists = checklistResp
          });
        }
      }
      else
      {
        //Get the checklist for the project number
        var projCL = await _context.Projects
          .Where(p => p.Id.ToString() == projNo)
          .Select(p => p.Checklist)
          .SingleOrDefaultAsync();
        var projCLArr = projCL.Split(',').ToList();
        var checklistsAssProj = await _context.Checklist.Where(c => projCLArr.Contains(c.Id.ToString())).ToListAsync();

        foreach (Checklist cL in checkLists)
        {
          //If the checklist has a project assignement, then pull the existing one.
          var clId = checklistsAssProj.Where(c => c.MainId == cL.MainId).ToList();
          var newID = cL.Id;
          var newVer = cL.Version;
          if (clId.Count > 0)
          {
            //Check if the old CL was answered, only if it was answered then use the old ID, otherwise, use the new ID
            bool checklistResp = await _context.ChecklistResponse.AnyAsync(c => c.CheckList == clId[0]);
            if (checklistResp) { newID = clId[0].Id; newVer = clId[0].Version; }
          }

          cList.Add(new
          {
            Id = newID,
            Name = cL.Name,
            Ver = newVer
          });
        }

      }

      return cList;
    }

    /**
     * Gets the checklist survey json data
     *
     * @params int checklistID
     * @return json
     **/
    [Authorize(Policy = "ForAdmin")]
    [HttpGet("survey/{id}")]
    public async Task<ActionResult> GetCheckListSurvey(int id)
    {
      var checkList = await _context.Checklist.FindAsync(id);
      if (checkList == null)
      {
        return BadRequest("Could not find Check Sheet with ID " + id);
      }

      return Ok(checkList.JsonData);
    }

    /**
     * Gets the checklist names for a project number
     *
     * @params string projectNo
     * @return json
     **/
    [Authorize]
    [HttpGet("list/{projectNo}")]
    public async Task<ActionResult<List<dynamic>>> GetCheckListNamesforProject(string projectNo)
    {
      //Get the Checklist ID's for a project
      var projCL = await _context.Projects
          .Where(p => p.ProjectNo.ToLower() == projectNo.ToLower())
          .Select(p => p.Checklist)
          .SingleOrDefaultAsync();

      //Split them to a list
      var projCLArr = projCL.Split(',').ToList();

      //Use the list to fetch the checklist information
      var checkLists = await _context.Checklist
          .Where(c => projCLArr.Contains(c.Id.ToString()))
          .OrderBy(c => c.Name)
          .ToListAsync();

      var cList = new List<dynamic>();
      foreach (Checklist cL in checkLists)
      {
        cList.Add(new
        {
          Id = cL.Id,
          Name = cL.Name,
          Ver = cL.Version
        });
      }

      return cList;
    }

    /**
     * Gets the checklist jsonData and response for a project
     *
     * @params string projectNo
     * @params string ChecklistID
     * @return json
     **/
    [Authorize]
    [HttpGet("{projNo}/{id}")]
    public async Task<ActionResult> GetCheckListData(string projNo, int id)
    {

      var proj = await _context.Projects.Where(p => p.ProjectNo.ToLower() == projNo.ToLower()).SingleOrDefaultAsync();
      if (EqualityComparer<Project>.Default.Equals(proj, default(Project)))
      {
        return BadRequest("Could not find Project");
      }

      var checkList = await _context.Checklist.FindAsync(id);
      if (checkList == null)
      {
        return BadRequest("Could not find Check Sheet with ID " + id);
      }

      //See if there are any responses
      var clResp = await _context.ChecklistResponse.Where(c => c.Project == proj && c.CheckList == checkList).SingleOrDefaultAsync();
      string clRespJson = "";
      if (!EqualityComparer<ChecklistResponse>.Default.Equals(clResp, default(ChecklistResponse)))
      {
        clRespJson = clResp.Response;
      }

      //Get the Count of the Notes
      var countNotes = await _context.Notes
           .Where(n => n.Item == "check-" + proj.ProjectNo && n.Item_Id == id)
           .CountAsync();

      var clReturn = new
      {
        Id = checkList.Id,
        Name = checkList.Name,
        Questions = checkList.JsonData,
        Response = clRespJson,
        NoteCount = countNotes
      };

      return Ok(clReturn);
    }

    /**
     * Adds a new checklist
     *
     * @params CheckListDto clDto
     * @return string Data on Success or string on Failure
     **/
    [Authorize(Policy = "ForAdmin")]
    [HttpPost]
    public async Task<ActionResult> AddCheckList(ChecklistDto clDto)
    {
      if (clDto.Id == -1)
      { //Add

        //See if we have a checklist of the same name, this prevents already entered checksheets being resubmitted.
        var cl = await _context.Checklist.SingleOrDefaultAsync(c => c.Name.ToLower() == clDto.Name.ToLower());
        if (!EqualityComparer<Checklist>.Default.Equals(cl, default(Checklist)))
        {
          return BadRequest("Checksheet with the name " + clDto.Name + " already exists. If you are looking to update it, please select it from the left menu.");
        }

        var newCl = new Checklist { Name = clDto.Name, LastIteration = true, JsonData = clDto.JsonData, Version = 1 };
        var result = await _context.AddAsync(newCl);
        await _context.SaveChangesAsync();

        newCl.MainId = newCl.Id;
        _context.Entry(newCl).State = EntityState.Modified;
        await _context.SaveChangesAsync();

        return Created("Created", new { Id = newCl.Id, Name = newCl.Name, RespExists = false, Ver = 1 });
      }
      else
      { //Update
        var cl = await _context.Checklist.SingleOrDefaultAsync(x => x.Id == clDto.Id);
        if (EqualityComparer<Checklist>.Default.Equals(cl, default(Checklist)))
        {
          return BadRequest("Could not find CheckSheet ID " + clDto.Id);
        }

        if (clDto.verChange == true)
        {
          //Change the last IterationFlag of the old CL
          cl.LastIteration = false;
          _context.Entry(cl).State = EntityState.Modified;

          //Add the New Checklist 
          var newCl = new Checklist { Name = clDto.Name, JsonData = clDto.JsonData, MainId = cl.MainId, LastIteration = true, Version = cl.Version + 1 };
          var result = await _context.AddAsync(newCl);
          await _context.SaveChangesAsync();

          //Update projects that use the old checklist to the new one
          await checklistReplace(cl.Id, newCl.Id);

          return Ok(new { Id = newCl.Id, OldId = cl.Id, Name = newCl.Name, JsonData = newCl.JsonData, RespExists = false, Ver = newCl.Id - newCl.MainId + 1, });
        }
        else
        {
          cl.Name = clDto.Name;
          cl.JsonData = clDto.JsonData;
          _context.Entry(cl).State = EntityState.Modified;
          await _context.SaveChangesAsync();

          //Check if response exists
          bool checklistResp = await _context.ChecklistResponse.AnyAsync(c => c.CheckList == cl);

          return Ok(new { Id = cl.Id, OldId = cl.Id, Name = cl.Name, JsonData = cl.JsonData, RespExists = checklistResp, Ver = cl.Id - cl.MainId + 1 });
        }

      }
    }

    /**
     * Adds a response to the checklist survey
     *
     * This function also modifies the response adding in the roles and the dates
     * to the individual questions answered. It also updates the checklist log table
     * And notifies engineers via email if coordinator_singoff is done
     *
     * @params ChecklistRespDto cResp
     * @return string Data on Success or string on Failure
     **/
    [Authorize]
    [HttpPost("response")]
    public async Task<ActionResult> submitResponse(ChecklistRespDto cResp)
    {
      var proj = await _context.Projects.Where(p => p.ProjectNo.ToLower() == cResp.ProjNo.ToLower()).SingleOrDefaultAsync();
      if (EqualityComparer<Project>.Default.Equals(proj, default(Project)))
      {
        return BadRequest("Could not find Project");
      }

      var cl = await _context.Checklist.FindAsync(cResp.Id);
      if (cl == null)
      {
        return BadRequest("Could not find Checklist");
      }

      //Get the user logged in to add in the name to response
      var user = User.FindFirst(ClaimTypes.Name)?.Value;

      //Flag to check if co-ordinator has previously signed so we dont sent the email again
      bool prev_coordinator_signoff = false;
      bool prev_all_signoff = true; //Assume this is true and if any signoff is not done, then make it false.

      //Check if this response already exists
      var clRespExist = await _context.ChecklistResponse.Where(c => c.Project == proj && c.CheckList == cl).SingleOrDefaultAsync();
      if (EqualityComparer<ChecklistResponse>.Default.Equals(clRespExist, default(ChecklistResponse)))
      {
        //Add in Users into the reponse based on the answers
        JsonNode dataNode = JsonNode.Parse(cResp.AllData);
        JsonArray dataArr = dataNode.AsArray();
        JsonNode dataAns = JsonNode.Parse(cResp.Answers);
        foreach (var q in dataAns.AsObject())
        {
          for (int i = 0; i < dataArr.Count; i++)
          {

            //WE don't want to store the role
            if (dataArr[i]["name"].ToString() == "role")
            {
              dataArr[i]["value"] = "";
              dataArr[i]["displayValue"] = "";
              dataArr[i]["data"] = "";
            }

            if (dataArr[i]["name"].ToString() == q.Key)
            {
              dataArr[i]["user"] = user;
              dataArr[i]["date"] = DateTime.Now;
            }
          }
        }

        var clRespAdd = new ChecklistResponse { Project = proj, CheckList = cl, Response = JsonSerializer.Serialize(dataArr) };
        await _context.AddAsync(clRespAdd);

        //Add in the version of the response
        var repVer = new ChecklistResponseVersion { Project = proj, CheckList = cl, User = user, Response = dataArr.ToJsonString() };
        await _context.AddAsync(repVer);

        await _context.SaveChangesAsync();
      }
      else
      {
        //Find out who replied to the previous questions
        //write their names into the user responses
        JsonNode dataNodeNew = JsonNode.Parse(cResp.AllData);
        JsonArray dataArrNew = dataNodeNew.AsArray();
        if (clRespExist.Response != "")
        {
          JsonNode dataNodePrev = JsonNode.Parse(clRespExist.Response);
          JsonArray dataArrPrev = dataNodePrev.AsArray();

          for (int i = 0; i < dataArrPrev.Count; i++)
          {
            for (int j = 0; j < dataArrNew.Count; j++)
            {

              //Clear the role data
              if (dataArrNew[j]["name"].ToString() == "role")
              {
                dataArrNew[j]["value"] = "";
                dataArrNew[j]["displayValue"] = "";
                dataArrNew[j]["data"] = "";
              }

              if (dataArrNew[j]["name"].ToString() == dataArrPrev[i]["name"].ToString())
              {

                //Copy the answer if we have a coordinator or previous answered value with an undefined new value
                if (dataArrNew[j]!["value"] == null && dataArrPrev[i]!["value"] != null)
                {
                  //If we cannot parse the value, copy it as the base string
                  try
                  {
                    dataArrNew[j]["value"] = JsonNode.Parse(dataArrPrev[i]["value"].ToString());
                  }
                  catch (Exception ex)
                  {
                    if (ex.GetType().ToString() == "System.Text.Json.JsonReaderException")
                    {
                      dataArrNew[j]["value"] = dataArrPrev[i]["value"].ToString();
                    }
                  }
                }

                //Copy the user
                if (dataArrPrev[i]!["user"] != null)
                {
                  dataArrNew[j]["user"] = dataArrPrev[i]["user"].ToString();
                  dataArrNew[j]["date"] = dataArrPrev[i]["date"].ToString();
                }

                if (dataArrPrev[i]!["value"] == null && dataArrNew[j]!["value"] != null)
                {
                  dataArrNew[j]["user"] = user;
                  dataArrNew[j]["date"] = DateTime.Now;
                }
                else if (dataArrPrev[i]!["value"] != null && dataArrNew[j]!["value"] != null && dataArrNew[j]["value"].ToJsonString() != dataArrPrev[i]["value"].ToJsonString())
                {
                  dataArrNew[j]["user"] = user;
                  dataArrNew[j]["date"] = DateTime.Now;
                }

              }
            }

            //This is inside the outer loop of dataArrPrev
            //Check if coordinator signed off previously
            if (dataArrPrev[i]["name"].ToString() == "coordinator_signoff" && dataArrPrev[i]!["value"] != null)
            {
              prev_coordinator_signoff = true;
            }

            //Check if all the signatures have been signed previously
            if (dataArrPrev[i]!["questionType"].ToString() == "signaturepad" && dataArrPrev[i]!["value"] == null)
            {
              prev_all_signoff = false;
            }

          }
        }
        else
        {
          //Put the names of the user into the questions just answered
          JsonNode dataAns = JsonNode.Parse(cResp.Answers);
          foreach (var q in dataAns.AsObject())
          {
            for (int i = 0; i < dataArrNew.Count; i++)
            {
              if (dataArrNew[i]["name"].ToString() == q.Key)
              {
                dataArrNew[i]["user"] = user;
                dataArrNew[i]["date"] = DateTime.Now;
              }
            }
          }
        }

        //Store it in the database
        clRespExist.Response = dataArrNew.ToJsonString();
        _context.Entry(clRespExist).State = EntityState.Modified;

        //Add in the version of the response
        var repVer = new ChecklistResponseVersion { Project = proj, CheckList = cl, User = user, Response = dataArrNew.ToJsonString() };
        await _context.AddAsync(repVer);

        await _context.SaveChangesAsync();
      }

      //if we need to notify the users that do so here. We check if the Coordinator Signoff has been done
      //if the signoff was earlier done, then the mail would have already been sent and we do not want to
      //   do that twice, hence this check
      if (!prev_coordinator_signoff)
      {
        JsonNode dataNodeNotif = JsonNode.Parse(cResp.AllData);
        JsonArray dataArrNotif = dataNodeNotif.AsArray();
        for (int i = 0; i < dataArrNotif.Count; i++)
        {
          if (dataArrNotif[i]["name"].ToString() == "coordinator_signoff" && dataArrNotif[i]!["value"] != null)
          {
            var toAddr = "";
            if (proj.MechEng != "" || proj.ElecEng != "")
            {
              toAddr = (proj.MechEng + "," + proj.ElecEng).TrimStart(',').TrimEnd(',');
            }
            var emailSub = proj.ProjectNo + " checklist signed by Co-ordinator";
            var emailBody = "The checklist " + cl.Name + " for Project No" + proj.ProjectNo + "has been signed by the Coordinator. <br /><br /><em>MAAG TechDoc</em>";
            NotifyEmail(toAddr, emailSub, emailBody);
          }
        }
      }

      //Check that we dont send the email again
      if (!prev_all_signoff)
      {
        JsonNode dataNodeNotif = JsonNode.Parse(cResp.AllData);
        JsonArray dataArrNotif = dataNodeNotif.AsArray();
        var all_signoff = true;
        for (int i = 0; i < dataArrNotif.Count; i++)
        {
          if (dataArrNotif[i]!["questionType"].ToString() == "signaturepad" && dataArrNotif[i]!["value"] == null)
          {
            all_signoff = false;
          }
        }

        if (all_signoff)
        {
          var toAddr = await _context.Params.Where(p => p.Name == "doc_email").Select(p => p.Value).FirstAsync();
          if (toAddr != "")
          {
            var emailSub = proj.ProjectNo + " checklist signed";
            var emailBody = "The checklist " + cl.Name + " for Project No" + proj.ProjectNo + "has been signed by all the Approvers. This marks the documentation as completed. <br /><br /><em>MAAG TechDoc</em>";
            NotifyEmail(toAddr, emailSub, emailBody);
          }
        }
      }

      return Ok("Response Submitted");
    }

    /**
     * Email to be send out
     *
     * @params string Address
     * @params string Subject
     * @params string Body
     **/
    private void NotifyEmail(string toAddr, string eSubject, string eBody)
    {
      try
      {

        var smtpClient = new SmtpClient("smtp.dovercorporation.com") { Port = 25 };

        var mailMessage = new MailMessage
        {
          From = new MailAddress("maag.egr.techdocs@maag.com"),
          Subject = eSubject,
          Body = eBody,
          IsBodyHtml = true,
        };
        mailMessage.To.Add(toAddr);

        smtpClient.Send(mailMessage);

      }
      catch
      {
        //Nothing required to be done here. Just adding it in if the send email fails
      }

    }

    /**
     * Prints the checklist to a PDF file
     *
     * @params string projNo
     * @params int id - Checklist ID
     * @params int names - Should the names be shown or not
     **/
    [AllowAnonymous]
    [HttpGet("print/{projNo}/{id}/{names}")]
    public async Task<ActionResult> GetPDFResponse(string projNo, int id, int names)
    {

      StringBuilder htmlContent = new StringBuilder();

      var proj = await _context.Projects.Where(p => p.ProjectNo.ToLower() == projNo.ToLower()).SingleOrDefaultAsync();
      if (EqualityComparer<Project>.Default.Equals(proj, default(Project)))
      {
        htmlContent.AppendLine($@"<h3>QUALITY ASSURANCE CHECKSHEET</h3><p style='color:red'>Could not find project</p>");
        var pdfFileErr = _docService.GeneratePDF(htmlContent.ToString());
        Stream streamErr = new MemoryStream(pdfFileErr);
        return new FileStreamResult(streamErr, "application/pdf");
      }

      var checkList = await _context.Checklist.FindAsync(id);
      if (checkList == null)
      {
        htmlContent.AppendLine($@"<h3>QUALITY ASSURANCE CHECKSHEET</h3><p style='color:red'>Could not find Check Sheet with ID + {id}</p>");
        var pdfFileErr = _docService.GeneratePDF(htmlContent.ToString());
        Stream streamErr = new MemoryStream(pdfFileErr);
        return new FileStreamResult(streamErr, "application/pdf");
      }

      htmlContent.Append($@"
                <h1>{checkList.Name}</h1>
                <h3>QUALITY ASSURANCE CHECKSHEET <span class='cl_ver'>v{checkList.Id - checkList.MainId + 1}</span></h3>
                <p>
                  Project No: <strong>{proj.ProjectNo}</strong>&nbsp;&nbsp;&nbsp;
                  Customer: <strong>{proj.ProjectName}</strong>
                </p>");

      //See if there are any responses
      var clResp = await _context.ChecklistResponse.Where(c => c.Project == proj && c.CheckList == checkList).SingleOrDefaultAsync();
      if (EqualityComparer<ChecklistResponse>.Default.Equals(clResp, default(ChecklistResponse)))
      {
        htmlContent.AppendLine("<p style='color:red'>No Responses Found</p>");
        var pdfFileErr = _docService.GeneratePDF(htmlContent.ToString());
        Stream streamErr = new MemoryStream(pdfFileErr);
        return new FileStreamResult(streamErr, "application/pdf");
      }

      //If we need to replace the names with the user codes then pull the user codes
      Dictionary<string, string> userCodes = new Dictionary<string, string>();
      if (names == 2)
      {
        var users = await _context.Users.ToListAsync();
        foreach (AppUser user in users)
        {
          userCodes.Add(user.UserName, user.UserCode);
        }
      }

      var clQuestions = checkList.JsonData;
      JsonNode dataNode = JsonNode.Parse(clQuestions);
      JsonNode dataResp = JsonNode.Parse(clResp.Response);
      JsonArray dataRespArr = dataResp.AsArray();

      if (dataNode!["pages"] != null)
      {
        JsonArray dataArrPages = dataNode!["pages"].AsArray();
        for (int pgCnt = 0; pgCnt < dataArrPages.Count; pgCnt++)
        {

          //Check if page should be rendered based on visibleIf
          var showPage = true;
          var visibleIf = "";
          if (dataArrPages[pgCnt]!["visibleIf"] != null)
          {
            visibleIf = dataArrPages[pgCnt]!["visibleIf"].ToString();
          }

          if (!string.IsNullOrWhiteSpace(visibleIf) && !visibleIf.Contains("role"))
          {
            Regex rx = new Regex(@"{(?<name>\w+)}\s=\s'(?<value>\w+)'", RegexOptions.IgnoreCase);
            Match m = rx.Match(visibleIf);
            if (m.Success)
            {
              JsonNode resp = findResp(m.Groups[1].Value, dataRespArr);
              var logicAns = resp["value"].ToString();
              showPage = logicAns == m.Groups[2].Value;
            }
          }

          //Skip showing the page if showPage is false
          if (!showPage) { continue; }

          //Add in the Page title
          if (dataArrPages[pgCnt]!["title"] != null)
          {
            htmlContent.AppendLine($@"<div class='pageTitle'>{dataArrPages[pgCnt]!["title"]}</div>");
            if (dataArrPages[pgCnt]!["description"] != null)
            {
              htmlContent.AppendLine($@"<div class='pageDesc'>{dataArrPages[pgCnt]!["description"]}</div>");
            }
          }

          //Add in the questions
          if (dataArrPages[pgCnt]!["elements"] != null)
          {
            JsonArray dataArrElem = dataArrPages[pgCnt]!["elements"].AsArray();
            for (int elCnt = 0; elCnt < dataArrElem.Count; elCnt++)
            {
              htmlContent.AppendLine("<div class='q_wrap'>");
              //If there are Panels, then there we need to add in the Title and the Questions inside
              if (dataArrElem[elCnt]!["type"].ToString() == "panel")
              {
                //Panel Title
                if (dataArrElem[elCnt]!["title"] != null)
                {
                  htmlContent.AppendLine($@"<div class='question l70'>{dataArrElem[elCnt]!["title"]}<br /><span class='question_desc'>{dataArrElem[elCnt]!["description"]}</span></div>");
                }
                JsonArray dataArrPanelElem = dataArrElem[elCnt]!["elements"].AsArray();

                //Loop for Booleans to put them on the right
                var qisApplicable = true;
                for (int panElCnt = 0; panElCnt < dataArrPanelElem.Count; panElCnt++)
                {
                  //Check if there is a Not Applicable question, assume all questions are applicable
                  //If not applicable, then print out the NA question and answer instead of any others following it.
                  if (dataArrPanelElem[panElCnt]!["type"].ToString() == "checkbox"
                      && dataArrPanelElem[panElCnt]!["name"].ToString().Substring(0, 2) == "na")
                  {
                    JsonNode resp = findResp(dataArrPanelElem[panElCnt]!["name"].ToString(), dataRespArr);
                    if (resp["value"] != null && resp["value"].AsArray().Count > 0)
                    {
                      htmlContent.AppendLine($@"<div class='l10'><span class='question_bold'>{dataArrPanelElem[panElCnt]!["title"]}</span>");
                      htmlContent.AppendLine(formatAnswer(dataArrPanelElem[panElCnt], resp, names, userCodes, true));
                      htmlContent.AppendLine($@"</div>");
                      qisApplicable = false;
                    }
                  }

                  if (qisApplicable && dataArrPanelElem[panElCnt]!["type"].ToString() == "boolean")
                  {
                    htmlContent.AppendLine($@"<div class='l10'><span class='question_bold'>{dataArrPanelElem[panElCnt]!["title"]}</span>");
                    JsonNode resp = findResp(dataArrPanelElem[panElCnt]!["name"].ToString(), dataRespArr);
                    if (resp != null) { htmlContent.AppendLine(formatAnswer(dataArrPanelElem[panElCnt], resp, names, userCodes, true)); }
                    htmlContent.AppendLine($@"</div>");
                  }
                }
                htmlContent.AppendLine($@"<div class='clear'></div>");

                //Loop for other non boolean answers
                if (qisApplicable)
                {
                  for (int panElCnt = 0; panElCnt < dataArrPanelElem.Count; panElCnt++)
                  {
                    if (dataArrPanelElem[panElCnt]!["type"].ToString() != "boolean" &&
                        !(dataArrPanelElem[panElCnt]!["type"].ToString() == "checkbox"
                        && dataArrPanelElem[panElCnt]!["name"].ToString().Substring(0, 2) == "na"))
                    {
                      htmlContent.AppendLine($@"<div><span class='question_bold'>{dataArrPanelElem[panElCnt]!["title"]} : </span>");
                      JsonNode resp = findResp(dataArrPanelElem[panElCnt]!["name"].ToString(), dataRespArr);
                      if (resp != null) { htmlContent.AppendLine(formatAnswer(dataArrPanelElem[panElCnt], resp, names, userCodes, false)); }
                      htmlContent.AppendLine($@"</div>");
                    }
                  }
                }
              }
              else if (dataArrElem[elCnt]!["type"].ToString() == "html")
              {
                htmlContent.AppendLine($@"<span>{dataArrElem[elCnt]!["html"]}</span>");
              }
              else if (dataArrElem[elCnt]!["type"].ToString() == "image")
              {
                htmlContent.AppendLine($@"<img src='{_docService.GetHostEnv() + dataArrElem[elCnt]!["imageLink"]}' style='width:60%'/>");
              }
              else
              {
                if (dataArrElem[elCnt]!["name"].ToString() != "role"
                      && dataArrElem[elCnt]!["name"].ToString() != "model"
                      && !(names == 0 && dataArrElem[elCnt]!["type"].ToString() == "signaturepad"))
                {
                  htmlContent.AppendLine($@"<p><span class='question_bold'>{dataArrElem[elCnt]!["title"]}</span><br />");
                  JsonNode resp = findResp(dataArrElem[elCnt]!["name"].ToString(), dataRespArr);
                  if (resp != null)
                  {
                    htmlContent.AppendLine(formatAnswer(dataArrElem[elCnt], resp, names, userCodes, false));
                  }
                  htmlContent.AppendLine("</p>");
                }
                else if (dataArrElem[elCnt]!["name"].ToString() == "model")
                {
                  JsonNode resp = findResp(dataArrElem[elCnt]!["name"].ToString(), dataRespArr);
                  htmlContent.AppendLine($@"<p><span>{dataArrElem[elCnt]!["title"]}</span>: <strong>{resp["displayValue"].ToString()}</strong>");
                }
              }
              htmlContent.AppendLine("</div>");
            }
          }
          /*if (pgCnt < dataArrPages.Count - 1)
          {
            htmlContent.AppendLine("<p style='page-break-after: always;'>&nbsp;</p>");
          }*/
        }
      }

      //var pdfFile = _docService.GenerateHTML(htmlContent.ToString(), true);
      //return base.Content(pdfFile, "text/html");

      var pdfFile = _docService.GeneratePDF(htmlContent.ToString());
      Stream stream = new MemoryStream(pdfFile);
      return new FileStreamResult(stream, "application/pdf");
    }

    /**
     * Format the answer for printing based on the type
     **/
    private string formatAnswer(JsonNode ques, JsonNode resp, int names, Dictionary<string, string> userCodes, bool isBool)
    {
      StringBuilder ansOut = new StringBuilder();

      //Answer Line
      if (resp["value"] != null)
      {
        string formatResp = _docService.FormatResponse(ques, resp);
        ansOut.AppendLine(formatResp);
      }
      else
      {
        if (isBool) { ansOut.AppendLine("<br />"); }
        ansOut.AppendLine("<span class='no_ans'>No Answer</span>");
      }

      //Date Line
      if (resp["user"] != null)
      {
        DateTime ansDate = DateTime.Parse(resp["date"].ToString(), System.Globalization.CultureInfo.InvariantCulture);
        if (names == 1)
        {
          string br = " on ";
          if (isBool) { br = "<br />"; }
          ansOut.AppendLine($@"<span class='resp_user'>{resp["user"]}{br}{ansDate.ToString("MM/dd/y HH:mm")}</span>");
        }
        else if (names == 2)
        {
          string br = " on ";
          if (isBool) { br = "<br />"; }
          ansOut.AppendLine($@"<span class='resp_user'>{userCodes[resp["user"].ToString()]}{br}{ansDate.ToString("MM/dd/y HH:mm")}</span>");
        }
        else
        {
          ansOut.AppendLine($@"<span class='resp_user'>{ansDate.ToString("MM/dd/y HH:mm")}</span>");
        }
      }

      return ansOut.ToString();
    }

    private JsonNode findResp(string qName, JsonArray jsonArr)
    {
      for (int i = 0; i < jsonArr.Count; i++)
      {
        if (jsonArr[i]!["name"].ToString() == qName)
        {
          return jsonArr[i];
        }
      }

      return null;
    }

    /**
     * Not used in the program, but kept to backup the checksheets
     * to a file, just in case we need to. Otherwise if the DB is refreshed
     * we lose the checksheets, which is a pain to recreate.
     **/
    [AllowAnonymous]
    [HttpGet("backup")]
    public async Task BackUpChecksheets()
    {
      var checkLists = await _context.Checklist.ToListAsync();
      string stor = JsonSerializer.Serialize(checkLists);
      await System.IO.File.WriteAllTextAsync("Data\\Checklist.json", stor);
    }

    private async Task checklistReplace(int oldId, int newId)
    {
      var projects = await _context.Projects.Where(p => p.State != "error" && p.State != "closed" && !String.IsNullOrEmpty(p.Checklist)).ToListAsync();
      foreach (Project proj in projects)
      {
        var cl = proj.Checklist.Split(',').ToList();
        if (cl.Contains(oldId.ToString()))
        {
          //Check if response exists
          var cList = await _context.Checklist.FindAsync(oldId);
          bool checklistResp = await _context.ChecklistResponse.AnyAsync(c => c.Project == proj && c.CheckList == cList);

          if (!checklistResp)
          {
            cl.Remove(oldId.ToString());
            cl.Add(newId.ToString());
            proj.Checklist = String.Join(',', cl);
            _context.Entry(proj).State = EntityState.Modified;
          }
        }
      }
      await _context.SaveChangesAsync();
    }

  }
}