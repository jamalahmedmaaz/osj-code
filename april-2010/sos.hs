sum_list = foldr (+) 0
squares = map (\x -> x * x)

sum_squares list = sum_list (squares list)

sum_squares_composed = sum_list . squares

prod_squares = foldr (*) 1 . map (\x -> x * x)