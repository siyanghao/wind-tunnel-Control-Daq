% Or is this more so finding the neutral point than the
% aerodynamic center since there is a body and tail and such

function [NP_pos, NP_mom] = findNP(mean_results, AoA_sel, plot_bool, sub_title)
    % increment to shift position where moments are considered
    diff_shift = 0.0001;
    % cutoff threshold for what's considered zero slope
    slope_margin = 0.000001;

    % initial regression to check which direction to shift in
    pitch_moment = mean_results(5,:,:,:,:);

    x = [ones(size(AoA_sel')), AoA_sel'];
    y = pitch_moment';
    og_b = x\y;
    og_model = x*og_b;
    og_Rsq = 1 - sum((y - og_model).^2)/sum((y - mean(y)).^2);
    og_slope = og_b(2);

    cur_slope = og_slope;
    Rsq = og_Rsq;

    % direction to shift dependent on initial value of slope
    if (cur_slope > 0)
        diff_shift = -diff_shift;
    end
    prev_slope = cur_slope*2;

    shift_distance = 0;
    iter = 0;
    max_iter = 100000;
    Rsq_vals = zeros(1,10000);
    res_vals = zeros(1,10000);
    % keep adjusting COP position until slope falls within
    % certain bounds of zero as long as the magnitude of the
    % slope is decreasing and max number of iterations is not
    % exceeded and the residual error of the linear fit is below
    % a threshold
    while(abs(cur_slope) > slope_margin && abs(cur_slope) < abs(prev_slope) && iter < max_iter)
        prev_slope = cur_slope;
        shift_distance = shift_distance + diff_shift;
    
        shifted_results = shiftPitchMom(mean_results, AoA_sel, shift_distance);
        shifted_pitch_moment = shifted_results(5,:,:,:,:);
    
        x = [ones(size(AoA_sel')), AoA_sel'];
        y = shifted_pitch_moment';
        b = x\y;
        model = x*b;
        Rsq = 1 - sum((y - model).^2) / sum((y - mean(y)).^2);
        res = sum((y - model).^2);
        cur_slope = b(2);
    
        iter = iter + 1;
        Rsq_vals(iter) = Rsq;
        res_vals(iter) = res;
    end

    NP_mom = mean(shifted_pitch_moment);
    NP_pos = shift_distance;
    [NP_pos_LE, NP_pos_chord] = posToChord(NP_pos);
    disp("Number of iterations " + iter)
    disp("Neutral point located at the " + NP_pos_chord + "% chord")
    disp("Starting slope of " + og_slope)
    disp("Final slope of " + cur_slope)
    disp("Reduced by a factor of " + round((og_slope / cur_slope), 1) )

    if plot_bool
        colors = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250];...
    [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]; [0.3010 0.7450 0.9330]];

        figure
        hold on
        s_old = scatter(AoA_sel, pitch_moment, 25, "filled");
        s_old.HandleVisibility = "off";
        s_old.MarkerFaceColor = colors(1,:);
        s_old.MarkerEdgeColor = colors(1,:);
        line_old = plot(AoA_sel, og_model);
        line_old.Color = colors(1,:);

        s_new = scatter(AoA_sel, shifted_pitch_moment, 25, "filled");
        s_new.HandleVisibility = "off";
        s_new.MarkerFaceColor = colors(2,:);
        s_new.MarkerEdgeColor = colors(2,:);
        line_new = plot(AoA_sel, model);
        line_new.Color = colors(2,:);

        hold off
        line_old.DisplayName = "Original, y = " + og_b(2) +...
            "x + " + og_b(1) + "   R^2 = " + og_Rsq;
        line_new.DisplayName = "Flattened, y = " + b(2) +...
            "x + " + b(1) + "   R^2 = " + Rsq;
        xlabel("Angle of Attack (deg)")
        ylabel("Pitching Moment (N*m)")
        legend(Location="best", FontSize=18);
        title(sub_title, FontSize=18);
    end
end