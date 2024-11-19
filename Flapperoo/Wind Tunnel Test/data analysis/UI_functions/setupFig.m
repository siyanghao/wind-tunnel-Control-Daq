function [option_panel, plot_panel, fig_size] = setupFig(mon_num)
        monitor_positions = get(0, 'MonitorPositions');

        % Check if a second monitor exists
        if size(monitor_positions, 1) >= 2 && mon_num == 2
            screen_size = monitor_positions(2, :);
        elseif mon_num == 1
            screen_size = monitor_positions(1, :);
        else
            disp('A second monitor is not detected.');
            screen_size = monitor_positions(1, :);
        end
        
        fig = uifigure('Name', 'Dynamic Force Plotting');
        fig_size = [screen_size(1) screen_size(2) + 40 screen_size(3) screen_size(4) - 70];
        fig.Position = fig_size;
        
        % Create a grid layout
        plot_grid = uigridlayout(fig, [1, 2]);
        plot_grid.RowHeight = {'1x'};
        plot_grid.ColumnWidth = {200, '1x'};
        % 0.1*screen_size(3)
        
        % Panel for dropdowns
        option_panel = uipanel(plot_grid);
        option_panel.Layout.Row = 1;
        option_panel.Layout.Column = 1;
        option_panel.AutoResizeChildren = false;
        
        % Panel for plots
        plot_panel = uipanel(plot_grid);
        plot_panel.Layout.Row = 1;
        plot_panel.Layout.Column = 2;
end