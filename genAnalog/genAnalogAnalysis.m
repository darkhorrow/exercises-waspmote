clear all;

WINDOW_SIZE = 10;

data = readmatrix('SAMPLES.TXT');

x = data(:, 1);
y = data(:, 2);

figure(1);

plot(x, y);

amplitude = max(y);

filtered_y = [];

for index=1:WINDOW_SIZE:size(y, 1)
    upper_window = index+(WINDOW_SIZE-1);
    
    if upper_window > size(y, 1)
        upper_window = upper_window - mod(index+WINDOW_SIZE-1, size(y, 1));
    end
    
    filtered_y(end+1) = mean(y(index:upper_window));
end

noise_ratio = snr(rms(y), rms(filtered_y));
