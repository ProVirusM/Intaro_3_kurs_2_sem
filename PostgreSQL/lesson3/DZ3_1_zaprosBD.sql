-- Основной запрос для вычисления среднего времени нахождения заказа в каждом статусе
SELECT
    new_value AS "Статус заказа", -- Выбор нового значения статуса и присвоение ему понятного названия "Статус заказа"
    avg(T.date_difference)::decimal(10,2) AS "Среднее время статуса" -- Вычисление среднего времени нахождения заказа в данном статусе, округление до двух знаков после запятой и присвоение названия "Среднее время статуса"
FROM
(
    -- Подзапрос для расчета временной разницы между изменениями статусов
    SELECT
        order_id, -- Выбор идентификатора заказа
        created_at, -- Выбор даты изменения статуса
        new_value, -- Выбор нового значения статуса
        lead(created_at) OVER (PARTITION BY order_id ORDER BY created_at) - created_at AS date_difference
        -- Функция lead для получения даты следующего изменения статуса, вычисление разницы между текущей и следующей датой изменения статуса
        -- PARTITION BY order_id делит данные на группы по идентификатору заказа
        -- ORDER BY created_at упорядочивает изменения по дате внутри каждой группы
    FROM
        order_history
    WHERE
        field_name = 'status_id' -- Фильтрация только тех записей, которые относятся к изменению статуса заказа
) T
GROUP BY
    new_value -- Группировка по новому значению статуса
HAVING
    avg(T.date_difference) IS NOT NULL; -- Отбор только тех групп, где среднее время не является NULL
