close all
clear
clc
addpath("simlib\")
addpath("First Full Test\")
numEvents = 150;
queue = futureEventsList();
for i=1:numEvents
    b = rand;
    if b > 0.5
        event = arrivalEvent(['ARR', num2str(i)], 1.1);
        event.clock = rand * 100;
    else
        event = serviceEvent(['SERV', num2str(i)], 1.2);
        event.clock = rand * 100;
    end
    queue.Enqueue(event);
end
for i=1:length(queue.events_heap)
    nextEvent = queue.Dequeue();
    disp(['Event ', nextEvent.label, ' processed at time ', num2str(nextEvent.clock)]);
end