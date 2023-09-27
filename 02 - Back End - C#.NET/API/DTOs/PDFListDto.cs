namespace API.DTOs
{
    public class PDFListDto
    {
        public int Id { get; set; }        
        public string Type { get; set; }
        //Cut, Fab, Weld, Asm
        public string Name { get; set; }
        public string JobNumber { get; set; }
        //If Cut -> CutListType
        //If Fab or Weld -> JobNumber
        public string JobState { get; set; }
        public string JobName { get; set; }
        public int NoteCount { get; set; }
        public int Order { get; set; }
        public bool isComplete { get; set; }
    }
}