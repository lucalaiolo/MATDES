classdef Arrival < event
    %ARRIVAL 
    % Event representing a car arriving at the gas station
 
    properties
        lane        % Integer value indicating which pump lane the car will join.
                    % For the layout shown in tutorial.mlx:
                    %   lane = 0 ⇒ the car joins the lane served by pumps A and B.
                    %   lane = 1 ⇒ the car joins the lane served by pumps C and D.
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        function obj = Arrival(label, parameters, clock, laneDist)
            obj = obj@event(label, parameters, clock);
            obj.lane = random(laneDist);                
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function to generate random variables
        function randomVar = rnd(obj)
            randomVar = obj.clock + exprnd(obj.parameters); 
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Function to manage the event
        function manageEvent(obj, simEngine)
            fuelQueueLength = length(simEngine.state.fuelQueue);
            if fuelQueueLength >= simEngine.maxFuelQueueLength
                % Update the statistic that counts the amount of lost
                % customers
                simEngine.stats.update('numLost');
            else
                if fuelQueueLength == 0
                    % Select the most convenient lane that can serve this
                    % car
                    nLanes = length(simEngine.state.layout(:, 1));
                    possibleLanes_idx = 1:nLanes;
                    possibleLanes_idx = possibleLanes_idx(mod(possibleLanes_idx, 2) == mod(obj.lane,2));
                    possibleLanes_idx(possibleLanes_idx == obj.lane) = [];
                    possibleLanes_idx = [obj.lane, possibleLanes_idx];

                    possibleLanes = simEngine.state.layout(possibleLanes_idx, :);
                    freeLane = find(possibleLanes(:, 1) == 1, 1);
                    if isempty(freeLane)
                        % The entrances to all the possible lanes are
                        % occupied
                        % The car must wait in line
                        simEngine.state.fuelQueue(end+1) = obj.lane;
                        % Update the statistic that keeps track of the
                        % average queue length
                        simEngine.stats.update('averageFuelQueueLength', fuelQueueLength);
                    else
                        simEngine.stats.update('averageFuelQueueLength', fuelQueueLength);
                        actualLane = possibleLanes_idx(freeLane);
                        chosenLane = simEngine.state.layout(actualLane, :);
                        % The entrance is free
                        % The car can enter to refuel
                        nSpots = length(chosenLane);
                        idx = 1;    
                        for i=1:nSpots
                            % Check whether the spot is free or not
                            if chosenLane(i) == 1
                                % Free spot
                                idx = i;
                            else
                                % We have found an occupied spot
                                break;
                            end
                        end

                        % Update the statistic that keeps track of the
                        % usage of the pump and set to 0 (occupied) the
                        % chosen spot
                        oldLayout = simEngine.state.layout;
                        simEngine.stats.update('averagePumpUsage', double(oldLayout == 0));
                        % This is because we want to track average pump
                        % usage

                        % Update the layout
                        simEngine.state.layout(actualLane, idx) = 0;
                                                
                        % Schedule the refueling completion event 
                        refEv = Refueling('Refueling', ...
                            [simEngine.lb_refuel, simEngine.ub_refuel], ...
                            obj.clock, actualLane, idx);
                        refEv.clock = refEv.rnd();
                        simEngine.eventsList.Enqueue(refEv);
                    end
                    
                else
                    % Add the car to the queue
                    simEngine.state.fuelQueue(end+1) = obj.lane;
                    simEngine.stats.update('averageFuelQueueLength', fuelQueueLength);
                end %end if fuelQueueLength == 0
            
            end %end if fuelQueueLength >= simEngine.maxFuelQueueLength
            
            % Schedule the next arrival
            arrEv = Arrival('Arrival', 1/simEngine.arrivalRate, obj.clock, simEngine.laneDist);
            arrEv.clock = arrEv.rnd();
            simEngine.eventsList.Enqueue(arrEv);
        
        end %end manageEvent 

    end %end methods
end %end classdef

