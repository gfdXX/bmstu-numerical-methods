function lab_04()
clc();
cla

a = 0;
b = 1;
delta = 1e-3;
eps = 1e-6;

debugFlag = true;
delay = 1;

fplot(@f, [a, b]);
hold on;

x = (a + b) / 2;

f2_x0 = (f(x - delta) - 2 * f(x) + f(x + delta)) / power(delta, 2);
N = 3;

while true
    f1 = (f(x + delta) - f(x - delta)) / (2 * delta);
    N = N + 2;

    if debugFlag
        fprintf('N = %2d:   x = %.10f;   f1 = %.10f;\n\n', N, x, f1);
        plot(x, f(x), 'xk');
        pause(delay);
    end

    if abs(f1) < eps
        break;
    else
        x = x - f1 / f2_x0;
    end
end

x_star = x;
f_star = f(x);
N = N + 1;
scatter(x_star, f_star, 'filled');
fprintf('Ответ:   N = %2d;   x* = %.10f;   f(x*) = %.10f;\n\n', N, x_star, f_star);

options = optimset('TolX', eps);
if debugFlag
    options = optimset(options, 'Display', 'iter');
end
[x_star, f_star] = fminbnd(@f, a, b, options);
fprintf('fminbnd:   x = %.10f;   f(x) = %.10f.\n\n', x_star, f_star);
end

function y = f(x)
y = asin((35.* power(x, 2) - 30.*x + 9) ./ 20) + cos((10.* power(x, 3) + 185.* power(x, 2) + 340.*x + 103) ./ (50.* power(x, 2) + 100.*x + 30)) + 0.5;
end
