--#1 Добавить внешние ключи
ALTER TABLE student
	ADD FOREIGN KEY(id_group) REFERENCES "group"(id_group);
ALTER TABLE mark
	ADD FOREIGN KEY(id_student) REFERENCES student(id_student);
ALTER TABLE mark
	ADD FOREIGN KEY(id_lesson) REFERENCES lesson(id_lesson);
ALTER TABLE lesson
	ADD FOREIGN KEY(id_teacher) REFERENCES teacher(id_teacher);
ALTER TABLE lesson
	ADD FOREIGN KEY(id_subject) REFERENCES subject(id_subject);
ALTER TABLE lesson
	ADD FOREIGN KEY(id_group) REFERENCES "group"(id_group);

--#2Выдать оценки студентов по информатике если они обучаются данному
--предмету. Оформить выдачу данных с использованием view.

CREATE OR REPLACE VIEW students_rating AS
  SELECT DISTINCT
    s.name,
    m.mark
  FROM mark m
    LEFT JOIN student s ON s.id_student = m.id_student
    LEFT JOIN lesson l ON l.id_lesson = m.id_lesson
    LEFT JOIN subject sub ON sub.id_subject = l.id_subject
  WHERE sub.name = 'Информатика' AND m.mark IS NOT NULL;

SELECT * FROM students_rating;

-- 3. Дать информацию о должниках с указанием фамилии студента и названия предмета.
--    Должниками считаются студенты, не имеющие оценки по предмету, который ведется в группе.
--    Оформить в виде процедуры, на входе идентификатор группы
DROP FUNCTION  get_debtors(IN group_id INT);
CREATE OR REPLACE FUNCTION get_debtors(id INT) RETURNS TABLE (student_name TEXT, subject_name TEXT) AS $$
BEGIN
DROP TABLE IF EXISTS group_lessons;
CREATE TEMPORARY TABLE group_lessons AS (
SELECT
    s.id_student,
    s.name AS student_name,
    sub.name AS subject_name,
    l.id_lesson AS id_lesson
    FROM lesson l
    LEFT JOIN "group" g ON g.id_group = l.id_group
    LEFT JOIN student s ON s.id_group = g.id_group
    LEFT JOIN subject sub ON sub.id_subject = l.id_subject
    WHERE g.id_group = id
);

RETURN QUERY
SELECT DISTINCT
    gl.student_name,
    gl.subject_name
    FROM group_lessons gl
    LEFT JOIN mark ON mark.id_lesson = gl.id_lesson AND mark.id_student = gl.id_student
GROUP BY gl.student_name,  gl.subject_name
HAVING COUNT(mark.mark) = 0;
END
$$ LANGUAGE plpgsql;
SELECT get_debtors(3);
-- 4. Дать среднюю оценку студентов по каждому предмету для тех предметов,
--    по которым занимается не менее 35 студентов  (студентов убавить)
SELECT
   sub.name AS subject,
       count(distinct),
   AVG(m.mark) AS average
FROM mark m
  LEFT JOIN lesson l ON m.id_lesson = l.id_lesson
         LEFT JOIN subject sub ON l.id_subject = sub.id_subject
         LEFT JOIN student s ON m.id_student = s.id_student
GROUP BY subject
  HAVING COUNT( DISTINCT m.id_student) >= 35;

-- 5. Дать оценки студентов специальности ВМ по всем проводимым предметам с указанием группы, фамилии, предмета, даты.
--    При отсутствии оценки заполнить значениями NULL поля оценки( заполнить нулем)
SELECT sub.name AS subject_name,
       g.name AS group_name,
       s.name AS student_name,
       m.mark,
       l.date
FROM student s
         LEFT JOIN "group" g ON s.id_group = g.id_group
         LEFT JOIN lesson l ON l.id_group = g.id_group
         LEFT JOIN subject sub ON l.id_subject = sub.id_subject
         LEFT JOIN mark  m ON (l.id_lesson = m.id_lesson AND s.id_student = m.id_student)
WHERE g.name = 'ВМ'
ORDER BY sub.name;

-- 6. Всем студентам специальности ПС, получившим оценки меньшие 5 по предмету БД до 12.05,
--    повысить эти оценки на 1 балл.
UPDATE mark m
    SET mark = m.mark + 1 from mark
    LEFT JOIN lesson l ON l.id_lesson = mark.id_lesson
    LEFT JOIN subject sub ON sub.id_subject = l.id_subject
  WHERE sub.name = 'БД' AND m.mark < 5  AND l.date <= '2019-05-12';

-- 7. Индексы(добавить)

CREATE INDEX group_name_index
	ON "group" (name);

CREATE INDEX lesson_id_group_index
	ON lesson (id_group);

CREATE INDEX lesson_id_subject_index
	ON lesson (id_subject);

CREATE INDEX lesson_id_teacher_index
	ON lesson (id_teacher);

CREATE INDEX mark_id_lesson_index
	ON mark (id_lesson);

CREATE INDEX mark_id_student_index
	ON mark (id_student);

CREATE INDEX mark_mark_index
	ON mark (mark);

CREATE INDEX student_id_group_index
	ON student (id_group);

CREATE INDEX student_name_index
	ON student (name);

CREATE INDEX subject_name_index
	ON subject (name);

CREATE INDEX teacher_name_index
	ON teacher (name);
