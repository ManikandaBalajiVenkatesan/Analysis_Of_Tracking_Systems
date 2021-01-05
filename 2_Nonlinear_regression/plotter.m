%to be filled by user
data = load('data_C.txt');
an = 0.289;

syms x;
curve = log(an*x);
x = data(:,1);
y = data(:,2);
figure()
plot(x,y,'.')
title("Plot of raw data & nonlinear regression fit")
xlabel("X")
ylabel("Y")
hold on
fplot(curve,[min(x),max(x)]);
legend('raw data',['ln(',num2str(an),'*x)'])

