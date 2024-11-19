clear;clc;
uc = [160;180;200;220;240;260;280;300;320;340;360;380;400;420;440;460;480];
Tc_total = [400;430;460;490;520;550;580;610;640;670;700;730;760;790;820;850;880];
W = zeros(size(uc));
lighthill_p = zeros(size(uc));
k = size(uc,1);%Number of rows in the matrix
k_watt = (1.5 + rand(1))*(10^(-4));%the range of the coefficient k_watt is(1.5e-4,2.5e-4)
for i = 1:1:k
    [W(i),lighthill_p(i)] = acoustic_power_calculation(uc(i),Tc_total(i),k_watt);
end
loglog(lighthill_p,W,'*');
xlabel('Lighthill parameter')
ylabel('Power of Jet Noise [Watt]')
grid on
