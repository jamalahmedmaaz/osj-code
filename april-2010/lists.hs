sum_list [] = 0
sum_list (x:xs) = x + sum_list xs
--sum_list l = (head l) + sum_list (tail l)

prod_list [] = 1
prod_list (x:xs) = x * prod_list xs

list_calc [] base _ = base
list_calc (x:xs) base f = f x (list_calc xs base f)

prod_list2 list = list_calc list 1 (*)
sum_list2 list = list_calc list 0 (+)

sum_list_recursive list = calc list 0
   where calc [] result = result
         calc (x:xs) result = calc xs (result + x)

list_calc_recursive list base f = calc list base
    where 
      calc [] acc = acc
      calc (x:xs) acc = calc xs (f x acc)

prod_list3 list = list_calc_recursive list 1 (*)
sum_list3 list = list_calc_recursive list 0 (+)

prod_list4 list = foldr (*) 1 list
sum_list4 list = foldr (+)  0 list

squares [] = []
squares (x:xs) = (x * x) : squares xs

squares_map list = map square list
	where square x = x * x

squares_lambda list = map (\x -> x * x) list