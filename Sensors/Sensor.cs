using System;

//http://www.mfg.mtu.edu/cyberman/machtool/machtool/sensors/fundamental.html
namespace Iot.Sensors
{
    public class Sensor
    {
        internal Sensor(SensorKind kind, ReportingMode reportingMode)
        {
            Id = Guid.NewGuid();
            Kind = kind;
            ReportingMode = reportingMode;
        }
        public Guid Id { get; set; }
        public SensorKind Kind {get; set;}
        public ReportingMode ReportingMode { get; set; }
    }
}