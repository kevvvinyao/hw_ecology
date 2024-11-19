clc; clear;
my_spl = [100.3, 100.4, 100.6, 99.5, 98.8, 97.8, 97.8, 96.3, 94.6, 94.1, 94.3, 94.6, 96.5, ...
           97, 95.1, 93.9, 94.2, 94.5, 91.1, 91.6, 91.4, 91.6, 90.9, 87.2];
avg = mean(my_spl);
y = random('Normal', avg, 1, 1000, 1);  % 生成随机数
nbins = 40;
% 计算所有区间的样本数量 区间范围
[counts, edges] = histcounts(y, nbins); 

% 理论正态分布频率计算
cdf_values = normcdf(edges, avg, 1);
probabilities = diff(cdf_values);
expected_counts = probabilities * sum(counts);

% 计算卡方统计量
chi_square_stat = sum(((counts - expected_counts).^2) ./ expected_counts);

% 自由度计算
degrees_of_freedom = nbins - 1 - 2; % 2 for estimated mean and std

% 计算 p 值
p_value = 1 - chi2cdf(chi_square_stat, degrees_of_freedom);

% 显示结果
fprintf('Chi-square statistic: %.4f\n', chi_square_stat);
fprintf('Degrees of freedom: %d\n', degrees_of_freedom);
fprintf('p-value: %.4f\n', p_value);


if p_value < 0.05
    disp('Reject null hypothesis: The data does not follow the expected distribution.');
else % p_value >= 0.05, chi2cdf <= 0.95
    disp('Fail to reject null hypothesis: The data follows the expected distribution.');
end
