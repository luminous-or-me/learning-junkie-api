{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-missing-export-lists #-}

module Database.Queries.Exercises.Questions where

import Database (toSqlQuery)
import Database.PostgreSQL.Simple (Query)

allQuestionsQ :: Query
allQuestionsQ =
        toSqlQuery
                [ "SELECT e.id, e.title, e.grade, q.question, q.answer"
                , "FROM questions q"
                , "JOIN exercises e"
                , "ON q.id = e.id"
                , "WHERE e.course = ? AND e.lesson = ?"
                ]

questionByIdQ :: Query
questionByIdQ =
        toSqlQuery
                [ "SELECT e.id, e.title, e.grade, q.question, q.answer"
                , "FROM questions q"
                , "JOIN exercises e"
                , "ON q.id = e.id"
                , "WHERE e.id = ?"
                ]

insertQuestionQ :: Query
insertQuestionQ =
        toSqlQuery
                [ "WITH inserted_exercise AS ("
                , "INSERT INTO exercises (grade, title, course, lesson)"
                , "VALUES (?, ?, ?, ?)"
                , "RETURNING *),"
                , "inserted_question AS ("
                , "INSERT INTO questions (id, question, answer)"
                , "VALUES ("
                , "(SELECT id FROM inserted_exercise),"
                , "?, ?)"
                , "RETURNING *)"
                , "SELECT e.id, e.title, e.grade, q.question, q.answer"
                , "FROM inserted_exercise e"
                , "JOIN inserted_question q"
                , "ON e.id = q.id"
                ]

updateQuestionQ :: Query
updateQuestionQ =
        toSqlQuery
                [ "WITH updated_question AS ("
                , "UPDATE questions"
                , "SET question = ?, answer = ?"
                , "WHERE id = ?"
                , "RETURNING *)"
                , "SELECT e.id, e.title, e.grade, q.question, q.answer"
                , "FROM updated_question q"
                , "JOIN exercises e"
                , "ON q.id = e.id"
                ]
