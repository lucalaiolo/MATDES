classdef Payment < event
    %PAYMENT 
    %Event that models the completion of payment by a driver    
    properties
        lane
        idx_car
        idx_server
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        function obj = Payment(label, parameters, clock, lane, idx_car, idx_server)
            obj = obj@event(label, parameters, clock);
            obj.lane  = lane;
            obj.idx_car = idx_car;
            obj.idx_server = idx_server;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function to generate random variables
        function randomVar = rnd(obj)
            randomVar = obj.clock + unifrnd(obj.parameters(1), obj.parameters(2)); 
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function to manage the event
        function manageEvent(obj, simEngine)
            
            % Update the statistic that keeps track of the average length
            % of the queue
            Q = cellfun(@length, simEngine.state.serverQueue);
            simEngine.stats.update('averageServerQueueLength', Q);
            
            if Q(obj.idx_server) == 1
                % The server gets idle
                simEngine.stats.update('averageServerIdlensess', double(Q == 0))
            end
            
            % Update the state of the server queue
            simEngine.state.serverQueue{obj.idx_server} = ...
                simEngine.state.serverQueue{obj.idx_server}(2:end);
            
            % Check whether the car can leave the system and rearrange the
            % layout accordingly
            myLane = simEngine.state.layout(obj.lane, :);
            myLane(obj.idx_car) = -1;
            [myLane, ~] = rearrangeLane(myLane);
            simEngine.state.layout(obj.lane, :) = myLane;

            % Check whether new cars can start refueling after having
            % updated the layout. If this is the case, schedule the
            % corresponding events too
            fillFromQueue(simEngine);

            if ~isempty(simEngine.state.serverQueue{obj.idx_server})
                tmp = simEngine.state.serverQueue{obj.idx_server}{1};
                new_lane = tmp(1);
                new_idx_car = tmp(2);
                payEv = Payment('Payment', ...
                    [simEngine.lb_server, simEngine.ub_server], obj.clock, ...
                    new_lane, new_idx_car, obj.idx_server);
                payEv.clock = payEv.rnd();
                simEngine.eventsList.Enqueue(payEv);
            end
        end
    end %end methods
end %end classdef
