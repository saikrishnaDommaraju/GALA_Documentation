using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace API.DTOs
{
    public class ChecklistRespDto
    {
        public int Id { get; set; }
        public string ProjNo { get; set; }
        public string AllData { get; set; }
        public string Answers { get; set; }
    }
}