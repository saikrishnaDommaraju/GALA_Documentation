namespace API.Entities
{
    public class Checklist
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string JsonData { get; set; }
        public int MainId { get; set; }
        public bool LastIteration { get; set; }
        public int Version { get; set; }
    }
}