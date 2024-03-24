function plot_forces_AoA(selected_vars, avg_forces, err_forces, names, sub_title, nondimensional, forceIndex)
    AoA_sel = selected_vars.AoA;
    wing_freq_sel = selected_vars.freq;
    wind_speed_sel = selected_vars.wind;
    type_sel = selected_vars.type;

    regression = true;
    error = false;
    
    if (forceIndex == 0)
    
    x_label = "Angle of Attack (deg)";
    if (nondimensional)
        y_label_F = "Trial Average Force Coefficient";
        y_label_M = "Trial Average Moment Coefficient";
    else
        y_label_F = "Trial Average Force (N)";
        y_label_M = "Trial Average Moment (N*m)";
    end
    axes_labels = [x_label, y_label_F, y_label_M];
    
    colors = [[0, 0.4470, 0.7410]; [0.8500, 0.3250, 0.0980]; ...
            [0.9290, 0.6940, 0.1250]; [0.4940, 0.1840, 0.5560]; ...
            [0.4660, 0.6740, 0.1880]; [0.3010, 0.7450, 0.9330]; ...
            [0.6350, 0.0780, 0.1840]; [0.25, 0.25, 0.25]];
    
    % Open a new figure.
    f = figure;
    f.Position = [200 50 900 560];
    tcl = tiledlayout(2,3);
        
    % Create three subplots to show the force time histories. 
    nexttile(tcl)
    hold on
    for j = 1:length(wing_freq_sel)
    for m = 1:length(wind_speed_sel)
    for n = 1:length(type_sel)
        
    if (error)
    e = errorbar(AoA_sel, avg_forces(1, :, j, m, n), err_forces(1, :, j, m, n),'.');
    e.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    e.MarkerSize = 20;
    elseif (regression)
    s = scatter(AoA_sel, avg_forces(1, :, j, m, n), 25, HandleVisibility="off");
    s.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    x = [ones(size(AoA_sel')), AoA_sel'];
    y = avg_forces(:, j, 1)';
    b = x\y;
    model = x*b;
    Rsq = 1 - sum((y - model).^2)/sum((y - mean(y)).^2);
    label = "R^2 = " + Rsq;
    plot(AoA_sel, model, DisplayName=label, Color=colors(j,:))
    else
    s = scatter(AoA_sel, avg_forces(1, :, j, m, n), 25, 'filled',"HandleVisibility","off");
    s.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    end
    
    end
    end
    end
    hold off
    title(["F_x (streamwise)"]);
    xlabel(axes_labels(1));
    ylabel(axes_labels(2));
    
    nexttile(tcl)
    hold on
    for j = 1:length(wing_freq_sel)
    for m = 1:length(wind_speed_sel)
    for n = 1:length(type_sel)
        
    if (error)
    e = errorbar(AoA_sel, avg_forces(2, :, j, m, n), err_forces(2, :, j, m, n),'.');
    e.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    e.MarkerSize = 20;
    elseif (regression)
    s = scatter(AoA_sel, avg_forces(2, :, j, m, n), 25, HandleVisibility="off");
    s.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    x = [ones(size(AoA_sel')), AoA_sel'];
    y = avg_forces(:, j, 2)';
    b = x\y;
    model = x*b;
    Rsq = 1 - sum((y - model).^2)/sum((y - mean(y)).^2);
    label = "R^2 = " + Rsq;
    plot(AoA_sel, model, DisplayName=label, Color=colors(j,:))
    else
    s = scatter(AoA_sel, avg_forces(2, :, j, m, n), 25, 'filled',"HandleVisibility","off");
    s.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    end
    
    end
    end
    end
    hold off
    title(["F_y (transverse)"]);
    xlabel(axes_labels(1));
    
    nexttile(tcl)
    hold on
    for j = 1:length(wing_freq_sel)
    for m = 1:length(wind_speed_sel)
    for n = 1:length(type_sel)
        
    if (error)
    e = errorbar(AoA_sel, avg_forces(3, :, j, m, n), err_forces(3, :, j, m, n),'.');
    e.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    e.MarkerSize = 20;
    elseif (regression)
    s = scatter(AoA_sel, avg_forces(3, :, j, m, n), 25, HandleVisibility="off");
    s.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    x = [ones(size(AoA_sel')), AoA_sel'];
    y = avg_forces(:, j, 3)';
    b = x\y;
    model = x*b;
    Rsq = 1 - sum((y - model).^2)/sum((y - mean(y)).^2);
    label = "R^2 = " + Rsq;
    plot(AoA_sel, model, DisplayName=label, Color=colors(j,:))
    else
    s = scatter(AoA_sel, avg_forces(3, :, j, m, n), 25, 'filled',"HandleVisibility","off");
    s.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    end
    
    end
    end
    end
    hold off
    title(["F_z (vertical)"]);
    xlabel(axes_labels(1));
    
    % Create three subplots to show the moment time histories.
    nexttile(tcl)
    hold on
    for j = 1:length(wing_freq_sel)
    for m = 1:length(wind_speed_sel)
    for n = 1:length(type_sel)
        
    if (error)
    e = errorbar(AoA_sel, avg_forces(4, :, j, m, n), err_forces(4, :, j, m, n),'.');
    e.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    e.MarkerSize = 20;
    elseif (regression)
    s = scatter(AoA_sel, avg_forces(4, :, j, m, n), 25, HandleVisibility="off");
    s.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    x = [ones(size(AoA_sel')), AoA_sel'];
    y = avg_forces(:, j, 4)';
    b = x\y;
    model = x*b;
    Rsq = 1 - sum((y - model).^2)/sum((y - mean(y)).^2);
    label = "R^2 = " + Rsq;
    plot(AoA_sel, model, DisplayName=label, Color=colors(j,:))
    else
    s = scatter(AoA_sel, avg_forces(4, :, j, m, n), 25, 'filled',"HandleVisibility","off");
    s.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    end
    
    end
    end
    end
    hold off
    title(["M_x (roll)"]);
    xlabel(axes_labels(1));
    ylabel(axes_labels(3));
    
    nexttile(tcl)
    hold on
    for j = 1:length(wing_freq_sel)
    for m = 1:length(wind_speed_sel)
    for n = 1:length(type_sel)
        
    if (error)
    e = errorbar(AoA_sel, avg_forces(5, :, j, m, n), err_forces(5, :, j, m, n),'.');
    e.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    e.MarkerSize = 20;
    elseif (regression)
    s = scatter(AoA_sel, avg_forces(5, :, j, m, n), 25, HandleVisibility="off");
    s.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    x = [ones(size(AoA_sel')), AoA_sel'];
    y = avg_forces(:, j, 5)';
    b = x\y;
    model = x*b;
    Rsq = 1 - sum((y - model).^2)/sum((y - mean(y)).^2);
    label = "R^2 = " + Rsq;
    plot(AoA_sel, model, DisplayName=label, Color=colors(j,:))
    else
    s = scatter(AoA_sel, avg_forces(5, :, j, m, n), 25, 'filled',"HandleVisibility","off");
    s.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    end
    
    end
    end
    end
    hold off
    title(["M_y (pitch)"]);
    xlabel(axes_labels(1));
    
    nexttile(tcl)
    hold on
    for j = 1:length(wing_freq_sel)
    for m = 1:length(wind_speed_sel)
    for n = 1:length(type_sel)
        
    if (error)
    e = errorbar(AoA_sel, avg_forces(6, :, j, m, n), err_forces(6, :, j, m, n),'.');
    e.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    e.MarkerSize = 20;
    elseif (regression)
    s = scatter(AoA_sel, avg_forces(6, :, j, m, n), 25, HandleVisibility="off");
    s.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    x = [ones(size(AoA_sel')), AoA_sel'];
    y = avg_forces(:, j, 6)';
    b = x\y;
    model = x*b;
    Rsq = 1 - sum((y - model).^2)/sum((y - mean(y)).^2);
    label = "R^2 = " + Rsq;
    plot(AoA_sel, model, DisplayName=label, Color=colors(j,:))
    else
    scatter(AoA_sel, avg_forces(6, :, j, m, n), 25, 'filled',"HandleVisibility","off");
    s.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
    end
    
    end
    end
    end
    hold off
    title(["M_z (yaw)"]);
    xlabel(axes_labels(1));
    

    hL = legend(names);
    hL.Layout.Tile = 'East';

    % Label the whole figure.
    sgtitle(["Force and Moment Means vs. Angle of Attack" sub_title]);
    
    else
         x_label = "Angle of Attack (deg)";
        if (nondimensional)
            y_label_F = "Cycle Average Force Coefficient";
            y_label_M = "Cycle Average Moment Coefficient";
        else
            y_label_F = "Cycle Average Force (N)";
            y_label_M = "Cycle Average Moment (N*m)";
        end
        y_labels = [y_label_F, y_label_F, y_label_F, y_label_M, y_label_M, y_label_M];
        titles = ["Drag", "Transverse Lift", "Lift", "Roll Moment", "Pitch Moment", "Yaw Moment"];
        colors(:,:,1) = [[189, 201, 225]; [116, 169, 207]; [5, 112, 176]];
        colors(:,:,2) = [[253,204,138]; [252,141,89]; [215,48,31]];
        colors = colors / 255;
        % Open a new figure.
        % f = figure;
        % f.Position = [200 50 900 560];
        
        hold on
        for n = 1:length(type_sel)
        for j = 1:length(wing_freq_sel)
        for m = 1:length(wind_speed_sel)

        if (error)
        markers = ["o", "pentagram"];
        e = errorbar(AoA_sel, avg_forces(forceIndex, :, j, m, n), err_forces(forceIndex, :, j, m, n),'.');
%         e.Color = colors(n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
%         e.MarkerSize = 20;

%         e.Color = colors(3 + n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
%         e.MarkerFaceColor = colors(3 + n + (m-1)*length(type_sel) + (j-1)*length(wind_speed_sel)*length(type_sel),:);
%         e.MarkerSize = 8;
%         e.Marker = markers(n);
        e.Color = colors(j,:,n);
        e.MarkerFaceColor = colors(j,:,n);
        e.MarkerSize = 10;
        e.Marker = markers(m);
        e.DisplayName = names(j,m,n);
        elseif (regression)
        s = scatter(AoA_sel, avg_forces(forceIndex, :, j, m, n), 25, HandleVisibility="off");
        s.MarkerEdgeColor = colors(j,:,n);
        s.MarkerFaceColor = colors(j,:,n);
        x = [ones(size(AoA_sel')), AoA_sel'];
        y = avg_forces(forceIndex, :, j, m, n)';
        b = x\y;
        model = x*b;
        Rsq = 1 - sum((y - model).^2)/sum((y - mean(y)).^2);
        label = names(j,m,n) + ", y = " + b(2) + "x + " + b(1) + "   R^2 = " + Rsq;
        plot(AoA_sel, model, DisplayName=label, Color=colors(j,:,n))
        else
        s = scatter(AoA_sel, avg_forces(forceIndex, :, j, m, n), 100, 'filled');
        s.MarkerEdgeColor = colors(j,:,n);
        s.MarkerFaceColor = colors(j,:,n);
        end

        end
        end
        end
        hold off
        title([titles(forceIndex) sub_title], FontSize=18);
        xlabel(x_label, FontSize=14);
        ylabel(y_labels(forceIndex), FontSize=14);
        legend(Location="best", FontSize=18);
    end
end