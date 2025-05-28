function [newLane, departures] = rearrangeLane(lane)
% REARRANGE_LANE  Moves all “done‐paying” cars (–1) forward into free spots (1)
%   [newLane, departures] = rearrangeLane(lane)
%   repeatedly pushes every –1 one cell forward if the next cell is 1,
%   and removes (counts) any that reach the end, until no more moves/exits
%   are possible.
%
%   lane        1×N vector with values  1 = free,  0 = refueling, 2 = paying, –1 = done‐paying
%   newLane  updated layout after all moves
%   departures  number of cars that exited at the end

newLane = lane;
departures = 0;

moved = true;
while moved
    moved = false;

    idxs = find(newLane(1:end-1)==-1 & newLane(2:end)==1);
    for k = fliplr(idxs)   % process right‐to‐left
        newLane(k)   = 1;
        newLane(k+1) = -1;
        moved = true;
    end

    while ~isempty(newLane) && newLane(end)==-1
        newLane(end) = 1;
        departures = departures + 1;
        moved = true;
    end
end
end


