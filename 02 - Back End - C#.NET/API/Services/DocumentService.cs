using System.Text;
using System.Text.Json.Nodes;
using API.Interfaces;
using DinkToPdf;
using DinkToPdf.Contracts;

namespace API.Services
{
  public class DocumentService : IDocumentService
  {
    private readonly IConverter _converter;
    private readonly IWebHostEnvironment _webHostEnvironment;

    public DocumentService(IConverter converter, IWebHostEnvironment webHostEnvironment)
    {
      _webHostEnvironment = webHostEnvironment;
      _converter = converter;
    }

    public string GetHostEnv()
    {
      return _webHostEnvironment.WebRootPath;
    }

    public byte[] GeneratePDF(string htmlContent)
    {
      var globalSettings = new GlobalSettings
      {
        ColorMode = ColorMode.Color,
        Orientation = Orientation.Portrait,
        PaperSize = PaperKind.A4,
        Margins = new MarginSettings { Top = 10, Bottom = 18 }
      };

      var htmlFull = GenerateHTML(htmlContent);

      var objectSettings = new ObjectSettings
      {
        PagesCount = true,
        HtmlContent = htmlFull,
        WebSettings = { DefaultEncoding = "utf-8" },
        FooterSettings = { FontSize = 10, Right = "Page [page] of [toPage]", Line = true },
      };

      var htmlToPdfDocument = new HtmlToPdfDocument()
      {
        GlobalSettings = globalSettings,
        Objects = { objectSettings },
      };

      return _converter.Convert(htmlToPdfDocument);
    }

    public string GenerateHTML(string htmlContent, bool display = false)
    {
      return __HTMLHead(display) + htmlContent + __HTMLFoot();
    }

    public string FormatResponse(JsonNode ques, JsonNode resp)
    {
      if (ques["type"].ToString() == "text" ||
          ques["type"].ToString() == "dropdown" ||
          ques["type"].ToString() == "radiogroup" ||
          ques["type"].ToString() == "rating" ||
          ques["type"].ToString() == "ranking")
      {
        return @$"<span class='ans'>{resp["displayValue"].ToString()}<span><br />";
      }
      else if (ques["type"].ToString() == "checkbox")
      {
        if (ques["name"].ToString().Substring(0, 2) == "na") return "";
        return @$"<span class='ans'>{string.Join(", ", resp["displayValue"])}<span><br />";
      }
      else if (ques["type"].ToString() == "boolean")
      {
        if (resp["displayValue"].ToString() == "Yes")
        {
          return @$"<span class='ans bool_yes'>&#10004;</span><br />";
        }
        else
        {
          return @$"<span class='ans bool_no'>&#x2717;</span><br />";
        }
      }
      else if (ques["type"].ToString() == "multipletext")
      {
        var itemStr = new StringBuilder();
        JsonArray items = ques["items"].AsArray();
        itemStr.AppendLine("<ul class='mult_text_ul'>");
        for (int i = 0; i < items.Count; i++)
        {
          itemStr.Append("<li>");
          itemStr.Append(items[i]["title"] + " : ");
          if (resp!["value"]![items[i]["name"].ToString()] != null)
          {
            itemStr.Append(resp!["value"]![items[i]["name"].ToString()]);
          };
          itemStr.Append("</li>");
        }
        itemStr.AppendLine("</ul>");
        return itemStr.ToString();
      }
      else if (ques["type"].ToString() == "comment")
      {
        return @$"<span class='ans'>{resp["displayValue"].ToString().ReplaceLineEndings("<br />")}<span><br />";
      }
      else if (ques["type"].ToString() == "matrix")
      {
        JsonArray rows = ques["rows"].AsArray();
        JsonArray cols = ques["columns"].AsArray();

        StringBuilder table = new StringBuilder("<table class='tab'>");
        table.AppendLine("<tr><th></th>");
        for (int i = 0; i < cols.Count; i++)
        {
          table.Append(@$"<td>{(cols[i].ToString().TrimStart()[0] == '{' ? cols[i]["text"] : cols[i])}</td>");
        }
        table.Append("</tr>");

        for (int r = 0; r < rows.Count; r++)
        {
          table.AppendLine("<tr>");
          table.Append(@$"<td>{(rows[r].ToString().TrimStart()[0] == '{' ? rows[r]["text"] : rows[r])}</td>");
          var ans = "";
          if (resp["displayValue"].ToString() != "")
          {
            ans = resp["value"][rows[r].ToString().TrimStart()[0] == '{' ? rows[r]["value"].ToString() : rows[r].ToString()].ToString();
          }
          for (int c = 0; c < cols.Count; c++)
          {
            table.Append("<td style='text-align:center'>");
            if (ans == (cols[c].ToString().TrimStart()[0] == '{' ? cols[c]["value"].ToString() : cols[c].ToString()))
            {
              table.Append("&#10004;");
            }
            table.Append("</td>");
          }
          table.Append("</tr>");
        }

        table.AppendLine("</table>");

        //table.AppendLine(@$"<span class='ans'>{resp["displayValue"].ToString().ReplaceLineEndings("<br />")}<span>");
        return table.ToString();
      }
      else if (ques["type"].ToString() == "matrixdropdown")
      {
        JsonArray rows = ques["rows"].AsArray();
        JsonArray cols = ques["columns"].AsArray();
        JsonNode ans = resp!["value"];

        StringBuilder table = new StringBuilder("<table class='tab'>");
        table.AppendLine("<tr><th></th>");
        for (int i = 0; i < cols.Count; i++)
        {
          table.Append(@$"<td>{(cols[i]!["title"] == null ? cols[i]["name"] : cols[i]["title"])}</td>");
        }
        table.Append("</tr>");

        for (int r = 0; r < rows.Count; r++)
        {
          table.AppendLine("<tr>");
          table.Append(@$"<td>{(rows[r].ToString().TrimStart()[0] == '{' ? rows[r]["text"] : rows[r])}</td>");
          JsonNode ansR = null;
          if (ans != null)
          {
            var rName = rows[r].ToString().TrimStart()[0] == '{' ? rows[r]["value"].ToString() : rows[r].ToString();
            ansR = ans![rName];
          }
          for (int c = 0; c < cols.Count; c++)
          {
            table.Append("<td style='text-align:center'>");
            if (ansR != null)
            {
              if (ansR![cols[c]["name"].ToString()] != null)
              {
                table.Append(ansR[cols[c]["name"].ToString()]);
              }
            }
            table.Append("</td>");
          }
          table.AppendLine("</tr>");
        }
        table.AppendLine("</table>");
        return table.ToString();
      }
      else if (ques["type"].ToString() == "signaturepad")
      {
        return @$"<img src='{resp["value"].ToString()}' width='200' height='150'/><br />";
      }
      else
      {
        return "<span style='color:red'>Not Implemented<span><br />";
      }

    }

    private string __HTMLHead(bool display = false)
    {
      var titleImg = _webHostEnvironment.WebRootPath + "\\checksheet_assets\\title.jpg";
      if (display)
      {
        titleImg = "/checksheet_assets/title.jpg";
      }

      return $@"<!DOCTYPE html>
            <html lang=""en"">
            <head>
                <style>
                body{{font: 14px Arial, sans-serif;}}
                h1{{font: 20px Arial, sans-serif; text-transform: uppercase; font-weight:bold; text-align:center;}}
                h3{{font: 18px Arial, sans-serif; color:gray; text-transform: uppercase; font-weight:bold; text-align:center;}}
                .cl_ver{{font-size:12px}}
                .pageTitle{{color:gray; font-size:18px; font-weight:bold; margin-top:10px; margin-bottom:10px;}}
                .pageDesc{{font-style: oblique; margin-bottom:20px;}}
                .subtitle{{color:gray; font-size:16px; font-weight:bold; margin-top:10px; margin-bottom:10px;}}
                .l70{{float:left; width:65%; padding-right:10px;}}
                .l10{{float:left; width:12%; padding-right:10px;}}
                .clear{{clear:both}}
                .question{{font-weight:400}}
                .question_bold{{font-weight:600;}}
                .question_desc{{font-size:12px; color: #909090}}
                .no_ans{{color:red; font-style: oblique; font-size:13px;}}
                .mult_text_ul{{list-style-type: none; margin:0; padding:0}}
                .resp_user{{font-size:11px; font-style: oblique; color:rosybrown}}
                .tab {{border-collapse:collapse; page-break-inside:avoid}}
                .tab td,th{{border:1px solid #ccc; padding:3px}}
                .q_wrap{{page-break-inside:avoid; margin-top:10px}}
                .bool_yes{{font-size:16px; color:#20b2aa}}
                .bool_no{{font-size:16px; font-weight:bold; color:#ff1493}}
                </style>
            </head>
            <body>
            <img src=" + titleImg + " style='width:90%' />";
    }

    private static string __HTMLFoot()
    {
      return $@"</body></html>";
    }


  }
}