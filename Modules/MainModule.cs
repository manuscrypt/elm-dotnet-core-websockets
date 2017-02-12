using System.IO;
using Nancy;
namespace Iot.Modules
{
    public class HomeModule : NancyModule
    {
        public HomeModule(IRootPathProvider rootPath)
        {
            var index = Path.Combine(rootPath.GetRootPath(),"wwwroot/index.html");
            Get("/", args => Response.AsFile(index, "text/html"));
        }
    }
}
