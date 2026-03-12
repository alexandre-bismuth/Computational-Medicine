clear;

% Specify path to .acm file
file_in = fopen('activation_info_it_0.acm');
i=1;

tline = fgetl(file_in);
tline = fgetl(file_in);
while ischar(tline)
    %% Read .acm file
    % Change [ %f ] if multiple activations were recorded
    data{i} = sscanf(tline,'%f,%f,%f,%f,%f,%f,%f,%f,%f %f [ %f ] [ %f ]');

    %% Print .alg file
    % Change data{i}(11) if you recorded multiple activations and don't
    % want to use the first one
    new_data{i} = sprintf('%4f,%4f,%4f,%4f,%4f,%4f,%f', data{i}(1:6), data{i}(11));
    
    i = i+1;
    tline = fgetl(file_in);
end

fclose(file_in);

% Specify desired path to output .alg file
file_out = fopen('activation_info.alg', 'w');
fprintf(file_out, '%s\n', new_data{:});
fclose(file_out);