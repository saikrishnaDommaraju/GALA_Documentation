using System.ComponentModel.DataAnnotations;

namespace API.DTOs
{
    public class UserAddDto
    {
        [Required]
        public string username { get; set; }
        [Required]
        public string Name { get; set; }
        [Required]
        public string Usercode { get; set; }
        [Required]
        [EmailAddress(ErrorMessage = "Enter valid Email address")]
        public string Email { get; set; }
        [Required]
        public string Role { get; set; }
    }
}