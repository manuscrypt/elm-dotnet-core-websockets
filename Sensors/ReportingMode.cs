namespace Iot.Sensors
{
    public class ReportingMode
    {
        public ReportingMode(int freq){
            Frequency = freq;
        }
        public int Frequency { get; set; }
    }
}