open Cnf 
open Utils
open List


type solutionState = SolutionState of (literal list  *  Cnf.t) 


type t = Unsatisfiable | Satisfiable of (literal list)

(*
let find_shortest_clause (cnf:Cnf.t) = 
  let rec aux (clause , len) = function
    | [] -> clause
    | x :: xs -> let l = length x in 
      if l = 1 then x 
      else if (l<len) then aux (x , l) xs 
      else aux (clause , len) xs
  in 
  match cnf with
  | [] -> None 
  | x :: xs -> let res = aux (x , length x) xs in Some res *)


let clean_cnf (_cnf:Cnf.t) ((sym , b):literal) = 
  drop_while (contains (sym , b)) _cnf
  
    
let choose_literal (cnf:Cnf.t) : literal option =
  list_to_maybe @@ concat cnf


let is_unit = function
  | [x] -> true
  | _ -> false 


let get_unit_literal (cnf:Cnf.t) : literal option = 
  list_to_maybe @@  (filter is_unit cnf)


let rec unit_propagation ((m , f) : solutionState) : solutionState = 
  match get_unit_literal f with 
  | None -> SolutionState (m , f)
  | Some x -> unit_propagation (SolutionState( x::m ,  clean_cnf x))


let rec dpll (sol : solutionState) : t= 
  match sol with
  | (m , []) -> Satisfiable m 
  | t ->
    let (m , phi) = unit_propagation t in 
    let (sym , b) = choose_literal phi in 
    match dpll (SolutionState ( (sym , b)::m , clean_cnf phi (sym , b))) with
    | Satisfiable s -> Satisfiable s 
    | Unsatisfiable -> dpll @@ SolverState( (sym,not b)::m , clean_cnf phi (sym , not b))




