clc
clear all
% Исходная матрица стоимостей.
c = [
1 1 1 1 1 ;
1 8 3 7 6;
1 4 5 7 2;
1 3 3 2 9;
1 4 2 3 8
];
%max(c(:))
% Матрица для решения задачи максимизации.
c1 = max(c, [], 'all') - c;
marks_min = hungarian(c, true);
%marks_max = hungarian(c1, true);
fmin = sum(c.*marks_min, 'all');
%fmax = sum(c.*marks_max, 'all');
fprintf("\nМатрица стоимостей:\n");
print_matrix(c);
fprintf("\nЗадача минимизации.\n");
fprintf("\nШаг 5. Оптимальное решение:\n");
print_matrix(marks_min);
fprintf("\nШаг 6. Оптимальное значение функции: %d\n", fmin);
% fprintf("\nЗадача максимизации.\n");
% fprintf("\nШаг 5. Оптимальное решение:\n");
% print_matrix(marks_max);
% fprintf("\nШаг 6. Оптимальное значение функции: %d\n", fmax);
function [marks] = hungarian(source_matrix, debug)
    %Размер исходной матрицы (n x n)
    n = length(source_matrix );
    % Текущий режим (с выводом - true, без вывода - false).
    DEBUG = debug;
    
    if DEBUG
        fprintf("Исходная матрица стоимостей:\n");
        print_matrix(source_matrix);
    end
    
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
    
    fprintf("\n=== Подготовительный этап венгерского метода ===\n");
    
    source_matrix = source_matrix - min(source_matrix );
    if DEBUG
        fprintf("\nШаг 1. Вычтем из столбцов минимальные элементы.\n");
        print_matrix(source_matrix);
    end
    
    source_matrix = source_matrix - min(source_matrix , [], 2);
    if DEBUG
        fprintf("\nШаг 2. Вычтем из строк минимальные элементы.\n");
        print_matrix(source_matrix);
    end
    
    % Количество элементов в системе независимых нулей.
    k = 0;
    
    % Шаг 3 Строим начальную систему независимых нулей (0*).
    if DEBUG
        fprintf("\nШаг 3. Построение начальной системы независимых нулей (0*).\n");
    end
    
    for j = 1:n
        for i = 1:n
            if (source_matrix (i,j) == 0)
                if (max(marks(i, :)) == 0) % Если в строке еще нет 0*
                    marks(i,j) = 1;
                    mark_column (j) = 1; % (Шаг 3, стр. 398) "Столбцы... выделяем знаком '+'"
                    k = k+1;
                    if DEBUG
                        fprintf(" Найден 0* в (%d, %d). k = %d. Отмечаем столбец %d.\n", i, j, k, j);
                    end
                    break;
                end
            end
        end
    end
    
    iter = print_siz(DEBUG, iter, source_matrix, marks, mark_row, mark_column);
    
    % --- Итеративный этап (стр. 398) ---
    fprintf("\n=== Основной этап венгерского метода ===\n");
    while k < n
        if DEBUG
            fprintf("\n\t| Итеративный этап. | Итерация № %d. | k = %d, n = %d. (k < n), продолжаем. |\n", iter, k, n);
            fprintf("\nШаг 4. Поиск невыделенного нуля.\n");
        end
        has_zeros = false;
        j = 0;
        while ~has_zeros
            j = j+1;
            if j > n
                if DEBUG
                    fprintf(" Просмотрены все столбцы. Невыделенных нулей не найдено.\n");
                end
                break;
            end
            if mark_column (j) == 1 % Пропускаем выделенные столбцы
                continue
            end
            i = 0;
            while ~has_zeros
                i = i+1;
                if (i > n)
                    break;
                end
                if mark_row(i) == 1 % Пропускаем выделенные строки
                    continue
                end
        
                % Ищем ноль, который не 0* (т.е. невыделенный ноль)
                if source_matrix (i,j) ~= 0 || marks(i,j) == 1
                    continue;
                end
                
                % Нашли!
                if DEBUG
                    fprintf("\n Шаг 4.2. Найден невыделенный ноль в (%d, %d).\n", i, j);
                    fprintf("\n  Шаг 4.2.1. Отмечаем его как 0'.\n");
                end
                marks(i, j) = -1; % "помечаем через 0'"
                
                if DEBUG
                    fprintf("   Матрица с новым 0' в (%d, %d):\n", i, j);
                    print_current_marks(source_matrix, marks);
                end
                
                [mm, jmm] = max(marks(i, :)); % Ищем 0* в той же строке
        
                if DEBUG
                    fprintf("\n  Шаг 4.2.2. Проверяем наличие 0* в строке %d.\n", i);
                end
                if mm ~= 1 % Случай 1: В строке нет 0*.
                    if DEBUG
                        fprintf("    В строке %d НЕТ 0*. Переход к Шагу 4.2.3.\n", i);
                        fprintf("\n  Шаг 4.2.3. Построение L-цепочки.\n");
                    end
                    mark_row = zeros(1, n);    % "Снимаем знак '+' со столбца..."
                    mark_column = zeros(1, n); % "...и все знаки '+' со строк"
                    l_chain = [l_chain; [i j]];
                    mark_column (j) = 1; % (Этот шаг не описан, но он нужен для логики кода)
                    jm = j;
                    while (true)
                        [m, im] = max(marks(:, jm)); % Ищем 0* в столбце 0'
                        if m == 0
                            break;
                        end
                        [m, jmn] = min(marks(im, :)); % Ищем 0' в строке этого 0*
                        if (m == 0)
                            break;
                        end
                        marks(im, jm) = 0; % Инвертируем 0* -> 0
                        marks(i, j) = 1;   % Инвертируем 0' -> 0*
                        i = im;
                        j = jmn;
                        l_chain = [l_chain; [im jm]; [im jmn]]; % Добавляем звенья в цепь
                        jm = jmn;
                    end
                    marks(i,j) = 1; % Последний 0' -> 0*
                    
                    if DEBUG
                        fprintf("   L-цепочка построена. Произошла инверсия 0* и 0'.\n");
                        print_l_chain(l_chain); % Печатаем цепочку
                        l_chain = zeros(2,2); % Сбрасываем цепочку
                    end
                    
                    % Очищаем все штрихованные нули (0')
                    % "со всех элементов 0' снимаем знак ' "
                    for i_clean = 1:n
                        [m, j_clean] = min(marks(i_clean, :));
                        while m == -1
                            marks(i_clean, j_clean) = 0;
                            [m, j_clean] = min(marks(i_clean, :));
                        end
                    end
                    
                    % Восстанавливаем отметки столбцов (Шаг 3)
                    if DEBUG
                        fprintf("   Возврат к Шагу 4. Отмечаем + столбцы, содержащие 0*.\n");
                    end
                    for j_mark = 1:n
                        if (max(marks(:, j_mark)) == 1)
                            mark_column(j_mark) = 1;
                        end
                    end
                    
                    k = k+1;
                    iter = print_siz(DEBUG, iter, source_matrix, marks, mark_row, mark_column);
        
                else % Случай 2: В строке есть 0*
                    if DEBUG
                        fprintf("    В строке %d ЕСТЬ 0* (в столбце %d).\n", i, jmm);
                        fprintf("    Выделяем строку %d (+). Снимаем выделение со столбца %d (-).\n", i, jmm);
                    end
                    mark_column (jmm) = 0; % "снимаем знак '+' со столбца, в котором расположен 0*"
                    mark_row(i) = 1;       % "отмечаем знаком '+' его строку"
                    
                    if DEBUG
                        fprintf("    Текущие выделенные строки (+): %s\n", mat2str(mark_row));
                        fprintf("    Текущие выделенные столбцы (+): %s\n", mat2str(mark_column));
                    end
                    
                    if DEBUG
                        fprintf("    Возврат к Шагу 4 (Поиск невыделенного нуля).\n");
                    end
                end
                has_zeros = true;
            end
        end
        if has_zeros
            continue;
    
        end
             
        if DEBUG
             fprintf("\n Шаг 4.3. Среди невыделенных элементов нет ни одного нуля.\n");
             fprintf("  Модификация матрицы\n");
        end
        source_matrix = make_zeros(source_matrix, mark_row, mark_column, DEBUG);
        
        % В оригинальном коде здесь нет вывода, но после make_zeros
        % цикл while начинается заново с "Шага 4" (поиск невыделенного нуля).
        if DEBUG
            fprintf("  Модификация завершена. Возврат к Шагу 4.2. (Поиск невыделенного нуля).\n");
            print_current_marks(source_matrix, marks);
        end
    end
end
% Преобразуем исходную матрицу так, чтобы в невыделенной части матрицы появился хотя
% бы один ноль
function [source_matrix] = make_zeros(source_matrix, mark_row, mark_column, DEBUG) % Добавил DEBUG
    n = length(source_matrix);
    %Находим минимальный элемент среди невыделенных.
    h = max(max(source_matrix));
    for i = 1:n
        if mark_row(i) == 1 % Пропускаем выделенные строки
            continue;
        end
        for j = 1:n
            if mark_column(j) == 1 % Пропускаем выделенные столбцы
                continue;
            end
            % Ищем h среди невыделенных элементов
            if source_matrix(i, j) < h
                h = source_matrix(i, j);
            end
        end
    end
    
    if DEBUG
        fprintf("  Найден h = %d (минимальный невыделенный элемент).\n", h);
    end
    
    % Вычитаем h из невыделенных столбцов.
    if DEBUG
        fprintf("  Вычитаем h из всех невыделенных столбцов (mark_column == 0).\n");
    end
    for j = 1:n
        if mark_column(j) == 0
            source_matrix(:, j) = source_matrix(:, j) - h;
        end
    end
    
    % Прибавляем h к выделенным строкам.
    if DEBUG
        fprintf("  Прибавляем h ко всем выделенным строкам (mark_row == 1).\n");
    end
    for i = 1:n
        if mark_row(i) == 1
            source_matrix(i, :) = source_matrix(i, :) + h;
        end
    end
end

function [iter] = print_siz(debug, iter, source_matrix, marks, mark_row, mark_column) 
    if debug
        n = length(source_matrix);
        fprintf("\n----------------------------------------"); 
        fprintf("\nСостояние на конец итерации № %d.\n", iter); 
        
        % Печатаем выделенные строки и столбцы
        fprintf(" Выделенные строки (+): %s\n", mat2str(mark_row));
        fprintf(" Выделенные столбцы (+): %s\n", mat2str(mark_column));
        
        fprintf("\nТекущая матрица (0* отмечен *, 0' отмечен '):\n");
        
        for i = 1:n
            for j = 1:n
                fprintf("%d", source_matrix(i,j));
                if marks(i, j) == 1
                    fprintf("*"); % 0*
                elseif marks(i, j) == -1
                    fprintf("'"); % 0' (штрих)
                end
                fprintf("\t");
            end
            fprintf("\n");
        end
        fprintf("\n");
    end
    iter = iter + 1;
    fprintf("----------------------------------------\n"); 
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

function [] = print_l_chain(l_chain)
    n = length(l_chain);
    
    if n > 2
        % Добавлен отступ для лучшей читаемости
        fprintf("   L-цепочка:\n   (%d, %d) ", l_chain(3, 1), l_chain(3, 2));
    if n > 3
        for i = 4:n
            fprintf(" -> (%d, %d) ", l_chain(i, 1), l_chain(i, 2));
        end
    end
    fprintf("\n");
    % l_chain = zeros(2,2); % Сброс удален
    end
end

% Вспомогательная функция для печати текущей матрицы с отметками
% (без заголовка итерации и инкремента)
function [] = print_current_marks(source_matrix, marks)
    n = length(source_matrix);
    for i = 1:n
        for j = 1:n
            fprintf("%d", source_matrix(i,j));
            if marks(i, j) == 1
                fprintf("*"); % 0*
            elseif marks(i, j) == -1
                fprintf("'"); % 0' (штрих)
            end
            fprintf("\t");
        end
        fprintf("\n");
    end
    fprintf("\n");
end