module Sql (Query, parse, execute) where

newtype Query = Query String

parse :: String -> Query
parse = Query . escape

-- in the real world, we'd add some real logic here
escape :: String -> String
escape = id

-- just write the query out for demo purposes
execute (Query rawSql) = putStrLn rawSql