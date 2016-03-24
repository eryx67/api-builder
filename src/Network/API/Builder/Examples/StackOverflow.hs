-- | Defines a basic example of API use - check the readme for more detail
--   or check the tutorial at <https://github.com/intolerable/api-builder>
module Network.API.Builder.Examples.StackOverflow where

import Network.API.Builder
import Control.Applicative
import Data.Aeson
import Data.Monoid (mempty)
import Data.Text (Text)

data Question = Question { title :: Text
                         , isAnswered :: Bool
                         , score :: Int
                         , tags :: [Text] }
  deriving (Show, Eq)

newtype Questions = Questions [Question]
  deriving (Show, Eq)

instance FromJSON Question where
  parseJSON (Object o) =
    Question <$> o .: "title"
             <*> o .: "is_answered"
             <*> o .: "score"
             <*> o .: "tags"
  parseJSON _ = mempty

instance FromJSON Questions where
  parseJSON (Object o) = Questions <$> o .: "items"
  parseJSON _ = mempty

instance Receivable Questions where
  receive = useFromJSON

stackOverflow :: Builder
stackOverflow = basicBuilder "StackOverflow API" "http://api.stackexchange.com"

stackOverflowSSL :: Builder
stackOverflowSSL = basicBuilder "StackOverflow API" "https://api.stackexchange.com"

answersRoute :: Route
answersRoute = Route { urlPieces = [ "2.2", "questions" ]
                     , urlParams = [ "order" =. ("desc" :: Text)
                                   , "sort" =. ("activity" :: Text)
                                   , "site" =. ("stackoverflow" :: Text) ]
                     , httpMethod = "GET" }

getAnswers :: IO (Either (APIError ()) Questions)
getAnswers = execAPI stackOverflow () $ runRoute answersRoute

getAnswersSSL :: IO (Either (APIError ()) Questions)
getAnswersSSL = execAPI stackOverflowSSL () $ runRoute answersRoute
