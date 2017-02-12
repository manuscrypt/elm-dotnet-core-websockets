using Nancy;
using Nancy.Conventions;

namespace iot
{
    public class Bootstrapper : DefaultNancyBootstrapper
    {
        protected override IRootPathProvider RootPathProvider
        {
            get { return new CustomRootPathProvider(); }
        }
        protected override void ConfigureConventions(NancyConventions nancyConventions)
        {
            nancyConventions.StaticContentsConventions.Add(StaticContentConventionBuilder.AddDirectory("wwwroot", "Content"));
            base.ConfigureConventions(nancyConventions);
        }
    }
    public class CustomRootPathProvider : IRootPathProvider
    {
        public string GetRootPath()
        {
            return "/home/mb/projects/iot";
        }
    }
}