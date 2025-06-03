classdef Refueling < event
    %REFUELING 
    %Event that models the completion of a car’s refueling
    properties
        lane
        idx
    end

    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        function obj = Refueling(label, parameters, clock, lane, idx)
            obj = obj@event(label, parameters, clock);

            obj.lane = lane;
            obj.idx = idx;
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function to generate random variables
        function randomVar = rnd(obj)
            randomVar = obj.clock + unifrnd(obj.parameters(1), obj.parameters(2)); 
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function to manage the event
        function manageEvent(obj, simEngine)

            % Update the statistic that keeps track of the pumps usage
            layout = simEngine.state.layout;
            simEngine.stats.update('averagePumpUsage', double(layout==0));
            
            % Update the layout
            % The car owner goes to the cashier to pay
            simEngine.state.layout(obj.lane, obj.idx) = 2; % 2 = done refueling, currenlty paying

            Q = cellfun(@length, simEngine.state.serverQueue);
            freeIdx = find(Q==0, 1);
            if isempty(freeIdx)
                [~, idx_server] = min(Q);
            else
                idx_server = freeIdx;
            end
        
            % Enqueue or start paying
            if Q(idx_server) > 0
                % all busy => join shortest queue
                simEngine.state.serverQueue{idx_server}{end+1} = [obj.lane, obj.idx];
                % Update the statistics that keeps track of the average
                % queue length
                simEngine.stats.update('averageServerQueueLength', Q);
            else
                % cashier free => go immediately to payment
                simEngine.state.serverQueue{idx_server}{end+1} = [obj.lane, obj.idx];
                simEngine.stats.update('averageServerQueueLength', Q)
                simEngine.stats.update('averageServerIdlensess', double(Q==0));
                payEv = Payment('Payment', ...
                    [simEngine.lb_server, simEngine.ub_server], ...
                    obj.clock, obj.lane, obj.idx, idx_server);
                payEv.clock = payEv.rnd();
                simEngine.eventsList.Enqueue(payEv);
            end

        end % end manageEvent
    
    end %end methods

end %end classdef

