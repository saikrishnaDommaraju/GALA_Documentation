namespace API.Entities
{
    public class BillofMaterial
    {
        public int Id { get; set; }
        public Project Project { get; set; }
        public string JobNumber { get; set; }
        public int Suffix { get; set; }
        public string Parent { get; set; }
        public string Child { get; set; }
        public string ChildDesc { get; set; }
        public int SeqNo { get; set; }
        public float Qty { get; set; }
        public string UM { get; set; }
        public string WC { get; set; }
        public bool Picklist { get; set; }
        public float PQty { get; set; }
        public string PLoc { get; set; }
        public float Picked { get; set; }
        public bool isComplete { get; set; }
    }
}