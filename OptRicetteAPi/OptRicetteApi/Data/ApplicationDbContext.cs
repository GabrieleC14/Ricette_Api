using Microsoft.EntityFrameworkCore;
using OptimaRicetteWS.Models;
using System.Collections.Generic;

namespace OptimaRicetteWS.Data
{


    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options) { }

        public DbSet<Ricette> ricette { get; set; }
        public DbSet<Utenti> utenti { get; set; }
        public DbSet<RicettaTag> ricetteTag { get; set; }
        public DbSet<TagTestata> tagTestate { get; set; }
        public DbSet<TagDettaglio> tagDettagli { get; set; }

      //  public DbSet<InserisciApportoRequest> apportocalorico { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Mappatura esplicita alla tabella SQL "ricette_tag"
            modelBuilder.Entity<RicettaTag>().ToTable("ricette_tag");

            modelBuilder.Entity<RicettaTag>()
                .HasKey(rt => new { rt.IdRicetta, rt.IdTagDettaglio });

            modelBuilder.Entity<RicettaTag>()
                .HasOne<Ricette>()
                .WithMany(r => r.RicettaTag)
                .HasForeignKey(rt => rt.IdRicetta);
        }


    }



}

