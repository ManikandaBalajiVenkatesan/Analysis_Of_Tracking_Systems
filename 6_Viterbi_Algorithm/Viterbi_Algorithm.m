pi = [0.5;0.5]; %prior probability
pi = log2(pi);  %converting log2 scale
A = [0.5 0.4;
     0.5 0.6];  %state transition probability matrix
% [ a_hh, a_lh;
%   a_hl, a_ll ]
A = log2(A);   %converting log2 scale
B = [0.2 0.3 0.3 0.2;
     0.3 0.2 0.2 0.3];  %observation probability matrix
B = log2(B);    %converting log2 scale

% A - 1, C - 2, G - 3, T - 4
% H - 1, L - 2
%obs_seq = [3 3 2 1 2 4 3 1 1];         %GGCACTGAA
%obs_seq = [4 2 1 3 2 3 3 2 4];         %TCAGCGGCT

%GGCACTGAA
% obs_seq = [observation.G;
%            observation.G;
%            observation.C;
%            observation.A;
%            observation.C;
%            observation.T;
%            observation.G;
%            observation.A;
%            observation.A]';
       

% TCAGCGGCT
obs_seq = [observation.T;
           observation.C;
           observation.A;
           observation.G;
           observation.C;
           observation.G;
           observation.G;
           observation.C;
           observation.T]';
       


lambda = zeros(2,length(obs_seq));   %probability matrix for output
path = zeros(1,length(obs_seq));     %predicted set of inputs
%initialization
i = 1;  %iterator
obs = obs_seq(i);
curr_state = 1; % state H
lambda(curr_state,1) = pi(curr_state) + B(curr_state, obs);
curr_state = 2; % state L
lambda(curr_state,1) = pi(curr_state) + B(curr_state, obs);


while (i < length(obs_seq))
    i = i + 1;
    obs = obs_seq(i);
    lambda(1,i) = B(1,obs) + max(lambda(1,i-1)+A(1,1), lambda(2,i-1)+A(1,2));
    lambda(2,i) = B(2,obs) + max(lambda(1,i-1)+A(2,1), lambda(2,i-1)+A(2,2));    
end

%tracking the path
i = 1;
while (i <= length(obs_seq))
    [~,curr_state] = max(lambda(:,i));
    path(1,i) = state(curr_state);
    i = i + 1;
end

disp(state(path))




