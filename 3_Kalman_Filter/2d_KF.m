load('data.mat')
T = 0.01; %sample time of 0.01 s
psi = [1 0 T 0; 
       0 1 0 T; 
       0 0 1 0; 
       0 0 0 1];       %state transition matrix
init = 30;      %number of variables that will be used to calculate initial value of system
rate_x = zeros(init,1); rate_y = zeros(init,1); %matrices to store initial rate of change in x & y
init_x = zeros(init,1); init_y = zeros(init,1); %matrices to store initial values of x and y
for i=1:init
   rate_x(i) = (data_2d_raw(i+1,1) - data_2d_raw(i,1))/T;
   rate_y(i) = (data_2d_raw(i+1,2) - data_2d_raw(i,2))/T;
   init_x(i) = data_2d_raw(i,1); init_y(i) = data_2d_raw(i,2);
end

%X_previous =  [mean(init_x); mean(rate_x); mean(init_y); mean(rate_y)]; %state matrix for previous instance
cov_x_x_dot = cov(init_x, rate_x);
cov_x_y = cov(init_x, init_y);
cov_x_y_dot = cov(init_x, rate_y);
cov_x_dot_y_dot = cov(rate_x, rate_y);
cov_x_dot_y = cov(rate_x, init_y);
cov_y_y_dot = cov(init_x, rate_y);

X_previous =  [init_x(1); 
               init_y(1); 
               0; 
               0]; %state matrix for previous instance
S_previous = [ var(init_x) 0 0 0;
               0 var(init_y) 0 0; 
               0 0 var(rate_x) 0; 
               0 0 0 var(rate_y);];

dyn_var_x = 0.1;
dyn_var_y = 0.1;
meas_var_x = 1;
meas_var_y = 1;
Q = [0 0 0 0; 
     0 0 0 0; 
     0 0 dyn_var_x 0; 
     0 0 0 dyn_var_y];
R = [meas_var_x     0; 
    0               meas_var_y];
M = [1 0 0 0; 
     0 1 0 0];
I = [1 0 0 0; 
     0 1 0 0; 
     0 0 1 0; 
     0 0 0 1];

data_2d_filtered = zeros(length(data_2d_raw),2);
for i=1:length(data_2d_raw)
    X_predicted = psi * X_previous;       %predicting current state value based on transition matrix
    S_predicted = psi * S_previous * psi' + Q;    %updating state covariance matrix
    Y = [data_2d_raw(i,1); data_2d_raw(i,2)];              %obtaining current measurement
    K = S_predicted*M'/(M*S_predicted*M' + R);   %Kalman gain calculation
    X_updated = X_predicted + K*(Y - M*X_predicted);    %updated state value
    S_updated = (I - K*M) * S_predicted;        %updated state covarinace matrix
    X_previous = X_updated;
    S_previous = S_updated;
    data_2d_filtered(i,1) = X_updated(1,1);
    data_2d_filtered(i,2) = X_updated(2,1);
end

figure(1)
plot(data_2d_raw(:,1),data_2d_raw(:,2))
hold on
plot(data_2d_filtered(:,1),data_2d_filtered(:,2))
title("Actual vs Filtered movement 2d")
xlabel("position x(m)")
ylabel("position y(m)")

figure(2)
plot(data_2d_raw(:,1))
hold on
plot(data_2d_filtered(:,1))
title("Actual vs Filtered movement x direction")
xlabel("Time (s)")
ylabel("position x(m)")

figure(3)
plot(data_2d_raw(:,2))
hold on
plot(data_2d_filtered(:,2))
title("Actual vs Filtered movement y direction")
xlabel("Time (s)")
ylabel("position y(m)")

%S_previous = cov(init_x, rate_x, init_y, rate_y);
%                [ std(init_x) cov(init_x, rate_x) cov(init_x, init_y) cov(init_x, rate_y) ; 
%                cov(rate_x, init_x) std(rate_x) cov(rate_x, init_y) cov(rate_x, rate_y) ;
%                cov(init_y, init_x) cov(init_y, rate_x) std(init_y) cov(init_y, rate_y) ;
%                cov(rate_y, init_x) cov(rate_y, rate_x) cov(rate_y, init_y) std(rate_y) ];  %state covariance matrix at previous instance S_t-1,t-1
%            

