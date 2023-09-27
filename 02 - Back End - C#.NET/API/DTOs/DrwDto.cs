namespace API.DTOs
{
    public class DrwDto
    {
        public int Id { get; set; }
        public string DrawNo { get; set; }
        public string DrawTitle { get; set; }
        public int Suffix { get; set; }
        public bool isComplete { get; set; }
    }
}