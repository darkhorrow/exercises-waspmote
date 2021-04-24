clear all;

WINDOW_SIZE = 10;

data = readmatrix('SAMPLES.TXT');

x = data(:, 1);
y = data(:, 2);

figure(1);

plot(x, y);
xlabel('Tiempo (s)');
ylabel('Voltaje (mV)');
title('Mediciones genAnalog');


amplitude = max(y);

filtered_x = [];
filtered_y = [];

for index=1:WINDOW_SIZE:size(y, 1)
    upper_window = index+(WINDOW_SIZE-1);
    
    if upper_window > size(y, 1)
        upper_window = upper_window - mod(index+WINDOW_SIZE-1, size(y, 1));
    end
    
    filtered_y(end+1) = mean(y(index:upper_window));
    filtered_x(end+1) = mean(x(index:upper_window));
end

figure(2);

plot(filtered_x, filtered_y);
xlabel('Tiempo (s)');
ylabel('Voltaje (mV)');
title('Filtrado de genAnalog');

noise_ratio_mV = rms(y)/rms(filtered_y);
noise_ratio_dB = snr(rms(y), rms(filtered_y));

data_sine = readmatrix('SAMPLES_SINE.TXT');

x_sine = data_sine(:, 1);
y_sine = data_sine(:, 2);

figure(3);

plot(x_sine, y_sine);
xlabel('Tiempo (s)');
ylabel('Voltaje (mV)');
title('Señal sinusoidal genAnalog');
