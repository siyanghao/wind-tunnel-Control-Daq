classdef dataProcessingUI
properties
    selection;
    index;
    axes_labels;
    range;
    angles;
    norm;
    dim_list;
    norm_list;
end

methods
    function obj = dataProcessingUI()
        obj.selection = strings(0);
        obj.index = 0;
        obj.axes_labels = ["All", "Drag", "Transverse Lift", "Lift",...
            "Roll Moment", "Pitch Moment", "Yaw Moment"];
        obj.range = [-16 16];
        obj.angles = [-16:1.5:-13 -12:1:-9 -8:0.5:8 9:1:12 13:1.5:16];
        obj.norm = false;

        % wing_freq_sel = [0, 2, 4, 2, 4];
        % wind_speed_sel = [5];
        % type_sel = ["blue wings"];
        % AoA_sel = [-16:1.5:-13 -12:1:-9 -8:0.5:8 9:1:12 13:1.5:16];

        obj.dim_list = [];
        obj.norm_list = [];

        data_path = "./plot data/";
        % Get a list of all files in the folder with the desired file name pattern.
        filePattern = fullfile(data_path, '*.mat');
        theFiles = dir(filePattern);
        
        % Grab each file and process the data from that file, storing the results
        for k = 1 : length(theFiles)
            baseFileName = convertCharsToStrings(theFiles(k).name);
            parsed_name = extractBefore(baseFileName, "_saved");
            
            if(contains(parsed_name, "dim"))
                load("./plot data/" + baseFileName, "names");
                data_struct.file_name = baseFileName;
                data_struct.dir_name = extractBefore(parsed_name, "_dim");

                for j = 1:length(names)
                % distinguish repeat trials with unique name
                if(sum(names == names(j)) > 1)
                    ind = find(names == names(j), 1, 'last');
                    names(ind) = names(ind) + " v2";
                end
                end

                data_struct.trial_names = names;
                obj.dim_list = [obj.dim_list data_struct];
            elseif (contains(parsed_name, "norm"))
                load("./plot data/" + baseFileName, "names");
                data_struct.file_name = baseFileName;
                data_struct.dir_name = extractBefore(parsed_name, "_norm");

                for j = 1:length(names)
                % distinguish repeat trials with unique name
                if(sum(names == names(j)) > 1)
                    ind = find(names == names(j), 1, 'last');
                    names(ind) = names(ind) + " v2";
                end
                end

                data_struct.trial_names = names;
                obj.norm_list = [obj.norm_list data_struct];
            end
        end
    end

    function dynamic_plotting(obj)

        % Create a GUI figure with a grid layout
        [option_panel, plot_panel, screen_size] = dataProcessingUI.setup_fig();
       
        tree_y = screen_size(4) - 400;
        t = uitree(option_panel,'checkbox');
        t.Position = [20 tree_y 200 300];
        % Assign callback in response to node selection
        t.CheckedNodesChangedFcn = @(src, event) select(src, event, plot_panel);
        for i = 1:length(obj.dim_list)
            data_struct = obj.dim_list(i);
            parent = uitreenode(t, 'Text',data_struct.dir_name);

            for j = 1:length(data_struct.trial_names)
                child = uitreenode(parent, 'Text',data_struct.trial_names(j));
            end
        end
        
        drop_y = tree_y - 35;
        d1 = uidropdown(option_panel);
        d1.Position = [20 drop_y 200 30];
        d1.Items = obj.axes_labels;
        d1.ValueChangedFcn = @(src, event) index_change(src, event, plot_panel);

        button_y = drop_y - 35;
        b = uibutton(option_panel,"state");
        b.Text = "Normalize?";
        b.Position = [20 button_y 160 30];
        b.BackgroundColor = [1 1 1];
        b.ValueChangedFcn = @(src, event) norm_change(src, event, plot_panel);

        AoA_y = 160;
        s = uislider(option_panel,"range");
        s.Position = [20 AoA_y - 100 200 3];
        s.Limits = obj.range;
        s.Value = obj.range;
        s.MajorTicks = [-16 -12 -8 -4 0 4 8 12 16];
        s.MinorTicks = [-14.5 -13 -11:1:-9 -7.5:0.5:-4.5 -3.5:0.5:-0.5 0.5:0.5:3.5 4.5:0.5:7.5 9:1:11 13 14.5];
        s.ValueChangedFcn = @(src, event) AoA_change(src, event, plot_panel);

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

        function select(~, event, plot_panel)
            % event.SelectedNodes.Text
            % event.Source.CheckedNodes
            
            % Get the selected node
            selectedNodes = event.CheckedNodes;

            obj.selection = strings(0);
                
            for i = 1:length(selectedNodes)
                % Get the parent node
                parentNode = selectedNodes(i).Parent;

                cur_node_str = convertCharsToStrings(selectedNodes(i).Text);
                full_str = parentNode.Text + "/" + cur_node_str;
                obj.selection = [obj.selection full_str];
            end
    
            obj.update_plot(plot_panel);
        end
    
        function index_change(src, ~, plot_panel)
            obj.index = find(obj.axes_labels == src.Value) - 1;
            obj.update_plot(plot_panel);
        end

        function norm_change(src, ~, plot_panel)
            if (src.Value)
                obj.norm = true;
                src.BackgroundColor = [0.3010 0.7450 0.9330];
                src.Text = "Normalized";
            else
                obj.norm = false;
                src.BackgroundColor = [1 1 1];
                src.Text = "Normalize?";
            end

            obj.update_plot(plot_panel);
        end
    
        function AoA_change(src, ~, plot_panel)
            % ensure that slider can only be moved to discrete
            % acceptable locations where a measurement was
            % recorded
            AoA = obj.angles;
            [M, I] = min(abs(AoA - src.Value(1)));
            AoA_min = AoA(I);
            [M, I] = min(abs(AoA - src.Value(2)));
            AoA_max = AoA(I);
            src.Value = [AoA_min AoA_max];
    
            % update range property
            obj.range = src.Value;
    
            obj.update_plot(plot_panel);
        end
        %-----------------------------------------------------%
        %-----------------------------------------------------%
        
    end
end

methods(Static, Access = private)
    function [option_panel, plot_panel, screen_size] = setup_fig()
        monitor_positions = get(0, 'MonitorPositions');
        
        % Check if a second monitor exists
        if size(monitor_positions, 1) >= 2
            screen_size = monitor_positions(2, :);
        else
            disp('A second monitor is not detected.');
            screen_size = monitor_positions(2, :);
        end
        
        fig = uifigure('Name', 'Dynamic Lift Force Plotting', ...
            'Position', [screen_size(1) screen_size(2) + 40 screen_size(3) screen_size(4) - 70]);
        
        % Create a grid layout
        plot_grid = uigridlayout(fig, [1, 2]);
        plot_grid.RowHeight = {'1x'};
        plot_grid.ColumnWidth = {200, '1x'};
        
        % Panel for dropdowns
        option_panel = uipanel(plot_grid);
        option_panel.Layout.Row = 1;
        option_panel.Layout.Column = 1;
        
        % Panel for plots
        plot_panel = uipanel(plot_grid);
        plot_panel.Layout.Row = 1;
        plot_panel.Layout.Column = 2;
        end

    function St = freqToSt(wing_freq, wind_speed)
        % Constant values based on geometry of wings and robot design
        wing_span = 0.25; % meters, length of single wing
        wing_chord = 0.10; % meters
        wing_length = 0.31; % meters, distance from wingtip to axis of rotation
        angle_up = 30; % degrees
        angle_down = 30; % degrees
        
        amplitude = wing_length * (sind(angle_up) + sind(angle_down));
        % m, vertical distance traversed by wings during a full stroke, a
        % single wingbeat consists of two strokes: upstroke & downstroke
        
        St = (wing_freq * amplitude) / wind_speed;
        St = round(St,2,"significant");
    end

    function St_str = freqToSt_str(trial_name, dir_name)
        wing_freq = str2double(extractBefore(trial_name, " Hz"));
        dir_strings = split(dir_name, "_");
        wind_speed = str2double(extractBefore(dir_strings(end), "m.s"));
        St = dataProcessingUI.freqToSt(wing_freq, wind_speed);
        St_str = " St: " + St;
    end
end

methods (Access = private)
    function update_plot(obj, plot_panel)
        delete(plot_panel.Children)
        
        struct_matches = [];
        for i = 1:length(obj.selection)
            dir_name = extractBefore(obj.selection(i), "/");
            if (obj.norm)
                struct_match = obj.norm_list(contains([obj.norm_list.dir_name], dir_name));
            else
                struct_match = obj.dim_list(contains([obj.dim_list.dir_name], dir_name));
            end
            % check for repeat files to load
            if (length(struct_matches) == 0 || sum(contains([struct_matches.dir_name], struct_match.dir_name)) == 0)
                struct_matches = [struct_matches struct_match];
            end
        end
        disp("Found following matches:")
        disp(struct_matches)

        x_label = "Angle of Attack (deg)";
        if (obj.norm)
            y_label_F = "Cycle Average Force Coefficient";
            y_label_M = "Cycle Average Moment Coefficient";
        else
            y_label_F = "Cycle Average Force (N)";
            y_label_M = "Cycle Average Moment (N*m)";
        end
        y_labels = [y_label_F, y_label_F, y_label_F, y_label_M, y_label_M, y_label_M];
        titles = ["Drag", "Transverse Lift", "Lift", "Roll Moment", "Pitch Moment (LE)", "Yaw Moment"];

        colors = ["#3BD9A5";"#D9CD3B";"#9E312C";"#333268";...
            "#2C3331";"#4BEA59";"#845A4F";"#84804F";"#673BD9";"#D95A3B";"#645099";"#4F8473"];
        % colors = ["#7f2704"; "#a63603"; "#d94801"; "#f16913"; "#fd8d3c"; "#fdae6b"; "#fdd0a2"; "#fee6ce"];
        % colors(:,:,2) = ["#3f007d"; "#54278f"; "#6a51a3"; "#807dba"; "#9e9ac8"; "#bcbddc"; "#dadaeb"; "#efedf5"];

        lim_AoA_sel = obj.angles(obj.angles >= obj.range(1) & obj.angles <= obj.range(2));

        if (obj.index == 0)
            % Initialize tiled layout for plots
            tcl = tiledlayout(plot_panel, 2, 3, 'Padding', 'compact', 'TileSpacing', 'compact');
            % UPDATE_PLOT  Update the plot based on selected settings
            % delete(tcl.Children);

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

            for i = 1:length(struct_matches)
                disp("Loading " + "plot data/" + struct_matches(i).file_name)
                load("plot data/" + struct_matches(i).file_name, "avg_forces", "err_forces")
                lim_avg_forces = avg_forces(:,obj.angles >= obj.range(1) & obj.angles <= obj.range(2),:);
                lim_err_forces = err_forces(:,obj.angles >= obj.range(1) & obj.angles <= obj.range(2),:);
    
                for j = 1:length(obj.selection)
                    dir_name = extractBefore(obj.selection(j), "/");
                    trial_name = extractAfter(obj.selection(j), "/");
                    if (contains(struct_matches(i).dir_name, dir_name))
                        if (obj.norm)
                            St_str = dataProcessingUI.freqToSt_str(trial_name, dir_name);
                            freq_index = find(struct_matches(i).trial_names == St_str);
                        else
                            freq_index = find(struct_matches(i).trial_names == trial_name);
                        end
                        for idx = 1:6
                        hold(tiles(idx), 'on');
                        e = errorbar(tiles(idx), lim_AoA_sel, lim_avg_forces(idx,:,freq_index), lim_err_forces(idx,:,freq_index),'.');
                        e.MarkerSize = 20;
                        e.Color = colors(j);
                        e.MarkerFaceColor = colors(j);
                        e.DisplayName = strrep(obj.selection(j), "_", " ");
                        % e.Marker = markers(m);

                        % s = scatter(tiles(idx), lim_AoA_sel, lim_avg_forces(idx,:,freq_index), 40, "filled");
                        % s.DisplayName = strrep(obj.selection(j), "_", " ");
                        % s.MarkerFaceColor = colors(j);
                        % s.MarkerEdgeColor = colors(j);
                        end
                    end
                end
           end

        else
            ax = axes(plot_panel);
            idx = obj.index;
            for i = 1:length(struct_matches)
                disp("Loading " + "plot data/" + struct_matches(i).file_name)
                load("plot data/" + struct_matches(i).file_name, "avg_forces")
                lim_avg_forces = avg_forces(:,obj.angles >= obj.range(1) & obj.angles <= obj.range(2),:);
                for j = 1:length(obj.selection)
                    dir_name = extractBefore(obj.selection(j), "/");
                    trial_name = extractAfter(obj.selection(j), "/");
                    if (contains(struct_matches(i).dir_name, dir_name))
                        if (obj.norm)
                            St_str = dataProcessingUI.freqToSt_str(trial_name, dir_name);
                            freq_index = find(struct_matches(i).trial_names == St_str);
                        else
                            freq_index = find(struct_matches(i).trial_names == trial_name);
                        end
                        hold(ax, 'on');
                        s = scatter(ax, lim_AoA_sel, lim_avg_forces(idx,:,freq_index), 40, "filled");
                        s.DisplayName = strrep(obj.selection(j), "_", " ");
                        s.MarkerFaceColor = colors(j);
                        s.MarkerEdgeColor = colors(j);
                    end
                end
            end

            title(ax, titles(idx));
            xlabel(ax, x_label);
            ylabel(ax, y_labels(idx))
            grid(ax, 'on');
            legend(ax);
        end
    end
end
end