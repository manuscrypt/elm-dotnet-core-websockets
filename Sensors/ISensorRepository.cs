using System;
using System.Collections.Generic;

namespace Iot.Sensors
{
    public interface ISensorRepository
    {
        IEnumerable<Sensor> GetAll();
        Sensor GetById(Guid sensorId);
    }
}