clear; clc;
load('alpha_interp.mat');

SPL = load('ground_test_data.txt');
T=14;
H=67;
% 适配alpha_interp的索引 温度从-10开始 湿度从50开始
alpha = alpha_interp(:,T+10+1,H-50+1);
% alpha是个数组 有24个元素 分别对应了24个不同的频率
% disp(size(alpha)); % 24行1列
R=[500,1000,3000,5000,7000];
R_1=50;
k = size(R,2); % k = 5
L = zeros(k, 24); % L包含120个L_pri
L_sum = zeros(k, 1); % 每个距离上的24个L求和
for dist = 1:1:k
    for freq = 1:1:24
        L(dist, freq) = SPL(freq) - 20 * log10(R(dist)/R_1) - 17.38 * alpha(freq) * (R(dist) - R_1) / 100;
        L_sum(dist) = L_sum(dist) + power(10, L(dist, freq) / 10);
    end
end


L_sum = 10*log10(L_sum);
% L_sum有五个元素 对应五个不同距离
disp(L_sum);