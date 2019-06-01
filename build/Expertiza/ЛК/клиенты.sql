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
'Комитет капитального строительства администрации г. Тобольск',
'Комитет капиталь
ного строительства Администрации города Тобольска',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626152'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тобольск'),
'dom','ул. Аптекарская',
'korpus','3',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Технодор ООО',
'ООО «ТехноДор»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Чекистов'),
'dom','д. 31',
'korpus','стр. 10',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Институт Строительного Проектирования ООО',
'Институт Строительного Проектирования ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Геопроект ООО',
'Геопроект ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Уральская теплосетевая компания ОАО',
'Уральская теплосетевая компания ОАО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Никос ООО',
'Никос ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Максимус ООО',
'Максимус ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Мостострой-11 ОАО',
'Мостострой-11 ОАО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'РН-Уватнефтегаз',
'РН-Уватнефтегаз',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Архитектурно-строительная компания ООО',
'Архитектурно-строительная компания ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Завод ЖБИ-3 000',
'000"Завод ЖБИ-3"',
'ИНН',
'7203321348 КПП 7',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. 50 лет Октября'),
'dom','215',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. 50 лет Октября'),
'dom','215',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Мостострой-12 ООО',
'ООО "Мостострой-12"',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','г. Тюмень'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ул. Пермякова'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','д.1'),
'dom','стр.5',
'korpus','литер А14',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Тюменские молочные фермы ООО',
'Общество с ограниченной ответственностью «Тюменские 
молочные фермы»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627305'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Голышмановский район'),
'dom','с. Усть-Ламенка',
'korpus','ул. Комсомольская',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'УКС ГКУ ТО',
'Государственное казенное учреждение Тюменской области "Управление капитального строительства"',
'7202180535',
'720201001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625000'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Некрасова'),
'dom','11',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625000'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Некрасова'),
'dom','11',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Свинокомплекс Тюменский ООО',
'Свинокомплекс Тюменский ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'УАД ГКУ ТО',
'Государственное казенное учреждение Тюменской области "Управление автомобильных дорог"',
'7203001860',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул.Республики д.143 корпус 2.'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул.Республики'),
'dom','143',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Сургутнефтегаз ОАО',
'Открытое акционерное общество "Сургутнефтегаз"',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','628415'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','РФ'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменская обл.'),
'dom','ХМАО-Югра',
'korpus','г. Сургут',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'ДКХС ГБУ ТО',
'Государственное казенное учреждение Тюменской области "Дирекция коммунально-хозяйственного строительства"',
'7203112133',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','ул. Республики',
'korpus','272',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','ул. Республики',
'korpus','272',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Служба заказчика Уватского муниципального района МКУ МУ',
'Муниципальное казенное учреждение "Служба заказчика Уватского муниципального района"',
'7225004600',
'722501001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626170'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','с. Уват'),
'dom','ул. Иртышская',
'korpus','19',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626170'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','с. Уват'),
'dom','ул. Иртышская',
'korpus','19',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Служба заказчика МКУ Ялуторовского района',
'Служба заказчика МКУ Ялуторовского района',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Проектировщик ЗАО',
'Закрытое акционерное общество «Проектировщик»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625002'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Циолковского'),
'dom','д. 13',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Стеклотех ООО',
'Стеклотех ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Спектр Проектный институт ООО',
'Общество с ограниченной ответственностью «Проектный
институт «Спектр»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625003'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','РФ'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменская область'),
'dom','г. Тюмень',
'korpus','ул. Володарского',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Дорстрой-Инвест ООО',
'ООО "Дорстрой-Инвест"',
'720180214',
'720501001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г.Ишим'),
'dom','ул.Заречная',
'korpus','д.1',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г.Ишим'),
'dom','ул.Заречная',
'korpus','д.1',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Гейн Виктор Карлович ИП',
'Гейн Виктор Карлович ИП',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Агентство по ипотечному жилищному кредитованию ТО ОАО',
'АО «АИЖК по Тюменской 
области»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','г. Тюмень'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ул. Орджоникидзе'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','63'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Запсибгидропром  ИТЦ ООО',
'ООО «Инженерно-технический центр «Запсибгидропром»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625007'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','ул. Депутатская',
'korpus','дом № 80',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'М - Сетьстрой ООО',
'М - Сетьстрой ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Администрация Тобольского муниципального района',
'Администрация Тобольского муниципального района Тюменской области',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626159'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тобольский район'),
'dom','д. Башкова',
'korpus','ул. Мелиораторов',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Южно-Приобский газоперерабатывающий завод ООО',
'Южно-Приобский газоперерабатывающий завод ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Комитет жилищно-коммунальной политики админ. Упоровского МР',
'Комитет жилищно-коммунальной политики админ. Упоровского МР',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'ТюменьСтройПроектБизнес ООО',
'ТюменьСтройПроектБизнес ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'РосГаз ООО',
'Общество с ограниченной ответственностью «РосГаз»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625016'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Россия'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменская область'),
'dom','г. Тюмень',
'korpus','ул. Пермякова',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'МАРКОН терминал ЗАО',
'ЗАО "МАРКОН терминал"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'НИИ новые технологии ООО',
'НИИ новые технологии ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Тюменьоблстрой СМУ ООО',
'Тюменьоблстрой СМУ ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Проектное бюро ООО',
'Проектное бюро ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'СПИНОКС ЗАО',
'ЗАО «СПИНОКС»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625049'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Мо
сковский тракт'),
'dom','д.140',
'korpus','стр.1',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Администрация Тюменского муниципального района',
'Администрация Тюменского муниципального района',
'7204095797',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','г.Тюмень'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ул.Московский тракт'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','115'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','г.Тюмень'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ул.Московский тракт'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','115'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Электросетьстрой ООО',
'Электросетьстрой ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'РЖД ОАО (Российские железные дороги)',
'ОАО «Российские железные дороги»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','107174
РФ'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Москва'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Новая Басманная'),
'dom','дом 2',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Антипинский НПЗ АО',
'АО "Антипинский нефтеперерабатывающий завод"',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625047'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','6 км Старого Тобольского тракта',
'korpus','20',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'ЗАГРОС ЗАО',
'Закрытое акционерное общество "ЗАГРОС"',
'7215003396',
'721501001',
'03912115',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627140'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ТО'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Заводоуковский р-н'),
'dom','пос. Комсомольский',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627140'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ТО'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Заводоуковский р-н'),
'dom','пос. Комсомольский',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'ИТС Инжиниринг ООО',
'ИТС Инжиниринг ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Союзэнергопроект ООО',
'Союзэнергопроект ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'АТ ООО',
'Общество с ограниченной ответственностью "АТ"',
'7204189572',
'720401001',
'26155993',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625022'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тюмень. ул. Ю-Р.Г. Эрвье'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','д.10/7'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625022'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тюмень. ул. Ю-Р.Г. Эрвье'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','д.10/7'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Департамент лесного комплекса Тюменской области',
'Департамент лесного комплекса Тюменской области',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Проектно-инженерный центр УралТЭП ЗАО',
'Проектно-инженерный центр УралТЭП ЗАО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'ТДСК  ОАО',
'ОАО "Тюменская домостроительная компания"',
'7203032191',
'723150001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул.Республики'),
'dom','253',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул.Республики'),
'dom','253',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Прогресс+ НППК ООО',
'ООО "НППК "Прогресс+"',
'7203222386',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','ул. Ямская',
'korpus','87А',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','ул. Мельникайте',
'korpus','105',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Администрация Каменского муниципального образования',
'Администрация Каменского муниципального образования',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Птицефабрика Боровская ОАО',
'ОАО Птицефабрика Боровская',
'7224008030',
'722401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625504'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','п. Боровский',
'korpus','ул. Островского',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625504'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','п. Боровский',
'korpus','ул. Островского',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'ТОДЭП АО',
'АО "Тюменское областное дорожно-эксплуатационное предприятие"',
'7203175930',
'720350001',
'33582661',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Республики'),
'dom','143',
'korpus','кор.2',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Республики'),
'dom','143. кор.2',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Тепличный Комбинат ТюменьАгро ООО',
'Тепличный Комбинат ТюменьАгро ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'ТюменьСпецИнженеринг ООО',
'ТюменьСпецИнженеринг ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Компания "Слава" ООО',
'Компания "Слава" ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Кайгородов Михаил Юрьевич ИП',
'Кайгородов Михаил Юрьевич ИП',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'ГРАДИЕНТ ООО',
'ООО «ГРАДИЕНТ»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Уральская'),
'dom','д. 74',
'korpus','корп. 1/4',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'ТюмГНГУ ФГБОУ ВО',
'ТюмГНГУ ФГБОУ ВО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Областная больница №23 (г.Ялуторовск) ГБУЗ ТО',
'Областная больница №23 (г.Ялуторовск) ГБУЗ ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'УралДорТехнологии Проектная Компания ООО',
'Общество с ограниченной ответственностью «Проектная Компания «УралДорТехнологии»',
'6658434632',
'6658010',
'25937995',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','620014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Свердловская обл.'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Екатеринбург'),
'dom','ул.Маршала Жукова',
'korpus','д.5',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','620109'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Свердловская обл.'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Екатеринбург'),
'dom','ул. Крауля',
'korpus','д. 51',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Тяжпромэлектромет ЗАО',
'ЗАО "Тяжпромэлектромет"',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Екатеринбург'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','пр. Ленина'),
'dom','24/8',
'korpus','оф. 501',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'АТ-Инжиниринг МПК ООО',
'Общество с ограниченной ответствненость МПК "АТ-Инжиниринг"',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625033'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','п. Рощино',
'korpus','ул. Сергея Ильюшина',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Газсервис ООО',
'Газсервис ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Гейн Роман Викторович ИП',
'Гейн Роман Викторович ИП',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Стандарт ООО',
'Общество с ограниченной ответственностью "Стандарт"',
'7202198420',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. М.Горького'),
'dom','д.44',
'korpus','оф611',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. М.Горького'),
'dom','д.44',
'korpus','оф611',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Хоккейный клуб Рубин ГАУ ТО',
'Хоккейный клуб Рубин ГАУ ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Торговый дом ЛИТ ООО',
'ООО "Торговый дом ЛИТ"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Жилищно-строительный кооператив "Антипинский"',
'Жилищно-строительный кооператив "Антипинский"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'ЗапСибНефтехим ООО',
'ЗапСибНефтехим ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Департамент дорожной инфр-ры и тр-та Администрации г.Тюмени',
'Департамент дорожной инфраструктуры и транспорта Администрации города Тюмени',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','г. Тюмень'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ул.
Киевская'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','60а'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Дорожно-строительное управление "Мостострой-11" ООО',
'Общество с ограниченной ответственностью Дорожно-строительное управление "Мостсострой-11"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'МКМЦ "Медицинский город" ГАУЗ ТО',
'Государственное автономное учреждение здравоохранения Тюменской области "Многопрофильный клинический  медицинский центр "Медицинский город"',
'7204006910',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625041'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Барнаульская'),
'dom','32',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625041'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Барнаульская'),
'dom','32',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Агрофирма КРиММ ООО',
'ООО "Агрофирма "КРиММ"',
'7226003278',
'722601001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627180'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Упоровский район'),
'dom','с. Упорово',
'korpus','ул. Заречная',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627180'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Упоровский район'),
'dom','с. Упорово',
'korpus','ул. Заречная',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Таволжан СПК',
'Сельскохозяйственный производственный кооператив "Таволжан"',
'7221002619',
'722101001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627625'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Сладковский район'),
'dom','д. Таволжан',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627625'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Сладковский район'),
'dom','д. Таволжан',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Савинов Давид Захарович',
'Савинов Давид Захарович',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Сладковское товарное рыбоводческое хозяйство ООО',
'Сладковское товарное рыбоводческое хозяйство ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Промстрой ООО',
'Промстрой ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'НИПИКБС-ИЦ ООО',
'НИПИКБС-ИЦ ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Эра-98 ООО',
'Эра-98 ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Меридиан Констракшн Тобольск ООО',
'Меридиан Констракшн Тобольск ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Брусника. Тюмень ООО',
'Общество с ограниченной ответственностью "Брусника. Тюмень"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Турай ООО',
'Турай ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Жемчужина Сибири Областной центр зимних видов спорта ГАУ ТО',
'Жемчужина Сибири Областной центр зимних видов спорта ГАУ ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'АрКон ООО',
'АрКон ООО',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','г. Новосибирск'),
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
'Устав'
)
,(
'Тюменское экологическое объединение ООО',
'ООО «Тюменское экологическое объединение»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625030'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Г. Тюмень'),
'dom','ул. Тимирязева',
'korpus','10/4',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Агрофирма Междуречье ООО',
'Агрофирма Междуречье ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Васильев Лазарь Анадасович',
'Васильев Лазарь Анадасович',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Тюменьдорпроект ПИИ ОАО',
'ОАО «Проектно-изыскательский институт «Тюменьдорпроект»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625007'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Депутатская'),
'dom','д. 91',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'ПСК Дом ООО',
'Общество с ограниченной ответственностью "Проектно-строительная компания "Дом"',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Барабинская'),
'dom','д. 1',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Комитет ЖКХ Администрации г.Тобольска',
'Комитет жилищно-коммунального хозяйства
администрации города Тобольска',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626150'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г.Тобольск'),
'dom','8 микро
район',
'korpus','д.32',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Институт Тюменьгражданпроект ЗАО',
'Акционерное общество "Институт Тюменьгражданпроект"',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','город Тюмень'),
'dom','ул. Салтыкова-Щедрина',
'korpus','д. 58',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Департамент АПК Тюменской области',
'Департамент АПК Тюменской области',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'ИНКО и К  ООО',
'ООО "ИНКО и К"',
'7203094857',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул.Полевая'),
'dom','115 б',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','г. Тюмень'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ул. Энергетиков'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','98/11'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'ФОРТЕКС-УПЕК ООО',
'ФОРТЕКС-УПЕК ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Птицефабрика Пышминская ЗАО',
'ЗАО «Птицефа-
брика «Пышминская»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625547'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','с. Онохино',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Нео-Ком ООО',
'Общество с ограниченной ответственностью "Нео-Ком"',
'7203287344',
'720301001',
'15381284',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625013'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. 50 лет Октября'),
'dom','88',
'korpus','оф.305',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625013'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. 50 лет Октября'),
'dom','88',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Тюменьмостпроект ООО',
'Тюменьмостпроект ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'ЮИТ Уралстрой АО',
'ЮИТ Уралстрой АО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Надежда АУ ЦКД',
'Автономное учреждение Центр культуры и досуга "Надежда"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'УНИ-Строй ООО',
'Общество с ограниченной ответственностью "УНИ-Строй"',
'8602108510',
'860201001',
'52053129',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','628403. Ханты-Мансийский -Югра АО'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Сургут г'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Университетская ул'),
'dom','до №7',
'korpus','оф. 27',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','628403. Ханты-Мансийский -Югра АО'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Сургут г'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Университетская ул'),
'dom','до №7',
'korpus','оф. 27',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Стройзаказчик МКУ',
'Муниципальное казенное учреждение "Стройзаказчик"',
'7207000017',
'720701001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627011'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Российская Федерация'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменская область'),
'dom','г.
Ялуторовск',
'korpus','ул. Свободы',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627010'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Ялуторовск'),
'dom','ул. Свердлова',
'korpus','42',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Новый город-Инвест+ ООО',
'Новый город-Инвест+ ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'ТЭПКОМ ООО',
'Общество с ограниченной ответственностью "ТЭПКОМ"',
'5507231685',
'550701001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','644074'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Омск'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул.Дмитриева. д.15/3'),
'dom','кв.15',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','644074'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Омск'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул.Дмитриева. д.15/3'),
'dom','кв.15',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Администрация Исетского муниципального района',
'Администрация 
Исетского муниципального района',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626380'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Исетский район'),
'dom','с.
Исетское',
'korpus','ул. Чкалова',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Газпром Трансгаз Сургут ООО',
'Газпром Трансгаз Сургут ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'ЕвроСтройРеставрация ООО',
'ЕвроСтройРеставрация ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Ишимский многопрофильный техникум ГАПОУ ТО',
'Ишимский многопрофильный техникум ГАПОУ ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Сибстройсервис ОАО',
'ОАО Сибсиройсервис',
'7224001941',
NULL,
'12498488',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','г. Тюмень'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ул. Мельникайте'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','134'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','г.Тюмень'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ул. Мельникайте'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','134'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Экос ЗАО',
'Экос ЗАО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Геокад ООО',
'Геокад ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Единый расчетный центр МУ',
'Муниципальное учреждение «Единый расчетный центр»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627141'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г.Заводоуковск'),
'dom','ул.Шоссейная',
'korpus','дом 141',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Централизован.культ.-досуг.объединение "Исток" МАУ Абат.р-на',
'Централизован.культ.-досуг.объединение "Исток" МАУ Абат.р-на',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Сибирия ООО',
'Общество с ограниченной ответственностью "Сибирия"',
'7214006436',
'722001001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627324'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Голышмановский район'),
'dom','с.Боровлянка',
'korpus','ул. 60 лет Октября',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627324'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Голышмановский район'),
'dom','с.Боровлянка',
'korpus','ул. 60 лет Октября',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Тюменькоммунстрой Институт ЗАО',
'Тюменькоммунстрой Институт ЗАО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Служба заказчика по благоустройству КАО г.Тюмени  МКУ',
'Муниципальное казенное 
учреждение «Служба заказчика по благоустройству Калининского административного
округа города Тюмени»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Луначарского'),
'dom','д.61',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Агентство инфраструктурного развития Тюменской области АО',
'Агентство инфраструктурного развития Тюменской области АО',
'7203223118',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625034 г.Тюмень'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ул. Камчатская'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','д.194'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'ГМС Нефтемаш АО',
'Акционерное общество "ГМС Нефтемаш"',
'7204002810',
'720350001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625003'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Военная'),
'dom','44',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625003'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Военная'),
'dom','44',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'СИБУР Тобольск ООО',
'Общество с ограниченной ответственностью "СИБУР Тобольск"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Тюменьгражданпроект Институт ЗАО',
'ЗАО «Институт Тюменьгражданпроект»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул.Салтыкова – Щедрина'),
'dom','д.58',
'korpus','корпус 4',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Централизованная религ. орг- я Тобольско-Тюменская Епархия',
'Централизованная религ. орг- я Тобольско-Тюменская Епархия',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'ТехноСтройПроект ООО',
'ООО «ТехноСтройПроект»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625051'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','РФ'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','ул. Пермякова',
'korpus','43а',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'ПРОДО Тюменский бройлер АО',
'Акционерное общество "ПРОДОТюменский бройлер"',
'7224005872',
'722401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625512'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','с. Каскара',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625512'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','с. Каскара',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Птицефабрика Боровская имени А.А. Созонова ПАО',
'ПАО Птицефабрика Боровская',
'7224008030',
'722401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625504'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','п. Боровский',
'korpus','ул. Островского',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625504'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','п. Боровский',
'korpus','ул. Островского',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Тюменьэнерго АО',
'АО "Тюменьэнерго"',
'8602060185',
'720202001',
'05789943',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625000'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Даудельная'),
'dom','44',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','628412'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Сургут'),
'dom','ул. Университетская',
'korpus','4',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Тюменьдороргтехстрой ОАО',
'Открытое акционерное общество «Тюменьдороргтехстрой»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','ул. Республики',
'korpus','д. 143',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Водоканал ВКХ ТУМП',
'Водоканал ВКХ ТУМП',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'СОШ №14 МАОУ г. Тобольск',
'СОШ №14 МАОУ г. Тобольск',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'СОШ №2 г.Ишим МАОУ',
'Муниципальное автономное общеобразовательное учреждение средняя общеобразовательная школа №2 г.Ишима',
'7205009938',
'720501001',
'42177528',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Ишим'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Орджоникидзе'),
'dom','41',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Ишим'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Орджоникидзе'),
'dom','41',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Сибгипрокоммунводоканал ООО',
'Сибгипрокоммунводоканал ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Областная инфекционная клиническая больница ГБУЗ ТО',
'Государственное бюджетное учреждение здравоохранения Тюменской области "Областная инфекционная клиническая больница"',
'7202100272',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625002'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Комсомольская'),
'dom','д.54а',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625002'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Комсомольская'),
'dom','д.54а',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'РЖДстрой АО',
'РЖДстрой АО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Ишим.центр реставрац.и стр-ва "Ставрос" АНО',
'Ишим.центр реставрац.и стр-ва "Ставрос" АНО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Промстройпроект ПКИ ЗАО',
'ЗАО Проектный и конструкторский институт
«Промстройпроект»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626150'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская обл.'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г.Тобольск'),
'dom','ул. Строителей',
'korpus','дом 6а',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'КЦСОН СР МАУ',
'Муниципальное автономное учреждение "Комплексный центр социального обслуживания населения Сорокинского района"',
'7222018393',
'720501001',
'84672443',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Сорокинский район'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','с Б.Сорокино'),
'dom','ул. Ленина',
'korpus','123',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627500 Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Сорокинский район'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','с Б.Сорокино'),
'dom','ул. Ленина',
'korpus','123',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Невил ООО',
'ООО «Невил»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625051'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г.Тюмень'),
'dom','ул. 30 лет Победы',
'korpus','д.81а',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'КРЕАЛ ЗАО',
'Закрытое акционерное общество КРЕАЛ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Опеновское ООО',
'Общество с ограниченной ответственностью "Опеновское"',
'7205010764',
'720501001',
'12527758',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627704'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Ишимский район'),
'dom','с.Тоболово',
'korpus','ул. Мира',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Ишимский район'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','с.Тоболово'),
'dom','ул. Мира',
'korpus','д.7/2',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Тюменский техникум индустрии питания, коммерции и сервиса',
'ГАПОУ ТО "Тюменский техникум индустрии питания, коммерции и сервиса"',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Управление ЖКХ г.Ишима МКУ',
'Муниципальное казенное учреждение «Управление жи-
лищно-коммунальным хозяйством города Ишима»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Российская Федерация'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменская область'),
'dom','г. Ишим',
'korpus','ул. Чайковско-
го',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Строительная компания Звезда ООО',
'Общество с ограниченной ответственностью "Строительная компания "Звезда"',
'7203267387',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625027'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Мельникайте'),
'dom','72 "А"',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625027'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Мельникайте'),
'dom','72 "А"',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Областная больница №3 (г. Тобольск) ГБУЗ ТО',
'Государственное бюджетное учреждение здравоохранения Тюменской области "Областная больница №3" (г. Тобольск)',
'7223008503',
'720601001',
'01948571',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626150'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тобольск'),
'dom','3б микрорайон',
'korpus','№24',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тобольск'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','3б микрорайон'),
'dom','№24',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Администрация Ишимского муниципального района',
'Администрация Ишимского муниципального района',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Детский сад №183 МАДОУ',
'Муниципальное автономное дошкольное образовательное учреждение Детский сад №183 города Тюмени',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Радищева'),
'dom','27',
'korpus','корпус 2 Литера А',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Тобольский колледж искусств и культуры имени А.А. Алябьева Г',
'Государственное автономное профессиональное образовательное учреждение Тюменской области "Тобольский колледж искусств и культуры имени А.А. Алябьева"',
'7206017385',
'720601001',
'02177688',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626150 Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тобольск'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','10 микрорайон'),
'dom','д.85',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626150 Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тобольск'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','10 микрорайон'),
'dom','д.85',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Тюменский Архитектурно-Реставрационный союз ООО',
'ООО «Тюменский Архитектурно-Реставрационный союз»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625032'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул.
Братская'),
'dom','д.23',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Юность ЦК и Д АО Каскаринского МО',
'Юность ЦК и Д АО Каскаринского МО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Агротехнологический колледж ГАПОУ ТО',
'Агротехнологический колледж ГАПОУ ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Абсолют-Агро ООО',
'Абсолют-Агро ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Боркун Екатерина Игоревна ИП',
'Индивидуальный предприниматель Боркун Екатерина Игоревна',
'7202126466',
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Седова'),
'dom','д. 15',
'korpus','кв.49',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'ЛесПаркХоз МКУ',
'ЛесПаркХоз МКУ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Мостострой-11 АО',
'Мостострой-11 АО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Горжилстрой  ЗАО',
'ЗАО "Горжилстрой"',
'7204012769',
'720401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул.Республики'),
'dom','14/9',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','г. Тюмень'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ул. Республики'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','14/1'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Ремонтно-эксплуатационный участок №2 ОАО',
'ОАО «Ремонтно-эксплуатационный участок № 2»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','150014'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Ярославль'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Вольная'),
'dom','д. 3',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Фортум ОАО',
'Фортум ОАО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Фонд имущества МКУ',
'Фонд имущества МКУ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Проектно-изыскательский центр ООО',
'Проектно-изыскательский центр ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'ЗапСибХлеб-Исеть ООО',
'ООО "ЗапСибХлеб-Исеть"',
'7216005220',
'721601001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','ул. Фабричная',
'korpus','1/9',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626385'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Исетский район'),
'dom','с. Красново',
'korpus','ул. Мира',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'СОШ №5 г. Ишима МАОУ',
'СОШ №5 г. Ишима МАОУ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Жилищное строительство ООО',
'Жилищное строительство ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Запсибгазпром ОАО',
'Запсибгазпром ОАО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Градстройпроект ООО',
'Общество с ограниченной ответственностью
«Градстройпроект»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г.Ишим'),
'dom','ул.Свердлова',
'korpus','41',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Администрация Ярковского муниципального района',
'Администрация Ярковского муниципального района',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626050'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Ярковский район'),
'dom','с. Ярково',
'korpus','ул. Пионерская',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Петелино ООО',
'Петелино ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Клат Валерий Романович',
'Клат Валерий Романович',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Администрация Нижнетавдинского муниципального района',
'Администрация Нижнетавдинского муниципального района',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Тюменгипроводхоз АО',
'Акционерное общество «Тюменский проектно-изыска-
тельский институт водного хозяйства»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625023'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','ул.
Республики',
'korpus','дом 169',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Зейналов Адалят Гара Оглы',
'Зейналов Адалят Гара Оглы',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Сетовская СОШ МАОУ',
'Сетовская СОШ МАОУ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Байкаловская СОШ МАОУ',
'Байкаловская СОШ МАОУ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Стройпроект ООО',
'ООО «Стройпроект»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625022'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','ул. Щербакова',
'korpus','д. 112',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Бизинская СОШ МАОУ',
'Муниципальное автономное общеобразовательное учреждение "Бизинская средняя общеобразоватеная школа"',
'7223009352',
'720601001',
'52540013',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626110'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тобольский район'),
'dom','с. Бизино',
'korpus','ул. Юбилейная',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Кутарбитская СОШ МАОУ',
'Муниципальное автономное общобразовательное учреждение "Кутарбитская  средняя общеобразовательная школа"',
'7223009232',
'720601001',
'52540119',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626115 Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тобольский район'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','с. Кутарбитка'),
'dom','ул. Школьная',
'korpus','27',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Центр культуры и досуга Ишимского района МАУ культуры',
'Центр культуры и досуга Ишимского района МАУ культуры',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Партнер-Агро ООО',
'Партнер-Агро ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'СОШ №65 МАОУ г. Тюмень',
'Муниципальное автономное общеобразовательное учреждение Средняя общеобразовательная школа №65, г. Тюмень',
'7203076544',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625046'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Широтная'),
'dom','116',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625046'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Широтная'),
'dom','116',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Западно-Сибирский государственный колледж ГАПОУ ТО',
'Государственное автономное профессиональное образовательное учреждение Тюменской области "Западно-Сибирский государственный колледж"',
'7204007166',
'720301001',
'42155320',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Рылеева'),
'dom','34',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Рылеева'),
'dom','34',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Шишкинская средняя общеобразовательная школа МАОУ',
'Муниципальное общеобразовательное учреждение Шишкинская общеобразовательная школа',
'7212003630',
'720601001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626252 Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Вагайский район'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','с. Шишкина'),
'dom','ул',
'korpus','Зеленая',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626252 Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Вагайский район'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','с. Шишкина'),
'dom','ул',
'korpus','Зеленая',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Областная больница №24  ГБУЗ ТО (с.Ярково)',
'Государственное бюджетное учреждение здравоохранения Тюменской области "Областная больница №24" (с.Ярково)',
'7229000035',
'722401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626050 Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Ярковский район'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','с. Ярково'),
'dom','ул. Ленина',
'korpus','68',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626050 Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Ярковский район'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','с. Ярково'),
'dom','ул. Ленина',
'korpus','68',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Центр экспертиз ООО',
'Общество с ограниченной ответственностью "Центр экспертиз"',
'5612072699',
'561201001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','460019'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Оренбург'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Шарлыкское шоссе'),
'dom','36/2 (1 этаж)',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','460026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Оренбург'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Одесская'),
'dom','д.80',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'ТюменьПроектСервис ООО',
'ООО "Тюменьпроектсервис"',
'7203175256',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','РФ'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ТО'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','625014'),
'dom','г. Тюмень',
'korpus','ул. Республики',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','РФ'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ТО'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','625014'),
'dom','г. Тюмень',
'korpus','ул. Республики',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Альтернатива ООО УК',
'Общество с ограниченной ответственностью Управляющая компания "Альтернатива"',
'7206050093',
'7',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626102'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тобольск'),
'dom','п. Сумкино',
'korpus','ул. Водников',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626102'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тобольск'),
'dom','п. Сумкино',
'korpus','ул. Нагорная',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Новая Земля ООО',
'Новая Земля ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Областная больница №4 (г. Ишим) ГБУЗ ТО',
'Областная больница №4 (г. Ишим) ГБУЗ ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Служба заказчика Тюменского района МКУ',
'Муниципальное
казенное учреждение «Служба заказчика Тюменского района»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625049'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул.
Московский тракт'),
'dom','дом 115',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Луговская СОШ МАОУ ТМР',
'Луговская СОШ МАОУ ТМР',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Абатская СОШ №2 МАОУ',
'Абатская СОШ №2 МАОУ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Ембаевскя СОШ  им. А. Аширбекова МАОУ',
'Муниципальное автономное общеобразовательное учреждение "Ембаевская  средняя общеобразовательная школа',
'7224038010',
'722401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625511'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','с.Ембаево',
'korpus','ул. Мусы Джалиля',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625511'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','с.Ембаево',
'korpus','ул. Мусы Джалиля',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Детский сад №2 комбинированного типа города Ишима МАДОУ',
'Муниципальное автономное дошкольное образовательное учреждение "Детский сад №2 комбинированного типа" города Ишима',
'7205018731',
'720501001',
'84672644',
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750 Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Ишим'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','проезд М.Горького'),
'dom','35',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750 Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Ишим'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','проезд М.Горького'),
'dom','35',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Яровская СОШ Тюменского МР МАОУ',
'Муниципальное автономное общеобразовательное учреждение Яровская средняя общеобразоательная школа Тюменского муниципального района',
'7224037948',
'722401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625541'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','с.Яр',
'korpus','ул',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625541'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','с.Яр',
'korpus','ул',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'ФКР ТО НО',
'Некоммерческая организация "Фонд капитального ремонта многоквартирных домов Тюменской области"',
'7204201389',
'720301001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048 Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Новгородская'),
'dom','10',
'korpus',NULL,
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048 Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Новгородская'),
'dom','10',
'korpus',NULL,
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Чикчинский детский сад "Улыбка" МАДОУ Тюменского МР',
'Муниципальное автономное дошкольное ощеобразовательное учреждение  Тюменского муниципального района  Чикчинский детский сад "Улыбка"',
'7224037962',
'722401001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625537'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','с. Чикча',
'korpus','ул. Луговая',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625537'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','с. Чикча',
'korpus','ул. Луговая',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Родильный дом №3 ГБУЗ ТО',
'Родильный дом №3 ГБУЗ ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Каскаринская СОШ МАОУ',
'Муниципальное автономное общеобразова-
тельное учреждение Каскаринская средняя общеобразовательная школа Тюменского
муниципального района',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625512'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','с. Каскара',
'korpus','ул.
Школьная',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'ТюмГУ ФГАУ ВО',
'ТюмГУ ФГАУ ВО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Тараскуль Центр реабилитации Фонда соц. страх-я РФ ФБУ',
'БУ Центр реаби-
литации ФСС РФ «Тараскуль»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625058 г. Тюмень'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ул. Санаторная'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','д.10'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Тюменская обл. науч. библ. им. Д.И.Менделеева ГАУК',
'Тюменская обл. науч. библ. им. Д.И.Менделеева ГАУК',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Городская поликлиника №8 ММАУ',
'Муниципальное 
медицинское автономное учреждение «Городская поликлиника № 8»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625031'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тю
мень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул.Ватутина'),
'dom','10 б',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Аксаринская СОШ',
'Аксаринская СОШ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Физико-математическая школа ГАОУ ТО',
'Государственное автономное общеобразовательное учреждение
Тюменской области «Физико-математическая школа»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625051'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. 30 лет Победы'),
'dom','102',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Фармация АО',
'Фармация АО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Дом детского творчества МАУ ДО',
'Дом детского творчества МАУ ДО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Тепло Тюмени АО',
'Тепло Тюмени АО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'ЭНКО РИАЛ ЭСТЭЙТ ГРУПП ООО',
'ЭНКО РИАЛ ЭСТЭЙТ ГРУПП ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Служба заказчика по благоустройству ЦАО г. Тюмени МКУ',
'Муниципальное казенное учреждение "Служба заказчика по благоустройству ЦАО г. Тюмени',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Тюменское музейно-просветительское объединение ГАУК ТО',
'Тюменское музейно-просветительское объединение ГАУК ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Алтайводпроект ЗАО ПИИ',
'Алтайводпроект ЗАО ПИИ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Каскаринский детский сад МАДОУ',
'Каскаринский детский сад МАДОУ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Червишевская СОШ МАОУ',
'Червишевская СОШ МАОУ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'СПЕКТР ООО',
'СПЕКТР ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'ЭТЕК ЛТД НПФ ООО',
'ЭТЕК ЛТД НПФ ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Весна ДНТ',
'Весна ДНТ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Тюменская областная ветеринарная лаборатория ГАУ ТО',
'Тюменская областная ветеринарная лаборатория ГАУ ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Ишимский медицинский колледж ГАПОУ ТО',
'Ишимский медицинский колледж ГАПОУ ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Московская СОШ',
'Московская СОШ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Сибирь Компания ООО',
'Сибирь Компания ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Стройимпульс ООО',
'Стройимпульс ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Новотарманская СОШ',
'Новотарманская СОШ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'ГЕОФОНД+ ООО',
'ООО «ГЕОФОНД+»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г.Тюмень'),
'dom','ул. Ямская 87а',
'korpus','оф. 416',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'ТюмГАСУ НПО ООО',
'Общество с ограниченной ответственностью "научно-производственное объединение "Тюменское главное архитектурно-строительное управление"',
'7203371003',
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625022'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Ю.-Р.Г. Эрвье'),
'dom','д.10',
'korpus','к.94',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625022'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Ю.-Р.Г. Эрвье'),
'dom','д.10',
'korpus','к.94',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Дирекция по управлению муниципальным хозяйством Уватского МР',
'МКУ «Дирекция по управлению муниципальным хозяйством Уватского муниципального района»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626170'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область Уватский район'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','с. Уват'),
'dom','ул. Иртышская 19',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Детская художественная школа им. А.П. Митинского МАУ ДО горо',
'Детская художественная школа им. А.П. Митинского МАУ ДО горо',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Медико-санитарная часть "Нефтяник" ОАО',
'Акционерное общество «Медико-санитарная часть
«Нефтяник»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625000'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','РФ'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменская область'),
'dom','г.Тюмень',
'korpus','ул. Шиллера',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Западно-Сибирский инновационный центр ГАУ ТО',
'Государственное автономное учреждение Тю-
менской области «Западно-Сибирский инновационный центр»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Российская
Федерация'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменская область'),
'dom','г. Тюмень',
'korpus','ул. Республики',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Газпром газораспределение Север АО',
'АО «Газпром газораспределение Север»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Энергетиков'),
'dom','д. 163',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Газстройпроект ЗАО',
'ЗАО "Газстройпроект" г. Ишим',
'7205011662',
'720501001',
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Ишим'),
'dom','ул. Казанская',
'korpus','51',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627750'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Ишим'),
'dom','ул. Казанская',
'korpus','51',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Областная больница №4 (г. Ишим) ГБУЗ ТО',
'Областная больница №4 (г. Ишим) ГБУЗ ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Макстерм ООО',
'Общество с ограниченной ответственностью «МАКСТЕРМ»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625047'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','7 км. Старого Тобольского тракта'),
'dom','д. 18',
'korpus','стр. 6',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'СибПроектМонтажИнжиниринг ООО',
'Общество с ограниченной ответственностью
«СибПроектМонтажИнжиниринг»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Мельникайте'),
'dom','106',
'korpus','оф. 408',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Бегишевская СОШ МАОУ',
'Муниципальное
 автономное общеобразовательное учреждение Бегишевская средняя общеобразо
вательная школа Вагайского района Тюменской области',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626260'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская об-
ласть'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Вагайский район'),
'dom','с. Бегишево',
'korpus','пер. Школьный',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Онохинская ДШИ МАУ ДО',
'Муниципальное автономное учреждение допол-
нительного образования Онохинская детская школа искусств Тюменского муници-
пального района',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625547'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский
район'),
'dom','с. Онохино',
'korpus','ул. Касьянова',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Родильный дом №2 ГБУЗ ТО',
'Государственное бюджетное учреждение здравоохранения Тюменской области «Родильный дом №2»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625027'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Холодильная'),
'dom','58',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Инженерно-проектный центр Новой генерации ООО',
'ООО «Инженерно-проектный центр Новой генерации»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','107045'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Москва'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Уланский пер.'),
'dom','дом 24',
'korpus','стр. 1.',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Стандарт Проект ООО',
'Общество с ограниченной ответственностью «Проект Стан
дарт»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','г. Тюмень'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ул. Седова'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','19'),
'dom','кв.45',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'СОШ №9 с углубленным изучением отдельных предметов МАОУ',
'Муниципальное
автономное общеобразовательное учреждение «Средняя общеобразовательная школа
№9 с углубленным изучением отдельных предметов»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626150'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тобольск'),
'dom','4 микрорайон',
'korpus','д.32',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Завод ЖБИ-3 ЗАО',
'ЗАО "Завод ЖБИ-3"',
'7203045070',
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменский район'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','с. Кулаково'),
'dom','ул. Советская',
'korpus','4',
'kvartira',null)
,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменский район'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','с. Кулаково'),
'dom','ул. Советская',
'korpus','4',
'kvartira',null)
,
'enterprise',
'Устав'
)
,(
'Духовное управление мусульман ТО ЦРО',
'Духовное управление мусульман ТО ЦРО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Чикчинская СОШ имени Якина МАОУ Тюменского МР',
'Муниципальное автономное
общеобразовательное учреждение «Чикчинская средняя общеобразовательная
школа имени Х.Х. Якина Тюменского муниципального района»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625537'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская
область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','с. Чикча',
'korpus','ул. Гагарина',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Служба заказчика по благоустройству ЛАО г. Тюмени',
'Муниципальное казенное учреждение «Служба заказчика по благоустройству Ленинского административного округа города Тюмени»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625027'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Мельникайте'),
'dom','д. 74',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Госпиталь для ветеранов войн ГБУ ТО',
'Госпиталь для ветеранов войн ГБУ ТО',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625000'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Володарского'),
'dom','47/1',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Областная больница №12 (г. Заводоуковск) ГБУЗ ТО',
'Государственное бюджетное учреждение здра
воохранения Тюменской области «Областная больница №12»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','Тюменская область'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Заводоуковский район'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г.Заво
доуковск'),
'dom','ул. Хахина',
'korpus','19',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Администрация Борковского МО ТР',
'Администрация 
Борковского муниципального образования Тюменского района Тюменской области',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625513'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменский район'),
'dom','с.Борки',
'korpus','ул.Советская',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Тюменьгипроводхоз ОАО',
'ОАО «Тюменьгипроводхоз»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','Россия'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Республики'),
'dom','д. 169',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Администрация Нижнепышминского муниципального образования',
'Администрация Нижнепышминского муниципального образования',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Тюмень ТеплоСтройСервис ООО',
'Общество с ограниченной ответственностью «Тюмень ТеплоСтройСервис»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625000'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','ул. Пархоменко',
'korpus','54',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Банниковская СОШ МАОУ',
'Муниципальное автономное
общеобразовательное учреждение Банниковская средняя общеобразовательная 
школа',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627551'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Абатский район'),
'dom','с.
Банниково',
'korpus','ул. Центральная',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Центр культуры и досуга Юргинского МР АУ',
'Автономное учреждение «Центр культуры и 
досуга Юргинского муниципального района»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627250'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Юргинский район'),
'dom','с.Юргинское',
'korpus','ул. Ленина',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'ТГУ ФГАОУ ВО',
'Федеральное государственное автономное об
разовательное учреждение высшего образования «Тюменский государственный университет»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625003'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г. Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Володарского'),
'dom','д.6',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Областная инфекционная клиническая больница ГБУЗ ТО',
'ГБУЗ ТО «Областная инфекционная клиническая больница»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625002'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. Комсомольская'),
'dom','54а',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Проектное бюро Цитадель ООО',
'Общество с ограниченной ответственностью «Проектное
бюро Цитадель»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','644100'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Омская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г.
Омск'),
'dom','ул. Академика Королева',
'korpus','3',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Дом детского творчества МАУ ДО г. Тобольск',
'Дом детского творчества МАУ ДО г. Тобольск',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Служба заказчика и технадзора ЗАО',
'ЗАО «Служба заказчика и технадзора»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','627140'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Российская Федерация'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменская область'),
'dom','г.
Заводоуковск',
'korpus','ул. Шоссейная',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'СОШ № 18 МАОУ',
'Муниципальное
автономное общеобразовательное учреждение «Средняя общеобразовательная школа
№18»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626158'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тобольск'),
'dom','9 микрорайон',
'korpus','строение 12',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Детский сад № 30 г. Тобольска МАДОУ',
'Детский сад № 30 г. Тобольска МАДОУ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'АвтоДорСетьПроект ПИФ ООО',
'ООО ПИФ «АвтоДорСетьПроект»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625049'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','РФ'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменская область'),
'dom','г. Тюмень',
'korpus','ул. Московский тракт',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Метам ООО',
'Общество с ограниченной ответственностью «МЕТАМ»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','455047'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Челябинская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Магнитогорск'),
'dom','ул. Советская',
'korpus','д. 162',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'СибСпецСтройРеставрация НППО ООО',
'Общество с ограниченной ответственностью «СибСпец-
СтройРеставрация»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625037'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','Ямская',
'korpus','87',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Тюменское городское имущественное казначейство МКУ',
'Тюменское городское имущественное казначейство МКУ',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625000'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская обл.'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','ул. Со
ветская',
'korpus','20',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Детский сад комбинированного вида № 1 МАДОУ г. Тобольск',
'Муниципальное 
автономное дошкольное образовательное учреждение «Детский сад комбинирован-
ного вида №1» г. Тобольска',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626157'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тобольск'),
'dom','7',
'korpus','микрорайон',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Строитель ООО',
'Общество с ограниченной ответственностью
«Строитель»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625001'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','ул. Чернышевского',
'korpus','2а',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Проект ООО',
'ООО «Проект»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','626150'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г.
Тобольск'),
'dom','ул. Строителей',
'korpus','д. 9',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Урало-Сибирская Теплоэнергетическая компания АО',
'Акционерное об
щество «Урало-Сибирская Теплоэнергетическая компания»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625023'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','ул. Одесская',
'korpus','5',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Западно-Сибирский Нефтехимический Комбинат ООО',
'Западно-Сибирский Нефтехимический Комбинат ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Тюменское концертно-театральное объединение ГАУК ТО',
'ГАУК ТО «Тюмен-
ское концертно-театральное объединение»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625048'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г.
Тюмень'),
'dom','ул. Республики',
'korpus','129',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Сметный альянс РЦЦС ООО',
'Общество с ограниченной ответственностью 
РЦЦС «Сметный альянс»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625022'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Тюменская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Тюмень'),
'dom','проезд Солнеч
ный',
'korpus','21',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Проект Перспектива ООО',
'Проект Перспектива ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Архитектура, Инновации, Строительство, Технологии ПМ ООО',
'Архитектура, Инновации, Строительство, Технологии ПМ ООО',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625026'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул. 50 лет ВЛКСМ'),
'dom','51',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'СибПромГражданПроект ООО',
'СибПромГражданПроект ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'НИПИпромстрой ООО',
'НИПИпромстрой ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Газинвестпроект ООО',
'Общество с ограниченной ответственностью 
«Газинвестпроект»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','г. Тюмень'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ул. Дзержинского'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','д.78 А'),
'dom',NULL,
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Эйч Эс эн Кей ООО',
'Эйч Эс эн Кей ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'НефтеГазСтрой Проектная компания ООО',
'ООО Проектная компания «НефтеГазСтрой»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625034'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','РФ'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','Тюменская область'),
'dom','г.Тюмень',
'korpus','ул.Домостроителей',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Эндос Консультативно-диагностический центр ГАУЗ ТО',
'Эндос Консультативно-диагностический центр ГАУЗ ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Хоспис ГАУЗ ТО',
'Хоспис ГАУЗ ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Областная больница № 20 (с. Уват) ГБУЗ ТО',
'Областная больница № 20 (с. Уват) ГБУЗ ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'СОШ № 7 МАОУ',
'СОШ № 7 МАОУ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Уралинвест ООО',
'Уралинвест ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Детский сад № 112 города Тюмени МАДОУ',
'Детский сад № 112 города Тюмени МАДОУ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Долганова Анна Юрьевна ИП',
'Долганова Анна Юрьевна ИП',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Администрация Омутинского муниципального района',
'Администрация Омутинского муниципального района',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Бюро диагностики строительных конструкций ООО',
'Бюро диагностики строительных конструкций ООО',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','644020'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','Омская область'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','г. Омск'),
'dom','ул. Карбышева',
'korpus','6',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Тюменский колледж транспортных технологий и сервиса ГАПОУ ТО',
'Тюменский колледж транспортных технологий и сервиса ГАПОУ ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Проспект ООО',
'Проспект ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'СибАкваТрейд ООО',
'СибАкваТрейд ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Парфентьева Е.А. ИП',
'Индивидуальный предприниматель Парфентьева Елена Александровна',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','г. Омск'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','ул. 22 апреля'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','д.57'),
'dom','кв.72',
'korpus',NULL,
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Земельный кадастровый центр ООО',
'Земельный кадастровый центр ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Стройгеопроект ООО',
'Общество с ограниченной ответственно
стью «Стройгеопроект»',
NULL,
NULL,
NULL,
4,
json_build_object(
'region',json_build_object('keys',json_build_object('region_code',null),'descr','625030'),
'raion',json_build_object('keys',json_build_object('raion_code',null),'descr',NULL),
'naspunkt',null,
'gorod',json_build_object('keys',json_build_object('gorod_code',null),'descr','г.Тюмень'),
'ulitsa',json_build_object('keys',json_build_object('ulitsa_code',null),'descr','ул.Невская'),
'dom','112',
'korpus','корп.1',
'kvartira',null)
,
NULL,
'enterprise',
'Устав'
)
,(
'Обь-Иртышское УГМС ФГБУ',
'Обь-Иртышское УГМС ФГБУ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'СтройГеодезия ООО',
'СтройГеодезия ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Тобольский многопрофильный техникум ГАПОУ ТО',
'Тобольский многопрофильный техникум ГАПОУ ТО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'ГеоЛайн ООО',
'ГеоЛайн ООО',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Детский сад № 40 - ЦРР г. Тобольска МАДОУ',
'Детский сад № 40 - ЦРР г. Тобольска МАДОУ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Детский сад №49 г. Тобольска МАДОУ',
'Детский сад №49 г. Тобольска МАДОУ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)
,(
'Детский сад № 51 г. Тобольска МАДОУ',
'Детский сад № 51 г. Тобольска МАДОУ',
NULL,
NULL,
NULL,
4,
NULL,
NULL,
'enterprise',
'Устав'
)