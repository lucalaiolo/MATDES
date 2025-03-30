classdef arrivalEvent < event
  
    methods
        function randomVar = rnd(obj)
            randomVar = exprnd(1/obj.parameters);
        end

        function manageEvent(obj, simEngine)
            if simEngine.state.numInQueue == 0
                simEngine.statistics.update('queue_length', simEngine.state.numInQueue)
                simEngine.state.numInQueue = simEngine.state.numInQueue + 1;
                % Schedule completion
                newService = serviceEvent('SERVICE', configuration.SERVICE_RATE);
                newService.clock = obj.clock + newService.rnd();
                simEngine.eventsList.Enqueue(newService);
            elseif simEngine.state.numInQueue < 10
                simEngine.statistics.update('queue_length', simEngine.state.numInQueue)
                simEngine.state.numInQueue = simEngine.state.numInQueue + 1;
            elseif simEngine.state.numInQueue <= 15
                if rand <= 0.5
                    simEngine.statistics.update('queue_length', simEngine.state.numInQueue)
                    simEngine.state.numInQueue = simEngine.state.numInQueue + 1;
                else
                    % Customer balked
                    simEngine.statistics.update('num_lost', 1);
                end
            else
                % Customer balked
                simEngine.statistics.update('num_lost', 1);
            end %end if
            % Schedule next arrival
            newArrival = arrivalEvent('ARRIVAL', configuration.ARRIVAL_RATE);
            newArrival.clock = obj.clock + newArrival.rnd();
            simEngine.eventsList.Enqueue(newArrival);
        end %end manageEvent
    end %end methods
end %end arrivalEvent definition

