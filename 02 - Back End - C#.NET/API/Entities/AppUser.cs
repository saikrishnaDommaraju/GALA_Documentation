using Microsoft.AspNetCore.Identity;

namespace API.Entities
{
    public class AppUser : IdentityUser<int>
    {
        public string Name { get; set; }
        public string UserCode { get; set; }
        public ICollection<AppUserRole> UserRoles {get; set;}
        public int isDeleted { get; set; }
    }
}