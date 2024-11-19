clear;clc;
fre_arr = [50, 63, 80, 100, 125, 160, 200, 250, 315, 400, ...
            500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, ...
            5000, 6300, 8000, 10000];
SPL_arr = [100.3, 100.4, 100.6, 99.5, 98.8, 97.8, 97.8, 96.3, 94.6, 94.1, ...
            94.3, 94.6, 96.5, 97, 95.1, 93.9, 94.2, 94.5, 91.1, 91.6, ...
            91.4, 91.6, 90.9, 87.2];

n_arr = [27.9, 29.9, 36.8, 39.4, 39.4, 39.4, 45.3, 42.2, 42.2, 42.2, ...
            42.2, 45.3, 52, 52, 52, 62.7, 72, 88.6, 72, 77.2, ...
            67.2, 67.2, 51, 31.5];
N = 0.85 * max(n_arr) + 0.15 * sum(n_arr);

PNL = 40.0 + 10 * log10(N) / log10(2);

%% Tone correction

%% Step 1
s_arr = zeros(24, 1);
for i = 4:24
    s_arr(i) = SPL_arr(i) - SPL_arr(i - 1);
end

%% Step 2
delta_s_arr = zeros(24, 1);
encircle_2 = zeros(24, 1);
for i = 5:24
    delta_s_arr(i) = s_arr(i) - s_arr(i - 1);
    if abs(delta_s_arr(i)) > 5
        encircle_2(i) = 1;
    end
end

%% Step 3
encircle_3 = zeros(24, 1);
for i = 1:24
    if encircle_2(i) == 1
        if s_arr(i) > 0 && s_arr(i) > s_arr(i - 1)
            encircle_3(i) = 1;
        elseif s_arr(i) <= 0 && s_arr(i - 1) > 0
            encircle_3(i - 1) = 1;
        end
    end
end
%% Step 4
new_SPL_arr = zeros(24, 1);
for i = 1:24
    if i == 24
        new_SPL_arr(24) = SPL_arr(23) + s_arr(23);
    elseif encircle_3(i) == 0
        new_SPL_arr(i) = SPL_arr(i);
    elseif encircle_3(i) == 1
        new_SPL_arr(i) = 0.5 * (SPL_arr(i - 1) + SPL_arr(i + 1));
    end
end

%% Step 5
new_s_arr = zeros(25, 1);
for i = 4:24
    new_s_arr(i) = new_SPL_arr(i) - new_SPL_arr(i - 1);
end
new_s_arr(3) = new_s_arr(4);
new_s_arr(25) = new_s_arr(24);

%% Step 6
s_bar_arr = zeros(23, 1);
for i = 3:23
    s_bar_arr(i) = (new_s_arr(i) + new_s_arr(i + 1) + new_s_arr(i + 2)) / 3;
end

%% Step 7
newnew_SPL_arr = zeros(24, 1);
newnew_SPL_arr(3) = SPL_arr(3);
for i = 4:24
    newnew_SPL_arr(i) = newnew_SPL_arr(i - 1) + s_bar_arr(i - 1);
end
%% Step 8
F_arr = zeros(24, 1);
for i = 3:24
    F_arr(i) = SPL_arr(i) - newnew_SPL_arr(i);
end
%% Step 9
C_arr = zeros(24, 1);
for i = 3:24
    if fre_arr(i) <= 500 
        if F_arr(i) >= 1.5 && F_arr(i) < 3
            C_arr(i) = F_arr(i) / 3 - 0.5;
        elseif F_arr(i) >= 3 && F_arr(i) < 20
            C_arr(i) = F_arr(i) / 6;
        elseif F_arr(i) >= 20
            C_arr(i) = 10 / 3;
        end
    elseif fre_arr(i) >= 500 && fre_arr(i) <= 5000
        if F_arr(i) >= 1.5 && F_arr(i) < 3
            C_arr(i) = 2 * F_arr(i) / 3 - 1;
        elseif F_arr(i) >= 3 && F_arr(i) < 20
            C_arr(i) = F_arr(i) / 3;
        elseif F_arr(i) >= 20
            C_arr(i) = 20 / 3;
        end
    elseif fre_arr(i) >= 5000 && fre_arr(i) <= 10000
        if F_arr(i) >= 1.5 && F_arr(i) < 3
            C_arr(i) = F_arr(i) / 3 - 0.5;
        elseif F_arr(i) >= 3 && F_arr(i) < 20
            C_arr(i) = F_arr(i) / 6;
        elseif F_arr(i) >= 20
            C_arr(i) = 10 / 3;
        end
    end
end
%% Step 10
max_C = max(C_arr);
PNLT = PNL + max_C;
PNLTM = PNLT;

D = 10 * log10(sum(10 ^ (PNLT / 10))) - PNLTM - 13;

EPNL = PNLTM + D;
disp(EPNL);