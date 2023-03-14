function b_ni0s = beta_ni_muSmallerThan0(h,n,H,mu,s, A_n_pre,B_n_pre,C_n_pre)
    %{ ==============================================================
    %{ Calcolca i coefficienti a_ni0 che in P_i[N=n] moltiplicano e^u
    %{ ==============================================================
    b_ni0s = zeros(H,1);
    %% calcolo dei 'b_{n,i,0}'
    % prob di fermarsi in ´n-1´ passi partendo da 0.
    %p0_nmeno1 = ProbNew2(h,n-1,mu,s,0);
    
    %% monomi
    m_nMeno1_1 =  (n-2);%min(n-1,H-1+1)-1;
    p = 0:m_nMeno1_1;
    monomi = transpose((0+(n-2)*mu).^p);
    K0 = ( mtimes(A_n_pre(1,:), monomi) + mtimes(B_n_pre(1,:), monomi) ) + C_n_pre(1);
    
    % il ciclo va fino a 'L-1' perchè 'b_{n,i,0}' si calcola diversamente
    for i = 2:H
        i_star = i-1;
        B = 0;
        %% Calcolo dei K_j^(1) formula (4.73)
        for j = 1:(i_star-1)
            % estremi di integrazione
            Ij_l = -(j-1)*mu;   
            Ij_r = min(-j*mu,h);  
            % degree of polynomial 
            m_nmeno1_j = (n-2); %min(n-1,H-j+1)-1;
            % coefficienti in P_j[N=n+1]
            b_nMeno1j = B_n_pre(j,:);
            a_nMeno1j = A_n_pre(j,:);
            c_nMeno1j = C_n_pre(j,:);
            for p = 0:m_nmeno1_j
                % gamma_jp = (gammainc(-2/s*(Ij_l+(n-1)*mu),p+1) - gammainc(-2/s*(Ij_r+(n-1)*mu),p+1))*gamma(p+1)*(s/2)^(p+1)*(-1)^p*exp(-2*(n-1)*mu/s)
                %y = sym('y');
                %gamma_jp = int((y+(n-1)*mu)^p*exp(2*y/s), y,Ij_l, Ij_r);
                %fun = @(y,p,n,k,s) (y+(n-2)*k).^p.*exp(2.*y./s);
                %gamma_jp = integral(@(y) fun(y,p,n,mu,s), Ij_l, Ij_r);
                gamma_jp = gammaMia(Ij_l, Ij_r ,p, -s/2, (n-2)*mu);
                power_jp = ((Ij_r+(n-2)*mu)^(p+1)-(Ij_l+(n-2)*mu)^(p+1))/(p+1);
                B = B + a_nMeno1j(p+1)*gamma_jp + b_nMeno1j(p+1)*power_jp;   
            end
            %B = B + c_nj*(2*s)^(n-1)*(exp(Ij_r/s)-exp(Ij_l/s));
            B = B + c_nMeno1j*s*(exp(Ij_r/s)-exp(Ij_l/s));
        end
        if H > 1 % && i+1<=H
            %estremi di integrazione
            Iistar_l = -(i_star-1)*mu;         
            Iistar_r =  min(-(i_star)*mu,h);  
            m_istar_nmeno1 = (n-2); %min((n-1),H-i_star+1)-1;
            % coefficienti in P_{i+1}[N=n-1]
            b_nMeno1istar = B_n_pre(i_star,:);
            a_nMeno1istar = A_n_pre(i_star,:);
            c_nMeno1istar = C_n_pre(i_star);
            for p = 0:m_istar_nmeno1                                                       
               power_istarp = ((Iistar_l+(n-2)*mu)^(p+1))/(p+1);  
               % gamma_ip = -(-1)^p*(s/2)^(p+1)*exp(-2*(n-1)*mu/s)*(  gammainc(-2/s*(Iipiu1_l+(n-1)*mu),p+1)*gamma(p+1))
               gamma_istarp = 0;
               for d=0:p               
                   % WRONG!
                   %gamma_ip = gamma_ip + (Iipiu1_l+(n-1)*mu)^(p-d)*exp(2*(Iipiu1_l+(n-1)*mu)/s)*factorial(p)/factorial(p-d)*(s/2)^(d+1)*(-1)^d;
                   gamma_istarp = gamma_istarp + (Iistar_l+(n-2)*mu)^(p-d)*exp(2*(Iistar_l)/s)*factorial(p)/factorial(p-d)*(s/2)^(d+1)*(-1)^d;
               end
               B = B - b_nMeno1istar(p+1)*(power_istarp - (s/2)^(p+1)*factorial(p)) - a_nMeno1istar(p+1)*gamma_istarp;                                                                                                
            end
            %B = B - c_nistar*(2*s)^(n-1)*exp(Iistar_l/s);
            B = B - c_nMeno1istar*s*exp(Iistar_l/s);
        end
        B = B*exp(-mu/s)/(2*s);
        if i > 1 % obvious
            B = B + K0*exp(-mu/s)/2;
        end
        b_ni0s(i) = B;
    end
end