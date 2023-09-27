using System.Text.Json;
using API.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace API.Data
{
  public class Seed
  {
    public static async Task SeedData(DataContext context, UserManager<AppUser> userManager, RoleManager<AppRole> roleManager)
    {
      if (!await userManager.Users.AnyAsync())
      {

        //Create a List of Roles
        var roles = new List<AppRole>
        { new AppRole{Name = "Admin"} };

        //Add the Roles to the Database
        foreach (var role in roles)
        {
          await roleManager.CreateAsync(role);
        }

        //Create Users
        var sudeep = new AppUser
        {
          UserName = "sudeep",
          Name = "Sudeep DSouza",
          Email = "c-sdsouza@dovercorp.com"
        };
        await userManager.CreateAsync(sudeep, "Pa$$w0rd");
        await userManager.AddToRoleAsync(sudeep, "Admin");

        var don = new AppUser
        {
          UserName = "don",
          Name = "Don Adams",
          Email = "don.adams@maag.com"
        };
        await userManager.CreateAsync(don, "Pa$$w0rd");
        await userManager.AddToRoleAsync(don, "Admin");
      }

      //Add in the WorkCenters if they do not exist
      if (!await context.WorkCenters.AnyAsync())
      {
        var wcData = await System.IO.File.ReadAllTextAsync("Data\\wc.json");
        var wcList = JsonSerializer.Deserialize<List<WcList>>(wcData);
        foreach (var wc in wcList)
        {
          await context.WorkCenters.AddAsync(wc);
        }
        await context.SaveChangesAsync();
      }

      //Add in the Checksheets if they do not exist
      if (File.Exists("Data\\Checklist.json"))
      {
        if (!await context.Checklist.AnyAsync())
        {
          var wcData = await System.IO.File.ReadAllTextAsync("Data\\Checklist.json");
          var wcList = JsonSerializer.Deserialize<List<Checklist>>(wcData);
          foreach (var wc in wcList)
          {
            await context.Checklist.AddAsync(wc);
          }
          await context.SaveChangesAsync();
        }
      }

      //Add Default Contact info
      if (!await context.Params.AnyAsync())
      {
        var contactParam = new Params
        {
          Name = "contact",
          Value = "<strong>System Admin</strong><br /><br />Don Adams<br /><a href='mailto:don.adams@maag.com'>don.adams@maag.com</a><br />540-884-3140"
        };
        await context.Params.AddAsync(contactParam);
        await context.SaveChangesAsync();
      }
    }

  }
}