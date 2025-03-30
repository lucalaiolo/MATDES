classdef SimulationEngine < handle
    % SimulationEngine
    % The SimulationEngine class defines the framework for discrete event 
    % simulation

    properties
        state                   % a state object
        clock = 0               % simulation clock
        eventsList              % a futureEventsList object
        statistics              % statistical counters
    end
    
    methods (Abstract)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Termination condition
        flag = terminationCondition(obj, stoppingParameters)

    end

    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        function obj = SimulationEngine(DataStruct, StatFields, StatMethods)
            % Initialize the state
            if ~isstruct(DataStruct)
                error(['Error during construction of SimulationEngine object. ' ...
                    'The first argument is not a struct.'])
            end
            obj.state = state(DataStruct);
            
            % Initialize the clock
            obj.clock = 0;
            
            % Initialize the future events list
            obj.eventsList = futureEventsList();
            
            % Initialize the statistics
            obj.statistics = statsManager(StatFields, StatMethods);
            
        end %end constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Initialize the events list
        % events must be an array of subclasses of event class
        % This function must be called after the creation of a
        % SimulationEngine object and before calling the run method
        function initEventsList(obj, events)
            for i=1:length(events)
                obj.eventsList.Enqueue(events(i));
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Run the simulation
        function run(obj, stoppingParameters)
            while ~obj.terminationCondition(stoppingParameters)
                % Determine the next event
                nextEvent = obj.eventsList.Dequeue();
                % Advance the simulation clock
                obj.clock = nextEvent.clock;
                obj.statistics.simulationClock = obj.clock;
                % Update the system state and schedule the next event
                % The statistics will be update inside this function
                nextEvent.manageEvent(obj);
            end
            % Print a report
            obj.generateReport();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Clear the state and the statistical counters
        % The state will be cleared using the struct DataStruct
        function clear(obj, DataStruct)
            fields = fieldnames(DataStruct)';
            values = struct2cell(DataStruct)';
            obj.state.update(fields, values);
            obj.statistics.clear();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Generate final report
        function generateReport(obj)
            disp('Simulation ended.')
            disp('Statistics collected:');
            fields = obj.statistics.fields_;
            for i=1:length(fields)
                field = obj.statistics.fields_{i};
                method = obj.statistics.methods_{i};
                disp(field);
                disp(['Statistic: ', method]);
                disp(obj.statistics.counters.(field));
            end
        end

    end

end

