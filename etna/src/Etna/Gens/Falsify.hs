module Etna.Gens.Falsify where

import           Data.List.NonEmpty (NonEmpty(..))
import qualified Data.List.NonEmpty as NE
import qualified Test.Falsify.Generator as F
import qualified Test.Falsify.Range     as FR

import Etna.Properties

ne :: [a] -> NonEmpty a
ne []     = error "Etna.Gens.Falsify.ne: empty list"
ne (x:xs) = x :| xs

-- Pick `n` distinct keys from [lo .. hi] by shuffling. Falsify lacks a
-- direct shuffle combinator, so we build one via list-of-indices
-- + element selection. Keep it simple: take a fresh random subset by
-- generating each key's "include?" bit, then trim/pad to length n. For
-- our small key spaces (~10), this gives reasonable distribution and is
-- enough to stress the bugs.
distinctKeyPairsFS :: Int -> Int -> Int -> F.Gen (NonEmpty (Int, Char))
distinctKeyPairsFS maxN keyMin keyMax = do
  let space = [keyMin .. keyMax]
  -- shuffle by sorting on random tags
  tagged <- mapM (\k -> do
                    t <- F.inRange (FR.between (0 :: Int, 1000))
                    pure (t, k)) space
  let shuffled = map snd (orderBy fst tagged)
  n <- fromIntegral <$> F.inRange (FR.between (1 :: Word, fromIntegral maxN))
  let ks = take n shuffled
  vs <- mapM (const (F.elem (ne ['a' .. 'z']))) ks
  case zip ks vs of
    []     -> error "distinctKeyPairsFS: empty"
    (x:rs) -> pure (x :| rs)
  where
    orderBy f = foldr ins []
      where
        ins x [] = [x]
        ins x (y:ys)
          | f x <= f y = x : y : ys
          | otherwise  = y : ins x ys

distinctIntsFS :: Int -> Int -> Int -> F.Gen (NonEmpty Int)
distinctIntsFS maxN lo hi = do
  let space = [lo .. hi]
  tagged <- mapM (\k -> do
                    t <- F.inRange (FR.between (0 :: Int, 1000))
                    pure (t, k)) space
  let shuffled = map snd (orderBy fst tagged)
  n <- fromIntegral <$> F.inRange (FR.between (1 :: Word, fromIntegral maxN))
  case take n shuffled of
    []     -> error "distinctIntsFS: empty"
    (x:xs) -> pure (x :| xs)
  where
    orderBy f = foldr ins []
      where
        ins x [] = [x]
        ins x (y:ys)
          | f x <= f y = x : y : ys
          | otherwise  = y : ins x ys

------------------------------------------------------------------------------

gen_delete_max_ne_map_keys_shrink :: F.Gen NeMapPairs
gen_delete_max_ne_map_keys_shrink = NeMapPairs <$> distinctKeyPairsFS 6 0 12

gen_delete_max_ne_int_map_keys_shrink :: F.Gen NeIntMapPairs
gen_delete_max_ne_int_map_keys_shrink = NeIntMapPairs <$> distinctKeyPairsFS 6 0 12

gen_delete_max_ne_set_shrink :: F.Gen NeSetElems
gen_delete_max_ne_set_shrink = NeSetElems <$> distinctIntsFS 6 0 12

gen_delete_max_ne_int_set_shrink :: F.Gen NeIntSetElems
gen_delete_max_ne_int_set_shrink = NeIntSetElems <$> distinctIntsFS 6 0 12

gen_intersperse_length_invariant :: F.Gen NeSeqElems
gen_intersperse_length_invariant = do
  -- bias toward singleton (length 1) to hit the singleton-only bug
  bit <- F.inRange (FR.between (0 :: Word, 2))
  let nMax | bit == 0  = 1
           | otherwise = 5
  n <- fromIntegral <$> F.inRange (FR.between (1 :: Word, fromIntegral (nMax :: Int)))
  xs <- mapM (const (F.inRange (FR.between (0 :: Int, 99)))) [1 .. n]
  sep <- F.inRange (FR.between (0 :: Int, 99))
  case xs of
    []     -> error "gen_intersperse: impossible"
    (x:rs) -> pure (NeSeqElems (x :| rs) sep)

gen_split_left_partition_at_upper_bound :: F.Gen SplitArgs
gen_split_left_partition_at_upper_bound = do
  -- Need >= 2 distinct keys.
  let space = [0 .. 12 :: Int]
  tagged <- mapM (\k -> do
                    t <- F.inRange (FR.between (0 :: Int, 1000))
                    pure (t, k)) space
  let shuffled = map snd (orderBy fst tagged)
  n <- fromIntegral <$> F.inRange (FR.between (2 :: Word, 6))
  let ks = take n shuffled
  vs <- mapM (const (F.elem (ne ['a' .. 'z']))) ks
  case zip ks vs of
    []     -> error "gen_split: empty"
    (x:rs) -> pure (SplitArgs (x :| rs))
  where
    orderBy f = foldr ins []
      where
        ins x [] = [x]
        ins x (y:ys)
          | f x <= f y = x : y : ys
          | otherwise  = y : ins x ys

gen_is_submap_of_reflexive_and_key_exists :: F.Gen SubmapArgs
gen_is_submap_of_reflexive_and_key_exists = do
  a <- distinctKeyPairsFS 4 0 9
  b <- distinctKeyPairsFS 4 0 9
  pure (SubmapArgs a b)

gen_update_lookup_returns_original :: F.Gen UpdLookupArgs
gen_update_lookup_returns_original = do
  pairs <- distinctKeyPairsFS 4 0 12
  mode <- F.elem (ne [0, 1])
  pure (UpdLookupArgs pairs mode)

-- Suppress unused-import warning for NE; kept available for future use.
_neUsage :: NonEmpty a -> [a]
_neUsage = NE.toList
