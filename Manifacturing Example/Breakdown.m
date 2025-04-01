classdef Breakdown < event
    % Breakdown event
    methods

        function randomVar = rnd(obj)
           randomVar = obj.clock + exprnd(obj.parameters); 
        end

        function manageEvent(obj, simEngine)

            numIdleRepairmen = simEngine.state.numIdleRepairmen;
            
            if numIdleRepairmen > 0
                
                % Schedule the repairment time
                repair_event = Repair('REPAIR', 1/simEngine.repairRate, obj.clock);
                repair_event.clock = repair_event.rnd();
                
                % Update the system state and statistics
                simEngine.eventsList.Enqueue(repair_event);
                simEngine.stats.update('numIdleRepairmen', numIdleRepairmen)
                simEngine.state.numIdleRepairmen = numIdleRepairmen - 1;
                
                % Update the costs (assuming that the repairman stats working
                % as soon as the machine breaks down)
                simEngine.cost = simEngine.cost + ...
                    50 * (repair_event.clock - obj.clock);
            else
                % Update the repair queue
                simEngine.state.repair_queue.Enqueue(obj);
            end
            
        end
    end

end

