classdef serviceEvent < event
  
    methods
        function randomVar = rnd(obj)
            randomVar = exprnd(1/obj.parameters);
        end

        function manageEvent(obj, simEngine)
            disp('ciao')
        end
    end
end


