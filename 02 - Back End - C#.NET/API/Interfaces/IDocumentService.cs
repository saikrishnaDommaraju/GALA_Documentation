using System.Text.Json.Nodes;

namespace API.Interfaces
{
  public interface IDocumentService
  {
    byte[] GeneratePDF(string htmlContent);
    string GenerateHTML(string htmlContent, bool display);
    string FormatResponse(JsonNode ques, JsonNode resp);
    string GetHostEnv();
  }
}