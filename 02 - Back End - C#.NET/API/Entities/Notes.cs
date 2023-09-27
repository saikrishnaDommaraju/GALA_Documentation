namespace API.Entities
{
  public class Notes
  {
    public int Id { get; set; }
    public Project Project { get; set; }
    public string Item { get; set; }
    public int Item_Id { get; set; }
    public string Note { get; set; }
    public string User { get; set; }
    public DateTime CreatedDateTime { get; set; }
  }
}