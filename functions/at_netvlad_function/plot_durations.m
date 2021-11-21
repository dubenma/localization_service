function plot_durations(durs)
%PLOT_DURATIONS Summary of this function goes here
%   Detailed explanation goes here

vals_num = size(durs, 2);

figure; hold on;
plot(1:vals_num, durs(1,:), 'r.');
plot(1:vals_num, durs(2,:), 'g.');
plot(1:vals_num, durs(3,:), 'b.');
plot(1:vals_num, durs(4,:), 'k.');

legend("Matlab (originální)", "MKL", "Eigen", "cuBLAS");
xlabel("Opakování měření (" + vals_num + "x)");
ylabel("Trvání [s]");
title("Rychlost implementací get\_tcs");

end

