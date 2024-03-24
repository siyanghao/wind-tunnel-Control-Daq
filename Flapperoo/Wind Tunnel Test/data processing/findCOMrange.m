function [low_pos, high_pos] = findCOMrange(mean_results, AoA_sel)
    center_to_LE = 0.06335; % in meters, distance from center of force transducer to leading edge of wing
    chord = 0.10; % in meters
    
    pitchMoment = mean_results(5,:,:,:,:);

    x = [ones(size(AoA_sel')), AoA_sel'];
    y = pitchMoment';
    b = x\y;
    model = x*b;
    Rsq = 1 - sum((y - model).^2)/sum((y - mean(y)).^2);
    base_slope = b(2);

    % need code to first find shift distance where slope becomes
    % negative

    slope = base_slope;
    shift_distance = 0;
    slopes = zeros(1,10000);
    iter = 0;
    while(slope < 0 && shift_distance > -1)
        shifted_results = shiftPitchMom(mean_results, AoA_sel, shift_distance);
        pitchMoment = shifted_results(5,:,:,:,:);
    
        x = [ones(size(AoA_sel')), AoA_sel'];
        y = pitchMoment';
        b = x\y;
        model = x*b;
        Rsq = 1 - sum((y - model).^2)/sum((y - mean(y)).^2);
        slope = b(2);

        shift_distance = shift_distance - 0.001;
        iter = iter + 1;
        slopes(iter) = slope;
    end
    low_pos = shift_distance;
    avg_slope = sum(slopes) / iter;

    figure
    hold on
    scatter(AoA_sel, pitchMoment, 25, HandleVisibility="off");
    plot(AoA_sel, model)

    cur_slope = base_slope;
    shift_distance = 0;
    while(cur_slope < 0 && shift_distance < 1)
        prev_slope = cur_slope;
        shift_distance = shift_distance + 0.001;

        shifted_results = shiftPitchMom(mean_results, AoA_sel, shift_distance);
        pitchMoment = shifted_results(5,:,:,:,:);
    
        x = [ones(size(AoA_sel')), AoA_sel'];
        y = pitchMoment';
        b = x\y;
        model = x*b;
        Rsq = 1 - sum((y - model).^2)/sum((y - mean(y)).^2);
        cur_slope = b(2);

        if (cur_slope < prev_slope)
            shift_distance = 1;
        end
    end
    high_pos = shift_distance;

    scatter(AoA_sel, pitchMoment, 25, HandleVisibility="off");
    plot(AoA_sel, model)
    hold off

    low_pos_LE = low_pos - center_to_LE;
    percent_chord = -(low_pos_LE / chord) * 100;
    if (round(high_pos,4) == 1)
        disp("Stable COM positions include [" + low_pos + ", inf]")
        disp("[" + percent_chord + " %, inf]")
        disp("Average slope of " + avg_slope)
    end

end