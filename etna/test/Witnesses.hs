module Main where

import Etna.Result    (PropertyResult(..))
import Etna.Witnesses
import System.Exit    (exitFailure, exitSuccess)

cases :: [(String, PropertyResult)]
cases =
  [ ("witness_delete_max_nemap_keys_shrink_case_singleton",   witness_delete_max_nemap_keys_shrink_case_singleton)
  , ("witness_delete_max_nemap_keys_shrink_case_two_elem",    witness_delete_max_nemap_keys_shrink_case_two_elem)
  , ("witness_delete_max_neintmap_keys_shrink_case_singleton", witness_delete_max_neintmap_keys_shrink_case_singleton)
  , ("witness_delete_max_neintmap_keys_shrink_case_two_elem",  witness_delete_max_neintmap_keys_shrink_case_two_elem)
  , ("witness_delete_max_neset_shrink_case_singleton",        witness_delete_max_neset_shrink_case_singleton)
  , ("witness_delete_max_neset_shrink_case_two_elem",         witness_delete_max_neset_shrink_case_two_elem)
  , ("witness_delete_max_neintset_shrink_case_singleton",     witness_delete_max_neintset_shrink_case_singleton)
  , ("witness_delete_max_neintset_shrink_case_two_elem",      witness_delete_max_neintset_shrink_case_two_elem)
  , ("witness_intersperse_length_invariant_case_singleton",   witness_intersperse_length_invariant_case_singleton)
  , ("witness_intersperse_length_invariant_case_two_elem",    witness_intersperse_length_invariant_case_two_elem)
  , ("witness_split_left_partition_at_upper_bound_case_three", witness_split_left_partition_at_upper_bound_case_three)
  , ("witness_split_left_partition_at_upper_bound_case_two",   witness_split_left_partition_at_upper_bound_case_two)
  , ("witness_is_submap_of_reflexive_and_key_exists_case_self_singleton", witness_is_submap_of_reflexive_and_key_exists_case_self_singleton)
  , ("witness_is_submap_of_reflexive_and_key_exists_case_disjoint_keys",  witness_is_submap_of_reflexive_and_key_exists_case_disjoint_keys)
  , ("witness_update_lookup_returns_original_case_delete",    witness_update_lookup_returns_original_case_delete)
  , ("witness_update_lookup_returns_original_case_update",    witness_update_lookup_returns_original_case_update)
  ]

main :: IO ()
main = do
  let failures =
        [ (n, msg) | (n, Fail msg) <- cases ] ++
        [ (n, "discard") | (n, Discard) <- cases ]
  if null failures
    then do
      putStrLn $ "OK: all " ++ show (length cases) ++ " witnesses passed"
      exitSuccess
    else do
      mapM_ (\(n, m) -> putStrLn (n ++ ": FAIL: " ++ m)) failures
      exitFailure
