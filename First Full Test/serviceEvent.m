classdef serviceEvent < event
  
    methods        
        function randomVar = rnd(obj)
            randomVar = exprnd(1/obj.parameters);
        end

        function manageEvent(obj, simEngine)
            simEngine.statistics.update('num_served', 1)
            simEngine.statistics.update('queue_length', simEngine.state.numInQueue)
            if simEngine.state.numInQueue == 1
                simEngine.state.numInQueue = 0;
            else
                simEngine.state.numInQueue = simEngine.state.numInQueue - 1;
                % Schedule next service event
                newService = serviceEvent('SERVICE', configuration.SERVICE_RATE);
                newService.clock = obj.clock + newService.rnd();
                simEngine.eventsList.Enqueue(newService);
            end
        end
    end %end methods
end %end class serviceEvent definition


