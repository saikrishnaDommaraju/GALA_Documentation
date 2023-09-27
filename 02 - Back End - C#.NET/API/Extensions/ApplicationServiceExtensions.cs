using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using API.Data;
using API.Interfaces;
using API.Services;
using DinkToPdf;
using DinkToPdf.Contracts;
using Microsoft.EntityFrameworkCore;

namespace API.Extensions
{
  public static class ApplicationServiceExtensions
  {
    public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration config)
    {
      services.AddSingleton(typeof(IConverter), new SynchronizedConverter(new PdfTools()));

      services.AddScoped<ITokenService, TokenService>();

      services.AddTransient<IDocumentService, DocumentService>();

      services.AddDbContext<DataContext>(options =>
      {
       // options.UseSqlite(config.GetConnectionString("SqLiteConnection"));
        options.UseSqlServer(config.GetConnectionString("SqlServerConnection"));
      });

      return services;
    }
  }
}