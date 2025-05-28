function fillFromQueue(simEngine)
%FILLFROMQUEUE  Admit cars from the waiting queue into available spots
%   simEngine: a SimulationEngine object

oldLayout = simEngine.state.layout;
newLayout = oldLayout;

fuelQueue = simEngine.state.fuelQueue;
fuelQueueLength = length(fuelQueue);

while ~isempty(fuelQueue)
    lane = fuelQueue(1);                    
    laneLayout = newLayout(lane, :);         

    % find all positions i from rightmost to leftmost that are free AND reachable
    N = numel(laneLayout);
    possible = false(N,1);
    for i = N:-1:1
        if laneLayout(i)==1 && all(laneLayout(1:i-1)==1)
            possible(i) = true;
        end
    end
    idx = find(possible, 1, 'last');      % the furthest-in (largest i)

    if isempty(idx)
        break   % this car can’t enter yet ⇒ stop admitting anyone
    end

    % admit the car at position idx
    laneLayout(idx) = 0;
    refEv = Refueling('Refueling', ...
        [simEngine.lb_refuel, simEngine.ub_refuel], ...
        simEngine.clock, lane, idx);
    refEv.clock = refEv.rnd();
    simEngine.eventsList.Enqueue(refEv);

    % dequeue that car
    fuelQueue(1) = [];

    % write back the updated lane
    newLayout(lane, :) = laneLayout;
end

% Update the statistics that keep track of pump usage and average fuel
% queue length (using, as always, the old values)
simEngine.stats.update('averageFuelQueueLength', fuelQueueLength);
simEngine.stats.update('averagePumpUsage', double(oldLayout == 0));

% Update the state of the system
simEngine.state.fuelQueue = fuelQueue;
simEngine.state.layout = newLayout;

end

