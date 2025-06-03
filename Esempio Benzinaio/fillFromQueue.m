function fillFromQueue(simEngine)
%FILLFROMQUEUE  Admit cars from the waiting queue into available spots
%   simEngine: a SimulationEngine object

oldLayout = simEngine.state.layout;
newLayout = oldLayout;

fuelQueue = simEngine.state.fuelQueue;
fuelQueueLength = length(fuelQueue);
numLanes = size(oldLayout, 1);

while ~isempty(fuelQueue)
    % The lane that the car wants to enter
    % If there is room, the car enters this lane. Otherwise, we check if
    % there are other appropriate lanes available
    desiredLane = fuelQueue(1);                    
                    
    sameParityLanes = find(mod((1:numLanes), 2) == mod(desiredLane, 2));
    otherParityLanes = setdiff(sameParityLanes, desiredLane);

    laneList = [desiredLane, otherParityLanes];

    admitted = false;

    for k=1:numel(laneList)
        laneLayout = newLayout(laneList(k), :);
        N = numel(laneLayout);
        possible = false(N,1);
        % find all positions i from rightmost to leftmost that are free AND reachable
        for i = N:-1:1
            if laneLayout(i)==1 && all(laneLayout(1:i-1)==1)
                possible(i) = true;
            end
        end
        idx = find(possible, 1, 'last');      % the furthest-in (largest i)
        if ~isempty(idx)
            % Admit into laneList(k) at position idx
            lane = laneList(k);
            laneLayout(idx) = 0;
            refEv = Refueling('Refueling', ...
                [simEngine.lb_refuel, simEngine.ub_refuel], ...
                simEngine.clock, lane, idx);
            refEv.clock = refEv.rnd();
            simEngine.eventsList.Enqueue(refEv);
            
            % Update layout and dequeue car
            newLayout(lane, :) = laneLayout;
            fuelQueue(1) = [];
            admitted = true;
            break;
        end

    end
    % If this car couldn’t get into any same-parity lane, stop admitting
    if ~admitted
        break;
    end

end

% Update the statistics that keep track of pump usage and average fuel
% queue length (using, as always, the old values)
simEngine.stats.update('averageFuelQueueLength', fuelQueueLength);
simEngine.stats.update('averagePumpUsage', double(oldLayout == 0));

% Update the state of the system
simEngine.state.fuelQueue = fuelQueue;
simEngine.state.layout = newLayout;

end

