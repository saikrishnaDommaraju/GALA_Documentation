namespace API.Entities
{
  public class PDFList
  {
    public int Id { get; set; }
    public Project Project { get; set; }
    public string Type { get; set; }
    public string JobNumber { get; set; }
    //If Cut -> CutListType
    //Else -> JobNumber
    public bool isComplete { get; set; }
  }
}