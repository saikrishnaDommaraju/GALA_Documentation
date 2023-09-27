using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace API.Entities
{
    public class ChecklistResponseVersion
    {
        public int Id { get; set; }
        public Project Project { get; set; }
        public Checklist CheckList { get; set; }
        public string User { get; set; }
        public string Response { get; set; }
    }
}