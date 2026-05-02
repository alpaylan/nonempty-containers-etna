module Etna.Gens.QuickCheck where

import           Data.List.NonEmpty (NonEmpty(..))
import qualified Test.QuickCheck as QC

import Etna.Properties

-- Helper: produce a non-empty list of size 1..maxN with distinct keys.
distinctKeyPairsSimple :: Int -> Int -> Int -> QC.Gen (NonEmpty (Int, Char))
distinctKeyPairsSimple maxN keyMin keyMax = do
  n <- QC.choose (1, maxN)
  shuffled <- QC.shuffle [keyMin .. keyMax]
  let ks = take n shuffled
  vs <- QC.vectorOf (length ks) (QC.elements ['a' .. 'z'])
  case zip ks vs of
    []       -> error "distinctKeyPairsSimple: empty"
    (x:rest) -> pure (x :| rest)

distinctInts :: Int -> Int -> Int -> QC.Gen (NonEmpty Int)
distinctInts maxN lo hi = do
  n <- QC.choose (1, maxN)
  shuffled <- QC.shuffle [lo .. hi]
  case take n shuffled of
    []     -> error "distinctInts: empty"
    (x:xs) -> pure (x :| xs)

------------------------------------------------------------------------------

gen_delete_max_ne_map_keys_shrink :: QC.Gen NeMapPairs
gen_delete_max_ne_map_keys_shrink = NeMapPairs <$> distinctKeyPairsSimple 6 0 12

gen_delete_max_ne_int_map_keys_shrink :: QC.Gen NeIntMapPairs
gen_delete_max_ne_int_map_keys_shrink = NeIntMapPairs <$> distinctKeyPairsSimple 6 0 12

gen_delete_max_ne_set_shrink :: QC.Gen NeSetElems
gen_delete_max_ne_set_shrink = NeSetElems <$> distinctInts 6 0 12

gen_delete_max_ne_int_set_shrink :: QC.Gen NeIntSetElems
gen_delete_max_ne_int_set_shrink = NeIntSetElems <$> distinctInts 6 0 12

gen_intersperse_length_invariant :: QC.Gen NeSeqElems
gen_intersperse_length_invariant = do
  -- include length-1 sequences with high probability so the singleton bug
  -- is reliably hit.
  n <- QC.frequency [(2, pure 1), (1, QC.choose (2, 5))]
  xs <- QC.vectorOf n (QC.choose (0, 99))
  sep <- QC.choose (0, 99)
  case xs of
    []     -> error "gen_intersperse: impossible"
    (x:rs) -> pure (NeSeqElems (x :| rs) sep)

gen_split_left_partition_at_upper_bound :: QC.Gen SplitArgs
gen_split_left_partition_at_upper_bound = do
  -- Need >= 2 distinct keys to exercise the bug.
  n <- QC.choose (2, 6)
  shuffled <- QC.shuffle [0 .. 12]
  let ks = take n shuffled
  vs <- QC.vectorOf (length ks) (QC.elements ['a' .. 'z'])
  case zip ks vs of
    []     -> error "gen_split: empty"
    (x:rs) -> pure (SplitArgs (x :| rs))

gen_is_submap_of_reflexive_and_key_exists :: QC.Gen SubmapArgs
gen_is_submap_of_reflexive_and_key_exists = do
  a <- distinctKeyPairsSimple 4 0 9
  b <- distinctKeyPairsSimple 4 0 9
  pure (SubmapArgs a b)

gen_update_lookup_returns_original :: QC.Gen UpdLookupArgs
gen_update_lookup_returns_original = do
  pairs <- distinctKeyPairsSimple 4 0 12
  mode <- QC.elements [0, 1]
  pure (UpdLookupArgs pairs mode)
