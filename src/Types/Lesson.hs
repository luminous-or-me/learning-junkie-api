{-# LANGUAGE DeriveGeneric #-}

module Types.Lesson (Lesson (..)) where

import Data.Aeson (FromJSON, ToJSON)
import Data.Swagger (ToSchema)
import Data.Text (Text)
import Database.PostgreSQL.Simple (FromRow)
import Database.PostgreSQL.Simple.FromRow (FromRow (fromRow), field)
import GHC.Generics (Generic)

data Lesson = Lesson
    { number :: !Int
    , title :: !Text
    , description :: !Text
    , content :: !Text
    }
    deriving (Show, Read, Generic)

instance ToJSON Lesson
instance FromJSON Lesson
instance FromRow Lesson where
    fromRow =
        Lesson
            <$> field
            <*> field
            <*> field
            <*> field

instance ToSchema Lesson
