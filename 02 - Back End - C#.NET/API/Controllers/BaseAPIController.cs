using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
  /**
   * The base API Controller class that is inherited by 
   * all the other classes in the application
   **/
  [ApiController]
    [Route("api/[controller]")]
    public class BaseAPIController : ControllerBase
    {
        
    }
}