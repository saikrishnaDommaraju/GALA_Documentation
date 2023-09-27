using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using API.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace API.Data
{
  public class DataContext : IdentityDbContext<AppUser, AppRole, int, 
      IdentityUserClaim<int>, AppUserRole, IdentityUserLogin<int>, 
      IdentityRoleClaim<int>, IdentityUserToken<int>>
  {
    public DataContext(DbContextOptions options) : base(options)
    {
    }

    public DbSet<Jobs> Jobs { get; set; }
    public DbSet<Project> Projects { get; set; }
    public DbSet<PDFList> PDFList { get; set; }
    public DbSet<Drawing> Drawings { get; set; }
    public DbSet<WcList> WorkCenters { get; set; }
    public DbSet<BillofMaterial> BOM { get; set; }
    public DbSet<Checklist> Checklist { get; set; }
    public DbSet<ChecklistResponse> ChecklistResponse { get; set; }
    public DbSet<ChecklistResponseVersion> ChecklistResponseVersion { get; set; }
    public DbSet<Params> Params { get; set; }
    public DbSet<Notes> Notes { get; set; }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<AppUser>()
              .HasMany(ur => ur.UserRoles)
              .WithOne(u => u.User)
              .HasForeignKey(ur => ur.UserId)
              .IsRequired();

        builder.Entity<AppRole>()
              .HasMany(ur => ur.UserRoles)
              .WithOne(u => u.Role)
              .HasForeignKey(ur => ur.RoleId)
              .IsRequired();
              
    }

  }
}