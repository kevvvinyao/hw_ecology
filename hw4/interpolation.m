clear;clc;
alpha_1 = readmatrix('humidity_50%_docsmall.com.xlsx');
alpha_2 = readmatrix('humidity_60%_docsmall.com.xlsx');
alpha_3 = readmatrix('humidity_70%_docsmall.com.xlsx');
alpha_4 = readmatrix('humidity_80%_docsmall.com.xlsx');
alpha = cat(3,alpha_1,alpha_2,alpha_3,alpha_4);

f=[50,63,80,100,125,160,200,250,315,400,500,630,800,1000,...
    1250,1600,2000,2500,3150,4000,5000,6300,8000,10000]'; % 转置为列向量

T=[-10,-5,0,5,10,15,20,25,30,35,40];
h=[50,60,70,80]';
% 创建步长为1的表格 方便一会进行插值
h_1=50:1:80;
h_1=h_1';
T_1=-10:1:40;
% 对网格中的所有制进行插值 并且保存文件到本地方便后续直接查找
alpha_interp = interp3(T,f,h,alpha,T_1,f,h_1,'linear');
save('alpha_interp.mat',"alpha_interp")

disp("插值表格已经保存到本地，可供查询。")
