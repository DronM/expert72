INSERT INTO clients (
name,
name_full,
inn,
kpp, 
okpo, 
user_id, 
post_address, 
legal_address, 
client_type, 
base_document_for_contract
)
VALUES 
(
'������� ������������ ������������� ������������� �. ��������',
'������� ��������
���� ������������� ������������� ������ ���������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626152'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ��������'),
'dom','��. �����������',
'korpus','3',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'�������� ���',
'��� ���������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ��������'),
'dom','�. 31',
'korpus','���. 10',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'�������� ������������� �������������� ���',
'�������� ������������� �������������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� ���',
'��������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� ������������ �������� ���',
'��������� ������������ �������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����� ���',
'����� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������� ���',
'�������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����������-11 ���',
'����������-11 ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��-������������',
'��-������������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������-������������ �������� ���',
'������������-������������ �������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����� ���-3 000',
'000"����� ���-3"',
'���',
'7203321348 ��� 7',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. 50 ��� �������'),
'dom','215',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. 50 ��� �������'),
'dom','215',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'����������-12 ���',
'��� "����������-12"',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','�. ������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��. ���������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.1'),
'dom','���.5',
'korpus','����� �14',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� �������� ����� ���',
'�������� � ������������ ���������������� ���������� 
�������� ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627305'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�������������� �����'),
'dom','�. ����-�������',
'korpus','��. �������������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��� ��� ��',
'��������������� �������� ���������� ��������� ������� "���������� ������������ �������������"',
'7202180535',
'720201001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625000'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ���������'),
'dom','11',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625000'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ���������'),
'dom','11',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'������������� ��������� ���',
'������������� ��������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��� ��� ��',
'��������������� �������� ���������� ��������� ������� "���������� ������������� �����"',
'7203001860',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��.���������� �.143 ������ 2.'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��.����������'),
'dom','143',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'�������������� ���',
'�������� ����������� �������� "��������������"',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','628415'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� ���.'),
'dom','����-����',
'korpus','�. ������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'���� ��� ��',
'��������������� �������� ���������� ��������� ������� "�������� �����������-�������������� �������������"',
'7203112133',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. ����������',
'korpus','272',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. ����������',
'korpus','272',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'������ ��������� ��������� �������������� ������ ��� ��',
'������������� �������� ���������� "������ ��������� ��������� �������������� ������"',
'7225004600',
'722501001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626170'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ����'),
'dom','��. ���������',
'korpus','19',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626170'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ����'),
'dom','��. ���������',
'korpus','19',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'������ ��������� ��� ������������� ������',
'������ ��������� ��� ������������� ������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������� ���',
'�������� ����������� �������� ��������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625002'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ������������'),
'dom','�. 13',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ���',
'��������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������ ��������� �������� ���',
'�������� � ������������ ���������������� ����������
�������� �������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625003'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �������'),
'dom','�. ������',
'korpus','��. ������������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������-������ ���',
'��� "��������-������"',
'720180214',
'720501001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.����'),
'dom','��.��������',
'korpus','�.1',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.����'),
'dom','��.��������',
'korpus','�.1',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'���� ������ �������� ��',
'���� ������ �������� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� �� ���������� ��������� ������������ �� ���',
'�� ����� �� ��������� 
�������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','�. ������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��. ������������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','63'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'���������������  ��� ���',
'��� ����������-����������� ����� ����������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625007'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. �����������',
'korpus','��� � 80',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'� - ��������� ���',
'� - ��������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������� ����������� �������������� ������',
'������������� ����������� �������������� ������ ��������� �������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626159'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','���������� �����'),
'dom','�. �������',
'korpus','��. ������������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����-��������� �������������������� ����� ���',
'����-��������� �������������������� ����� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������� �������-������������ �������� �����. ����������� ��',
'������� �������-������������ �������� �����. ����������� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����������������������� ���',
'����������������������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������ ���',
'�������� � ������������ ���������������� �������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625016'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �������'),
'dom','�. ������',
'korpus','��. ���������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������ �������� ���',
'��� "������ ��������"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��� ����� ���������� ���',
'��� ����� ���������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������������� ��� ���',
'�������������� ��� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� ���� ���',
'��������� ���� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������� ���',
'��� �������ѻ',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625049'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ��
�������� �����'),
'dom','�.140',
'korpus','���.1',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������������� ���������� �������������� ������',
'������������� ���������� �������������� ������',
'7204095797',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','�.������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��.���������� �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','115'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','�.������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��.���������� �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','115'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'���������������� ���',
'���������������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��� ��� (���������� �������� ������)',
'��� ����������� �������� ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','107174
��'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ����� ���������'),
'dom','��� 2',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����������� ��� ��',
'�� "����������� ��������������������� �����"',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625047'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','6 �� ������� ����������� ������',
'korpus','20',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������ ���',
'�������� ����������� �������� "������"',
'7215003396',
'721501001',
'03912115',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627140'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�������������� �-�'),
'dom','���. �������������',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627140'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�������������� �-�'),
'dom','���. �������������',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'��� ���������� ���',
'��� ���������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���������������� ���',
'���������������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�� ���',
'�������� � ������������ ���������������� "��"',
'7204189572',
'720401001',
'26155993',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625022'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.������. ��. �-�.�. �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.10/7'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625022'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.������. ��. �-�.�. �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.10/7'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'����������� ������� ��������� ��������� �������',
'����������� ������� ��������� ��������� �������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������-���������� ����� ������� ���',
'��������-���������� ����� ������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����  ���',
'��� "��������� ���������������� ��������"',
'7203032191',
'723150001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��.����������'),
'dom','253',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��.����������'),
'dom','253',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'��������+ ���� ���',
'��� "���� "��������+"',
'7203222386',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. ������',
'korpus','87�',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. �����������',
'korpus','105',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'������������� ���������� �������������� �����������',
'������������� ���������� �������������� �����������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������ ��������� ���',
'��� ������������ ���������',
'7224008030',
'722401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625504'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�. ���������',
'korpus','��. �����������',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625504'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�. ���������',
'korpus','��. �����������',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'����� ��',
'�� "��������� ��������� �������-���������������� �����������"',
'7203175930',
'720350001',
'33582661',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ����������'),
'dom','143',
'korpus','���.2',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ����������'),
'dom','143. ���.2',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'��������� �������� ���������� ���',
'��������� �������� ���������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������������������� ���',
'�������������������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������� "�����" ���',
'�������� "�����" ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���������� ������ ������� ��',
'���������� ������ ������� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������� ���',
'��� ��������һ',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ���������'),
'dom','�. 74',
'korpus','����. 1/4',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������� ����� ��',
'������� ����� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� �������� �23 (�.����������) ���� ��',
'��������� �������� �23 (�.����������) ���� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����������������� ��������� �������� ���',
'�������� � ������������ ���������������� ���������� �������� ������������������',
'6658434632',
'6658010',
'25937995',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','620014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','������������ ���.'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.�������������'),
'dom','��.������� ������',
'korpus','�.5',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','620109'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','������������ ���.'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.�������������'),
'dom','��. ������',
'korpus','�. 51',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'����������������� ���',
'��� "�����������������"',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ������'),
'dom','24/8',
'korpus','��. 501',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��-���������� ��� ���',
'�������� � ������������ ��������������� ��� "��-����������"',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625033'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','�. ������',
'korpus','��. ������ ��������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ���',
'��������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���� ����� ���������� ��',
'���� ����� ���������� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������� ���',
'�������� � ������������ ���������������� "��������"',
'7202198420',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �.��������'),
'dom','�.44',
'korpus','��611',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �.��������'),
'dom','�.44',
'korpus','��611',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'��������� ���� ����� ��� ��',
'��������� ���� ����� ��� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������� ��� ��� ���',
'��� "�������� ��� ���"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������-������������ ���������� "�����������"',
'�������-������������ ���������� "�����������"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������������� ���',
'�������������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����������� �������� ����-�� � ��-�� ������������� �.������',
'����������� �������� �������������� � ���������� ������������� ������ ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','�. ������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��.
��������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','60�'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'�������-������������ ���������� "����������-11" ���',
'�������� � ������������ ���������������� �������-������������ ���������� "�����������-11"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���� "����������� �����" ���� ��',
'��������������� ���������� ���������� ��������������� ��������� ������� "��������������� �����������  ����������� ����� "����������� �����"',
'7204006910',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625041'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ������������'),
'dom','32',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625041'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ������������'),
'dom','32',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'��������� ����� ���',
'��� "��������� "�����"',
'7226003278',
'722601001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627180'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','���������� �����'),
'dom','�. �������',
'korpus','��. ��������',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627180'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','���������� �����'),
'dom','�. �������',
'korpus','��. ��������',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'�������� ���',
'�������������������� ���������������� ���������� "��������"',
'7221002619',
'722101001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627625'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','����������� �����'),
'dom','�. ��������',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627625'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','����������� �����'),
'dom','�. ��������',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'������� ����� ���������',
'������� ����� ���������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����������� �������� ������������� ��������� ���',
'����������� �������� ������������� ��������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� ���',
'��������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������-�� ���',
'�������-�� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���-98 ���',
'���-98 ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������� ���������� �������� ���',
'�������� ���������� �������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������. ������ ���',
'�������� � ������������ ���������������� "��������. ������"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����� ���',
'����� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� ������ ��������� ����� ������ ����� ������ ��� ��',
'��������� ������ ��������� ����� ������ ����� ������ ��� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����� ���',
'����� ���',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','�. �����������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr',NULL),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr',NULL),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ������������� ����������� ���',
'��� ���������� ������������� �����������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625030'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. ����������',
'korpus','10/4',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ���������� ���',
'��������� ���������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������� ������ ����������',
'�������� ������ ����������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������������� ��� ���',
'��� ���������-�������������� �������� ����������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625007'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �����������'),
'dom','�. 91',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��� ��� ���',
'�������� � ������������ ���������������� "��������-������������ �������� "���"',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �����������'),
'dom','�. 1',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������� ��� ������������� �.���������',
'������� �������-������������� ���������
������������� ������ ���������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626150'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.��������'),
'dom','8 �����
�����',
'korpus','�.32',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'�������� ������������������� ���',
'����������� �������� "�������� �������������������"',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','����� ������'),
'dom','��. ���������-�������',
'korpus','�. 58',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����������� ��� ��������� �������',
'����������� ��� ��������� �������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���� � �  ���',
'��� "���� � �"',
'7203094857',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��.�������'),
'dom','115 �',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','�. ������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��. �����������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','98/11'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'�������-���� ���',
'�������-���� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������ ���������� ���',
'��� ��������-
����� ������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625547'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�. �������',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'���-��� ���',
'�������� � ������������ ���������������� "���-���"',
'7203287344',
'720301001',
'15381284',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625013'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. 50 ��� �������'),
'dom','88',
'korpus','��.305',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625013'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. 50 ��� �������'),
'dom','88',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'���������������� ���',
'���������������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��� ��������� ��',
'��� ��������� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������� �� ���',
'���������� ���������� ����� �������� � ������ "�������"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���-����� ���',
'�������� � ������������ ���������������� "���-�����"',
'8602108510',
'860201001',
'52053129',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','628403. �����-���������� -���� ��'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','������ �'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������������� ��'),
'dom','�� �7',
'korpus','��. 27',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','628403. �����-���������� -���� ��'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','������ �'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������������� ��'),
'dom','�� �7',
'korpus','��. 27',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'������������� ���',
'������������� �������� ���������� "�������������"',
'7207000017',
'720701001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627011'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','���������� ���������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �������'),
'dom','�.
����������',
'korpus','��. �������',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627010'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ����������'),
'dom','��. ���������',
'korpus','42',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'����� �����-������+ ���',
'����� �����-������+ ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������ ���',
'�������� � ������������ ���������������� "������"',
'5507231685',
'550701001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','644074'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��.���������. �.15/3'),
'dom','��.15',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','644074'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��.���������. �.15/3'),
'dom','��.15',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'������������� ��������� �������������� ������',
'������������� 
��������� �������������� ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626380'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�������� �����'),
'dom','�.
��������',
'korpus','��. �������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������� �������� ������ ���',
'������� �������� ������ ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������������������� ���',
'�������������������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������� ��������������� �������� ����� ��',
'�������� ��������������� �������� ����� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������������� ���',
'��� ��������������',
'7224001941',
NULL,
'12498488',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','�. ������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��. �����������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','134'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','�.������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��. �����������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','134'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'���� ���',
'���� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������ ���',
'������ ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������ ��������� ����� ��',
'������������� ���������� ������� ��������� �����',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627141'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.������������'),
'dom','��.���������',
'korpus','��� 141',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'�������������.�����.-�����.����������� "�����" ��� ����.�-��',
'�������������.�����.-�����.����������� "�����" ��� ����.�-��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������� ���',
'�������� � ������������ ���������������� "�������"',
'7214006436',
'722001001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627324'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�������������� �����'),
'dom','�.����������',
'korpus','��. 60 ��� �������',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627324'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�������������� �����'),
'dom','�.����������',
'korpus','��. 60 ��� �������',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'����������������� �������� ���',
'����������������� �������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������ ��������� �� ��������������� ��� �.������  ���',
'������������� �������� 
���������� ������� ��������� �� ��������������� ������������ �����������������
������ ������ ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ������������'),
'dom','�.61',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ����������������� �������� ��������� ������� ��',
'��������� ����������������� �������� ��������� ������� ��',
'7203223118',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625034 �.������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��. ����������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.194'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��� �������� ��',
'����������� �������� "��� ��������"',
'7204002810',
'720350001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625003'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �������'),
'dom','44',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625003'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �������'),
'dom','44',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'����� �������� ���',
'�������� � ������������ ���������������� "����� ��������"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������������� �������� ���',
'��� ��������� �������������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��.��������� � �������'),
'dom','�.58',
'korpus','������ 4',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'���������������� �����. ���- � ���������-��������� �������',
'���������������� �����. ���- � ���������-��������� �������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���������������� ���',
'��� �����������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625051'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. ���������',
'korpus','43�',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����� ��������� ������� ��',
'����������� �������� "�������������� �������"',
'7224005872',
'722401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625512'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�. �������',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625512'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�. �������',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'������������ ��������� ����� �.�. �������� ���',
'��� ������������ ���������',
'7224008030',
'722401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625504'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�. ���������',
'korpus','��. �����������',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625504'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�. ���������',
'korpus','��. �����������',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'������������ ��',
'�� "������������"',
'8602060185',
'720202001',
'05789943',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625000'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ����������'),
'dom','44',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','628412'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. ���������������',
'korpus','4',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'�������������������� ���',
'�������� ����������� �������� ���������������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. ����������',
'korpus','�. 143',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ��� ����',
'��������� ��� ����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��� �14 ���� �. ��������',
'��� �14 ���� �. ��������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��� �2 �.���� ����',
'������������� ���������� ������������������� ���������� ������� ������������������� ����� �2 �.�����',
'7205009938',
'720501001',
'42177528',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ������������'),
'dom','41',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ������������'),
'dom','41',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'����������������������� ���',
'����������������������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� ������������ ����������� �������� ���� ��',
'��������������� ��������� ���������� ��������������� ��������� ������� "��������� ������������ ����������� ��������"',
'7202100272',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625002'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �������������'),
'dom','�.54�',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625002'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �������������'),
'dom','�.54�',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'�������� ��',
'�������� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����.����� ���������.� ���-�� "�������" ���',
'����.����� ���������.� ���-�� "�������" ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������������� ��� ���',
'��� ��������� � ��������������� ��������
����������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626150'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� ���.'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.��������'),
'dom','��. ����������',
'korpus','��� 6�',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����� �� ���',
'������������� ���������� ���������� "����������� ����� ����������� ������������ ��������� ������������ ������"',
'7222018393',
'720501001',
'84672443',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','����������� �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','� �.��������'),
'dom','��. ������',
'korpus','123',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627500 ��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','����������� �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','� �.��������'),
'dom','��. ������',
'korpus','123',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'����� ���',
'��� ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625051'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.������'),
'dom','��. 30 ��� ������',
'korpus','�.81�',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����� ���',
'�������� ����������� �������� �����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���������� ���',
'�������� � ������������ ���������������� "����������"',
'7205010764',
'720501001',
'12527758',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627704'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�������� �����'),
'dom','�.��������',
'korpus','��. ����',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�������� �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.��������'),
'dom','��. ����',
'korpus','�.7/2',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'��������� �������� ��������� �������, ��������� � �������',
'����� �� "��������� �������� ��������� �������, ��������� � �������"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���������� ��� �.����� ���',
'������������� �������� ���������� ����������� ��-
�����-������������ ���������� ������ �����',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','���������� ���������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �������'),
'dom','�. ����',
'korpus','��. ���������-
��',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������������ �������� ������ ���',
'�������� � ������������ ���������������� "������������ �������� "������"',
'7203267387',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625027'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �����������'),
'dom','72 "�"',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625027'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �����������'),
'dom','72 "�"',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'��������� �������� �3 (�. ��������) ���� ��',
'��������������� ��������� ���������� ��������������� ��������� ������� "��������� �������� �3" (�. ��������)',
'7223008503',
'720601001',
'01948571',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626150'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ��������'),
'dom','3� ����������',
'korpus','�24',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ��������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','3� ����������'),
'dom','�24',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'������������� ��������� �������������� ������',
'������������� ��������� �������������� ������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������� ��� �183 �����',
'������������� ���������� ���������� ��������������� ���������� ������� ��� �183 ������ ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ��������'),
'dom','27',
'korpus','������ 2 ������ �',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'���������� ������� �������� � �������� ����� �.�. �������� �',
'��������������� ���������� ���������������� ��������������� ���������� ��������� ������� "���������� ������� �������� � �������� ����� �.�. ��������"',
'7206017385',
'720601001',
'02177688',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626150 ��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ��������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','10 ����������'),
'dom','�.85',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626150 ��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ��������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','10 ����������'),
'dom','�.85',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'��������� ������������-��������������� ���� ���',
'��� ���������� ������������-��������������� ����',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625032'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��.
��������'),
'dom','�.23',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������ �� � � �� ������������� ��',
'������ �� � � �� ������������� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������������� ������� ����� ��',
'������������������� ������� ����� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������-���� ���',
'�������-���� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������ ��������� �������� ��',
'�������������� ��������������� ������ ��������� ��������',
'7202126466',
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ������'),
'dom','�. 15',
'korpus','��.49',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'���������� ���',
'���������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����������-11 ��',
'����������-11 ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�����������  ���',
'��� "�����������"',
'7204012769',
'720401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��.����������'),
'dom','14/9',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','�. ������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��. ����������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','14/1'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'��������-���������������� ������� �2 ���',
'��� ���������-���������������� ������� � 2�',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','150014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ���������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �������'),
'dom','�. 3',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������ ���',
'������ ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���� ��������� ���',
'���� ��������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������-�������������� ����� ���',
'��������-�������������� ����� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����������-����� ���',
'��� "����������-�����"',
'7216005220',
'721601001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. ���������',
'korpus','1/9',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626385'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�������� �����'),
'dom','�. ��������',
'korpus','��. ����',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'��� �5 �. ����� ����',
'��� �5 �. ����� ����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������� ������������� ���',
'�������� ������������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������� ���',
'������������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������������� ���',
'�������� � ������������ ����������������
����������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.����'),
'dom','��.���������',
'korpus','41',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������������� ���������� �������������� ������',
'������������� ���������� �������������� ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626050'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�. ������',
'korpus','��. ����������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'�������� ���',
'�������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���� ������� ���������',
'���� ������� ���������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������� ���������������� �������������� ������',
'������������� ���������������� �������������� ������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���������������� ��',
'����������� �������� ���������� ��������-������-
�������� �������� ������� ���������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625023'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��.
����������',
'korpus','��� 169',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'�������� ������ ���� ����',
'�������� ������ ���� ����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� ��� ����',
'��������� ��� ����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������ ��� ����',
'������������ ��� ����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����������� ���',
'��� ������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625022'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. ���������',
'korpus','�. 112',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ��� ����',
'������������� ���������� ������������������� ���������� "��������� ������� ����������������� �����"',
'7223009352',
'720601001',
'52540013',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626110'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','���������� �����'),
'dom','�. ������',
'korpus','��. ���������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������������ ��� ����',
'������������� ���������� ������������������ ���������� "������������  ������� ������������������� �����"',
'7223009232',
'720601001',
'52540119',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626115 ��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','���������� �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ����������'),
'dom','��. ��������',
'korpus','27',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����� �������� � ������ ��������� ������ ��� ��������',
'����� �������� � ������ ��������� ������ ��� ��������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������-���� ���',
'�������-���� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��� �65 ���� �. ������',
'������������� ���������� ������������������� ���������� ������� ������������������� ����� �65, �. ������',
'7203076544',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625046'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ��������'),
'dom','116',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625046'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ��������'),
'dom','116',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'�������-��������� ��������������� ������� ����� ��',
'��������������� ���������� ���������������� ��������������� ���������� ��������� ������� "�������-��������� ��������������� �������"',
'7204007166',
'720301001',
'42155320',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �������'),
'dom','34',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �������'),
'dom','34',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'���������� ������� ������������������� ����� ����',
'������������� ������������������� ���������� ���������� ������������������� �����',
'7212003630',
'720601001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626252 ��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. �������'),
'dom','��',
'korpus','�������',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626252 ��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. �������'),
'dom','��',
'korpus','�������',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'��������� �������� �24  ���� �� (�.������)',
'��������������� ��������� ���������� ��������������� ��������� ������� "��������� �������� �24" (�.������)',
'7229000035',
'722401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626050 ��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. ������',
'korpus','68',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626050 ��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. ������',
'korpus','68',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'����� ��������� ���',
'�������� � ������������ ���������������� "����� ���������"',
'5612072699',
'561201001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','460019'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ��������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','���������� �����'),
'dom','36/2 (1 ����)',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','460026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ��������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ��������'),
'dom','�.80',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'������������������ ���',
'��� "������������������"',
'7203175256',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','��'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','625014'),
'dom','�. ������',
'korpus','��. ����������',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','��'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','625014'),
'dom','�. ������',
'korpus','��. ����������',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'������������ ��� ��',
'�������� � ������������ ���������������� ����������� �������� "������������"',
'7206050093',
'7',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626102'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ��������'),
'dom','�. �������',
'korpus','��. ��������',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626102'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ��������'),
'dom','�. �������',
'korpus','��. ��������',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'����� ����� ���',
'����� ����� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� �������� �4 (�. ����) ���� ��',
'��������� �������� �4 (�. ����) ���� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������ ��������� ���������� ������ ���',
'�������������
�������� ���������� ������� ��������� ���������� ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625049'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��.
���������� �����'),
'dom','��� 115',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ��� ���� ���',
'��������� ��� ���� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������� ��� �2 ����',
'�������� ��� �2 ����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� ���  ��. �. ���������� ����',
'������������� ���������� ������������������� ���������� "����������  ������� ������������������� �����',
'7224038010',
'722401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625511'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�.�������',
'korpus','��. ���� �������',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625511'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�.�������',
'korpus','��. ���� �������',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'������� ��� �2 ���������������� ���� ������ ����� �����',
'������������� ���������� ���������� ��������������� ���������� "������� ��� �2 ���������������� ����" ������ �����',
'7205018731',
'720501001',
'84672644',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750 ��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','������ �.��������'),
'dom','35',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750 ��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','������ �.��������'),
'dom','35',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'�������� ��� ���������� �� ����',
'������������� ���������� ������������������� ���������� �������� ������� ������������������ ����� ���������� �������������� ������',
'7224037948',
'722401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625541'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�.��',
'korpus','��',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625541'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�.��',
'korpus','��',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'��� �� ��',
'�������������� ����������� "���� ������������ ������� ��������������� ����� ��������� �������"',
'7204201389',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048 ��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ������������'),
'dom','10',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048 ��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ������������'),
'dom','10',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'���������� ������� ��� "������" ����� ���������� ��',
'������������� ���������� ���������� ������������������ ����������  ���������� �������������� ������  ���������� ������� ��� "������"',
'7224037962',
'722401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625537'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�. �����',
'korpus','��. �������',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625537'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�. �����',
'korpus','��. �������',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'��������� ��� �3 ���� ��',
'��������� ��� �3 ���� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������ ��� ����',
'������������� ���������� ������������-
������� ���������� ������������ ������� ������������������� ����� ����������
�������������� ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625512'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�. �������',
'korpus','��.
��������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����� ���� ��',
'����� ���� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� ����� ������������ ����� ���. �����-� �� ���',
'�� ����� �����-
������� ��� �� �����������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625058 �. ������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��. ����������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.10'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ���. ����. ����. ��. �.�.���������� ����',
'��������� ���. ����. ����. ��. �.�.���������� ����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� ����������� �8 ����',
'������������� 
����������� ���������� ���������� ���������� ����������� � 8�',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625031'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.��
����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��.��������'),
'dom','10 �',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����������� ���',
'����������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������-�������������� ����� ���� ��',
'��������������� ���������� ������������������� ����������
��������� ������� �������-�������������� �����',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625051'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. 30 ��� ������'),
'dom','102',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'�������� ��',
'�������� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��� �������� ���������� ��� ��',
'��� �������� ���������� ��� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����� ������ ��',
'����� ������ ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���� ���� ������ ����� ���',
'���� ���� ������ ����� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������ ��������� �� ��������������� ��� �. ������ ���',
'������������� �������� ���������� "������ ��������� �� ��������������� ��� �. ������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� �������-���������������� ����������� ���� ��',
'��������� �������-���������������� ����������� ���� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������������� ��� ���',
'�������������� ��� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������ ������� ��� �����',
'������������ ������� ��� �����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������ ��� ����',
'������������ ��� ����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������ ���',
'������ ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���� ��� ��� ���',
'���� ��� ��� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����� ���',
'����� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� ��������� ������������ ����������� ��� ��',
'��������� ��������� ������������ ����������� ��� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������� ����������� ������� ����� ��',
'�������� ����������� ������� ����� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���������� ���',
'���������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������ �������� ���',
'������ �������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������ ���',
'������������ ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������������� ���',
'�������������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������+ ���',
'��� ��������+�',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.������'),
'dom','��. ������ 87�',
'korpus','��. 416',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������� ��� ���',
'�������� � ������������ ���������������� "������-���������������� ����������� "��������� ������� ������������-������������ ����������"',
'7203371003',
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625022'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �.-�.�. �����'),
'dom','�.10',
'korpus','�.94',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625022'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �.-�.�. �����'),
'dom','�.10',
'korpus','�.94',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'�������� �� ���������� ������������� ���������� ��������� ��',
'��� ��������� �� ���������� ������������� ���������� ��������� �������������� ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626170'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� ������� �������� �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ����'),
'dom','��. ��������� 19',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������� �������������� ����� ��. �.�. ���������� ��� �� ����',
'������� �������������� ����� ��. �.�. ���������� ��� �� ����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������-���������� ����� "��������" ���',
'����������� �������� �������-���������� �����
���������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625000'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �������'),
'dom','�.������',
'korpus','��. �������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'�������-��������� ������������� ����� ��� ��',
'��������������� ���������� ���������� ��-
������� ������� ��������-��������� ������������� �����',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','����������
���������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �������'),
'dom','�. ������',
'korpus','��. ����������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������� ����������������� ����� ��',
'�� �������� ����������������� �����',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �����������'),
'dom','�. 163',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'�������������� ���',
'��� "��������������" �. ����',
'7205011662',
'720501001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ����'),
'dom','��. ���������',
'korpus','51',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ����'),
'dom','��. ���������',
'korpus','51',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'��������� �������� �4 (�. ����) ���� ��',
'��������� �������� �4 (�. ����) ���� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������� ���',
'�������� � ������������ ���������������� ��������̻',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625047'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','7 ��. ������� ����������� ������'),
'dom','�. 18',
'korpus','���. 6',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������������������������� ���',
'�������� � ������������ ����������������
��������������������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �����������'),
'dom','106',
'korpus','��. 408',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����������� ��� ����',
'�������������
 ���������� ������������������� ���������� ����������� ������� ����������
��������� ����� ���������� ������ ��������� �������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626260'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� ��-
�����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�. ��������',
'korpus','���. ��������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'���������� ��� ��� ��',
'������������� ���������� ���������� �����-
���������� ����������� ���������� ������� ����� �������� ���������� ������-
�������� ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625547'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','���������
�����'),
'dom','�. �������',
'korpus','��. ���������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ��� �2 ���� ��',
'��������������� ��������� ���������� ��������������� ��������� ������� ���������� ��� �2�',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625027'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �����������'),
'dom','58',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'���������-��������� ����� ����� ��������� ���',
'��� ����������-��������� ����� ����� ���������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','107045'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�������� ���.'),
'dom','��� 24',
'korpus','���. 1.',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'�������� ������ ���',
'�������� � ������������ ���������������� ������� ����
����',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','�. ������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','19'),
'dom','��.45',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��� �9 � ����������� ��������� ��������� ��������� ����',
'�������������
���������� ������������������� ���������� �������� ������������������� �����
�9 � ����������� ��������� ��������� ���������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626150'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ��������'),
'dom','4 ����������',
'korpus','�.32',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����� ���-3 ���',
'��� "����� ���-3"',
'7203045070',
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ��������'),
'dom','��. ���������',
'korpus','4',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ��������'),
'dom','��. ���������',
'korpus','4',
'kvartira',null)
,
'enterprise',
'�����'
)
,(
'�������� ���������� ��������� �� ���',
'�������� ���������� ��������� �� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���������� ��� ����� ����� ���� ���������� ��',
'������������� ����������
������������������� ���������� ����������� ������� �������������������
����� ����� �.�. ����� ���������� �������������� ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625537'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','���������
�������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�. �����',
'korpus','��. ��������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������ ��������� �� ��������������� ��� �. ������',
'������������� �������� ���������� ������� ��������� �� ��������������� ���������� ����������������� ������ ������ ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625027'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �����������'),
'dom','�. 74',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ��� ��������� ���� ��� ��',
'��������� ��� ��������� ���� ��� ��',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625000'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ������������'),
'dom','47/1',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� �������� �12 (�. ������������) ���� ��',
'��������������� ��������� ���������� ����
����������� ��������� ������� ���������� �������� �12�',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','��������� �������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�������������� �����'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.����
��������'),
'dom','��. ������',
'korpus','19',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������������� ����������� �� ��',
'������������� 
����������� �������������� ����������� ���������� ������ ��������� �������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625513'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�.�����',
'korpus','��.���������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����������������� ���',
'��� ������������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ����������'),
'dom','�. 169',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������������� ���������������� �������������� �����������',
'������������� ���������������� �������������� �����������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������ ���������������� ���',
'�������� � ������������ ���������������� ������� ����������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625000'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. ����������',
'korpus','54',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������������ ��� ����',
'������������� ����������
������������������� ���������� ������������ ������� ������������������� 
�����',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627551'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�������� �����'),
'dom','�.
���������',
'korpus','��. �����������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����� �������� � ������ ���������� �� ��',
'���������� ���������� ������ �������� � 
������ ���������� �������������� ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627250'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �����'),
'dom','�.���������',
'korpus','��. ������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��� ����� ��',
'����������� ��������������� ���������� ��
������������� ���������� ������� ����������� ���������� ��������������� �����������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625003'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�. ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. ������������'),
'dom','�.6',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ������������ ����������� �������� ���� ��',
'���� �� ���������� ������������ ����������� ��������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625002'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. �������������'),
'dom','54�',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ���� �������� ���',
'�������� � ������������ ���������������� ����������
���� ���������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','644100'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','������ �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.
����'),
'dom','��. ��������� ��������',
'korpus','3',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��� �������� ���������� ��� �� �. ��������',
'��� �������� ���������� ��� �� �. ��������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������ ��������� � ���������� ���',
'��� ������� ��������� � ����������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627140'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','���������� ���������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �������'),
'dom','�.
������������',
'korpus','��. ���������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��� � 18 ����',
'�������������
���������� ������������������� ���������� �������� ������������������� �����
�18�',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626158'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ��������'),
'dom','9 ����������',
'korpus','�������� 12',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������� ��� � 30 �. ��������� �����',
'������� ��� � 30 �. ��������� �����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����������������� ��� ���',
'��� ��� ������������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625049'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �������'),
'dom','�. ������',
'korpus','��. ���������� �����',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����� ���',
'�������� � ������������ ���������������� �����̻',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','455047'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','����������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������������'),
'dom','��. ���������',
'korpus','�. 162',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����������������������� ���� ���',
'�������� � ������������ ���������������� ��������-
�����������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625037'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','������',
'korpus','87',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ��������� ������������� ������������ ���',
'��������� ��������� ������������� ������������ ���',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625000'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� ���.'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. ��
�������',
'korpus','20',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������� ��� ���������������� ���� � 1 ����� �. ��������',
'������������� 
���������� ���������� ��������������� ���������� �������� ��� ������������-
���� ���� �1� �. ���������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626157'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ��������'),
'dom','7',
'korpus','����������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ���',
'�������� � ������������ ����������������
�����������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. �������������',
'korpus','2�',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������ ���',
'��� �������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626150'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.
��������'),
'dom','��. ����������',
'korpus','�. 9',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'�����-��������� ������������������� �������� ��',
'����������� ��
������ ������-��������� ������������������� ���������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625023'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','��. ��������',
'korpus','5',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'�������-��������� ��������������� �������� ���',
'�������-��������� ��������������� �������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� ���������-����������� ����������� ���� ��',
'���� �� ������-
���� ���������-����������� �����������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.
������'),
'dom','��. ����������',
'korpus','129',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������� ������ ���� ���',
'�������� � ������������ ���������������� 
���� �������� ������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625022'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��������� �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ������'),
'dom','������ ������
���',
'korpus','21',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'������ ����������� ���',
'������ ����������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�����������, ���������, �������������, ���������� �� ���',
'�����������, ���������, �������������, ���������� �� ���',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��. 50 ��� �����'),
'dom','51',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'�������������������� ���',
'�������������������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������� ���',
'������������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������������� ���',
'�������� � ������������ ���������������� 
����������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','�. ������'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��. ������������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.78 �'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��� �� �� ��� ���',
'��� �� �� ��� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������� ��������� �������� ���',
'��� ��������� �������� ��������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625034'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��������� �������'),
'dom','�.������',
'korpus','��.��������������',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'����� ��������������-��������������� ����� ���� ��',
'����� ��������������-��������������� ����� ���� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������ ���� ��',
'������ ���� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� �������� � 20 (�. ����) ���� ��',
'��������� �������� � 20 (�. ����) ���� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��� � 7 ����',
'��� � 7 ����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���������� ���',
'���������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������� ��� � 112 ������ ������ �����',
'������� ��� � 112 ������ ������ �����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'��������� ���� ������� ��',
'��������� ���� ������� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������� ����������� �������������� ������',
'������������� ����������� �������������� ������',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���� ����������� ������������ ����������� ���',
'���� ����������� ������������ ����������� ���',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','644020'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','������ �������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�. ����'),
'dom','��. ���������',
'korpus','6',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ������� ������������ ���������� � ������� ����� ��',
'��������� ������� ������������ ���������� � ������� ����� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������� ���',
'�������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������ ���',
'������������ ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'����������� �.�. ��',
'�������������� ��������������� ����������� ����� �������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','�. ����'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','��. 22 ������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','�.57'),
'dom','��.72',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'��������� ����������� ����� ���',
'��������� ����������� ����� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'�������������� ���',
'�������� � ������������ ������������
���� ���������������',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625030'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','�.������'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','��.�������'),
'dom','112',
'korpus','����.1',
'kvartira',null)
,
NULL,
'enterprise',
'�����'
)
,(
'���-��������� ���� ����',
'���-��������� ���� ����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������������� ���',
'������������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'���������� ��������������� �������� ����� ��',
'���������� ��������������� �������� ����� ��',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������� ���',
'������� ���',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������� ��� � 40 - ��� �. ��������� �����',
'������� ��� � 40 - ��� �. ��������� �����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������� ��� �49 �. ��������� �����',
'������� ��� �49 �. ��������� �����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)
,(
'������� ��� � 51 �. ��������� �����',
'������� ��� � 51 �. ��������� �����',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'�����'
)