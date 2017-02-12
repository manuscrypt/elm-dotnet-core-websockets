using System;
using System.Collections.Generic;
using System.Linq;

namespace Iot.Sensors
{
    public class InMemorySensorRepository : ISensorRepository
    {
        private static List<Sensor> _sensors = new List<Sensor>();
        static InMemorySensorRepository(){
            var t = new DefaultSensorKind();
            for(int i = 0; i < 10; i ++){
                var mode = new ReportingMode(20);
                _sensors.Add(t.Create(mode));
            }
            
        }
        public IEnumerable<Sensor> GetAll()
        {
            return _sensors;
        }

        public Sensor GetById(Guid sensorId)
        {
            return _sensors.SingleOrDefault(x=>x.Id.Equals(sensorId));
        }
    }
}