INSERT INTO employees (
name,
user_id,
department_id,
post_id
)
VALUES 
(
'Подьякова Ираида Дмитриевна',
(SELECT u.id FROM users AS u WHERE u.name='Подьякова Ираида Дмитриевна'),
3,
4
)
,(
'Желтышева Яна Борисовна',
(SELECT u.id FROM users AS u WHERE u.name='Магера Дмитрий Александрович'),
3,
4
)
,(
'Бессонова Татьяна Евгеньевна',
(SELECT u.id FROM users AS u WHERE u.name='Комаровская Вера Николаевна'),
3,
4
)
,(
NULL,
(SELECT u.id FROM users AS u WHERE u.name='Туманов Леонид Борисович'),
3,
4
)
,(
'Чупрунова Татьяна Романовна',
(SELECT u.id FROM users AS u WHERE u.name='Бессонова Татьяна Евгеньевна'),
3,
4
)
,(
NULL,
(SELECT u.id FROM users AS u WHERE u.name='эксперт не определен'),
3,
4
)
,(
'Янушевский Денис Анатольевич',
(SELECT u.id FROM users AS u WHERE u.name='Янушевский Денис Анатольевич'),
3,
4
)
,(
'Евсеев Сергей Витальевич',
(SELECT u.id FROM users AS u WHERE u.name='Евсеев Сергей Витальевич'),
3,
4
)