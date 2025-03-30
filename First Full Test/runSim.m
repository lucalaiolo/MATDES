close all
clear
clc
rng default

addpath('..\MATDES\')
config = configuration();
stateStruct = struct('numInQueue', config.INITIAL_QUEUE_SIZE);
stat_fields = {'num_served', 'num_lost', 'queue_length'};
stat_methods = {'count', 'sum', 'timeAverage'};
first_event = arrivalEvent('ARRIVAL', config.ARRIVAL_RATE);
first_event.clock = first_event.rnd();
simulation = MM1_balking_sim(stateStruct, stat_fields, stat_methods);
simulation.initEventsList(first_event);
simulation.run(config.HOW_MANY);
simulation.clear(stateStruct);