classdef statsManager < handle
    % statsManager class
    
    properties
        counters                    % struct that will contain statistics for certain specified fields
        simulationClock             % current simulation clock
        fields_                     % fields to track
        methods_                    % how to track those fields
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        function obj = statsManager(fields, methods)
            % Check the validity of the inputs
            if nargin < 2 || ~iscell(fields) || ~iscell(methods)
                err_string = ['Error during construction of statisticalCounter' ...
                    'object. You must provide a 1xn cell array of fields to take track of' ...
                     ' and the corresponding methods to collect statistics.'];
                error(err_string);
            end

            if length(fields) ~= length(methods)
                error(['Error during construction of statisticalCounter. The arguments ' ...
                    'fields and methods must have the same length.']);
            end

            obj.counters = struct();
            % Track the last update time for every field we are tracking
            obj.simulationClock = 0;
            obj.fields_ = fields;
            obj.methods_ = methods;
            for i=1:length(fields)
                field = fields{i};
                method = methods{i};
                switch method
                    case 'count'
                        obj.counters.(field) = struct('count', 0);
                    case 'sum'
                        obj.counters.(field) = struct('sum', 0);
                    case 'average'
                        obj.counters.(field) = struct('sum', 0, 'count', 0, 'average', 0);
                    case 'minmax'
                        obj.counters.(field) = struct('min', Inf, 'max', -Inf);
                    case 'timeAverage'
                        obj.counters.(field) = struct(...
                            'weightedSum', 0, ...
                            'totalTime', 0, ...
                            'average', 0, ...
                            'lastUpdateTime', 0);
                    otherwise
                        error(['Unrecognized statistic. Valid statistical counters are: ', newline, ...
                            '- count', newline, '- sum', newline, '- average', newline, ...
                            '- minmax', newline, '- timeAverage'])
                end %end switch
            end %end for

        end %end constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Update method
        function update(obj, field, value)
            if ~isfield(obj.counters, field)
                error('Error during update of statistical counters. Field %s not recognized', field);
            end
            counter = obj.counters.(field);
            
            % Update the statistic using the right method
            if isfield(counter, 'count') && ~isfield(counter, 'sum')
                obj.counters.(field).count = obj.counters.(field).count + 1;
            elseif ~isfield(counter, 'count') && isfield(counter, 'sum')
                obj.counters.(field).sum = obj.counters.(field).sum + value;
            elseif isfield(counter, 'count') && isfield(counter, 'sum')
                obj.counters.(field).count = obj.counters.(field).count + 1;
                obj.counters.(field).sum = obj.counters.(field).sum + value;
                obj.counters.(field).average = obj.counters.(field).sum / obj.counters.(field).count;
            elseif isfield(counter, 'min')
                obj.counters.(field).min = min(obj.counters.(field).min, value);
                obj.counters.(field).max = max(obj.counters.(field).max, value);
            elseif isfield(counter, 'weightedSum')
                % Important: in this case update must be called using the
                % old value and not the new value
                deltaT = obj.simulationClock - obj.counters.(field).lastUpdateTime;
                weightedSum = obj.counters.(field).weightedSum;
                obj.counters.(field).weightedSum = weightedSum + value * deltaT;
                obj.counters.(field).totalTime = obj.counters.(field).totalTime + deltaT;
                obj.counters.(field).average = obj.counters.(field).weightedSum / ...
                    obj.counters.(field).totalTime;
                % Update the last update time for that field
                obj.counters.(field).lastUpdateTime = obj.simulationClock;
            end %end if
        end %end update
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Clear the statistical counters
        % Lazy version (using a copy)
        function clear(obj)
            % Call the constructor
            new_obj = statsManager(obj.fields_, obj.methods_);
            % Clear obj
            obj.counters = new_obj.counters;
            obj.simulationClock = new_obj.simulationClock;
        end
        
    end %end methods

end %end classdef

