function lab_02()
    clc();
    cla

    a = 0;
    b = 1;
    eps = 1e-6;

    debugFlag = true;
    delay = 0;

    fplot(@f, [a, b]);
    hold on;

    tau = (sqrt(5) - 1) / 2;
    l = b - a;

    x1 = b - tau * l;
    x2 = a + tau * l;
    f1 = f(x1);
    f2 = f(x2);

    N = 2;
    while true
        if debugFlag
            fprintf('N = %2d:   a = %.10f;   b = %.10f;   x1 = %.10f;   x2 = %.10f;   f(x1) = %.10f;   f(x2) = %.10f\n', N, a, b, x1, x2, f1, f2);
            line([a b], [f(a) f(b)]);
            pause(delay);
        end

        if l > 2 * eps
            if f1 <= f2
                b = x2;
                l = b - a;

                x2 = x1;
                f2 = f1;

                x1 = b - tau * l;
                f1 = f(x1);
            else
                a = x1;
                l = b - a;

                x1 = x2;
                f1 = f2;

                x2 = a + tau * l;
                f2 = f(x2);
            end

            N = N + 1;
        else
            xStar = (a + b) / 2;
            fStar= f(xStar);

            N = N + 1;
            break
        end
    end

    scatter(xStar, fStar, 'r', 'filled');
    fprintf('\nОтвет:   N = %2d;   x* = %.10f;   f(x*) = %.10f.\n\n', N, xStar, fStar);
end

function y = f(x)
    y = asin((35.* power(x, 2) - 30.*x + 9) ./ 20) + cos((10.* power(x, 3) + 185.* power(x, 2) + 340.*x + 103) ./ (50.* power(x, 2) + 100.*x + 30)) + 0.5;
end
