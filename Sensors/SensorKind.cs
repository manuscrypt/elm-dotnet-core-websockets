namespace Iot.Sensors
{
    public abstract class SensorKind{
        public string Name { get; set; }
        protected SensorKind(string name){
            Name = name;
        }
        public Sensor Create(ReportingMode mode){
            return new Sensor(this, mode);
        }
    }
}