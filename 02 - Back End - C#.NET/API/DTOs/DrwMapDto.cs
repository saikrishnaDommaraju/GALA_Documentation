namespace API.DTOs
{
    public class DrwMapDto
    {
        public DrwListDto Parent { get; set; }
        public List<BomListDto> Children { get; set; }
    }
}