classdef MM1_balking_sim < SimulationEngine

    methods

        function flag = terminationCondition(obj, stoppingParameters)
            % In this case, stoppingParameters will be a double (how many
            % customers we want to serve)
            flag = (obj.statistics.counters.num_served.count >= stoppingParameters);
        end

    end

end

