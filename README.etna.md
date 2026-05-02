# nonempty-containers — ETNA workload

This directory is a fork of [mstksg/nonempty-containers][upstream] (BSD-3
licensed) wrapped as an ETNA workload. The upstream library provides
non-empty variants of `Data.Map`, `Data.IntMap`, `Data.Set`,
`Data.IntSet`, and `Data.Sequence`. Modern HEAD (commit
`001d6a890228f9dc852a912d1b2412b946e470e3`) is the *base* — every variant
under [`patches/`](patches/) reverse-applies a historical bug fix to
re-introduce the original bug for benchmarking purposes.

[upstream]: https://github.com/mstksg/nonempty-containers

## Summary

| | |
|---|---|
| Language | Haskell (GHC 9.6.6) |
| Backends | QuickCheck, Hedgehog, Falsify, SmallCheck |
| Variants | 8 (one bug per `patches/*.patch`) |
| Properties | 8 |
| Witnesses | 16 (2 per property) |
| Detection rate | 40/40 — every backend detects every variant |

## Variants

| Variant | Bug | Fix commit |
|---|---|---|
| `delete_max_nemap_singleton_ccc4283_1`   | `NEMap.deleteMax` returns the singleton instead of empty when the inner Map is empty | `ccc4283` |
| `delete_max_neintmap_singleton_ccc4283_2` | `NEIntMap.deleteMax` — same shape as above for IntMap | `ccc4283` |
| `delete_max_neset_singleton_ccc4283_3`    | `NESet.deleteMax` — same shape for Set | `ccc4283` |
| `delete_max_neintset_singleton_ccc4283_4` | `NEIntSet.deleteMax` — same shape for IntSet | `ccc4283` |
| `neseq_intersperse_singleton_90ad8f2_1`   | `NESeq.intersperse` inserts a stray separator on a singleton sequence | `90ad8f2` |
| `nemap_split_gt_9d516da_1`                | `NEMap.split` GT branch returns the whole input map instead of the proper left partition when the split key equals the max | `9d516da` |
| `nemap_issubmap_swap_967de8b_1`           | `NEMap.isSubmapOfBy` operands swapped — tests the inverse relation | `967de8b` |
| `neintmap_updlookup_return_23a26d6_1`     | `NEIntMap.updateLookupWithKey` returns the post-update value instead of the original | `23a26d6` |

The `ccc4283` commit was a single upstream fix touching four parallel
APIs; we mine each as its own variant so each container family
(`NEMap`, `NEIntMap`, `NESet`, `NEIntSet`) contributes an
independently-detectable bug.

## Layout

```
.                                       # upstream fork (do not edit upstream files)
├── cabal.project                       # ours — pins both upstream lib and etna/
├── etna.toml                           # ours — manifest (single source of truth)
├── patches/<variant>.patch             # ours — one git-format-patch per variant
├── etna/                               # ours — runner package
│   ├── etna-runner.cabal
│   ├── src/Etna/{Result,Properties,Witnesses}.hs
│   ├── src/Etna/Gens/{QuickCheck,Hedgehog,Falsify,SmallCheck}.hs
│   ├── app/Main.hs                     # CLI dispatcher
│   └── test/Witnesses.hs               # cabal test-suite asserting base passes
├── BUGS.md                             # generated, do not hand-edit
├── TASKS.md                            # generated, do not hand-edit
└── progress.jsonl                      # generated per-run scratch
```

## Running locally

```sh
# from the workload root:
cabal build all                                    # build upstream lib + runner
cabal test  etna-witnesses                         # all 16 witnesses pass on base

# Inside etna/:
cabal run -v0 etna-runner -- quickcheck DeleteMaxNeMapKeysShrink
# {"status":"passed","tests":200,"discards":0,"time":"1ms",...}

# Install bug, observe failure, restore:
git apply -R --whitespace=nowarn patches/delete_max_nemap_singleton_ccc4283_1.patch
( cd etna && cabal run -v0 etna-runner -- quickcheck DeleteMaxNeMapKeysShrink )
# {"status":"failed","tests":1,"counterexample":"...",...}
git apply --whitespace=nowarn patches/delete_max_nemap_singleton_ccc4283_1.patch
```

## GHC toolchain

The project pins GHC 9.6.6 via `cabal.project`'s `with-compiler` field.
Falsify ≥ 0.2 requires `base >= 4.18` (GHC ≥ 9.6); older toolchains will
not resolve. Install GHC 9.6.6 via `ghcup install ghc 9.6.6` if missing.

## Source contract notes

- `Etna.Properties` defines one `property_<snake>` per variant. Pure,
  total, deterministic — no `IO`.
- `Etna.Witnesses` defines two `witness_<snake>_case_<tag>` values per
  property. Each evaluates the property at frozen inputs, equals `Pass`
  on base, and equals `Fail _` after reverse-applying the variant patch.
- `Etna.Gens.*` define one generator per property per backend. The four
  generator modules share the `Args` types from `Etna.Properties` but
  use each framework's native generator API.
- `app/Main.hs` is the dispatcher. `etna-runner <tool> <property>` emits
  one JSON line on stdout and exits 0 (except on argv-parse error).
  Hedgehog's `check` writes a status line to stdout that would corrupt
  the JSON contract; the runner silences stdout for the duration of the
  Hedgehog call via `dup2` on `/dev/null`.
