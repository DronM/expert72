INSERT INTO employees (
name,
user_id,
department_id,
post_id
)
VALUES 
(
'��������� ������ ����������',
(SELECT u.id FROM users AS u WHERE u.name='��������� ������ ����������'),
3,
4
)
,(
'��������� ��� ���������',
(SELECT u.id FROM users AS u WHERE u.name='������ ������� �������������'),
3,
4
)
,(
'��������� ������� ����������',
(SELECT u.id FROM users AS u WHERE u.name='����������� ���� ����������'),
3,
4
)
,(
NULL,
(SELECT u.id FROM users AS u WHERE u.name='������� ������ ���������'),
3,
4
)
,(
'��������� ������� ���������',
(SELECT u.id FROM users AS u WHERE u.name='��������� ������� ����������'),
3,
4
)
,(
NULL,
(SELECT u.id FROM users AS u WHERE u.name='������� �� ���������'),
3,
4
)
,(
'���������� ����� �����������',
(SELECT u.id FROM users AS u WHERE u.name='���������� ����� �����������'),
3,
4
)
,(
'������ ������ ����������',
(SELECT u.id FROM users AS u WHERE u.name='������ ������ ����������'),
3,
4
)