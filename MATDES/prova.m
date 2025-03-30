Inventory = zeros(5,5);
gozinto = zeros(5,1);
n = 3;
s = struct('Inventory', Inventory, 'gozinto', gozinto, 'n', n);

field_names = {'Inventory', 'gozinto'};
methods = {'average', 'minmax'};
myStatsManager = statsManager(field_names, methods);
% BISOGNA SEMPRE CHIAMARE UPDATE SULLA CONDIZIONE INIZIALE
myStatsManager.update('Inventory', zeros(5,5));
myStatsManager.update('Inventory', ones(5,5));
myStatsManager.update('Inventory', 4 * ones(5,5));

myStatsManager.update('gozinto', zeros(5,1));
myStatsManager.update('gozinto', rand*10*ones(5,1));
myStatsManager.update('gozinto', rand*ones(5,1));

myStatsManager.clear()