using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.WebSockets;
using System.Reactive.Linq;
using System.Text;
using System.Threading.Tasks;
using Iot.Middleware;
using Iot.Sensors;
using Microsoft.Extensions.Logging;

namespace Iot.Handlers
{
    public class SensorMessageSocketHandler : WebSocketHandler
    {
        private readonly Simulation _simulation;
        public Sensor Sensor { get; set; }
        private readonly Dictionary<string, IDisposable> _subscriptions =
            new Dictionary<string, IDisposable>();
        private ILogger<SensorMessageSocketHandler> _logger;

        public SensorMessageSocketHandler(WebSocketConnectionManager webSocketConnectionManager,
            Simulation simulation, ILoggerFactory loggerFactory ) : base(webSocketConnectionManager)
        {
            _simulation = simulation;
            _logger = loggerFactory.CreateLogger<SensorMessageSocketHandler>();
        }
        public override async Task OnConnected(WebSocket socket)
        {
            await base.OnConnected(socket);

            var socketId = WebSocketConnectionManager.GetId(socket);
            var generator = _simulation.StartSimulation(Sensor.Id);
            var newSub = generator.EventStream.
                Select(ev=> ev.Value.ToString())
                .Subscribe(async s=> await SendValue(socket,s));
            _subscriptions.Add(socketId, newSub);
        }
        private async Task SendValue (WebSocket socket, String value){
            try{
                await SendMessageAsync(socket, value);
            }catch(Exception ex){
                _logger.LogError(ex.Message, ex);
            }
        }
        public override Task OnDisconnected(WebSocket socket){
            var socketId = WebSocketConnectionManager.GetId(socket);
            IDisposable sub;
            if(_subscriptions.TryGetValue(socketId, out sub)){
                sub.Dispose();
            }
            return Task.CompletedTask;
        }
        public override Task ReceiveAsync(WebSocket socket, WebSocketReceiveResult result, byte[] buffer)
        {
            var inc = Encoding.UTF8.GetString(buffer, 0, result.Count);
            return Task.CompletedTask;
        }

    }
}