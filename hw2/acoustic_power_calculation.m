function [W, lighthill_p] = acoustic_power_calculation(uc, Tc_total, k_watt)
        T0 = 293;
        P0 = 1e5;
        k0 = 1.4;
        R0 = 287;
        kc = 1.33;
        Rc = 289;
        m = 0.0396;
        Gc = 50;

        a0 = sqrt(k0 * R0 * T0);
        a_cr = sqrt((2 * kc * Rc * Tc_total)/(kc + 1));
        lambda_c = uc / a_cr;
        %gasdynamic function pi(lambda_c) :static pressure/total pressure
        gdf_p_lambda_c = (1 - (kc - 1) * (lambda_c ^ 2)/(kc + 1)) ^ (kc / (kc - 1));
        P_c_total = P0 / gdf_p_lambda_c;

        %gasdynamic function e(lambda_c) :static density/total density
        gdf_e_lambda_c = ((1 - (kc - 1) * (lambda_c ^ 2) / (kc + 1)) ^ (1 / (kc - 1)));

        %gasdynamic function q(lambda_c)
        gdf_q_lambda_c = (((kc + 1) / 2) ^ (1 / (kc - 1))) * lambda_c * gdf_e_lambda_c;
        
        density_c = gdf_e_lambda_c * P_c_total / (Rc * Tc_total);
        Mc = sqrt(((2 * lambda_c ^ 2) / (kc + 1)) / (1 - (kc - 1) * lambda_c ^ 2 / (kc + 1)));
        Fc = Gc * sqrt(Tc_total)/(m*P_c_total*gdf_q_lambda_c);

        if Mc<0.5
            n=6;m=3;
        else
            n=8;m=5;
        end
        
        lighthill_p = density_c*(uc^n)*Fc/(a0^m);
        W = k_watt*lighthill_p;
end