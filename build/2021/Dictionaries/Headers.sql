DELETE FROM conclusion_dictionaries;
INSERT INTO conclusion_dictionaries (name,descr) VALUES('tExaminationForm','Форма экспертизы');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tExaminationResult','Результат экспертизы');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tExaminationStage','Вид экспертизы');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tExaminationObjectType','Вид объекта экспертизы');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tConstractionType','Вид работ');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tDocumentType','Типы документов');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tObjectType','Вид объекта капитального строительства');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tRegionsRF','Коды субъектов Российской Федерации');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tFinanceType','Вид источника финансирования');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tBudgetType','Уровень бюджета');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tExpertType','Направление деятельности эксперта');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tEngineeringSurveyType','Виды инженерных изысканий');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tClimateDistrict','Климатический район, подрайон');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tGeologicalConditions','Категория сложности инженерно-геологических условий');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tWindDistrict','Ветровой район');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tSnowDistrict','Снеговой район');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tSeismicActivity','Интенсивность сейсмических воздействий');

INSERT INTO conclusion_dictionaries (name,descr) VALUES('tExaminationType','Предмет экспертизы');

COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tExaminationForm.csv' DELIMITER ',';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tExaminationResult.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tExaminationStage.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tExaminationObjectType.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tConstractionType.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr,is_group) FROM '/home/andrey/2804/tDocumentType.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tObjectType.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tRegionsRF.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tFinanceType.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tBudgetType.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tExpertType.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tEngineeringSurveyType.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tClimateDistrict.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tGeologicalConditions.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tWindDistrict.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tSnowDistrict.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tSeismicActivity.csv' DELIMITER ';';
COPY conclusion_dictionary_detail(conclusion_dictionary_name, code, descr) FROM '/home/andrey/2804/tExaminationType.csv' DELIMITER ';';










