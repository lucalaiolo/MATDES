classdef SimBenzinaio < SimulationEngine
    properties
        maxFuelQueueLength  % maximum fuelQueue length
        numServer           % number of servers (cashiers)
        arrivalRate         % Arrival rate 
        lb_server              
        ub_server           % Lower and upper bound for the service times
        lb_refuel
        ub_refuel           % Lower and upper bound for the refueling times
        laneDist            % Probability distribution that models the choice of the lane 
                            % for every car that arrives to the gas station
    end

    methods
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        function obj = SimBenzinaio(stateStruct, statStruct, extra_params)
            obj = obj@SimulationEngine(stateStruct, statStruct);
            
            obj.maxFuelQueueLength = extra_params.maxFuelQueueLength;
            obj.numServer = extra_params.numServer;
            obj.arrivalRate = extra_params.arrivalRate;
            obj.lb_server = extra_params.lb_server;
            obj.ub_server = extra_params.ub_server;
            obj.lb_refuel = extra_params.lb_refuel;
            obj.ub_refuel = extra_params.ub_refuel;
            obj.laneDist = extra_params.laneDist;

        end %end constructor


        function flag = terminationCondition(obj, numHours)
            flag = (obj.clock >= numHours);
        end

        function generateReport(~)
            % Do nothing
            % (do not print anything when running multiple repetitions)
        end


    end
end


