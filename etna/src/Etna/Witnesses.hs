module Etna.Witnesses where

import Data.List.NonEmpty (NonEmpty(..))

import Etna.Properties
import Etna.Result

-- Variant 1: delete_max_nemap_singleton_ccc4283_1
witness_delete_max_nemap_keys_shrink_case_singleton :: PropertyResult
witness_delete_max_nemap_keys_shrink_case_singleton =
  property_delete_max_ne_map_keys_shrink (NeMapPairs ((5, 'a') :| []))

witness_delete_max_nemap_keys_shrink_case_two_elem :: PropertyResult
witness_delete_max_nemap_keys_shrink_case_two_elem =
  property_delete_max_ne_map_keys_shrink (NeMapPairs ((5, 'a') :| [(3, 'b')]))

-- Variant 2: delete_max_neintmap_singleton_ccc4283_2
witness_delete_max_neintmap_keys_shrink_case_singleton :: PropertyResult
witness_delete_max_neintmap_keys_shrink_case_singleton =
  property_delete_max_ne_int_map_keys_shrink (NeIntMapPairs ((5, 'a') :| []))

witness_delete_max_neintmap_keys_shrink_case_two_elem :: PropertyResult
witness_delete_max_neintmap_keys_shrink_case_two_elem =
  property_delete_max_ne_int_map_keys_shrink (NeIntMapPairs ((5, 'a') :| [(3, 'b')]))

-- Variant 3: delete_max_neset_singleton_ccc4283_3
witness_delete_max_neset_shrink_case_singleton :: PropertyResult
witness_delete_max_neset_shrink_case_singleton =
  property_delete_max_ne_set_shrink (NeSetElems (5 :| []))

witness_delete_max_neset_shrink_case_two_elem :: PropertyResult
witness_delete_max_neset_shrink_case_two_elem =
  property_delete_max_ne_set_shrink (NeSetElems (5 :| [3]))

-- Variant 4: delete_max_neintset_singleton_ccc4283_4
witness_delete_max_neintset_shrink_case_singleton :: PropertyResult
witness_delete_max_neintset_shrink_case_singleton =
  property_delete_max_ne_int_set_shrink (NeIntSetElems (5 :| []))

witness_delete_max_neintset_shrink_case_two_elem :: PropertyResult
witness_delete_max_neintset_shrink_case_two_elem =
  property_delete_max_ne_int_set_shrink (NeIntSetElems (5 :| [3]))

-- Variant 5: neseq_intersperse_singleton_90ad8f2_1
witness_intersperse_length_invariant_case_singleton :: PropertyResult
witness_intersperse_length_invariant_case_singleton =
  property_intersperse_length_invariant (NeSeqElems (5 :| []) 0)

witness_intersperse_length_invariant_case_two_elem :: PropertyResult
witness_intersperse_length_invariant_case_two_elem =
  property_intersperse_length_invariant (NeSeqElems (5 :| [7]) 0)

-- Variant 6: nemap_split_gt_9d516da_1
witness_split_left_partition_at_upper_bound_case_three :: PropertyResult
witness_split_left_partition_at_upper_bound_case_three =
  property_split_left_partition_at_upper_bound
    (SplitArgs ((5, 'a') :| [(3, 'b'), (7, 'c')]))

witness_split_left_partition_at_upper_bound_case_two :: PropertyResult
witness_split_left_partition_at_upper_bound_case_two =
  property_split_left_partition_at_upper_bound
    (SplitArgs ((5, 'a') :| [(3, 'b')]))

-- Variant 7: nemap_issubmap_swap_967de8b_1
witness_is_submap_of_reflexive_and_key_exists_case_self_singleton :: PropertyResult
witness_is_submap_of_reflexive_and_key_exists_case_self_singleton =
  property_is_submap_of_reflexive_and_key_exists
    (SubmapArgs ((1, 'a') :| []) ((1, 'a') :| []))

witness_is_submap_of_reflexive_and_key_exists_case_disjoint_keys :: PropertyResult
witness_is_submap_of_reflexive_and_key_exists_case_disjoint_keys =
  property_is_submap_of_reflexive_and_key_exists
    (SubmapArgs ((1, 'a') :| []) ((2, 'b') :| []))

-- Variant 8: neintmap_updlookup_return_23a26d6_1
witness_update_lookup_returns_original_case_delete :: PropertyResult
witness_update_lookup_returns_original_case_delete =
  property_update_lookup_returns_original (UpdLookupArgs ((5, 'a') :| []) 0)

witness_update_lookup_returns_original_case_update :: PropertyResult
witness_update_lookup_returns_original_case_update =
  property_update_lookup_returns_original (UpdLookupArgs ((5, 'a') :| []) 1)
