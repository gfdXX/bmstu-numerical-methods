clc
clear all

% Исходная матрица стоимостей.
c = [
4 7 1 5 5;
6 8 3 7 6;
6 4 5 7 7;
4 2 3 4 9;
8 1 8 3 8
];
% c = [
% 1 1 1 1 1;
% 1 9 5 4 4;
% 1 8 3 4 2;
% 1 7 9 2 4;
% 1 8 2 6 5
% ];

% Матрица для решения задачи максимизации.
c1 = max(c, [], 'all') - c;

marks_min = hungarian(c, true);
marks_max = hungarian(c1, true);

fmin = sum(c.*marks_min, 'all');
fmax = sum(c.*marks_max, 'all');

fprintf("Матрица стоимостей:\n");
print_matrix(c);
fprintf("\nЗадача минимизации.\n");
fprintf("Оптимальное значение функции: %d\nОптимальное решение:\n", fmin);
print_matrix(marks_min);
fprintf("\nЗадача максимизации.\n");
fprintf("Оптимальное значение функции: %d\nОптимальное решение:\n", fmax);
print_matrix(marks_max);

function [marks] = hungarian(source_matrix, debug)
    %Размер исходной матрицы (n x n)
    n = length(source_matrix );

    % Текущий режим (с выводом - true, без вывода - false).
    DEBUG = debug;
    
    % Отмеченные нули: 1 - "0*", -1 - "0'"
    marks = zeros(n,n);
    % Отмеченные столбцы
    mark_column = zeros(1,n);
    % Отмеченные строки
    mark_row = zeros(1,n);
    % L-цепочка
    l_chain = zeros(2,2);

    % Номер итерации.
    iter = 0;

    % Вычтем из столбцов минимальные элементы.

    source_matrix = source_matrix - min(source_matrix );
    % Вычтем из строк минимальные элементы.
    source_matrix = source_matrix - min(source_matrix , [], 2);
    % Количество элементов в системе независимых нулей.
    k = 0;
    % Строим начальную систему независимых нулей.
    for j = 1:n
        for i = 1:n
            if (source_matrix (i,j) == 0)
                if (max(marks(i, :)) == 0)
                    marks(i,j) = 1;
                    mark_column (j) = 1;
                    k = k+1;
                    break;
                end
            end
        end
    end

    iter = print_siz(DEBUG, iter, source_matrix, marks, l_chain);

    while k < n
        has_zeros = false;
        j = 0;
        while ~has_zeros
            j = j+1;
            if j > n
                break;
            end
            if mark_column (j) == 1
                continue
            end
            i = 0;
            while ~has_zeros
                i = i+1;
                if (i > n)
                    break;
                end
                if mark_row(i) == 1
                    continue
                end
        
                if source_matrix (i,j) ~= 0 || marks(i,j) == 1
                    continue;
                end
                marks(i, j) = -1;
                [mm, jmm] = max(marks(i, :));
        
                if mm ~= 1
                    mark_row = zeros(1, n);
                    mark_column = zeros(1, n);
                    l_chain = [l_chain; [i j]];
                    mark_column (j) = 1;
                    jm = j;
                    while (true)
                        [m, im] = max(marks(:, jm));
                        if m == 0
                            break;
                        end
                        [m, jmn] = min(marks(im, :));
                        if (m == 0)
                            break;
                        end
                        marks(im, jm) = 0;
                        marks(i, j) = 1;
                        i = im;
                        j = jmn;
                        l_chain = [l_chain; [im jm]; [im jmn]];
                        jm = jmn;
                    end
                    marks(i,j) = 1;
                    for i = 1:n
                        [m, j] = min(marks(i, :));
                        while m == -1
                            marks(i, j) = 0;
                            [m, j] = min(marks(i, :));
                        end
                    end
                    for j = 1:n
                        if (max(marks(:, j)) == 1)
                            mark_column(j) = 1;
                        end
                    end
                    k = k+1;
                    [iter, l_chain] = print_siz(DEBUG, iter, source_matrix, marks, l_chain);
        
                else
                    mark_column (jmm) = 0;
                    mark_row(i) = 1;
                end
                has_zeros = true;
            end
        end
        if has_zeros
            continue;
    
        end
        source_matrix = make_zeros(source_matrix, mark_row, mark_column);
    end
end

% Преобразуем исходную матрицу так, чтобы в невыделенной части матрицы появился хотя
% бы один ноль
function [source_matrix] = make_zeros(source_matrix, mark_row, mark_column)
    n = length(source_matrix);
    %Находим минимальный элемент среди невыделенных.
    h = max(max(source_matrix));
    for i = 1:n
        if mark_row(i) == 1
            continue;
        end
        for j = 1:n
            if mark_column(j) == 1
                continue;
            end
            if source_matrix(i, j) < h
                h = source_matrix(i, j);
            end
        end
    end
    
    % Вычитаем из невыделенных столбцов h.
    for j = 1:n
        if mark_column(j) == 0
            source_matrix(:, j) = source_matrix(:, j) - h;
        end
    end
    
    % Прибавляем к выделенным строкам h.
    for i = 1:n
        if mark_row(i) == 1
            source_matrix(i, :) = source_matrix(i, :) + h;
        end
    end
end

% Вывод текущей матрицы с отмеченной системой независимых нулей.
% (system_of_independent_zeros = siz)
function [iter, l_chain] = print_siz(debug, iter, source_matrix, marks, l_chain)
    if debug
        n = length(source_matrix);
        fprintf("Итерация № %d:\n", iter);
        l_chain = print_l_chain(l_chain);
        fprintf("Текущая матрица:\n");
        
        for i = 1:n
            for j = 1:n
                fprintf("%d", source_matrix(i,j));
                if marks(i, j) == 1
                    fprintf("*");
                end
                fprintf("\t");
            end
            fprintf("\n");
        end
        fprintf("\n");
    end
    iter = iter + 1;
end

function [] = print_matrix(matrix)
    n = length(matrix);
    for i = 1:n
        for j = 1:n
            fprintf("%d\t", matrix(i,j));
        end
        fprintf("\n");
    end
end

% Вывод L-цепочки.
function [l_chain] = print_l_chain(l_chain)
    n = length(l_chain);
    
    if n > 2
        fprintf("L-цепочка:\n(%d, %d) ", l_chain(3, 1), l_chain(3, 2));
    if n > 3
        for i = 4:n
            fprintf(" -> (%d, %d) ", l_chain(i, 1), l_chain(i, 2));
        end
    end
    fprintf("\n\n");
    l_chain = zeros(2,2);
    end
end
