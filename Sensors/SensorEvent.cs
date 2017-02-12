using System;

namespace Iot.Sensors
{
    public class SensorEvent
    {
        private Sensor _sensor;
        public SensorEvent(Sensor sensor, float value ){
            _sensor = sensor;
            Value = value;
        }
        public DateTimeOffset OccurredDate { get; set; }
        public DateTimeOffset RecordedDate { get; set; }
        public float Value { get; set; }

        public string SensorId => _sensor.Id.ToString();
    }
}