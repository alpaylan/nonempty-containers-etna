module Etna.Gens.Hedgehog where

import           Data.List.NonEmpty (NonEmpty(..))
import           Hedgehog (Gen, MonadGen)
import qualified Hedgehog.Gen   as Gen
import qualified Hedgehog.Range as Range

import Etna.Properties

distinctKeyPairsHH :: MonadGen m => Int -> Int -> Int -> m (NonEmpty (Int, Char))
distinctKeyPairsHH maxN keyMin keyMax = do
  n <- Gen.int (Range.linear 1 maxN)
  let space = [keyMin .. keyMax]
  shuffled <- Gen.shuffle space
  let ks = take n shuffled
  vs <- mapM (const (Gen.element ['a' .. 'z'])) ks
  case zip ks vs of
    []     -> error "distinctKeyPairsHH: empty"
    (x:rs) -> pure (x :| rs)

distinctIntsHH :: MonadGen m => Int -> Int -> Int -> m (NonEmpty Int)
distinctIntsHH maxN lo hi = do
  n <- Gen.int (Range.linear 1 maxN)
  shuffled <- Gen.shuffle [lo .. hi]
  case take n shuffled of
    []     -> error "distinctIntsHH: empty"
    (x:xs) -> pure (x :| xs)

------------------------------------------------------------------------------

gen_delete_max_ne_map_keys_shrink :: Gen NeMapPairs
gen_delete_max_ne_map_keys_shrink = NeMapPairs <$> distinctKeyPairsHH 6 0 12

gen_delete_max_ne_int_map_keys_shrink :: Gen NeIntMapPairs
gen_delete_max_ne_int_map_keys_shrink = NeIntMapPairs <$> distinctKeyPairsHH 6 0 12

gen_delete_max_ne_set_shrink :: Gen NeSetElems
gen_delete_max_ne_set_shrink = NeSetElems <$> distinctIntsHH 6 0 12

gen_delete_max_ne_int_set_shrink :: Gen NeIntSetElems
gen_delete_max_ne_int_set_shrink = NeIntSetElems <$> distinctIntsHH 6 0 12

gen_intersperse_length_invariant :: Gen NeSeqElems
gen_intersperse_length_invariant = do
  n <- Gen.frequency [(2, pure 1), (1, Gen.int (Range.linear 2 5))]
  xs <- mapM (const (Gen.int (Range.linear 0 99))) [1 .. n]
  sep <- Gen.int (Range.linear 0 99)
  case xs of
    []     -> error "gen_intersperse: impossible"
    (x:rs) -> pure (NeSeqElems (x :| rs) sep)

gen_split_left_partition_at_upper_bound :: Gen SplitArgs
gen_split_left_partition_at_upper_bound = do
  n <- Gen.int (Range.linear 2 6)
  shuffled <- Gen.shuffle [0 .. 12]
  let ks = take n shuffled
  vs <- mapM (const (Gen.element ['a' .. 'z'])) ks
  case zip ks vs of
    []     -> error "gen_split: empty"
    (x:rs) -> pure (SplitArgs (x :| rs))

gen_is_submap_of_reflexive_and_key_exists :: Gen SubmapArgs
gen_is_submap_of_reflexive_and_key_exists = do
  a <- distinctKeyPairsHH 4 0 9
  b <- distinctKeyPairsHH 4 0 9
  pure (SubmapArgs a b)

gen_update_lookup_returns_original :: Gen UpdLookupArgs
gen_update_lookup_returns_original = do
  pairs <- distinctKeyPairsHH 4 0 12
  mode <- Gen.element [0, 1]
  pure (UpdLookupArgs pairs mode)
