using System;

namespace Iot.Handlers
{
    internal class SensorSubscription{
        public String SocketId { get; set; }
        public Guid SensorId { get; set; }
        public IDisposable SubscriptionObject { get; set; }
    }
}