% I made this code to estimate what acceleration and number of cycles
% would be necessary to get the stepper motor up to speed.
% Ronan Gissler January 2022

rev_ticks = 51200;
init_pos = 0;
init_vel = 0;
acc = 150000; % 2000 counts/sec
desired_vel = 3*rev_ticks; % 1  rev/sec
measure_revs = 100;
wait_time = 2;

time_to_speed = desired_vel / acc;
disp("It will take " + time_to_speed + ...
     " seconds, for the system to reach " + (desired_vel/rev_ticks) ...
     + " Hz")
at_speed_pos = init_pos + (init_vel * time_to_speed) ...
             + (0.5 * acc * (time_to_speed^2));
disp("By the time it reached " + (desired_vel/rev_ticks) ...
     + " Hz, it would have travelled " + (at_speed_pos/rev_ticks) ...
     + " revolutions")
num_revs = measure_revs + 2*(at_speed_pos/rev_ticks);
session_duration = measure_revs/(desired_vel/rev_ticks) + 2*time_to_speed + 2*wait_time;
disp("The session duration at the speed of " + ...
    (desired_vel/rev_ticks) + " Hz, would be " + num_revs + ...
    " revs or " + session_duration + " seconds")
