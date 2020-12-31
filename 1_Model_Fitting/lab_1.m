load('meal_data.mat')
order =1;

% X = [5 6 7 8 9 ];    %input x data
% Y = [1 1 2 3 5 ];    %input y data
% curve = curve_normalization(X,Y,order);
% curve_plotter(X,Y,curve)


Y = meal_data(:,4)./meal_data(:,3); Y = Y';
X = meal_data(:,3); X = X';
data = [ X; Y];
curve = curve_exponential(X,Y,1);
curve_plotter(X,Y,curve)
[c_x, c_y, c_r] = curve_circle(data);
curve_plotter_circluar(X,Y,c_x, c_y, c_r)





function [c_x, c_y, c_r] = curve_circle(data)

X = data(1,:);
Y = data(2,:);
n = length(X);
m = 3;
syms x;
syms y;
syms fx [1 m];      %basis functions

A = zeros(n,m);
i = 1;
fx(1) = 2*x;
fx(2) = 2*y;
fx(3) = 1;

i = 1;      %first coloumn   
j = 1;
while j <= n
    A(j,i) = subs(fx(i),X(j));
    j = j+1;        
end

i = 2; j = 1;   %second coloumn
while j <= n
    A(j,i) = subs(fx(i),Y(j));
    j = j+1;        
end

i = 3; j = 1;   %second coloumn
while j <= n
    A(j,i) = subs(fx(i),X(j));
    j = j+1;        
end

X = X'; Y = Y';
% b = [X.^2, Y.^2];
b = [X.^2 + Y.^2];

a = (inv(A.'*A))*A.'*b;
c_x = a(1);
c_y = a(2);
center = [a(1) a(2)];
alpha = a(3);
c_r = sqrt(alpha + c_x^2 + c_y^2);
% viscircles(center,r);
syms curve   %equation of curve
i = 1;
curve = 0;
while i <= m
    curve = curve + a(i) * fx(i);  
    i = i + 1;
end

end



function curve = curve_exponential(X,Y,m)

n = length(X);
syms x; 
syms fx [1 m];      %basis functions

A = zeros(n,m);
i = 1;
while i <= m
    fx(i) = exp(-x); 
    i = i + 1;
end

b = Y';
i = 1;      %coloumn counter   
while i <= m
    j=1;    %row counter
    while j <= n
        A(j,i) = subs(fx(i),X(j));
        j = j+1;        
    end
    i = i + 1;
end

a = (inv(A.'*A))*A.'*b;
syms curve   %equation of curve
i = 1;
curve = 0;
while i <= m
    curve = curve + a(i) * fx(i);  
    i = i + 1;
end

end



function curve = curve_normalization(X,Y,m)

n = length(X);
syms x; 
syms fx [1 m+1];      %basis functions
%syms a [1 m+1];             %linear coefficients
%syms A [n m+1];
A = zeros(n,m+1);
i = 1;
while i <= m+1
    fx(i) = x^(i-1); 
    i = i + 1;
end

b = Y';
i = 1;      %coloumn counter   
while i <= m+1
    j=1;    %row counter
    while j <= n
        A(j,i) = subs(fx(i),X(j));
        j = j+1;        
    end
    i = i + 1;
end

a = (inv(A.'*A))*A.'*b;
syms curve   %equation of curve
i = 1;
curve = 0;
while i <= m+1
    curve = curve + a(i) * fx(i);  
    i = i + 1;
end

end


function curve_plotter(X,Y,curve)
    n = length(X);
    figure()
    plot(X,Y,'o')
    hold on
    fplot(curve,[min(X),max(X)],'LineWidth',5)
    title("Exponential Model")
    legend("Data Points","Model")
end


function curve_plotter_circluar(X,Y,c_x, c_y, c_r)
    n = length(X);
    center = [c_x c_y];
    i = c_x - c_r;
    Y_eqn = [];
    X_eqn = [];
    idx = 1;
    while(i <= c_x)
        Y_eqn = [Y_eqn, c_y - sqrt(c_r^2 - (i - c_x)^2)]; 
        X_eqn = [X_eqn, i];
        i = i+1;
    end
    figure()
    plot(X,Y,'o')
    hold on
    plot(X_eqn,Y_eqn,'r','LineWidth',5)
    title("Cicle Model")
    legend("Data Points","Model")
end






