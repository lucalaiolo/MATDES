function [costCI, numIdleCI] = runManifacturingSystem(numRep, numHours, ...
    numWorkers, numMachines, breakdownRate, repairRate)

% Simulate the manifacturing system numRep times

% Initialize the system
stateStruct = struct( ...
    'numIdleRepairmen', numWorkers, ...
    'repair_queue', futureEventsList);
statsStruct = struct('numIdleRepairmen', TimeAverageStatistic);

mySim = ManifacturingSystem(stateStruct, statsStruct);
mySim.breakdownRate = breakdownRate;
mySim.repairRate = repairRate;

% Initialize vectors containing quantities of interest
cost_vec = zeros(numRep, 1);
AverageNumIdleRepairmen_vec = zeros(numRep, 1);
employmentCosts = 10 * numWorkers * numHours;

for i=1:numRep
    mySim.initEventsList(numMachines);
    mySim.run(numHours);
    cost_vec(i) = (mySim.cost + employmentCosts)/numHours;
    AverageNumIdleRepairmen_vec(i) = mySim.stats.statistics.numIdleRepairmen.getResult();
    % Clear the system state and statistical counters
    mySim.clear(stateStruct);
    mySim.cost = 0;
end

[~, ~, costCI] = normfit(cost_vec);
[~, ~, numIdleCI] = normfit(AverageNumIdleRepairmen_vec);

end

