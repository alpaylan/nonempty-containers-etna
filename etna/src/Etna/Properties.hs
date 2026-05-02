{-# LANGUAGE OverloadedStrings #-}

module Etna.Properties where

import           Data.List.NonEmpty (NonEmpty(..))
import qualified Data.List.NonEmpty as NE
import qualified Data.Map.Strict     as M
import qualified Data.IntMap.Strict  as IM
import qualified Data.Set            as S
import qualified Data.IntSet         as IS
import qualified Data.Sequence       as Seq

import qualified Data.Map.NonEmpty       as NEMap
import qualified Data.IntMap.NonEmpty    as NEIM
import qualified Data.Set.NonEmpty       as NESet
import qualified Data.IntSet.NonEmpty    as NEIS
import qualified Data.Sequence.NonEmpty  as NESeq
import           Data.These (These(..))

import Etna.Result

------------------------------------------------------------------------------
-- Variant 1: delete_max_nemap_singleton_ccc4283_1
------------------------------------------------------------------------------

-- | A non-empty list of (Int, Char) pairs used as fromList input to
-- construct an NEMap. Generators choose small key/value spaces so that
-- the property runs in microseconds and the deleteMax invariant is easy
-- to violate.
data NeMapPairs = NeMapPairs (NonEmpty (Int, Char))
  deriving (Show, Eq)

property_delete_max_ne_map_keys_shrink :: NeMapPairs -> PropertyResult
property_delete_max_ne_map_keys_shrink (NeMapPairs kvs) =
  let nem      = NEMap.fromList kvs
      after    = NEMap.deleteMax nem
      original = NEMap.toMap nem
      maxKey   = fst (NE.last (NE.sortWith fst kvs))
      expected = M.delete maxKey original
  in if after == expected
       then Pass
       else Fail $
         "deleteMax " ++ show (M.toAscList original) ++
         " = " ++ show (M.toAscList after) ++
         "; expected " ++ show (M.toAscList expected)

------------------------------------------------------------------------------
-- Variant 2: delete_max_neintmap_singleton_ccc4283_2
------------------------------------------------------------------------------

data NeIntMapPairs = NeIntMapPairs (NonEmpty (Int, Char))
  deriving (Show, Eq)

property_delete_max_ne_int_map_keys_shrink :: NeIntMapPairs -> PropertyResult
property_delete_max_ne_int_map_keys_shrink (NeIntMapPairs kvs) =
  let neim     = NEIM.fromList kvs
      after    = NEIM.deleteMax neim
      original = NEIM.toMap neim
      maxKey   = fst (NE.last (NE.sortWith fst kvs))
      expected = IM.delete maxKey original
  in if after == expected
       then Pass
       else Fail $
         "deleteMax " ++ show (IM.toAscList original) ++
         " = " ++ show (IM.toAscList after) ++
         "; expected " ++ show (IM.toAscList expected)

------------------------------------------------------------------------------
-- Variant 3: delete_max_neset_singleton_ccc4283_3
------------------------------------------------------------------------------

data NeSetElems = NeSetElems (NonEmpty Int)
  deriving (Show, Eq)

property_delete_max_ne_set_shrink :: NeSetElems -> PropertyResult
property_delete_max_ne_set_shrink (NeSetElems xs) =
  let nes      = NESet.fromList xs
      after    = NESet.deleteMax nes
      original = NESet.toSet nes
      maxX     = NE.last (NE.sort xs)
      expected = S.delete maxX original
  in if after == expected
       then Pass
       else Fail $
         "deleteMax " ++ show (S.toAscList original) ++
         " = " ++ show (S.toAscList after) ++
         "; expected " ++ show (S.toAscList expected)

------------------------------------------------------------------------------
-- Variant 4: delete_max_neintset_singleton_ccc4283_4
------------------------------------------------------------------------------

data NeIntSetElems = NeIntSetElems (NonEmpty Int)
  deriving (Show, Eq)

property_delete_max_ne_int_set_shrink :: NeIntSetElems -> PropertyResult
property_delete_max_ne_int_set_shrink (NeIntSetElems xs) =
  let neis     = NEIS.fromList xs
      after    = NEIS.deleteMax neis
      original = NEIS.toSet neis
      maxX     = NE.last (NE.sort xs)
      expected = IS.delete maxX original
  in if after == expected
       then Pass
       else Fail $
         "deleteMax " ++ show (IS.toAscList original) ++
         " = " ++ show (IS.toAscList after) ++
         "; expected " ++ show (IS.toAscList expected)

------------------------------------------------------------------------------
-- Variant 5: neseq_intersperse_singleton_90ad8f2_1
------------------------------------------------------------------------------

data NeSeqElems = NeSeqElems
  { neSeqElems :: !(NonEmpty Int)
  , neSeqSep   :: !Int
  } deriving (Show, Eq)

property_intersperse_length_invariant :: NeSeqElems -> PropertyResult
property_intersperse_length_invariant (NeSeqElems xs sep) =
  let nes      = NESeq.fromList xs
      after    = NESeq.intersperse sep nes
      n        = length xs
      gotLen   = NESeq.length after
      expected = if n <= 0 then n else 2 * n - 1
  in if gotLen == expected
       then Pass
       else Fail $
         "intersperse " ++ show sep ++ " " ++ show (NE.toList xs) ++
         " has length " ++ show gotLen ++
         "; expected " ++ show expected

------------------------------------------------------------------------------
-- Variant 6: nemap_split_gt_9d516da_1
------------------------------------------------------------------------------

-- | Args for the NEMap.split GT bug. The bug is only observable in the
-- case where the (Just _, Nothing) sub-branch fires AND the left side
-- has been computed by removing an entry — i.e. when the split key is
-- present in the inner Map's tail. We choose k = max key of the NEMap
-- (which by NE invariant is in the tail when there are >= 2 elements).
-- The expected behaviour: split k n returns Just (This X) where X is n
-- with k removed. The buggy form returns Just (This n) — k still
-- present.
data SplitArgs = SplitArgs
  { splitPairs :: !(NonEmpty (Int, Char))
  } deriving (Show, Eq)

property_split_left_partition_at_upper_bound :: SplitArgs -> PropertyResult
property_split_left_partition_at_upper_bound (SplitArgs kvs)
  | NE.length kvs < 2 = Discard  -- bug is not exercised on singletons
  | otherwise =
      let nem      = NEMap.fromList kvs
          asMap    = NEMap.toMap nem
          k        = maximum (M.keys asMap)
          got      = NEMap.split k nem
          expected = M.delete k asMap
      in case got of
           Just (This left) ->
             let leftMap = NEMap.toMap left
             in if leftMap == expected
                  then Pass
                  else Fail $
                    "split " ++ show k ++ " " ++ show (M.toAscList asMap) ++
                    " left side = " ++ show (M.toAscList leftMap) ++
                    "; expected " ++ show (M.toAscList expected)
           other -> Fail $
             "split " ++ show k ++ " " ++ show (M.toAscList asMap) ++
             " = " ++ show other ++ "; expected Just (This _)"

------------------------------------------------------------------------------
-- Variant 7: nemap_issubmap_swap_967de8b_1
------------------------------------------------------------------------------

-- | Two NEMaps are sampled independently. The property checks the two
-- invariants that a swapped-operands isSubmapOfBy violates: reflexivity
-- (any NEMap is a submap of itself) and head-key-must-exist
-- (if a's head isn't in b's keys, isSubmapOfBy a b must be False).
data SubmapArgs = SubmapArgs
  { submapA :: !(NonEmpty (Int, Char))
  , submapB :: !(NonEmpty (Int, Char))
  } deriving (Show, Eq)

property_is_submap_of_reflexive_and_key_exists :: SubmapArgs -> PropertyResult
property_is_submap_of_reflexive_and_key_exists (SubmapArgs a _) =
  let nemA = NEMap.fromList a
      -- reflexivity check: nemA must be a submap of itself
      reflOk = NEMap.isSubmapOfBy (==) nemA nemA
      -- non-overlap check: build a map disjoint from nemA's keys, then a
      -- must NOT be a submap of it.
      maxA = maximum (fmap fst a)
      -- offset every key in B by maxA + 100 so they're disjoint
      bShifted = NE.fromList [ (maxA + 100, 'z') ]
      nemB = NEMap.fromList bShifted
      disjointOk = not (NEMap.isSubmapOfBy (==) nemA nemB)
  in case (reflOk, disjointOk) of
       (True, True)  -> Pass
       (False, _)    -> Fail $
         "isSubmapOfBy (==) m m == False for m = " ++ show (M.toAscList (NEMap.toMap nemA))
       (_, False)    -> Fail $
         "isSubmapOfBy (==) " ++ show (M.toAscList (NEMap.toMap nemA)) ++
         " " ++ show (M.toAscList (NEMap.toMap nemB)) ++ " == True (disjoint keys)"

------------------------------------------------------------------------------
-- Variant 8: neintmap_updlookup_return_23a26d6_1
------------------------------------------------------------------------------

-- | We pick a key actually present in the NEIntMap (always the head) and
-- check that updateLookupWithKey returns the original value.  The "delete"
-- and "update" cases are encoded by the `mode` field: 0 = always-delete f,
-- 1 = always-update f.
data UpdLookupArgs = UpdLookupArgs
  { updLookupPairs :: !(NonEmpty (Int, Char))
  , updLookupMode  :: !Int  -- 0 = delete, 1 = update
  } deriving (Show, Eq)

property_update_lookup_returns_original :: UpdLookupArgs -> PropertyResult
property_update_lookup_returns_original (UpdLookupArgs kvs mode)
  | mode /= 0 && mode /= 1 = Discard
  | otherwise =
      let neim    = NEIM.fromList kvs
          (k, v0) = NEIM.findMin neim
          f       = if mode == 0 then \_ _ -> Nothing else \_ _ -> Just 'z'
          (lkp, _) = NEIM.updateLookupWithKey f k neim
      in if lkp == Just v0
           then Pass
           else Fail $
             "updateLookupWithKey f " ++ show k ++ " " ++
             show (IM.toAscList (NEIM.toMap neim)) ++
             " (mode=" ++ show mode ++ ") returned lookup=" ++ show lkp ++
             "; expected " ++ show (Just v0)
