load('lab5_part1_data');

%state of the system are x, x_dot, h
%state transition equations are
% 1. x(t+1) = x(t) + x_dot(t)*T
% 2. x_dot(t+1) = x_dot(t) + a(t)
% 3. h(t+1) = sin(x(t)/10)
% where T - sample time, a(t) - uncertainity in propogation (velocity)
% h(t) - height of the thread along the spool 
% f(x(t),a(t)) = [1 2 3]'

%measurement is given by Y(t) = d(t)
% where dt is measurement
% g(x(t),n(t)) = d(t) = h(t) + n(t)

X_previous = [0; 0; 0];
S_previous = [1 0 0;
              0 1 0;
              0 0 1;];
          
T = 0.1;    %sample time in s
ratio = 3;    %ratio between measurement to dynamic covariance
covar_a = 0.01; %dynamic covariance
covar_n = ratio * covar_a;  %measurement covariance

Q = [0  0       0;
     0  covar_a 0;
     0  0       0];     %covariance matrix of dynamics
 R = [covar_n];     %covariance matrix of measurement
 
 I = [1 0 0;
      0 1 0;
      0 0 1];       %identity matrix
  
              
  data_filtered = zeros(length(measurement),1);
  difference = zeros(length(measurement),1);
  for i=1:length(measurement)
    meas = measurement(i);
    X_predicted = [X_previous(1) + X_previous(2)*T ;
               X_previous(2);
               sin(X_previous(1)/10)];
 
    jacobian_f_X = [1 T 0;
                    0 1 0;
                    0.1*cos(X_predicted(1)/10) 0 0];    %jacobian of f with respect to X
    jacobian_f_a = [0 0 0;
                    0 1 0;
                    0 0 0];           %jacobian of f with respect to a

    jacobian_g_X = [0 0 1];           %jacobian of g with respect to X
    jacobian_g_n = [1];               %jacobian of g with respect to n
    

               
    S_predicted = jacobian_f_X * S_previous * jacobian_f_X' +  jacobian_f_a * Q * jacobian_f_a';
    Y = meas;
    K = S_predicted * jacobian_g_X' / (jacobian_g_X * S_predicted * jacobian_g_X' + jacobian_g_n * R * jacobian_g_n'); 
    X_updated = X_predicted + K * (Y - X_predicted(3));
    S_updated = (I - K * jacobian_g_X) * S_predicted;
    X_previous = X_updated;
    S_previous = S_updated;
    data_filtered(i) = X_updated(3);
    difference(i) = true_data(i) - data_filtered(i);
  end
  
  fprintf("%d %d\n",ratio,rms(difference))
  figure(1)
  plot(measurement);
  hold on
  plot(data_filtered,'LineWidth',1.5);
  legend("measurement","filtered")
  title("Measurement vs Filtered data - EKF")
  
          
  figure(2)
  plot(true_data,'LineWidth',1.5);
  hold on
  plot(data_filtered,'LineWidth',1.5);
  legend("Actual","Filtered")
  title("Actual vs Filtered data - EKF")
          