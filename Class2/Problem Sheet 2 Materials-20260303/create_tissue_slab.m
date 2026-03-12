clear all;

resolution = 300;
dist = resolution/2;
x = dist:resolution:6000;
y = dist:resolution:3000;
z = dist:resolution:3000;

cell_count = 0;

%% Write File
for i = 1:size(x(:),1)
    for j = 1:size(y(:),1)
        for h = 1:size(z(:),1)
            if z(h) < 1000
                % Assign endocardial layer
                mesh{cell_count+1,1} = sprintf('%d,%d,%d,%d,%d,%d,%d,%d', x(i), y(j), z(h), dist, dist, dist, 0, 0);
                cell_count = cell_count + 1;
            elseif z(h) < 2000
                % Assign midmyocardial layer
                mesh{cell_count+1,1} = sprintf('%d,%d,%d,%d,%d,%d,%d,%d', x(i), y(j), z(h), dist, dist, dist, 2, 0);
                cell_count = cell_count + 1;
            else
                % Assign epicardial layer
                mesh{cell_count+1,1} = sprintf('%d,%d,%d,%d,%d,%d,%d,%d', x(i), y(j), z(h), dist, dist, dist, 1, 0);
                cell_count = cell_count + 1;
            end
        end
    end
end


file = fopen('tissueSlab_300.alg','w');
fprintf(file,'%s\n',mesh{:});
fclose(file);

disp(cell_count);