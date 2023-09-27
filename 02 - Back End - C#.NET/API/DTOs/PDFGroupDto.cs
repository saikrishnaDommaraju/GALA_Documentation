namespace API.DTOs
{
    public class PDFGroupDto
    {
        public string Type { get; set; }
        public string Name { get; set; }
        public int Order { get; set; }
        public List<PDFListDto> PDFList { get; set; }
    }
}