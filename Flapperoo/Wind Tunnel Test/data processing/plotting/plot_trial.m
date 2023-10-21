function plot_trial(file,path, movie_bool)

[case_name, type, wing_freq, AoA, wind_speed] = parse_filename(file);
load(path + file);

x_label = "Time (s)";
y_label_F = "Force (N)";
y_label_M = "Moment (N*m)";
subtitle = "Trimmed, Rotated";
axes_labels = [x_label, y_label_F, y_label_M];
plot_forces(time_data, results_lab, case_name, subtitle, axes_labels);

x_label = "Time (s)";
y_label_F = "Force Coefficient";
y_label_M = "Moment Coefficient";
subtitle = "Trimmed, Rotated, Non-dimensionalized, Filtered";
axes_labels = [x_label, y_label_F, y_label_M];
plot_forces(time_data, filtered_data, case_name, subtitle, axes_labels);

if (wing_freq > 0)
x_label = "Wingbeat Period (t/T)";
y_label_F = "Force Coefficient";
y_label_M = "Moment Coefficient";
axes_labels = [x_label, y_label_F, y_label_M];
subtitle = "Trimmed, Rotated, Non-dimensionalized, Filtered, Wingbeat Averaged, Shaded -> +/- 1 SD";
plot_forces_mean(frames, wingbeat_avg_forces, wingbeat_avg_forces + wingbeat_std_forces, wingbeat_avg_forces - wingbeat_std_forces, case_name, subtitle, axes_labels);

x_label = "Wingbeat Period (t/T)";
y_label_F = "Force (N)";
y_label_M = "Moment (N*m)";
axes_labels = [x_label, y_label_F, y_label_M];
subtitle = "Trimmed, Rotated, Non-dimensionalized, Filtered, Wingbeat Averaged, Shaded -> +/- 1 SD";
plot_forces_mean_subset(frames, wingbeat_avg_forces, wingbeat_avg_forces + wingbeat_std_forces, wingbeat_avg_forces - wingbeat_std_forces, case_name, subtitle, axes_labels);

x_label = "Wingbeat Period (t/T)";
y_label_F = "Force Coefficient";
y_label_M = "Moment Coefficient";
axes_labels = [x_label, y_label_F, y_label_M];
subtitle = "Trimmed, Rotated, Non-dimensionalized, Filtered, Wingbeat Averaged, Shaded -> Range";
plot_forces_mean(frames, wingbeat_avg_forces, wingbeat_max_forces, wingbeat_min_forces, case_name, subtitle, axes_labels);

x_label = "Wingbeat Period (t/T)";
y_label_F = "RMSE";
y_label_M = "RMSE";
axes_labels = [x_label, y_label_F, y_label_M];
subtitle = "Trimmed, Rotated, Non-dimensionalized, Filtered, Wingbeat RMS'd";
plot_forces(frames, wingbeat_rmse_forces, case_name, subtitle, axes_labels);

COP = wingbeat_avg_forces(:,5) ./ wingbeat_avg_forces(:,3); % M_y / F_z
% fc = 20; % cutoff frequency
% fs = 9000;
% [b,a] = butter(6,fc/(fs/2));
% filtered_COP = filtfilt(b,a,COP);
f = figure;
f.Position = [200 50 900 560];
plot(frames, COP)
% plot(frames, filtered_COP)
% plot(frames, wingbeat_COP)
ylim([-1, 1])
title("Movement of Center of Pressure for " + case_name)
xlabel("Wingbeat Period (t/T)");
ylabel("COP Location (m)");
end

if (movie_bool)
    y_label_F = "Force Coefficient";
    y_label_M = "Moment Coefficient";
    axes_labels = [x_label, y_label_F, y_label_M];
    subtitle = "Trimmed, Rotated, Non-dimensionalized, Filtered, Wingbeat Averaged";
    wingbeat_movie(frames, wingbeat_forces, case_name, subtitle, axes_labels);
end

subtitle = "Trimmed, Rotated, Non-dimensionalized, Power Spectrum";
plot_spectrum(freq, freq_power, dominant_freq, case_name, subtitle)

kinematics_bool = true;

if (kinematics_bool)

    % wind_speed = 100;
    [time, lin_vel] = get_kinematics(true);
    time = time / wing_freq;
    eff_AoA = zeros(size(lin_vel));
    u_rel = zeros(size(lin_vel)); % u_rel is opposite lin_vel

    v_x = -lin_vel * sind(AoA);
    v_y = -lin_vel * cosd(AoA);
    for i = 1:length(time)
        vec_mag = ((v_x(i,:) + wind_speed).^2 + v_y(i,:).^2).^(1/2);
        u_rel(i,:) = vec_mag;

        cross_prod = -((v_x(i,:) + wind_speed)*(-sind(AoA)) - v_y(i,:)*(cosd(AoA)));
        eff_AoA(i,:) = asind(cross_prod ./ vec_mag);
    %     dot_prod = (v_x(i,:) + wind_speed)*(cosd(AoA)) + v_y(i,:)*(-sind(AoA));
    %     eff_AoA(i,:) = acosd(dot_prod ./ vec_mag);
    end
    % Relative AoA

    % for i = 1:length(time)
    %     if (lin_vel(i,5) < 0) % downstroke
    %         mid_angle = 90 + AoA; % angle between freestream and wing vel
    %     else % downstroke 
    %         mid_angle = 90 - AoA; % angle between freestream and wing vel
    %     end
    % 
    % %     if (wind_speed == 0)
    % %         u_rel(i,:) = -lin_vel(i,:);
    % %     else
    %         u_rel(i,:) = (wind_speed^2 + lin_vel(i,:).^2 - 2*wind_speed*abs(lin_vel(i,:))*cosd(mid_angle)).^(1/2); % Law of Cosines
    %     end
    % %     if (lin_vel(i,5) > 0)
    % %         u_rel(i,:) = -u_rel(i,:);
    % %     end
    % %     U_angle = asind(lin_vel(i,:) .* (sind(mid_angle) ./ u_rel(i,:))); % Law of Sines
    % %     eff_AoA(i,:) = AoA - U_angle;
    % %     if (lin_vel(i,5) < 0) % downstroke 
    % %         eff_AoA(i,:) = -eff_AoA(i,:);
    % %     end
    % end

    % case_name = "100m.s 14deg 5Hz";

    fig = figure;
    fig.Position = [200 50 900 560];
    hold on
    plot(time, u_rel(:,51), DisplayName="r = 0.05")
    plot(time, u_rel(:,151), DisplayName="r = 0.15")
    plot(time, u_rel(:,251), DisplayName="r = 0.25")
    hold off
    xlabel("Time (s)")
    ylabel("Effective Wind Speed (m/s)")
    title("Effective Wind Speed during Flapping for " + case_name)
    legend(Location="northeast")

    fig = figure;
    fig.Position = [200 50 900 560];
    hold on
    plot(time, eff_AoA(:,51), DisplayName="r = 0.05")
    plot(time, eff_AoA(:,151), DisplayName="r = 0.15")
    plot(time, eff_AoA(:,251), DisplayName="r = 0.25")
    hold off
    xlabel("Time (s)")
    ylabel("Effective Angle of Attack (deg)")
    title("Effective Angle of Attack during Flapping for " + case_name)
    legend(Location="northeast")
end
end