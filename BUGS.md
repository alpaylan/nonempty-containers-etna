# nonempty-containers — Injected Bugs

Non-empty variants of containers types (mstksg/nonempty-containers). Bug fixes mined from upstream history; modern HEAD is the base, each patch reverse-applies a fix to install the original bug.

Total mutations: 8

## Bug Index

| # | Variant | Name | Location | Injection | Fix Commit |
|---|---------|------|----------|-----------|------------|
| 1 | `delete_max_neintmap_singleton_ccc4283_2` | `deleteMax_neintmap_returns_singleton` | `src/Data/IntMap/NonEmpty.hs:1822` | `patch` | `ccc4283f48592efe47b41d2f44330cbadfa73e4d` |
| 2 | `delete_max_neintset_singleton_ccc4283_4` | `deleteMax_neintset_returns_singleton` | `src/Data/IntSet/NonEmpty.hs:709` | `patch` | `ccc4283f48592efe47b41d2f44330cbadfa73e4d` |
| 3 | `delete_max_nemap_singleton_ccc4283_1` | `deleteMax_returns_singleton` | `src/Data/Map/NonEmpty.hs:2228` | `patch` | `ccc4283f48592efe47b41d2f44330cbadfa73e4d` |
| 4 | `delete_max_neset_singleton_ccc4283_3` | `deleteMax_neset_returns_singleton` | `src/Data/Set/NonEmpty.hs:994` | `patch` | `ccc4283f48592efe47b41d2f44330cbadfa73e4d` |
| 5 | `neintmap_updlookup_return_23a26d6_1` | `updateLookupWithKey_returns_post_update_value` | `src/Data/IntMap/NonEmpty.hs:680` | `patch` | `23a26d6ebed7ea58cb76c73f5f4fc8d7ea3d960c` |
| 6 | `nemap_issubmap_swap_967de8b_1` | `isSubmapOfBy_argument_order_swapped` | `src/Data/Map/NonEmpty.hs:1982` | `patch` | `967de8bd14a008fe155152b8a8d596680a3196d6` |
| 7 | `nemap_split_gt_9d516da_1` | `split_gt_returns_unsplit_map` | `src/Data/Map/NonEmpty.hs:1901` | `patch` | `9d516da493bb02edfefc66fba03b2736f19b50ab` |
| 8 | `neseq_intersperse_singleton_90ad8f2_1` | `intersperse_inserts_stray_separator_on_singleton` | `src/Data/Sequence/NonEmpty.hs:957` | `patch` | `90ad8f20e1dfeb164766825d8744e8cafea537a6` |

## Property Mapping

| Variant | Property | Witness(es) |
|---------|----------|-------------|
| `delete_max_neintmap_singleton_ccc4283_2` | `DeleteMaxNeIntMapKeysShrink` | `witness_delete_max_neintmap_keys_shrink_case_singleton`, `witness_delete_max_neintmap_keys_shrink_case_two_elem` |
| `delete_max_neintset_singleton_ccc4283_4` | `DeleteMaxNeIntSetShrink` | `witness_delete_max_neintset_shrink_case_singleton`, `witness_delete_max_neintset_shrink_case_two_elem` |
| `delete_max_nemap_singleton_ccc4283_1` | `DeleteMaxNeMapKeysShrink` | `witness_delete_max_nemap_keys_shrink_case_singleton`, `witness_delete_max_nemap_keys_shrink_case_two_elem` |
| `delete_max_neset_singleton_ccc4283_3` | `DeleteMaxNeSetShrink` | `witness_delete_max_neset_shrink_case_singleton`, `witness_delete_max_neset_shrink_case_two_elem` |
| `neintmap_updlookup_return_23a26d6_1` | `UpdateLookupReturnsOriginal` | `witness_update_lookup_returns_original_case_delete`, `witness_update_lookup_returns_original_case_update` |
| `nemap_issubmap_swap_967de8b_1` | `IsSubmapOfReflexiveAndKeyExists` | `witness_is_submap_of_reflexive_and_key_exists_case_self_singleton`, `witness_is_submap_of_reflexive_and_key_exists_case_disjoint_keys` |
| `nemap_split_gt_9d516da_1` | `SplitLeftPartitionAtUpperBound` | `witness_split_left_partition_at_upper_bound_case_three`, `witness_split_left_partition_at_upper_bound_case_two` |
| `neseq_intersperse_singleton_90ad8f2_1` | `IntersperseLengthInvariant` | `witness_intersperse_length_invariant_case_singleton`, `witness_intersperse_length_invariant_case_two_elem` |

## Framework Coverage

| Property | quickcheck | hedgehog | falsify | smallcheck |
|----------|---------:|-------:|------:|---------:|
| `DeleteMaxNeIntMapKeysShrink` | ✓ | ✓ | ✓ | ✓ |
| `DeleteMaxNeIntSetShrink` | ✓ | ✓ | ✓ | ✓ |
| `DeleteMaxNeMapKeysShrink` | ✓ | ✓ | ✓ | ✓ |
| `DeleteMaxNeSetShrink` | ✓ | ✓ | ✓ | ✓ |
| `UpdateLookupReturnsOriginal` | ✓ | ✓ | ✓ | ✓ |
| `IsSubmapOfReflexiveAndKeyExists` | ✓ | ✓ | ✓ | ✓ |
| `SplitLeftPartitionAtUpperBound` | ✓ | ✓ | ✓ | ✓ |
| `IntersperseLengthInvariant` | ✓ | ✓ | ✓ | ✓ |

## Bug Details

### 1. deleteMax_neintmap_returns_singleton

- **Variant**: `delete_max_neintmap_singleton_ccc4283_2`
- **Location**: `src/Data/IntMap/NonEmpty.hs:1822` (inside `deleteMax`)
- **Property**: `DeleteMaxNeIntMapKeysShrink`
- **Witness(es)**:
  - `witness_delete_max_neintmap_keys_shrink_case_singleton` — deleteMax (singleton 5 'a') must equal IM.empty
  - `witness_delete_max_neintmap_keys_shrink_case_two_elem` — deleteMax (fromList ((5,'a') :| [(3,'b')])) must equal IM.singleton 3 'b'
- **Source**: internal — v0.3.4.3 fix functions on singleton containers (NEIntMap.deleteMax slice)
  > Same bug shape as Variant 1, but in NEIntMap rather than NEMap. The buggy `insertMinMap k v . M.deleteMax` pattern returns the singleton instead of the empty IntMap when the inner IntMap is empty.
- **Fix commit**: `ccc4283f48592efe47b41d2f44330cbadfa73e4d` — v0.3.4.3 fix functions on singleton containers (NEIntMap.deleteMax slice)
- **Invariant violated**: For any non-empty NEIntMap, NEIntMap.deleteMax must return an IntMap whose key-set is the original key-set minus the maximum key. In particular, deleteMax (singleton k v) must equal IM.empty.
- **How the mutation triggers**: Reverse-applying the patch reintroduces the buggy insertMinMap-after-deleteMax pattern. deleteMax on a singleton then returns IM.singleton k v instead of IM.empty.

### 2. deleteMax_neintset_returns_singleton

- **Variant**: `delete_max_neintset_singleton_ccc4283_4`
- **Location**: `src/Data/IntSet/NonEmpty.hs:709` (inside `deleteMax`)
- **Property**: `DeleteMaxNeIntSetShrink`
- **Witness(es)**:
  - `witness_delete_max_neintset_shrink_case_singleton` — deleteMax (singleton 5) must equal IS.empty
  - `witness_delete_max_neintset_shrink_case_two_elem` — deleteMax (fromList (5 :| [3])) must equal IS.singleton 3
- **Source**: internal — v0.3.4.3 fix functions on singleton containers (NEIntSet.deleteMax slice)
  > IntSet analogue of Variant 1.
- **Fix commit**: `ccc4283f48592efe47b41d2f44330cbadfa73e4d` — v0.3.4.3 fix functions on singleton containers (NEIntSet.deleteMax slice)
- **Invariant violated**: For any non-empty NEIntSet, NEIntSet.deleteMax must return an IntSet whose elements are the originals minus the maximum. In particular, deleteMax (singleton x) must equal IS.empty.
- **How the mutation triggers**: Reverse-applying the patch makes deleteMax (singleton x) yield IS.singleton x instead of IS.empty.

### 3. deleteMax_returns_singleton

- **Variant**: `delete_max_nemap_singleton_ccc4283_1`
- **Location**: `src/Data/Map/NonEmpty.hs:2228` (inside `deleteMax`)
- **Property**: `DeleteMaxNeMapKeysShrink`
- **Witness(es)**:
  - `witness_delete_max_nemap_keys_shrink_case_singleton` — deleteMax (singleton 5 'a') must equal M.empty
  - `witness_delete_max_nemap_keys_shrink_case_two_elem` — deleteMax (fromList ((5,'a') :| [(3,'b')])) must equal M.singleton 3 'b'
- **Source**: internal — v0.3.4.3 fix functions on singleton containers (NEMap.deleteMax slice)
  > deleteMax was implemented as `insertMinMap k v . M.deleteMax`. On a singleton NEMap whose inner Map is empty, M.deleteMax is a no-op and the head (k,v) is re-inserted, so the result is the singleton itself instead of the empty Map. The fix uses M.maxView to detect the empty-inner case and short-circuits to M.empty.
- **Fix commit**: `ccc4283f48592efe47b41d2f44330cbadfa73e4d` — v0.3.4.3 fix functions on singleton containers (NEMap.deleteMax slice)
- **Invariant violated**: For any non-empty NEMap, NEMap.deleteMax must return a Map whose key-set is the original key-set minus the maximum key. In particular, deleteMax (singleton k v) must equal M.empty.
- **How the mutation triggers**: Reverse-applying the patch swaps the case-on-maxView definition for `insertMinMap k v . M.deleteMax`. Calling deleteMax on a singleton then yields M.singleton k v instead of M.empty.

### 4. deleteMax_neset_returns_singleton

- **Variant**: `delete_max_neset_singleton_ccc4283_3`
- **Location**: `src/Data/Set/NonEmpty.hs:994` (inside `deleteMax`)
- **Property**: `DeleteMaxNeSetShrink`
- **Witness(es)**:
  - `witness_delete_max_neset_shrink_case_singleton` — deleteMax (singleton 5) must equal S.empty
  - `witness_delete_max_neset_shrink_case_two_elem` — deleteMax (fromList (5 :| [3])) must equal S.singleton 3
- **Source**: internal — v0.3.4.3 fix functions on singleton containers (NESet.deleteMax slice)
  > Set analogue of Variant 1. `insertMinSet x . S.deleteMax` returns the singleton when the inner Set is empty rather than S.empty.
- **Fix commit**: `ccc4283f48592efe47b41d2f44330cbadfa73e4d` — v0.3.4.3 fix functions on singleton containers (NESet.deleteMax slice)
- **Invariant violated**: For any non-empty NESet, NESet.deleteMax must return a Set whose elements are the originals minus the maximum. In particular, deleteMax (singleton x) must equal S.empty.
- **How the mutation triggers**: Reverse-applying the patch makes deleteMax (singleton x) yield S.singleton x instead of S.empty.

### 5. updateLookupWithKey_returns_post_update_value

- **Variant**: `neintmap_updlookup_return_23a26d6_1`
- **Location**: `src/Data/IntMap/NonEmpty.hs:680` (inside `updateLookupWithKey`)
- **Property**: `UpdateLookupReturnsOriginal`
- **Witness(es)**:
  - `witness_update_lookup_returns_original_case_delete` — updateLookupWithKey (\_ _ -> Nothing) 5 (singleton 5 'a') must yield (Just 'a', _) — original value, not Nothing
  - `witness_update_lookup_returns_original_case_update` — updateLookupWithKey (\_ _ -> Just 'z') 5 (singleton 5 'a') must yield (Just 'a', _) — original 'a', not updated 'z'
- **Source**: internal — fix all tests (NEIntMap.updateLookupWithKey return value slice)
  > NEIntMap.updateLookupWithKey in the EQ branch returned `f k0 v` (the post-update value, i.e. Nothing if f deletes or Just newValue otherwise). The Data.Map convention is to return `Just v` — the *original* value at the key — regardless. The fix evaluates `f k0 v` once for the new map and returns `Just v` for the lookup component.
- **Fix commit**: `23a26d6ebed7ea58cb76c73f5f4fc8d7ea3d960c` — fix all tests (NEIntMap.updateLookupWithKey return value slice)
- **Invariant violated**: For any NEIntMap n with k present, updateLookupWithKey f k n must return (Just v_original, _) where v_original is n's value at k, irrespective of what f returns.
- **How the mutation triggers**: Reverse-applying the patch makes updateLookupWithKey return `f k0 v` for the lookup slot — Nothing when f decides to delete, or `Just (newValue)` when f decides to update — instead of the original `Just v`.

### 6. isSubmapOfBy_argument_order_swapped

- **Variant**: `nemap_issubmap_swap_967de8b_1`
- **Location**: `src/Data/Map/NonEmpty.hs:1982` (inside `isSubmapOfBy`)
- **Property**: `IsSubmapOfReflexiveAndKeyExists`
- **Witness(es)**:
  - `witness_is_submap_of_reflexive_and_key_exists_case_self_singleton` — isSubmapOfBy (==) (singleton 1 'a') (singleton 1 'a') must equal True
  - `witness_is_submap_of_reflexive_and_key_exists_case_disjoint_keys` — isSubmapOfBy (==) (singleton 1 'a') (singleton 2 'b') must equal False
- **Source**: internal — fixed all stability errors exposed by tests! (NEMap.isSubmapOfBy slice)
  > isSubmapOfBy was destructuring the wrong argument: it kept the first as a Map (toMap) and pulled the head off the second (NEMap k v m1). The lookup probed the wrong map, the M.isSubmapOfBy call ran with arguments swapped, and the f-comparison ran with operands flipped. Net effect: the function tested the inverse relation.
- **Fix commit**: `967de8bd14a008fe155152b8a8d596680a3196d6` — fixed all stability errors exposed by tests! (NEMap.isSubmapOfBy slice)
- **Invariant violated**: For any NEMap a, isSubmapOfBy (==) a a must be True (every map is a submap of itself). Additionally, if a's head key is not in b's keys, isSubmapOfBy (==) a b must be False.
- **How the mutation triggers**: Reverse-applying the patch reintroduces the swapped operand pattern. isSubmapOfBy (==) (singleton 1 'a') (singleton 2 'b') yields True (incorrect — head 1 is not in the second map's keys) and isSubmapOfBy (==) (singleton 1 'a') (singleton 1 'a') yields False (incorrect — anything is a submap of itself).

### 7. split_gt_returns_unsplit_map

- **Variant**: `nemap_split_gt_9d516da_1`
- **Location**: `src/Data/Map/NonEmpty.hs:1901` (inside `split`)
- **Property**: `SplitLeftPartitionAtUpperBound`
- **Witness(es)**:
  - `witness_split_left_partition_at_upper_bound_case_three` — split 100 (fromList ((5,'a') :| [(3,'b'), (7,'c')])) must keep all 3 entries on the left side
  - `witness_split_left_partition_at_upper_bound_case_two` — split 50 (fromList ((5,'a') :| [(3,'b')])) must keep both entries on the left
- **Source**: internal — fix the bugs! (NEMap.split GT branch slice)
  > In the GT branch of NEMap.split (k > k0), when M.split's right side is empty but the left side is non-empty, the buggy code returned the entire input NEMap (`This n`). The corrected behaviour rebuilds just the left side from m1 with the original head re-inserted at the minimum position.
- **Fix commit**: `9d516da493bb02edfefc66fba03b2736f19b50ab` — fix the bugs! (NEMap.split GT branch slice)
- **Invariant violated**: For any NEMap n and key k strictly larger than every key in n, split k n must return Just (This (NEMap with head k0 and original tail keys < k)).
- **How the mutation triggers**: Reverse-applying the patch makes split k n in the (Just _, Nothing) case yield `This n` instead of `This (insertMapMin k0 v m1)`. The two values can differ when M.split removes a maximal-key entry equal to or greater than the upper neighbours that the original map had.

### 8. intersperse_inserts_stray_separator_on_singleton

- **Variant**: `neseq_intersperse_singleton_90ad8f2_1`
- **Location**: `src/Data/Sequence/NonEmpty.hs:957` (inside `intersperse`)
- **Property**: `IntersperseLengthInvariant`
- **Witness(es)**:
  - `witness_intersperse_length_invariant_case_singleton` — intersperse 0 (singleton 5) must have length 1
  - `witness_intersperse_length_invariant_case_two_elem` — intersperse 0 (fromList (5 :| [7])) must have length 3
- **Source**: internal — fix NESeq.intersperse
  > NESeq.intersperse on a singleton inserted a stray separator. The buggy form `intersperse z (x :<|| xs) = x :<|| (z Seq.<| Seq.intersperse z xs)` unconditionally cons'd the separator z. For a singleton (x :<|| Seq.Empty), it produced (x, z) instead of just (x). The fix case-splits on xs and only intersperses when xs is non-empty.
- **Fix commit**: `90ad8f20e1dfeb164766825d8744e8cafea537a6` — fix NESeq.intersperse
- **Invariant violated**: intersperse z (singleton x) must equal singleton x. More generally, intersperse must produce a sequence of length 2*n - 1 for input length n, never 2*n.
- **How the mutation triggers**: Reverse-applying the patch makes intersperse z (singleton x) produce a length-2 NESeq (x, z) instead of length-1 (x).
