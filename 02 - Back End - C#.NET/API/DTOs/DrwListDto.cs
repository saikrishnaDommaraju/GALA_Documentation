namespace API.DTOs
{
    public class DrwListDto
    {
        public int Id { get; set; }
        public string Type { get; set; }
        public string DrawNo { get; set; }
        public string DrawTitle { get; set; }
        public bool DrwExists { get; set; }
        public string Parent { get; set; }
        public string ParentType { get; set; }
        public bool ParentExists { get; set; }
        public string List { get; set; }
        public int NoteCount { get; set; }
        public int toUpdate { get; set; }
        public DateTime UpdateDateTime { get; set; }
    }
}