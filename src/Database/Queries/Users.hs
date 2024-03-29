{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-missing-export-lists #-}

module Database.Queries.Users where

import Database (toSqlQuery)
import Database.PostgreSQL.Simple (Query)

allUsersQ :: Query
allUsersQ = "SELECT * FROM users"

insertUserQ :: Query
insertUserQ =
        toSqlQuery
                [ "INSERT INTO users"
                , "(name, birthday, education, role, email, passwordHash)"
                , "VALUES (?, ?, ?, 'student', ?, ?)"
                , "RETURNING *"
                ]

userByIdQ :: Query
userByIdQ =
        toSqlQuery
                [ "SELECT *"
                , "FROM users"
                , "WHERE id = ?"
                ]

userByEmailQ :: Query
userByEmailQ =
        toSqlQuery
                [ "SELECT *"
                , "FROM users"
                , "WHERE email = ?"
                ]

deleteUserQ :: Query
deleteUserQ =
        toSqlQuery
                [ "DELETE FROM users"
                , "WHERE id = ?"
                ]
