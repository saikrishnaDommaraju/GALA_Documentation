using Microsoft.AspNetCore.Identity;

namespace API.Entities
{
    public class AppRole : IdentityRole<int>
    {
        public ICollection<AppUserRole> UserRoles { get; set; }
        public string ListItems { get; set; }
        public bool ReadOnly { get; set; }
    }
}