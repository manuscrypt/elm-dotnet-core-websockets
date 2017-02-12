using System;
using System.Reactive.Linq;

namespace Iot.Sensors
{
    public class EventGenerator
    {
        public static Random Rnd = new Random((int)DateTime.Now.Ticks);
        private Sensor sensor;

        public EventGenerator(Sensor sensor)
        {
            this.sensor = sensor;
        }

        public IObservable<SensorEvent> EventStream { get; private set; }

        internal void Start()
        {
            double interval = 1.0f / sensor.ReportingMode.Frequency;
            EventStream = Observable.Interval(TimeSpan.FromSeconds(interval))
                .Select(ToEvent);
        }
        private SensorEvent ToEvent(long ts){
            return new SensorEvent(this.sensor, (float)Rnd.NextDouble());
        }
    }
}