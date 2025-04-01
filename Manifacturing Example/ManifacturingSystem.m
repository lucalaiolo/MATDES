classdef ManifacturingSystem < SimulationEngine
    properties
        cost = 0
        breakdownRate = 8
        repairRate = 2
    end

    methods
        
        function flag = terminationCondition(obj, numHours)
            flag = (obj.clock >= numHours);
        end

        function initEventsList(obj, numMachines)
            % Schedule the breakdowns for all the machines
            for i=1:numMachines
                breakdown_event = Breakdown('BREAKDOWN', 1/obj.breakdownRate);
                breakdown_event.clock = breakdown_event.rnd();
                obj.eventsList.Enqueue(breakdown_event);
            end
        end

        function generateReport(~)
            % Do nothing
            % (do not print anything when running multiple repetitions)
        end

    end
end

