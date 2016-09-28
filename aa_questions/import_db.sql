DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (parent_id) REFERENCES replies(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATe TABLE question_likes(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('Andrew','Tae'),             /*  1   */
  ('Travis', 'Ludlum'),         /*  2   */
  ('Robert', 'Koeze'),          /*  3   */
  ('Donald', 'Trump'),          /*  4   */
  ('Barack', 'Obama'),          /*  5   */
  ('Hillary', 'Clinton');       /*  6   */


INSERT INTO
  questions (title, body, user_id)
VALUES
  ('Assessment 3', 'What material is on assessment 3?', 2),
  ('Lunch lecture', 'Is the lunch lecture actually happening today?', 1),
  ('Wall Payment', 'When''s Mexico going to pay for my wall?', 4);

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  (3, 1),
  (4, 2),
  (2, 2),
  (5, 3),
  (6, 3),
  (4, 3);

INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  (1, NULL, 3, "Assessment 3 will cove SQL stuffs."),
  (1, 1, 1, "Thanks Robert, you''re sooooo helpful."),
  (3, NULL, 5, "LOL"),
  (3, 3, 4, "I''m going to be the bestest president ever OwnZerz HaxxOrz"),
  (3, NULL, 6, "...");

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  (1,1),
  (3,1),
  (3,2),
  (4,3);
