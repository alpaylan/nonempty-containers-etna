# nonempty-containers — ETNA Tasks

Total tasks: 32

## Task Index

| Task | Variant | Framework | Property | Witness |
|------|---------|-----------|----------|---------|
| 001 | `delete_max_neintmap_singleton_ccc4283_2` | quickcheck | `DeleteMaxNeIntMapKeysShrink` | `witness_delete_max_neintmap_keys_shrink_case_singleton` |
| 002 | `delete_max_neintmap_singleton_ccc4283_2` | hedgehog | `DeleteMaxNeIntMapKeysShrink` | `witness_delete_max_neintmap_keys_shrink_case_singleton` |
| 003 | `delete_max_neintmap_singleton_ccc4283_2` | falsify | `DeleteMaxNeIntMapKeysShrink` | `witness_delete_max_neintmap_keys_shrink_case_singleton` |
| 004 | `delete_max_neintmap_singleton_ccc4283_2` | smallcheck | `DeleteMaxNeIntMapKeysShrink` | `witness_delete_max_neintmap_keys_shrink_case_singleton` |
| 005 | `delete_max_neintset_singleton_ccc4283_4` | quickcheck | `DeleteMaxNeIntSetShrink` | `witness_delete_max_neintset_shrink_case_singleton` |
| 006 | `delete_max_neintset_singleton_ccc4283_4` | hedgehog | `DeleteMaxNeIntSetShrink` | `witness_delete_max_neintset_shrink_case_singleton` |
| 007 | `delete_max_neintset_singleton_ccc4283_4` | falsify | `DeleteMaxNeIntSetShrink` | `witness_delete_max_neintset_shrink_case_singleton` |
| 008 | `delete_max_neintset_singleton_ccc4283_4` | smallcheck | `DeleteMaxNeIntSetShrink` | `witness_delete_max_neintset_shrink_case_singleton` |
| 009 | `delete_max_nemap_singleton_ccc4283_1` | quickcheck | `DeleteMaxNeMapKeysShrink` | `witness_delete_max_nemap_keys_shrink_case_singleton` |
| 010 | `delete_max_nemap_singleton_ccc4283_1` | hedgehog | `DeleteMaxNeMapKeysShrink` | `witness_delete_max_nemap_keys_shrink_case_singleton` |
| 011 | `delete_max_nemap_singleton_ccc4283_1` | falsify | `DeleteMaxNeMapKeysShrink` | `witness_delete_max_nemap_keys_shrink_case_singleton` |
| 012 | `delete_max_nemap_singleton_ccc4283_1` | smallcheck | `DeleteMaxNeMapKeysShrink` | `witness_delete_max_nemap_keys_shrink_case_singleton` |
| 013 | `delete_max_neset_singleton_ccc4283_3` | quickcheck | `DeleteMaxNeSetShrink` | `witness_delete_max_neset_shrink_case_singleton` |
| 014 | `delete_max_neset_singleton_ccc4283_3` | hedgehog | `DeleteMaxNeSetShrink` | `witness_delete_max_neset_shrink_case_singleton` |
| 015 | `delete_max_neset_singleton_ccc4283_3` | falsify | `DeleteMaxNeSetShrink` | `witness_delete_max_neset_shrink_case_singleton` |
| 016 | `delete_max_neset_singleton_ccc4283_3` | smallcheck | `DeleteMaxNeSetShrink` | `witness_delete_max_neset_shrink_case_singleton` |
| 017 | `neintmap_updlookup_return_23a26d6_1` | quickcheck | `UpdateLookupReturnsOriginal` | `witness_update_lookup_returns_original_case_delete` |
| 018 | `neintmap_updlookup_return_23a26d6_1` | hedgehog | `UpdateLookupReturnsOriginal` | `witness_update_lookup_returns_original_case_delete` |
| 019 | `neintmap_updlookup_return_23a26d6_1` | falsify | `UpdateLookupReturnsOriginal` | `witness_update_lookup_returns_original_case_delete` |
| 020 | `neintmap_updlookup_return_23a26d6_1` | smallcheck | `UpdateLookupReturnsOriginal` | `witness_update_lookup_returns_original_case_delete` |
| 021 | `nemap_issubmap_swap_967de8b_1` | quickcheck | `IsSubmapOfReflexiveAndKeyExists` | `witness_is_submap_of_reflexive_and_key_exists_case_self_singleton` |
| 022 | `nemap_issubmap_swap_967de8b_1` | hedgehog | `IsSubmapOfReflexiveAndKeyExists` | `witness_is_submap_of_reflexive_and_key_exists_case_self_singleton` |
| 023 | `nemap_issubmap_swap_967de8b_1` | falsify | `IsSubmapOfReflexiveAndKeyExists` | `witness_is_submap_of_reflexive_and_key_exists_case_self_singleton` |
| 024 | `nemap_issubmap_swap_967de8b_1` | smallcheck | `IsSubmapOfReflexiveAndKeyExists` | `witness_is_submap_of_reflexive_and_key_exists_case_self_singleton` |
| 025 | `nemap_split_gt_9d516da_1` | quickcheck | `SplitLeftPartitionAtUpperBound` | `witness_split_left_partition_at_upper_bound_case_three` |
| 026 | `nemap_split_gt_9d516da_1` | hedgehog | `SplitLeftPartitionAtUpperBound` | `witness_split_left_partition_at_upper_bound_case_three` |
| 027 | `nemap_split_gt_9d516da_1` | falsify | `SplitLeftPartitionAtUpperBound` | `witness_split_left_partition_at_upper_bound_case_three` |
| 028 | `nemap_split_gt_9d516da_1` | smallcheck | `SplitLeftPartitionAtUpperBound` | `witness_split_left_partition_at_upper_bound_case_three` |
| 029 | `neseq_intersperse_singleton_90ad8f2_1` | quickcheck | `IntersperseLengthInvariant` | `witness_intersperse_length_invariant_case_singleton` |
| 030 | `neseq_intersperse_singleton_90ad8f2_1` | hedgehog | `IntersperseLengthInvariant` | `witness_intersperse_length_invariant_case_singleton` |
| 031 | `neseq_intersperse_singleton_90ad8f2_1` | falsify | `IntersperseLengthInvariant` | `witness_intersperse_length_invariant_case_singleton` |
| 032 | `neseq_intersperse_singleton_90ad8f2_1` | smallcheck | `IntersperseLengthInvariant` | `witness_intersperse_length_invariant_case_singleton` |

## Witness Catalog

- `witness_delete_max_neintmap_keys_shrink_case_singleton` — deleteMax (singleton 5 'a') must equal IM.empty
- `witness_delete_max_neintmap_keys_shrink_case_two_elem` — deleteMax (fromList ((5,'a') :| [(3,'b')])) must equal IM.singleton 3 'b'
- `witness_delete_max_neintset_shrink_case_singleton` — deleteMax (singleton 5) must equal IS.empty
- `witness_delete_max_neintset_shrink_case_two_elem` — deleteMax (fromList (5 :| [3])) must equal IS.singleton 3
- `witness_delete_max_nemap_keys_shrink_case_singleton` — deleteMax (singleton 5 'a') must equal M.empty
- `witness_delete_max_nemap_keys_shrink_case_two_elem` — deleteMax (fromList ((5,'a') :| [(3,'b')])) must equal M.singleton 3 'b'
- `witness_delete_max_neset_shrink_case_singleton` — deleteMax (singleton 5) must equal S.empty
- `witness_delete_max_neset_shrink_case_two_elem` — deleteMax (fromList (5 :| [3])) must equal S.singleton 3
- `witness_update_lookup_returns_original_case_delete` — updateLookupWithKey (\_ _ -> Nothing) 5 (singleton 5 'a') must yield (Just 'a', _) — original value, not Nothing
- `witness_update_lookup_returns_original_case_update` — updateLookupWithKey (\_ _ -> Just 'z') 5 (singleton 5 'a') must yield (Just 'a', _) — original 'a', not updated 'z'
- `witness_is_submap_of_reflexive_and_key_exists_case_self_singleton` — isSubmapOfBy (==) (singleton 1 'a') (singleton 1 'a') must equal True
- `witness_is_submap_of_reflexive_and_key_exists_case_disjoint_keys` — isSubmapOfBy (==) (singleton 1 'a') (singleton 2 'b') must equal False
- `witness_split_left_partition_at_upper_bound_case_three` — split 100 (fromList ((5,'a') :| [(3,'b'), (7,'c')])) must keep all 3 entries on the left side
- `witness_split_left_partition_at_upper_bound_case_two` — split 50 (fromList ((5,'a') :| [(3,'b')])) must keep both entries on the left
- `witness_intersperse_length_invariant_case_singleton` — intersperse 0 (singleton 5) must have length 1
- `witness_intersperse_length_invariant_case_two_elem` — intersperse 0 (fromList (5 :| [7])) must have length 3
