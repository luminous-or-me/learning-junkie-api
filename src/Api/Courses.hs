{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeOperators #-}

module Api.Courses (CoursesAPI, coursesServer) where

import Control.Monad.IO.Class (MonadIO (liftIO))
import Data.Pool (Pool)
import Database.Operations.Courses (allCourses, courseById, deleteCourse)
import Database.Operations.Courses.Enrollments (enrollUserInCourse, usersEnrolledInCourse)
import Database.PostgreSQL.Simple (Connection)
import Servant
import Servant.Auth
import Servant.Auth.Server
import qualified Types.Auth.User as AU
import Types.Course (Course)
import Types.User (User)
import Types.User.Role (Role (Admin))

type JWTAuth = Auth '[JWT] AU.AuthUser

type GetAllCourses =
  Summary "Get all courses"
    :> Get '[JSON] [Course]

type GetCourseById =
  Summary "Get course by ID"
    :> Capture' '[Required, Description "ID of the course"] "id" Int
    :> Get '[JSON] Course

type DeleteCourseById =
  Summary "Delete course by ID"
    :> JWTAuth
    :> Capture' '[Required, Description "ID of the course"] "id" Int
    :> Verb 'DELETE 204 '[JSON] NoContent

type EnrollInCourse =
  Summary "Enroll a user in a course"
    :> JWTAuth
    :> Verb 'POST 200 '[JSON] NoContent

type EnrolledUsers =
  Summary "Users enrolled in the course"
    :> Get '[JSON] [User]

type Enrollments =
  Capture' '[Required, Description "ID of the course"] "id" Int
    :> "enrollments"
    :> (EnrollInCourse :<|> EnrolledUsers)

type CoursesAPI =
  "courses"
    :> ( GetAllCourses
          :<|> GetCourseById
          :<|> DeleteCourseById
          :<|> Enrollments
       )

coursesServer :: Pool Connection -> Server CoursesAPI
coursesServer conns =
  getAllCourses
    :<|> getCourseById
    :<|> deleteCourseById
    :<|> enrollments
 where
  getAllCourses :: Handler [Course]
  getAllCourses = liftIO $ allCourses conns

  getCourseById :: Int -> Handler Course
  getCourseById courseId = do
    mbCourse <- liftIO $ courseById conns courseId

    case mbCourse of
      Nothing -> throwError err404
      Just course -> return course

  deleteCourseById :: AuthResult AU.AuthUser -> Int -> Handler NoContent
  deleteCourseById (Authenticated authUser) courseId =
    case AU.role authUser of
      Admin -> do
        liftIO $ deleteCourse conns courseId
        return NoContent
      _ -> throwError err401
  deleteCourseById _ _ = throwError err401

  enrollments courseId = enrollInCourse :<|> enrolledUsers
   where
    enrollInCourse :: AuthResult AU.AuthUser -> Handler NoContent
    enrollInCourse (Authenticated authUser) = do
      liftIO $ enrollUserInCourse conns (AU.id authUser) courseId
      return NoContent
    enrollInCourse _ = throwError err401

    enrolledUsers :: Handler [User]
    enrolledUsers = liftIO $ usersEnrolledInCourse conns courseId
