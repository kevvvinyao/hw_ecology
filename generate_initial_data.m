% 初始化参数
t_start = 0;
t_end = 10;
step = 0.5;
num_frequencies = 24;
num_times = 21;
mu = 65; % 平均值
sigma = 11; % 标准差

% 生成时间向量
t = t_start:step:t_end;

% 初始化随机数矩阵
ampArr = zeros(num_times, num_frequencies);


ampArr(:, 1) = mu + 7 * randn(size(t));
ampArr(:, 2) = mu + 8 * randn(size(t));
ampArr(:, 3) = mu + 9 * randn(size(t));

% 生成随机数
for i = 4:num_frequencies
    ampArr(:, i) = mu + sigma * randn(size(t));
end

ampArr = round(ampArr);
% 显示结果
disp(ampArr);

disp(size(ampArr));

LArr = zeros(length(t), 1);

for i = 1:num_times
    rowEle = ampArr(i, :);
    LArr(i) = 10 * log10(sum(10 .^ (rowEle / 10)));
end

LArr = round(LArr);
disp(LArr);
save('ampArr.mat', 'ampArr');
disp(size(ampArr))
figure;
for i = 1:num_frequencies
    subplot(6, 4, i); % 创建6x4的子图布局
    plot(t, ampArr(:, i));
    title(['Frequency ', num2str(i)]);
    xlabel('Time');
    ylabel('Amplitude');
end

% 获取最大值和最小值
max_value = max(ampArr, [], 'all');
min_value = min(ampArr, [], 'all');

% 显示结果
disp(['The maximum value in ampArr is: ', num2str(max_value)]);
disp(['The minimum value in ampArr is: ', num2str(min_value)]);