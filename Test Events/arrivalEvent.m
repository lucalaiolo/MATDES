classdef arrivalEvent < event
  
    methods
        function obj = arrivalEvent(label, parameters)
            obj@event(label, parameters)
        end
        
        function randomVar = rnd(obj)
            randomVar = obj.clock + exprnd(1/obj.parameters);
        end

        function manageEvent(obj, simEngine)
            disp('ciao')
        end
    end
end

