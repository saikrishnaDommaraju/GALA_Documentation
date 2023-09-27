namespace API.Entities
{
    public class ChecklistResponse
    {
        public int Id { get; set; }
        public Project Project { get; set; }
        public Checklist CheckList { get; set; }
        public string Response { get; set; }
    }
}