using Nancy;

namespace Iot.Sensors
{
    public class SensorModule : NancyModule
    {
        public ISensorRepository Sensors { get; set; }
        public SensorModule(ISensorRepository sensors)
        {
            Sensors = sensors;
            Get("/sensors", _ => Response.AsJson(Sensors.GetAll()));
        }
    }
}