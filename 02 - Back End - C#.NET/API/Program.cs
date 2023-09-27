using API.Extensions;
using API.Middleware;
/* - If DB migration required
using API.Data;
using API.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
*/
internal class Program
{
  private static void Main(string[] args)
  {
    //async Task - required if DB migration enabled
    
    var builder = WebApplication.CreateBuilder(args);

    // Service Container
    builder.Services.AddApplicationServices(builder.Configuration);
    builder.Services.AddControllers();
    builder.Services.AddCors(options => options.AddPolicy("MyPolicy", opt => opt.AllowAnyOrigin()));
    builder.Services.AddIdentityServices(builder.Configuration);

    // Middleware
    var app = builder.Build();

    app.UseMiddleware<ExceptionMiddleware>();
    //app.UseDeveloperExceptionPage();
    //app.UseHttpsRedirection();
    app.UseDefaultFiles();
    app.UseStaticFiles();
    app.UseRouting();

    app.UseCors(options => { options.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader(); });
    app.UseCors("MyPolicy");

    app.UseCookiePolicy(new CookiePolicyOptions
    {
      Secure = CookieSecurePolicy.Always
    });

    app.UseAuthentication();
    app.UseAuthorization();    

    #pragma warning disable ASP0014
    //Disabling the warning, without endpoint it gives an error.
    app.UseEndpoints(endpoints =>
    {
      endpoints.MapControllers();
    });
    #pragma warning restore ASP0014

    app.MapWhen(context =>
    {
      var path = context.Request.Path.Value;
      return !path.Contains(".");
    },
    spa =>
    {
      spa.Use((context, next) =>
      {
        context.Request.Path = new PathString("/index.html");
        return next();
      });
      spa.UseStaticFiles();
    });

    /*
    //Initialise Database
    //As the database is already initialised, we do not need to run this again.
    //Keeping in comments if required later
    using var scope = app.Services.CreateScope();
    var services = scope.ServiceProvider;
    try
    {
      var context = services.GetRequiredService<DataContext>();
      var userManager = services.GetRequiredService<UserManager<AppUser>>();
      var roleManager = services.GetRequiredService<RoleManager<AppRole>>();
      await context.Database.MigrateAsync();
      await Seed.SeedData(context, userManager, roleManager);
    }
    catch (Exception ex)
    {
      var logger = services.GetRequiredService<ILogger<Program>>();
      logger.LogError(ex, "An exception occured during migration");
    }*/

    app.Run();
  }
}