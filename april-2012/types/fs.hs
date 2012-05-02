data Directory = Root | Dir Directory String
data File = File Directory String String

--instance Show Directory where
--  show Root = "/"
--  show (Dir parent name) = show(parent) ++ name ++ "/"

--instance Show File where
--  show (File dir name ext) = show(dir) ++ name ++ "." ++ ext

class Path a where
  abspath  :: a -> String
  dirname  :: a -> String
  basename :: a -> String
  parent   :: a -> Maybe Directory

instance Path Directory where
  abspath  Root                 = "/"
  abspath  (Dir parentDir name) = abspath parentDir ++ name ++ "/"
  dirname  Root                 = "/"
  dirname  (Dir parentDir _)    = abspath parentDir
  basename Root                 = "/"
  basename (Dir _ name)         = name
  parent   Root                 = Nothing
  parent   (Dir parentDir _)    = Just parentDir

instance Path File where
  abspath file@(File dir name ext) = abspath dir ++ basename file
  dirname      (File dir _ _)      = abspath dir
  basename     (File _ name ext)   = name ++ "." ++ ext
  parent       (File dir _ _)      = Just dir

newtype WrappedPath a = WrappedPath {unwrapPath :: a}

instance Path a => Show (WrappedPath a)  where
  show (WrappedPath a) = abspath a