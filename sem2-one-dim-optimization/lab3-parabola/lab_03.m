function lab_03()
    clc();
    cla

    a = 0;
    b = 1;
    eps = 1e-6;

    debugFlag = true;
    delay = 1;

    fplot(@f, [a, b]);
    hold on;

    fprintf('Выбор изначальных точек x1, x2, x3 с помощью метода золотого сечения:\n\n');

    tau = (sqrt(5) - 1) / 2;
    l = b - a;

    x1 = b - tau * l;
    x2 = a + tau * l;
    f1 = f(x1);
    f2 = f(x2);

    N = 2;
    while true
        if debugFlag
            fprintf('N = %2d:   a = %.10f;   b = %.10f;\n', N, a, b);
            line([a b], [f(a) f(b)]);
            pause(delay);
        end

        if l > 2 * eps
            if f1 <= f2
                b = x2;
                fb = f2;
                l = b - a;

                x2 = x1;
                f2 = f1;

                x1 = b - tau * l;
                f1 = f(x1);

                if f1 >= f2
                    x3 = b;
                    f3 = fb;
                    break;
                end
            else
                a = x1;
                fa = f1;
                l = b - a;

                x1 = x2;
                f1 = f2;

                x2 = a + tau * l;
                f2 = f(x2);

                if f1 <= f2
                    x3 = x2;
                    f3 = f2;

                    x2 = x1;
                    f2 = f1;

                    x1 = a;
                    f1 = fa;
                    break;
                end
            end
        
            N = N + 1;
        else
            xStar = (a + b) / 2;
            fStar = f(xStar);

            N = N + 1;
            scatter(xStar, fStar, 'r', 'filled');
            fprintf('\nОтвет:   x* = %.10f;   f(x*) = %.10f.\n\n', xStar, fStar);
            return;
        end
    end

    N = N + 1;

    if debugFlag
        fprintf('N = %2d:   a = %.10f;   b = %.10f;\n\n', N, a, b);
        line([a b], [f(a) f(b)]);
        pause(delay);

        scatter(x1, f1, 'b', 'filled');
        scatter(x2, f2, 'b', 'filled');
        scatter(x3, f3, 'b', 'filled');
        line([x1 x3], [f1 f3], 'color', 'b');
        pause(delay);
    end

    fprintf('x1 = %.10f\nx2 = %.10f\nx3 = %.10f\n\n', x1, x2, x3);
    fprintf('Метод парабол:\n\n');

    a1 = (f2 - f1) ./ (x2 - x1);
    a2 = ((f3 - f1) ./ (x3 - x1) - (f2 - f1) ./ (x2 - x1)) ./ (x3 - x2);
    x_line = 1 / 2 .* (x1 + x2 - a1 ./ a2);
    f_line = f(x_line);
    N = N + 1;

    if debugFlag
        plot(x_line, f_line, 'xk');
        pause(delay);
    end

    it = 1;
    while true 
        if it == 1 || abs(prev_x_line - x_line) > eps
            it = it + 1;

            if f_line > f2
                temp = f_line; 
                f_line = f2; 
                f2 = temp;

                temp = x_line; 
                x_line = x2; 
                x2 = temp;
            end
    
            if x_line > x2
                x1 = x2; 
                f1 = f2;
            else
                x3 = x2; 
                f3 = f2;
            end

            x2 = x_line; 
            f2 = f_line;
            
            if debugFlag
                hold off;
                fplot(@f, [0, 1]);
                hold on;

                scatter(x1, f1, 'b', 'filled');
                scatter(x2, f2, 'b', 'filled');
                scatter(x3, f3, 'b', 'filled');
                line([x1 x3], [f1 f3], 'color', 'b');
                pause(delay);
            end

            prev_x_line = x_line;

            a1 = (f2 - f1) ./ (x2 - x1);
            a2 = ((f3 - f1) ./ (x3 - x1) - (f2 - f1) ./ (x2 - x1)) ./ (x3 - x2);
            x_line = 1 / 2 .* (x1 + x2 - a1 ./ a2);
            f_line = f(x_line);
            N = N + 1;

            if debugFlag
                fprintf('Для N = %2d:\n', N);
                fprintf('x1 = %.10f;   f1 = %.10f;\n', x1, f1);
                fprintf('x2 = %.10f;   f2 = %.10f;\n', x2, f2);
                fprintf('x3 = %.10f;   f3 = %.10f;\n', x3, f3);
                fprintf('Текущее приближение: x = %.10f, f(x) = %.10f\n\n', x_line, f_line);
                plot(x_line, f_line, 'xk');
                pause(delay);
            end
        else
            xStar = x_line;
            fStar = f_line;
            break;
        end
    end
    
    scatter(xStar, fStar, 'r', 'filled');
    fprintf('Ответ:   x* = %.10f;   f(x*) = %.10f.\n\n', xStar, fStar);
end

function y = f(x)
    y = asin((35.* power(x, 2) - 30.*x + 9) ./ 20) + cos((10.* power(x, 3) + 185.* power(x, 2) + 340.*x + 103) ./ (50.* power(x, 2) + 100.*x + 30)) + 0.5;
end
