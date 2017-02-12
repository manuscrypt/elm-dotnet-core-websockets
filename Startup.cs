using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Builder;
using System;
using Microsoft.Extensions.DependencyInjection;
using Nancy.Owin;
using Iot.Handlers;
using Iot.Middleware;
using System.Threading.Tasks;
using Iot.Sensors;
using System.Linq;

namespace Iot
{
    public class Startup
    {
        public Startup()
        {

        }

        public void ConfigureServices(IServiceCollection services)
        {
            services.AddSingleton<ISensorRepository, InMemorySensorRepository>();
            services.AddSingleton<Simulation>();
            services.AddWebSocketManager();
        }
        public void Configure(IApplicationBuilder app, IHostingEnvironment env, ILoggerFactory loggerFactory,
            IServiceProvider serviceProvider, ISensorRepository repo)
        {
            // loggerFactory
            //     .AddConsole()
            //     .AddDebug();
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            app.UseStaticFiles();
            app.UseWebSockets();
            app.MapWebSocketManager("/chat", serviceProvider.GetService<ChatMessageSocketHandler>());
            //app.MapWebSocketManager("/sensor", serviceProvider.GetService<SensorMessageSocketHandler>());

            repo.GetAll().ToList().ForEach(s => {
                var handler = serviceProvider.GetService<SensorMessageSocketHandler>();
                handler.Sensor = s;
                app.MapWebSocketManager("/sensor/" + s.Id.ToString(), handler);
            });
            app.UseOwin(x => x.UseNancy());
            app.Use(async (http, next) =>
            {
                http.Response.Redirect($"http://{http.Request.Host}");
                await Task.CompletedTask;
            });
        }
    }
}
