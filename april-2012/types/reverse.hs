rev :: [Integer] -> [Integer]
rev [] = []
rev (x:xs) = rev(xs) ++ [x]
