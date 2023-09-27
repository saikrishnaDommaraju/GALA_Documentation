namespace API.Entities
{
  public class Project
  {
    public int Id { get; set; }
    public string ProjectNo { get; set; }
    public string ProjectName { get; set; }
    public string State { get; set; }
    public string Checklist { get; set; }
    public bool isDeleted { get; set; }
    public string Notes { get; set; }
    public string Notify { get; set; }
    public string MechEng { get; set; }
    public string ElecEng { get; set; }
    public string SubmittedBy { get; set; }
    public DateTime SubmittedDateTime { get; set; }
    public DateTime UpdateDateTime { get; set; }
  }
}