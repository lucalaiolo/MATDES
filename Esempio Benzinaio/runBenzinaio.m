function [numLostCI, averageFuelQueueLengthCI, averageServerQueueLengthCI, ...
    averageServerIdlenessCI, averagePumpUsageCI] = runBenzinaio(params)

%% Parameters
maxFuelQueueLength = params.maxFuelQueueLength;
numServer = params.numServer;
arrivalRate = params.arrivalRate;
lb_server = params.lb_server;
ub_server = params.ub_server;
lb_refuel = params.lb_refuel;
ub_refuel = params.ub_refuel;
laneDist = params.laneDist;
nLanes = params.nLanes;
nSpots = params.nSpots;
numReps = params.numReps;
duration = params.duration;

%% Statistics collectors
numLost = zeros(numReps, 1);
averageFuelQueueLength = zeros(numReps, 1);
averageServerQueueLength = zeros(numReps, numServer);
averageServerIdleness = zeros(numReps, numServer);
averagePumpUsage = zeros(numReps, nLanes, nSpots);

%% Initialization
v = cell(1, numServer);
for i=1:numServer
    v{i} = {};
end
stateStruct = struct( ...
    'fuelQueue', [], ...
    'serverQueue', {v}, ...
    'layout', ones(nLanes, nSpots));
 
statsStruct = struct( ...
    'numLost', CountStatistic, ...
    'averageFuelQueueLength', TimeAverageStatistic, ...
    'averageServerQueueLength', TimeAverageStatistic, ...
    'averageServerIdlensess', TimeAverageStatistic, ...
    'averagePumpUsage', TimeAverageStatistic);

args = struct( ...
    'maxFuelQueueLength', maxFuelQueueLength, ...
    'numServer', numServer, ...
    'arrivalRate', arrivalRate, ...
    'lb_server', lb_server, ...
    'ub_server', ub_server, ...
    'lb_refuel', lb_refuel, ...
    'ub_refuel', ub_refuel, ...
    'laneDist', laneDist);

mySim = SimBenzinaio(stateStruct, statsStruct, args);

%% Run numReps simulations
for rep=1:numReps
    disp(['Running repetition ', num2str(rep), '/', num2str(numReps), '...'])
    arrEvent = Arrival('Arrival', 1/arrivalRate, 0, laneDist);
    mySim.initEventsList(arrEvent);
    mySim.run(duration);
    % Save the statistics
    numLost(rep) = mySim.stats.statistics.numLost.getResult;
    averageFuelQueueLength(rep) = mySim.stats.statistics.averageFuelQueueLength.getResult;
    averageServerQueueLength(rep, :) = mySim.stats.statistics.averageServerQueueLength.getResult;
    averageServerIdleness(rep, :) = mySim.stats.statistics.averageServerIdlensess.getResult;
    averagePumpUsage(rep, :, :) = mySim.stats.statistics.averagePumpUsage.getResult;
    mySim.clear(stateStruct);
end

%% Return 95% normal confidence intervals
[~, ~, numLostCI] = normfit(numLost);
[~, ~, averageFuelQueueLengthCI] = normfit(averageFuelQueueLength);
[~, ~, averageServerQueueLengthCI] = normfit(averageServerQueueLength);
[~, ~, averageServerIdlenessCI] = normfit(averageServerIdleness);
[~, ~, averagePumpUsageCI] = normfit(averagePumpUsage);

end

