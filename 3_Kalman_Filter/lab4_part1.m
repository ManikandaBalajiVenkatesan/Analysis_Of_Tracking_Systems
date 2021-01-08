load('data.mat')
T = 0.01; %sample time of 0.01 s
psi = [1 T; 
       0 1];       %state transition matrix
rate = 0;
init = 30;      %set of values choosen to determine initial states
rate_matrix = zeros(init,1);
for i=1:length(data_1d_raw) - 1
    rate_matrix(i) = (data_1d_raw(i+1) - data_1d_raw(i))/T;
end

X_previous =  [mean(data_1d_raw(1:init)); 
               mean(rate_matrix(1:init)) ]; %state matrix for previous instance
S_previous = [ std(data_1d_raw(1:10)) 0; 0 std(rate_matrix(1:10))];  %state covariance matrix at previous instance S_t-1,t-1


dyn_var = 10;
meas_var = 1;

Q = [0 0; 
     0 dyn_var] ;        %dynamic noise covariance matrix
R = meas_var;                   %measurement noise covariance
M = [1 0];                  %observation matrix
I = [1 0; 
     0 1];
data_1d_filtered = zeros(length(data_1d_raw),1);
for i=1:length(data_1d_raw)
    X_predicted = psi * X_previous;       %predicting current state value based on transition matrix
    S_predicted = psi * S_previous * psi' + Q;    %updating state covariance matrix
    Y = data_1d_raw(i);              %obtaining current measurement
    K = S_predicted*M'/(M*S_predicted*M' + R);   %Kalman gain calculation
    X_updated = X_predicted + K*(Y - M*X_predicted);    %updated state value
    S_updated = (I - K*M) * S_predicted;        %updated state covarinace matrix
    X_previous = X_updated;
    S_previous = S_updated;
    data_1d_filtered(i) = X_updated(1,1); 
end

figure(1)
plot(data_1d_raw)
hold on
plot(data_1d_filtered)
title(["Dynamic (Q) to Measurement (R) noise ratio ",num2str(dyn_var/meas_var)])
