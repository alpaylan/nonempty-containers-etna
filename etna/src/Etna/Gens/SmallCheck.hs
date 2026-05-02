{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Etna.Gens.SmallCheck where

import           Data.List.NonEmpty (NonEmpty(..))
import qualified Test.SmallCheck.Series as SC

import Etna.Properties

-- SmallCheck is a bounded-enumeration backend. We bound list lengths
-- and value ranges tightly so depths up to ~6 cover the buggy cases.

charSpace :: Monad m => SC.Series m Char
charSpace = SC.generate (\_ -> ['a', 'b'])

intSpaceSmall :: Monad m => SC.Series m Int
intSpaceSmall = SC.generate (\d -> [0 .. min (d + 1) 5])

intSpaceMid :: Monad m => SC.Series m Int
intSpaceMid = SC.generate (\d -> [0 .. min (d + 1) 8])

-- Build a non-empty list of distinct keys by enumerating the prefixes
-- of [0..k] of length 1..n with per-element value choices. This is
-- structurally simple for SmallCheck to enumerate.
distinctKeyPairsSC :: Monad m => Int -> Int -> SC.Series m (NonEmpty (Int, Char))
distinctKeyPairsSC maxN keyMax = do
  n <- SC.generate (\d -> [1 .. min (d + 1) maxN])
  let prefix = take n [0 .. keyMax]
  vs <- mapM (const charSpace) prefix
  case zip prefix vs of
    []     -> error "distinctKeyPairsSC: empty"
    (x:xs) -> pure (x :| xs)

distinctIntsSC :: Monad m => Int -> Int -> SC.Series m (NonEmpty Int)
distinctIntsSC maxN keyMax = do
  n <- SC.generate (\d -> [1 .. min (d + 1) maxN])
  case take n [0 .. keyMax] of
    []     -> error "distinctIntsSC: empty"
    (x:xs) -> pure (x :| xs)

------------------------------------------------------------------------------

series_delete_max_ne_map_keys_shrink :: Monad m => SC.Series m NeMapPairs
series_delete_max_ne_map_keys_shrink = NeMapPairs <$> distinctKeyPairsSC 4 5

series_delete_max_ne_int_map_keys_shrink :: Monad m => SC.Series m NeIntMapPairs
series_delete_max_ne_int_map_keys_shrink = NeIntMapPairs <$> distinctKeyPairsSC 4 5

series_delete_max_ne_set_shrink :: Monad m => SC.Series m NeSetElems
series_delete_max_ne_set_shrink = NeSetElems <$> distinctIntsSC 4 5

series_delete_max_ne_int_set_shrink :: Monad m => SC.Series m NeIntSetElems
series_delete_max_ne_int_set_shrink = NeIntSetElems <$> distinctIntsSC 4 5

series_intersperse_length_invariant :: Monad m => SC.Series m NeSeqElems
series_intersperse_length_invariant = do
  n <- SC.generate (\d -> [1 .. min (d + 1) 4])
  xs <- mapM (const intSpaceSmall) [1 .. n]
  sep <- intSpaceSmall
  case xs of
    []     -> error "series_intersperse: impossible"
    (x:rs) -> pure (NeSeqElems (x :| rs) sep)

series_split_left_partition_at_upper_bound :: Monad m => SC.Series m SplitArgs
series_split_left_partition_at_upper_bound = do
  -- Need >= 2 distinct keys.
  n <- SC.generate (\d -> [2 .. min (d + 2) 4])
  let prefix = take n [0 .. 5]
  vs <- mapM (const charSpace) prefix
  case zip prefix vs of
    []     -> error "series_split: empty"
    (x:xs) -> pure (SplitArgs (x :| xs))

series_is_submap_of_reflexive_and_key_exists :: Monad m => SC.Series m SubmapArgs
series_is_submap_of_reflexive_and_key_exists = do
  a <- distinctKeyPairsSC 3 4
  b <- distinctKeyPairsSC 3 4
  pure (SubmapArgs a b)

series_update_lookup_returns_original :: Monad m => SC.Series m UpdLookupArgs
series_update_lookup_returns_original = do
  pairs <- distinctKeyPairsSC 3 5
  mode <- SC.generate (\_ -> [0, 1])
  pure (UpdLookupArgs pairs mode)
