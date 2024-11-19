clear;clc;
load('ampArr.mat', 'ampArr');
amp_arr = ampArr;

fre_arr = [50, 63, 80, 100, 125, 160, 200, 250, 315, 400, ...
            500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, ...
            5000, 6300, 8000, 10000];

t_start = 0;
t_end = 10;
step = 0.5;

t = t_start:step:t_end;
% disp(length(t));
% disp(size(ampArr));
% 检查ampArr的大小以确保与时间向量匹配
[num_times, num_frequencies] = size(amp_arr);
if num_times ~= length(t)
    error('The number of time points in ampArr does not match the length of the time vector.');
end

% figure;
% for i = 1:num_frequencies
%     subplot(6, 4, i); % 创建6x4的子图布局
%     plot(t, amp_arr(:, i));
%     title(['Frequency ', num2str(i)]);
%     xlabel('Time');
%     ylabel('Amplitude');
% end

% 获取最大值和最小值
max_value = max(amp_arr, [], 'all');
min_value = min(amp_arr, [], 'all');

% 显示结果
disp(['The maximum value in ampArr is: ', num2str(max_value)]);
disp(['The minimum value in ampArr is: ', num2str(min_value)]);

LArr = zeros(num_times, 1);
for i = 1:num_times
    rowEle = ampArr(i, :);
    LArr(i) = 10 * log10(sum(10 .^ (rowEle / 10)));
end
% 画一下总信号
% figure;
% plot(t, LArr)
LArr = round(LArr);



%% calculate noy value
% read appendix
% dataTable = readtable('E:\Ecology\appendix.xlsx');
dataMatrix = readmatrix('E:\Ecology\appendix.xlsx');
% disp(dataMatrix)
% 提取频率和SPL
frequencies = dataMatrix(1, 2:end); % 第一行，去掉第一列
SPL_values = dataMatrix(2:end, 1);  % 第一列，去掉第一行
% disp(frequencies)
% disp(SPL_values)

% 设定目标频率和SPL
target_frequency = 200;
target_SPL = 111;

% 查找目标频率和SPL的索引
frequency_index = find(frequencies == target_frequency);
SPL_index = find(SPL_values == target_SPL);
% disp(frequency_index)
% disp(SPL_index)


% N_arr for each time instant 'k', totally 21
N_arr = zeros(21, 1);
n_arr = zeros(24, 21);
for k = 1:21
    for i = 1:24
        % 查找目标频率和SPL的索引
        frequency_index = find(frequencies == fre_arr(i));
        SPL_index = find(SPL_values == amp_arr(k, i));
        if isempty(frequency_index) || isempty(SPL_index)
            error('未找到对应的频率或SPL');
        else
            % 获取对应的值
            result_value = dataMatrix(SPL_index+1, frequency_index+1);
            if isnan(result_value)
                disp(fre_arr(i))
                disp(amp_arr(k, i))
                error('单元格为空');
            else
                % disp(['单元格的值是: ', num2str(result_value)]);
            end
        end
        n_arr(i, k) = result_value;
    end
end
% n_arr第一个维度是选择frequency，第二个维度是选择时间瞬间

max_n_arr = max(n_arr);
disp(size(max_n_arr))
for k = 1:21
    N_arr(k) = 0.85 * max_n_arr(k) + 0.15 * sum(n_arr(:, k));
end

% disp(N_arr)
% disp(size(N_arr))
PNL_arr = zeros(21, 1);
for k = 1:21
    PNL_arr(k) = 40.0 + 10 * log10(N_arr(k)) / log10(2);
end
%  disp(PNL_arr)


%% tone correction 
SPL_arr = amp_arr'; 
% disp(size(SPL_arr)) ------ 24 * 21
%% Step 1. 'i' from 4 to 24, totally 21.
s_arr = zeros(24, 21);
for k = 1:21
    for i = 4:24
        s_arr(i, k) = SPL_arr(i, k) - SPL_arr(i - 1, k);
    end
end

% disp(s_arr)
%% Step 2. 'i' from 5 to 24, totally 20.
delta_s_arr = zeros(24, 21);
encircle_2 = zeros(24, 21);
for k = 1:21
    for i = 5:24
        delta_s_arr(i, k) = s_arr(i, k) - s_arr(i - 1, k);
        if abs(delta_s_arr(i, k)) > 5
            encircle_2(i, k) = 1;
        end
    end
end
% delta_s_arr 前4行都是0
% encircle_2 前4行都是0
%% Step 3
encircle_3 = zeros(24, 21);
for k = 1:21
    for i = 1:24
        if encircle_2(i, k) == 1
            if s_arr(i, k) > 0 && s_arr(i, k) > s_arr(i - 1, k)
                encircle_3(i, k) = 1;
            elseif s_arr(i, k) <= 0 && s_arr(i - 1, k) > 0
                encircle_3(i - 1, k) = 1;
            end
        end
    end
end


%% Step 4
new_SPL_arr = zeros(24, 21);
for k = 1:21
    for i = 1:24
        if i == 24
            new_SPL_arr(24, k) = SPL_arr(23, k) + s_arr(23, k);
        elseif encircle_3(i, k) == 0
            new_SPL_arr(i, k) = SPL_arr(i, k);
        elseif encircle_3(i, k) == 1
            new_SPL_arr(i, k) = 0.5 * (SPL_arr(i - 1, k) + SPL_arr(i + 1, k));
        end
    end
end

%% Step 5
new_s_arr = zeros(25, 21);
for k = 1:21
    for i = 4:24
        new_s_arr(i, k) = new_SPL_arr(i, k) - new_SPL_arr(i - 1, k);
    end
    new_s_arr(3, k) = new_s_arr(4, k);
    new_s_arr(25, k) = new_s_arr(24, k);
end

%% Step 6
s_bar_arr = zeros(23, 21);
for k = 1:21
    for i = 3:23
        s_bar_arr(i, k) = (new_s_arr(i, k) + new_s_arr(i + 1, k) + new_s_arr(i + 2, k)) / 3;
    end
end

%% Step 7
newnew_SPL_arr = zeros(24, 21);
for k = 1:21
    newnew_SPL_arr(3, k) = SPL_arr(3, k);
    for i = 4:24
        newnew_SPL_arr(i, k) = newnew_SPL_arr(i - 1, k) + s_bar_arr(i - 1, k);
    end
end

%% Step 8
F_arr = zeros(24, 21);
for k = 1:21
    for i = 3:24
        F_arr(i, k) = SPL_arr(i, k) - newnew_SPL_arr(i, k);
    end
end

%% Step 9
C_arr = zeros(24, 21);
for k = 1:21
    for i = 3:24
        if fre_arr(i) <= 500 
            if F_arr(i, k) >= 1.5 && F_arr(i, k) < 3
                C_arr(i, k) = F_arr(i, k) / 3 - 0.5;
            elseif F_arr(i, k) >= 3 && F_arr(i, k) < 20
                C_arr(i, k) = F_arr(i, k) / 6;
            elseif F_arr(i, k) >= 20
                C_arr(i, k) = 10 / 3;
            end
        elseif fre_arr(i) >= 500 && fre_arr(i) <= 5000
            if F_arr(i, k) >= 1.5 && F_arr(i, k) < 3
                C_arr(i, k) = 2 * F_arr(i, k) / 3 - 1;
            elseif F_arr(i, k) >= 3 && F_arr(i, k) < 20
                C_arr(i, k) = F_arr(i, k) / 3;
            elseif F_arr(i, k) >= 20
                C_arr(i, k) = 20 / 3;
            end
        elseif fre_arr(i) >= 5000 && fre_arr(i) <= 10000
            if F_arr(i, k) >= 1.5 && F_arr(i, k) < 3
                C_arr(i, k) = F_arr(i, k) / 3 - 0.5;
            elseif F_arr(i, k) >= 3 && F_arr(i, k) < 20
                C_arr(i, k) = F_arr(i, k) / 6;
            elseif F_arr(i, k) >= 20
                C_arr(i, k) = 10 / 3;
            end
        end
    end
end

%% Step 10
% choose the largest C
max_C_arr = max(C_arr);
% disp(max_C_arr)
PNLT_arr = zeros(21, 1);
for k = 1:21
    PNLT_arr(k) = PNL_arr(k) + max_C_arr(k);
end

PNLTM = max(PNLT_arr);
disp(PNLTM)

%% Duration correction

D = 10 * log10(sum(10 .^ (PNLT_arr / 10))) - PNLTM - 13;

EPNL = PNLTM + D;
disp(EPNL);