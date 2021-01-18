clear all
load('input_data');

% step time,current time, total time

Ts = 1;
T = Ts;
total_t = length(actual_pos)*Ts - Ts;


sigma_a = 0.0625;
sigma_m = 4.0;
sigma_n = 0.003906;

x_m1 = -10; x_m2 = 10;
x_filtered = zeros(length(actual_pos),1);
x_dot_filtered = zeros(length(actual_pos),1);
y_particles = zeros(length(actual_pos),1);
resample = 0;       %resample flag
resample_threshold = 0.1;   %threshold to resample
particles = 100;
chi = zeros(particles,3);       %1st col-x; 2nd col-x_dot; 3rd col-w
chi_resample = zeros(particles,3);
chi_prev = zeros(particles,3);
chi_record = zeros(particles,3);
for i=1:particles               %initializing weights
    chi_prev(i,3) = 1/particles;     
end


while(T<=total_t)
    index = round(T/Ts);
    E_T = 0;
    sum = 0;
    
    for i=1:particles
        x = chi_prev(i,1);
        x_dot = chi_prev(i,2);
        w = chi_prev(i,3);
        
        %propogating particles through state transition equations
        x_next = x + x_dot*Ts;
        if x<-20
            x_dot_next = 2;
        elseif x>= -20 && x<0
            x_dot_next = x_dot + abs(normrnd(0,sigma_a));
        elseif x>=0 && x<=20
            x_dot_next = x_dot - abs(normrnd(0,sigma_a));
        else            
            x_dot_next = -2;
        end
        chi(i,1) = x_next;
        chi(i,2) = x_dot_next;
    
        %weights revaluation
%         y_t = meas(index);
%         y_m1 = (1/(sqrt(2*pi)*sigma_m)) * exp(-(x - x_m1)^2/(2*sigma_m^2));
%         y_m2 = (1/(sqrt(2*pi)*sigma_m)) * exp(-(x - x_m2)^2/(2*sigma_m^2));
%         
        %weights revaluation
        y_t = meas(index);
        y_m1 = (1/(sqrt(2*pi)*sigma_m)) * exp(-(x_next - x_m1)^2/(2*sigma_m^2));
        y_m2 = (1/(sqrt(2*pi)*sigma_m)) * exp(-(x_next - x_m2)^2/(2*sigma_m^2));
        
        y_m = y_m1 + y_m2;
        y_particles(index) = y_m;
        
        p = (1/(sqrt(2*pi)*sigma_n)) * exp(-(y_m - y_t)^2/(2*sigma_n^2));
        chi(i,3) = w * p;   %non normalized weight
        sum = sum + chi(i,3);     %sum of non normalized weights
    end
    
    %normalization of weights
    for i=1:particles
        chi(i,3) = chi(i,3)/sum;
    end
    
    %expected value calculation
    for i=1:particles
        E_T = E_T + chi(i,1)*chi(i,3); 
    end
    
    %filtered value calculation
    x_filtered(index) = E_T;  
    
    if(T == 730)
        chi_record = chi;
    end
    
    
    %checking whether to resample
    CV = 0;
    for i=1:particles
        CV = CV + (particles * chi(i,3) - 1)^2;
    end
    
    CV = CV/particles;
    ESS = particles / (1 + CV);
    
    if ESS < resample_threshold*particles
        resample = 1;
    end
    
    %resampling if required
    if resample == 1
        Q = cumsum(chi(:,3));
        t = rand(particles+1,1);
        T_rand = sort(t);
        T_rand(particles+1) = 1.0;
        i = 1; j=1;
        Index = zeros(particles,1);
        while( i <= particles)
            if(T_rand(i) < Q(j))
                Index(i) = j;
                i = i + 1;
            else
                j = j+1;
            end
        end

        for i=1:particles
            chi_resample(i,1) = chi(Index(i),1);
            chi_resample(i,2) = chi(Index(i),2);
            chi_resample(i,3) = 1/particles;
        end
        resample = 0;
        chi = chi_resample;
        chi_resample = zeros(particles,3);
    end
    
        
    
    chi_prev = chi;
    T = T + Ts;
end
figure(1)
plot(meas)
hold on
plot(y_particles)
xlabel("time(s)")
ylabel("Field Strength")
legend("Measurement","Filtered")
title("Field stength plot")

figure(2)
plot(actual_pos)
hold on
plot(x_filtered)
xlabel("time(s)")
ylabel("Position")
legend("Actual","Estimate")
title("Actual vs Estimated position of object")

figure(3)
plot(chi_record(:,1),chi_record(:,3),'*')
title("Particle's position guess vs weight half way thorugh")
xlabel("Position")
ylabel("Weight")