namespace API.Entities
{
    public class Jobs
    {
        public int Id { get; set; }
        public Project Project { get; set; }
        public string Job { get; set; }
        public string Name { get; set; }
        public string State { get; set; }
    }
}