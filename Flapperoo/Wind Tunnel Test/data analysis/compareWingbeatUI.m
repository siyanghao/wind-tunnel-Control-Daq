classdef compareWingbeatUI
properties
    % integer, 0-6, defines which force/moment axes to display
    index;
    % force and moment axes labels (changed for normalization)
    axes_labels;
    % boolean, normalization/non-dimensionalization on or off
    norm;

    % ------- Available parameters user can select from -------
    types;
    freqs;
    speeds;
    angles;

    % --------- Actively selected parameters ---------
    % full case name includes type, freq, speed, and angle
    selection;

    sel_type;
    sel_freq;
    sel_speed;
    sel_angle;
end

methods
    % Constructor Function
    % Defines constants and default values for parameters
    function obj = compareWingbeatUI()
        obj.index = 0;
        obj.axes_labels = ["All", "Drag", "Transverse Lift", "Lift",...
            "Roll Moment", "Pitch Moment", "Yaw Moment"];

        obj.types = ["Wings with Full Body", "Wings with Tail", ...
            "Wings with Half Body", "Full Body", "Tail", ...
            "Half Body", "Inertial Wings with Full Body"];
        obj.speeds = [0, 3, 4, 5, 6];
        obj.freqs = ["0.1 Hz", "2 Hz", "2.5 Hz", "3 Hz", "3.5 Hz",...
            "3.75 Hz", "4 Hz", "4.5 Hz", "5 Hz", "2 Hz v2", "4 Hz v2"];
        obj.angles = [-16:1.5:-13 -12:1:-9 -8:0.5:8 9:1:12 13:1.5:16];

        obj.selection = strings(0);
        obj.sel_type = compareWingbeatUI.nameToType(obj.types(1));
        obj.sel_freq = obj.freqs(1);
        obj.sel_speed = obj.speeds(1);
        obj.sel_angle = obj.angles(1);
    end

    % Builds figure with all UI elements and defines all callback
    % functions to be used when user clicks on UI elements
    function dynamic_plotting(obj)
        % Create a GUI figure with a grid layout
        [option_panel, plot_panel, screen_size] = setupFig();
       
        % Dropdown box for flapper type selection
        drop_y1 = screen_size(4) - 600;
        d1 = uidropdown(option_panel);
        d1.Position = [20 drop_y1 200 30];
        d1.Items = obj.types;
        d1.ValueChangedFcn = @(src, event) type_change(src, event);

        % Dropdown box for wingbeat frequency selection
        drop_y2 = drop_y1 - 35;
        d2 = uidropdown(option_panel);
        d2.Position = [20 drop_y2 200 30];
        d2.Items = obj.freqs;
        d2.ValueChangedFcn = @(src, event) freq_change(src, event);

        % Dropdown box for angle of attack selection
        drop_y3 = drop_y2 - 35;
        d3 = uidropdown(option_panel);
        d3.Position = [20 drop_y3 200 30];
        d3.Items = obj.angles + " deg";
        d3.ValueChangedFcn = @(src, event) angle_change(src, event);

        % Dropdown box for wind speed selection
        drop_y4 = drop_y3 - 35;
        d4 = uidropdown(option_panel);
        d4.Position = [20 drop_y4 200 30];
        d4.Items = obj.speeds + " m/s";
        d4.ValueChangedFcn = @(src, event) speed_change(src, event, d2);

        % Button to add entry defined by selected type,
        % frequency, angle, and speed to list of plotted cases
        button_y = drop_y4 - 35;
        b1 = uibutton(option_panel);
        b1.Position = [20 button_y 80 30];
        b1.Text = "Add entry";

        % Button to remove entry defined by selected type,
        % frequency, angle, and speed from list of plotted cases
        b2 = uibutton(option_panel);
        b2.Position = [140 button_y 80 30];
        b2.Text = "Delete entry";

        % List of cases currently displayed on the plots
        list_y = button_y - 35;
        lbox = uilistbox(option_panel);
        lbox.Position = [20 list_y 200 30];
        lbox.Items = strings(0);

        b1.ButtonPushedFcn = @(src, event) addToList(src, event, plot_panel, lbox);
        b2.ButtonPushedFcn = @(src, event) removeFromList(src, event, plot_panel, lbox);

        % Dropdown box for which force/moment axes to display
        drop_y5 = 160;
        d5 = uidropdown(option_panel);
        d5.Position = [20 drop_y5 200 30];
        d5.Items = obj.axes_labels;
        d5.ValueChangedFcn = @(src, event) index_change(src, event, plot_panel);

        % Set up plot titles and axes
        obj.update_plot(plot_panel);

        %-----------------------------------------------------%
        %-----------------------------------------------------%
        % Callback functions to respond to user inputs. These
        % functions must be nested inside this function otherwise
        % they will reference the object snapshot at the time the
        % callback function was defined rather than updating with
        % the object
        %-----------------------------------------------------%
        %-----------------------------------------------------%
    
        % update type variable with new value selected by user
        function type_change(src, ~)
            obj.sel_type = compareWingbeatUI.nameToType(src.Value);
        end

        % update frequency variable with new value selected by user
        function freq_change(src, ~)
            obj.sel_freq = src.Value;
        end

        % update angle variable with new value selected by user
        function angle_change(src, ~)
            obj.sel_angle = str2double(extractBefore(src.Value, " deg"));
        end

        % update speed variable with new value selected by user
        function speed_change(src, ~, d2)
            speed = str2double(extractBefore(src.Value, " m/s"));
            obj.sel_speed = speed;
            % 4.5 Hz and 5 Hz were run for all wind speeds except
            % 6 m/s
            if (speed == 6)
                d2.Items = ["0.1 Hz", "2 Hz", "2.5 Hz", "3 Hz",...
                    "3.5 Hz", "3.75 Hz", "4 Hz", "2 Hz v2", "4 Hz v2"];
            else
                d2.Items = ["0.1 Hz", "2 Hz", "2.5 Hz", "3 Hz",...
                    "3.5 Hz", "3.75 Hz", "4 Hz", "4.5 Hz", "5 Hz", "2 Hz v2", "4 Hz v2"];
            end
        end

        function addToList(~, ~, plot_panel, lbox)
            case_name = obj.sel_type + " " + obj.sel_speed + " m/s " + obj.sel_freq + " " + obj.sel_angle + " deg";
            if (sum(strcmp(string(lbox.Items), case_name)) == 0)
            lbox.Items = [lbox.Items, case_name];
            obj.selection = [obj.selection, case_name];
            end
            obj.update_plot(plot_panel);
        end

        function removeFromList(~, ~, plot_panel, lbox)
            case_name = lbox.Value;
            new_list_indices = string(lbox.Items) ~= case_name;
            lbox.Items = lbox.Items(new_list_indices);
            new_list_indices = obj.selection ~= case_name;
            obj.selection = obj.selection(new_list_indices);
            obj.update_plot(plot_panel);
        end

        function index_change(src, ~, plot_panel)
            obj.index = find(obj.axes_labels == src.Value) - 1;
            obj.update_plot(plot_panel);
        end
        %-----------------------------------------------------%
        %-----------------------------------------------------%
        
    end
end

methods(Static, Access = private)

    function type = nameToType(name)
        if (name == "Wings with Full Body")
            type = "blue wings";
        elseif (name == "Wings with Tail")
            type = "tail blue wings";
        elseif (name == "Wings with Half Body")
            type = "blue wings half body";
        elseif (name == "Full Body")
            type = "no wings";
        elseif (name == "Tail")
            type = "tail no wings";
        elseif (name == "Half Body")
            type = "half body no wings";
        elseif (name == "Inertial Wings")
            type = "inertial wings";
        else
            type = name;
        end
    end

    function [sel_type, sel_speed, sel_freq, sel_angle] = parseCases(case_name)
        % Parse relevant trial information from case name 
        case_parts = strtrim(split(case_name));
        sel_type = "";
        sel_freq = -1;
        sel_angle = -1;
        sel_speed = -1;
        for j=1:length(case_parts)
            if (contains(case_parts(j), "deg"))
                sel_angle = str2double(case_parts(j-1));
                end_ind = j-2;
            elseif (contains(case_parts(j), "m/s"))
                sel_speed = str2double(case_parts(j-1));
                sel_type = strjoin(case_parts(1:j-2)); % speed is first thing after type
                start_ind = j+1;
            end
        end
        sel_freq = strjoin(case_parts(start_ind:end_ind));
    end

    function [uniq_types, uniq_speeds, uniq_freqs] = getUniqParams(selected_cases)
        uniq_types = [];
        uniq_speeds = [];
        uniq_freqs = [];
        for i = 1:length(selected_cases)
            case_name = selected_cases(i);
            % Parse relevant trial information from case name 
            [sel_type, sel_speed, sel_freq, sel_angle] = compareWingbeatUI.parseCases(case_name);
            

            if (sum(strcmp(uniq_types, sel_type)) == 0)
                uniq_types = [uniq_types sel_type];
            end
            if (sum(uniq_speeds == sel_speed) == 0)
                uniq_speeds = [uniq_speeds sel_speed];
            end
            if (sum(strcmp(uniq_freqs, sel_freq)) == 0)
                uniq_freqs = [uniq_freqs sel_freq];
            end
        end
    end

    function [data_filename, data_folder] = findMatchFile(sel_type, sel_speed, sel_freq, sel_angle, freqs, processed_data_files)
        wing_freq_sel = str2double(extractBefore(freqs, " Hz"));
        wing_freq_sel_count = wing_freq_sel;
        for i = 1:length(wing_freq_sel)
            wing_freq_sel_count(i) = sum(wing_freq_sel == wing_freq_sel(i));
        end

        wing_freq = str2double(extractBefore(sel_freq, " Hz"));
        for i = 1 : length(processed_data_files)
            baseFileName = processed_data_files(i).name;
            [case_name_cur, time_stamp_cur, type_cur, wing_freq_cur, AoA_cur, wind_speed_cur] = parse_filename(baseFileName);
            type_cur = convertCharsToStrings(type_cur);

            if (wing_freq == wing_freq_cur ...
            && sel_angle == AoA_cur ...
            && sel_speed == wind_speed_cur ...
            && strcmp(sel_type, type_cur))

                data_filename = baseFileName;
                data_folder = processed_data_files(i).folder;

                % Check if any other files were recorded for the same set
                % of parameters but at a different time
                count = 0;
                timestamps_str = {};
                timestamps_val = [];
                for m = 1 : length(processed_data_files)
                    baseFileName = processed_data_files(m).name;
                    if (contains(baseFileName, case_name_cur))
                        count = count + 1;
                        time_str = strtrim(extractBefore(extractAfter(baseFileName, case_name_cur), ".mat"));
                        split_time_str = split(time_str);
                        h_m_s = split_time_str(2);
                        split_h_m_s = str2double(split(h_m_s, "-"));
                        if (split_h_m_s(1) < 6)
                            split_h_m_s(1) = split_h_m_s(1) + 12;
                        end
                        time_val = split_h_m_s(1)*3600 + split_h_m_s(2)*60 + split_h_m_s(3);
        
                        timestamps_str = [timestamps_str; time_str];
                        timestamps_val = [timestamps_val; time_val];
                    end
                end
        
                [B,I] = sort(timestamps_val);
                timestamps_str_sorted = timestamps_str(I);
                cur_time_index = find(timestamps_str_sorted == time_stamp_cur);
        
                num_repeat_freqs = wing_freq_sel_count(find(wing_freq_sel == wing_freq, 1, 'first'));
        
                disp("Obtaining data for " + type_cur + " " + wing_freq_cur + " Hz " + wind_speed_cur + " m/s "  + AoA_cur + " deg trial")
                if (count > 1) % counted multiple repeats in datastream
                if (num_repeat_freqs == count)
                    % num_repeat_freqs > 1 && cur_time_index > length(timestamps_str) - num_repeat_freqs
                    wing_freq_ind = find(wing_freq_sel == wing_freq);
                    wing_freq_ind = wing_freq_ind(cur_time_index);
        
                    disp("Found " + count + " files, timestamps: ")
                    disp(timestamps_str)
                    disp("    Using current timestamp: " + time_stamp_cur)
                    disp(" ")
                else
                    disp("Extra files found and current file too old, moving on...")
                    continue
                    % wing_freq_ind = wing_freq_sel == wing_freq;
                    % 
                    % modFileName = case_name + string(timestamps_str_sorted(end)) + ".mat";
                    % 
                    % disp("Found " + count + " files, timestamps: " + timestamps_str)
                    % disp("    Using last timestamp: " + timestamps_str_sorted(end))
                    % disp(" ")
                end
                end

                break

            end
        end
    end

    function theFiles = getFiles(filepath, filetype)
        % Get a list of all files in the folder with the desired file name pattern.
        filePattern = fullfile(filepath, filetype); % Change to whatever pattern you need.
        theFiles = [];
        for i = 1:length(filePattern)
            theFiles = [theFiles; dir(filePattern(i))];
        end
    end

    function lighter_color = getLightColor(original_color)
        original_color = hex2rgb(original_color);
                
        % Amount to lighten (0 = no change, 1 = completely white)
        fade_amount = 0.7;  % Adjust this value to control how light you want the color
        
        % White color in RGB
        white = [1, 1, 1];
        
        % Linearly interpolate between the original color and white
        lighter_color = (1 - fade_amount) * original_color + fade_amount * white;
    end
end

methods (Access = private)
    function update_plot(obj, plot_panel)
        delete(plot_panel.Children)

        % Variables for plotting later
        x_label = "Wingbeat Period (t/T)";
        if (obj.norm)
            y_label_F = "Cycle Average Force Coefficient";
            y_label_M = "Cycle Average Moment Coefficient";
        else
            y_label_F = "Cycle Average Force (N)";
            y_label_M = "Cycle Average Moment (N*m)";
        end
        y_labels = [y_label_F, y_label_F, y_label_F, y_label_M, y_label_M, y_label_M];
        titles = obj.axes_labels(2:7);

        if (~isempty(obj.selection))
        % Parse selected cases
        [uniq_types, uniq_speeds, uniq_freqs] = compareWingbeatUI.getUniqParams(obj.selection);
        
        % Get all type folders in the speed folders
        type_dir_names = [];
        for i = 1:length(uniq_speeds)
            speed_path = "../" + uniq_speeds(i) + " m.s/";
            type_dir_names = [type_dir_names; dir(speed_path)];
        end
        
        % remove . and .. directories
        ind_to_remove = [];
        for i = 1:length(type_dir_names)
            if (type_dir_names(i).name == "." || type_dir_names(i).name == "..")
                ind_to_remove = [ind_to_remove i];
            end
        end
        type_dir_names(ind_to_remove) = [];
        
        paths = [];
        % path to folders where processed data (.mat files) are stored
        for i = 1:length(type_dir_names)
            cur_name_parts = split(type_dir_names(i).name);
            cur_type = strrep(cur_name_parts{1},'_',' ');
            cur_speed = string(extractBefore(extractAfter(type_dir_names(i).folder, 'Data\')," m.s"));
            if (sum(uniq_types == cur_type) > 0 && sum(uniq_speeds == str2double(cur_speed)) > 0) % find matches
                filepath = "../" + cur_speed + " m.s/" + type_dir_names(i).name;
                processed_data_path = filepath + "/processed data/";
                paths = [paths processed_data_path];
            end
        end
        
        processed_data_files = [];
        for i = 1:length(paths)
            processed_data_path = paths(i);
            processed_data_files = [processed_data_files; compareWingbeatUI.getFiles(processed_data_path, '*.mat')];
        end

        colors = getColors(length(uniq_types), length(uniq_freqs));

        end

        if (obj.index == 0)
            % Initialize tiled layout for plots
            tcl = tiledlayout(plot_panel, 2, 3, 'Padding', 'compact', 'TileSpacing', 'compact');

            tiles = [];
            for idx = 1:6
                ax = nexttile(tcl, idx);
                title(ax, titles(idx));
                xlabel(ax, x_label);
                ylabel(ax, y_labels(idx))
                grid(ax, 'on');
                legend(ax);
                tiles = [tiles ax];
            end

            for i = 1:length(obj.selection)
            
            [sel_type, sel_speed, sel_freq, sel_angle] = compareWingbeatUI.parseCases(obj.selection(i));

            % Find exact filename matching this case
            [data_filename, data_folder] = compareWingbeatUI.findMatchFile(sel_type, sel_speed, sel_freq, sel_angle, obj.freqs, processed_data_files);
        
            vars = {'wingbeat_avg_forces_smoothest', 'wingbeat_std_forces_smoothest',...
                'wingbeat_min_forces_smoothest', 'wingbeat_max_forces_smoothest',...
                'wingbeat_rmse_forces_smoothest', 'frames', 'Re', 'St'};
            load([data_folder '\' data_filename], vars{:});
        
            disp("Loading data from " + data_filename)
            disp("From: " + data_folder)
        
            cycle_avg_forces = wingbeat_avg_forces_smoothest;
            cycle_std_forces = wingbeat_std_forces_smoothest;
            cycle_min_forces = wingbeat_min_forces_smoothest;
            cycle_max_forces = wingbeat_max_forces_smoothest;
            cycle_rmse_forces = wingbeat_rmse_forces_smoothest;

            for idx = 1:6
                upper_results = cycle_avg_forces + cycle_std_forces;
                lower_results = cycle_avg_forces - cycle_std_forces;

                original_color = colors(find(uniq_freqs == sel_freq), find(uniq_types == sel_type)); % hex
                lighter_color = compareWingbeatUI.getLightColor(original_color); % RGB

                hold(tiles(idx), 'on');
                xconf = [frames, frames(end:-1:1)];         
                yconf = [upper_results(idx, :), lower_results(idx, end:-1:1)];
                p = fill(tiles(idx), xconf, yconf, 'blue',HandleVisibility='off');
                p.FaceColor = lighter_color;      
                p.EdgeColor = 'none';
                line = plot(tiles(idx), frames, cycle_avg_forces(idx, :));
                line.DisplayName = sel_type + " " + sel_speed + " m/s " + sel_freq + " " + sel_angle + " deg";
                line.Color = original_color;
                % plot_wingbeat_patch();
                hold(tiles(idx), 'off');
            end
            end

        else
            ax = axes(plot_panel);
            idx = obj.index;

            for i = 1:length(obj.selection)
            
            [sel_type, sel_speed, sel_freq, sel_angle] = compareWingbeatUI.parseCases(obj.selection(i));
            % Find exact filename matching this case
            [data_filename, data_folder] = compareWingbeatUI.findMatchFile(sel_type, sel_speed, sel_freq, sel_angle, obj.freqs, processed_data_files);
        
            vars = {'wingbeat_avg_forces_smoothest', 'wingbeat_std_forces_smoothest',...
                'wingbeat_min_forces_smoothest', 'wingbeat_max_forces_smoothest',...
                'wingbeat_rmse_forces_smoothest', 'frames', 'Re', 'St'};
            load([data_folder '\' data_filename], vars{:});
        
            disp("Loading data from " + data_filename)
            disp("From: " + data_folder)
        
            cycle_avg_forces = wingbeat_avg_forces_smoothest;
            cycle_std_forces = wingbeat_std_forces_smoothest;
            cycle_min_forces = wingbeat_min_forces_smoothest;
            cycle_max_forces = wingbeat_max_forces_smoothest;
            cycle_rmse_forces = wingbeat_rmse_forces_smoothest;

            upper_results = cycle_avg_forces + cycle_std_forces;
            lower_results = cycle_avg_forces - cycle_std_forces;

            original_color = colors(find(uniq_freqs == sel_freq), find(uniq_types == sel_type)); % hex
            lighter_color = compareWingbeatUI.getLightColor(original_color); % RGB

            hold(ax, 'on');
            xconf = [frames, frames(end:-1:1)];         
            yconf = [upper_results(idx, :), lower_results(idx, end:-1:1)];
            p = fill(ax, xconf, yconf, 'blue',HandleVisibility='off');
            p.FaceColor = lighter_color;      
            p.EdgeColor = 'none';
            line = plot(ax, frames, cycle_avg_forces(idx, :));
            line.DisplayName = sel_type + " " + sel_speed + " m/s " + sel_freq + " " + sel_angle + " deg";
            line.Color = original_color;
            % plot_wingbeat_patch();
            hold(ax, 'off');

            title(ax, titles(idx));
            xlabel(ax, x_label);
            ylabel(ax, y_labels(idx))
            grid(ax, 'on');
            legend(ax, Location="best");
            ax.FontSize = 18;
            end
        end
    end
end
end