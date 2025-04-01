classdef Repair < event
    % Repair event
    methods
        
        function randomVar = rnd(obj)
           randomVar = obj.clock + exprnd(obj.parameters); 
        end

        function manageEvent(obj, simEngine)
            
            repair_queue_length = simEngine.state.repair_queue.heapsize;
            
            if repair_queue_length > 0
                % The repairman starts to repair a new machine
                
                % This is needed. For example, if there were a single
                % worker, the repair_queue would be almost always non
                % empty. If we do not write this command, the statistic
                % might never be updated (because numIdleRepairmen would
                % never change)
                numIdleRepairmen = simEngine.state.numIdleRepairmen;
                simEngine.stats.update('numIdleRepairmen', numIdleRepairmen)
                
                % Repair the machine that has been waiting the most
                toRepair = simEngine.state.repair_queue.Dequeue();
                
                % Schedule repair
                repair_event = Repair('REPAIR', 1/simEngine.repairRate, obj.clock);
                repair_event.clock = repair_event.rnd();
                
                % Add the repair event to the future events list
                simEngine.eventsList.Enqueue(repair_event);
                
                % Update the costs
                simEngine.cost = simEngine.cost + 50 * (repair_event.clock - toRepair.clock);
            else
                % The repairman gets idle
                numIdleRepairmen = simEngine.state.numIdleRepairmen;
                simEngine.stats.update('numIdleRepairmen', numIdleRepairmen);
                simEngine.state.numIdleRepairmen = numIdleRepairmen + 1;
            end
            % Schedule breakdown of the repaired machine
            breakdown_event = Breakdown('BREAKDOWN', 1/simEngine.breakdownRate, obj.clock);
            breakdown_event.clock = breakdown_event.rnd();
            simEngine.eventsList.Enqueue(breakdown_event);
        end
    end
end

