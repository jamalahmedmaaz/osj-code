data FileName = FileName String

data FilePath = FilePath String String String

isMarkdown (FilePath _ _ "md") = True
isMarkdown _ = False

fileExtension (FilePath _ _ ext) = ext

data Path = Directory String
            |
            File String String String

data Path =


