using System;
using System.Collections.Generic;

namespace Iot.Sensors
{
    public class Simulation
    {
        private ISensorRepository _repo;

        private Dictionary<Guid, EventGenerator> _generators = new Dictionary<Guid, EventGenerator>();

        public Simulation (ISensorRepository sensorRepository){
            _repo = sensorRepository;
        }

        public EventGenerator StartSimulation(Guid sensorId){
            EventGenerator generator;
            if(!_generators.TryGetValue(sensorId, out generator)){
                var sensor = _repo.GetById(sensorId);
                if( sensor == null )
                    throw new ArgumentException(nameof(sensorId));
                generator = new EventGenerator(sensor);
                generator.Start();
                _generators.Add(sensorId, generator);
            }
            return generator;
        }
    }
}