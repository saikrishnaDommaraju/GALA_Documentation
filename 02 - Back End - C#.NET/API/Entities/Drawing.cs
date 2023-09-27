namespace API.Entities
{
    public class Drawing
    {
        public int Id { get; set; }
        public Project Project { get; set; }
        public PDFList List { get; set; }
        public string DrawNo { get; set; }
        public string DrawTitle { get; set; }
        public string Parent { get; set; }
        public string Job { get; set; }
        public int Suffix { get; set; }
        public string ListStr { get; set; }
        public int toUpdate { get; set; }
        public DateTime UpdateDateTime { get; set; }
        public bool isComplete { get; set; }
    }
}