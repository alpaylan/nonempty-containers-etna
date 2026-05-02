{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import           Control.Exception     (SomeException, try)
import           Data.IORef            (newIORef, readIORef, modifyIORef')
import           Data.Time.Clock       (diffUTCTime, getCurrentTime)
import           System.Environment    (getArgs)
import           System.Exit           (exitWith, ExitCode(..))
import           System.IO             ( hFlush, stdout
                                       , openFile, IOMode(..), hClose, hSetBuffering
                                       , BufferMode(..) )
import           GHC.IO.Handle         (hDuplicate, hDuplicateTo)
import           Text.Printf           (printf)
import           Control.Exception     (bracket)

import           Etna.Result           (PropertyResult(..))
import qualified Etna.Properties       as P
import qualified Etna.Witnesses        as W
import qualified Etna.Gens.QuickCheck  as GQ
import qualified Etna.Gens.Hedgehog    as GH
import qualified Etna.Gens.Falsify     as GF
import qualified Etna.Gens.SmallCheck  as GS

import qualified Test.QuickCheck                    as QC
import qualified Hedgehog                           as HH
import qualified Test.Falsify.Generator             as FG
import qualified Test.Falsify.Interactive           as FI
import qualified Test.Falsify.Property              as FP
import qualified Test.SmallCheck                    as SC
import qualified Test.SmallCheck.Drivers            as SCD
import qualified Test.SmallCheck.Series             as SCS

allProperties :: [String]
allProperties =
  [ "DeleteMaxNeMapKeysShrink"
  , "DeleteMaxNeIntMapKeysShrink"
  , "DeleteMaxNeSetShrink"
  , "DeleteMaxNeIntSetShrink"
  , "IntersperseLengthInvariant"
  , "SplitLeftPartitionAtUpperBound"
  , "IsSubmapOfReflexiveAndKeyExists"
  , "UpdateLookupReturnsOriginal"
  ]

data Outcome = Outcome
  { oStatus :: String
  , oTests  :: Int
  , oCex    :: Maybe String
  , oErr    :: Maybe String
  }

main :: IO ()
main = do
  argv <- getArgs
  case argv of
    [tool, prop] -> dispatch tool prop
    _            -> do
      putStrLn "{\"status\":\"aborted\",\"error\":\"usage: etna-runner <tool> <property>\"}"
      hFlush stdout
      exitWith (ExitFailure 2)

dispatch :: String -> String -> IO ()
dispatch tool prop
  | prop /= "All" && prop `notElem` allProperties =
      emit tool prop "aborted" 0 0 Nothing (Just $ "unknown property: " ++ prop)
  | otherwise = do
      let targets = if prop == "All" then allProperties else [prop]
      mapM_ (runOne tool) targets

runOne :: String -> String -> IO ()
runOne tool prop = do
  t0 <- getCurrentTime
  result <- try (driver tool prop) :: IO (Either SomeException Outcome)
  t1 <- getCurrentTime
  let us = round ((realToFrac (diffUTCTime t1 t0) :: Double) * 1e6) :: Int
  case result of
    Left e  -> emit tool prop "aborted" 0 us Nothing (Just (show e))
    Right (Outcome status tests cex err) ->
      emit tool prop status tests us cex err

driver :: String -> String -> IO Outcome
driver "etna"       p = runWitnesses p
driver "quickcheck" p = runQuickCheck p
driver "hedgehog"   p = runHedgehog   p
driver "falsify"    p = runFalsify    p
driver "smallcheck" p = runSmallCheck p
driver tool         _ = pure (Outcome "aborted" 0 Nothing (Just ("unknown tool: " ++ tool)))

------------------------------------------------------------------------------
-- Tool: etna (witness replay)
------------------------------------------------------------------------------

runWitnesses :: String -> IO Outcome
runWitnesses prop = case witnessesFor prop of
  []    -> pure (Outcome "aborted" 0 Nothing (Just ("no witnesses for " ++ prop)))
  cs    -> go cs 0
  where
    go [] n = pure (Outcome "passed" n Nothing Nothing)
    go ((name, r):rest) n = case r of
      Pass     -> go rest (n + 1)
      Discard  -> go rest (n + 1)
      Fail msg -> pure (Outcome "failed" (n + 1) (Just name) (Just msg))

witnessesFor :: String -> [(String, PropertyResult)]
witnessesFor "DeleteMaxNeMapKeysShrink" =
  [ ("witness_delete_max_nemap_keys_shrink_case_singleton", W.witness_delete_max_nemap_keys_shrink_case_singleton)
  , ("witness_delete_max_nemap_keys_shrink_case_two_elem",  W.witness_delete_max_nemap_keys_shrink_case_two_elem)
  ]
witnessesFor "DeleteMaxNeIntMapKeysShrink" =
  [ ("witness_delete_max_neintmap_keys_shrink_case_singleton", W.witness_delete_max_neintmap_keys_shrink_case_singleton)
  , ("witness_delete_max_neintmap_keys_shrink_case_two_elem",  W.witness_delete_max_neintmap_keys_shrink_case_two_elem)
  ]
witnessesFor "DeleteMaxNeSetShrink" =
  [ ("witness_delete_max_neset_shrink_case_singleton", W.witness_delete_max_neset_shrink_case_singleton)
  , ("witness_delete_max_neset_shrink_case_two_elem",  W.witness_delete_max_neset_shrink_case_two_elem)
  ]
witnessesFor "DeleteMaxNeIntSetShrink" =
  [ ("witness_delete_max_neintset_shrink_case_singleton", W.witness_delete_max_neintset_shrink_case_singleton)
  , ("witness_delete_max_neintset_shrink_case_two_elem",  W.witness_delete_max_neintset_shrink_case_two_elem)
  ]
witnessesFor "IntersperseLengthInvariant" =
  [ ("witness_intersperse_length_invariant_case_singleton", W.witness_intersperse_length_invariant_case_singleton)
  , ("witness_intersperse_length_invariant_case_two_elem",  W.witness_intersperse_length_invariant_case_two_elem)
  ]
witnessesFor "SplitLeftPartitionAtUpperBound" =
  [ ("witness_split_left_partition_at_upper_bound_case_three", W.witness_split_left_partition_at_upper_bound_case_three)
  , ("witness_split_left_partition_at_upper_bound_case_two",   W.witness_split_left_partition_at_upper_bound_case_two)
  ]
witnessesFor "IsSubmapOfReflexiveAndKeyExists" =
  [ ("witness_is_submap_of_reflexive_and_key_exists_case_self_singleton", W.witness_is_submap_of_reflexive_and_key_exists_case_self_singleton)
  , ("witness_is_submap_of_reflexive_and_key_exists_case_disjoint_keys",  W.witness_is_submap_of_reflexive_and_key_exists_case_disjoint_keys)
  ]
witnessesFor "UpdateLookupReturnsOriginal" =
  [ ("witness_update_lookup_returns_original_case_delete", W.witness_update_lookup_returns_original_case_delete)
  , ("witness_update_lookup_returns_original_case_update", W.witness_update_lookup_returns_original_case_update)
  ]
witnessesFor _ = []

------------------------------------------------------------------------------
-- Tool: quickcheck
------------------------------------------------------------------------------

runQuickCheck :: String -> IO Outcome
runQuickCheck "DeleteMaxNeMapKeysShrink" =
  qcDrive (QC.forAll GQ.gen_delete_max_ne_map_keys_shrink (qcProp P.property_delete_max_ne_map_keys_shrink))
runQuickCheck "DeleteMaxNeIntMapKeysShrink" =
  qcDrive (QC.forAll GQ.gen_delete_max_ne_int_map_keys_shrink (qcProp P.property_delete_max_ne_int_map_keys_shrink))
runQuickCheck "DeleteMaxNeSetShrink" =
  qcDrive (QC.forAll GQ.gen_delete_max_ne_set_shrink (qcProp P.property_delete_max_ne_set_shrink))
runQuickCheck "DeleteMaxNeIntSetShrink" =
  qcDrive (QC.forAll GQ.gen_delete_max_ne_int_set_shrink (qcProp P.property_delete_max_ne_int_set_shrink))
runQuickCheck "IntersperseLengthInvariant" =
  qcDrive (QC.forAll GQ.gen_intersperse_length_invariant (qcProp P.property_intersperse_length_invariant))
runQuickCheck "SplitLeftPartitionAtUpperBound" =
  qcDrive (QC.forAll GQ.gen_split_left_partition_at_upper_bound (qcProp P.property_split_left_partition_at_upper_bound))
runQuickCheck "IsSubmapOfReflexiveAndKeyExists" =
  qcDrive (QC.forAll GQ.gen_is_submap_of_reflexive_and_key_exists (qcProp P.property_is_submap_of_reflexive_and_key_exists))
runQuickCheck "UpdateLookupReturnsOriginal" =
  qcDrive (QC.forAll GQ.gen_update_lookup_returns_original (qcProp P.property_update_lookup_returns_original))
runQuickCheck p = pure (Outcome "aborted" 0 Nothing (Just ("unknown property: " ++ p)))

qcProp :: (a -> PropertyResult) -> a -> QC.Property
qcProp f args = case f args of
  Pass     -> QC.property True
  Discard  -> QC.discard
  Fail msg -> QC.counterexample msg (QC.property False)

qcDrive :: QC.Property -> IO Outcome
qcDrive p = do
  result <- QC.quickCheckWithResult
              QC.stdArgs { QC.maxSuccess = 200, QC.chatty = False }
              p
  case result of
    QC.Success { QC.numTests = n } -> pure (Outcome "passed" n Nothing Nothing)
    QC.Failure { QC.numTests = n, QC.failingTestCase = tc } ->
      pure (Outcome "failed" n (Just (concat tc)) Nothing)
    QC.GaveUp  { QC.numTests = n } -> pure (Outcome "aborted" n Nothing (Just "QuickCheck gave up"))
    QC.NoExpectedFailure { QC.numTests = n } ->
      pure (Outcome "aborted" n Nothing (Just "no expected failure"))

------------------------------------------------------------------------------
-- Tool: hedgehog
------------------------------------------------------------------------------

runHedgehog :: String -> IO Outcome
runHedgehog "DeleteMaxNeMapKeysShrink" =
  hhDrive GH.gen_delete_max_ne_map_keys_shrink P.property_delete_max_ne_map_keys_shrink
runHedgehog "DeleteMaxNeIntMapKeysShrink" =
  hhDrive GH.gen_delete_max_ne_int_map_keys_shrink P.property_delete_max_ne_int_map_keys_shrink
runHedgehog "DeleteMaxNeSetShrink" =
  hhDrive GH.gen_delete_max_ne_set_shrink P.property_delete_max_ne_set_shrink
runHedgehog "DeleteMaxNeIntSetShrink" =
  hhDrive GH.gen_delete_max_ne_int_set_shrink P.property_delete_max_ne_int_set_shrink
runHedgehog "IntersperseLengthInvariant" =
  hhDrive GH.gen_intersperse_length_invariant P.property_intersperse_length_invariant
runHedgehog "SplitLeftPartitionAtUpperBound" =
  hhDrive GH.gen_split_left_partition_at_upper_bound P.property_split_left_partition_at_upper_bound
runHedgehog "IsSubmapOfReflexiveAndKeyExists" =
  hhDrive GH.gen_is_submap_of_reflexive_and_key_exists P.property_is_submap_of_reflexive_and_key_exists
runHedgehog "UpdateLookupReturnsOriginal" =
  hhDrive GH.gen_update_lookup_returns_original P.property_update_lookup_returns_original
runHedgehog p = pure (Outcome "aborted" 0 Nothing (Just ("unknown property: " ++ p)))

hhDrive
  :: (Show a) => HH.Gen a -> (a -> PropertyResult) -> IO Outcome
hhDrive gen f = do
  let test = HH.property $ do
        args <- HH.forAll gen
        case f args of
          Pass     -> pure ()
          Discard  -> HH.discard
          Fail msg -> do
            HH.annotate msg
            HH.failure
  ok <- silencingStdout (HH.check test)
  if ok
    then pure (Outcome "passed" 200 Nothing Nothing)
    else pure (Outcome "failed" 1 Nothing Nothing)

-- | Run an IO action with stdout redirected to /dev/null. Hedgehog's
-- public `check` writes a progress line to stdout that would corrupt the
-- single-JSON-line contract; silencing the call keeps the contract clean.
silencingStdout :: IO a -> IO a
silencingStdout act =
  bracket
    (do hFlush stdout
        saved <- hDuplicate stdout
        nullH <- openFile "/dev/null" WriteMode
        hSetBuffering nullH NoBuffering
        hDuplicateTo nullH stdout
        hClose nullH
        pure saved)
    (\saved -> do
        hFlush stdout
        hDuplicateTo saved stdout
        hClose saved)
    (const act)

------------------------------------------------------------------------------
-- Tool: falsify
------------------------------------------------------------------------------

runFalsify :: String -> IO Outcome
runFalsify "DeleteMaxNeMapKeysShrink" =
  fsDrive GF.gen_delete_max_ne_map_keys_shrink P.property_delete_max_ne_map_keys_shrink
runFalsify "DeleteMaxNeIntMapKeysShrink" =
  fsDrive GF.gen_delete_max_ne_int_map_keys_shrink P.property_delete_max_ne_int_map_keys_shrink
runFalsify "DeleteMaxNeSetShrink" =
  fsDrive GF.gen_delete_max_ne_set_shrink P.property_delete_max_ne_set_shrink
runFalsify "DeleteMaxNeIntSetShrink" =
  fsDrive GF.gen_delete_max_ne_int_set_shrink P.property_delete_max_ne_int_set_shrink
runFalsify "IntersperseLengthInvariant" =
  fsDrive GF.gen_intersperse_length_invariant P.property_intersperse_length_invariant
runFalsify "SplitLeftPartitionAtUpperBound" =
  fsDrive GF.gen_split_left_partition_at_upper_bound P.property_split_left_partition_at_upper_bound
runFalsify "IsSubmapOfReflexiveAndKeyExists" =
  fsDrive GF.gen_is_submap_of_reflexive_and_key_exists P.property_is_submap_of_reflexive_and_key_exists
runFalsify "UpdateLookupReturnsOriginal" =
  fsDrive GF.gen_update_lookup_returns_original P.property_update_lookup_returns_original
runFalsify p = pure (Outcome "aborted" 0 Nothing (Just ("unknown property: " ++ p)))

fsDrive
  :: (Show a)
  => FG.Gen a
  -> (a -> PropertyResult)
  -> IO Outcome
fsDrive gen f = do
  let prop = do
        args <- FP.gen gen
        case f args of
          Pass     -> pure ()
          Discard  -> FP.discard
          Fail msg -> FP.testFailed (show args ++ ": " ++ msg)
  mFailure <- FI.falsify prop
  case mFailure of
    Nothing  -> pure (Outcome "passed" 100 Nothing Nothing)
    Just msg -> pure (Outcome "failed" 1 (Just msg) Nothing)

------------------------------------------------------------------------------
-- Tool: smallcheck
------------------------------------------------------------------------------

runSmallCheck :: String -> IO Outcome
runSmallCheck "DeleteMaxNeMapKeysShrink" =
  scDrive GS.series_delete_max_ne_map_keys_shrink P.property_delete_max_ne_map_keys_shrink
runSmallCheck "DeleteMaxNeIntMapKeysShrink" =
  scDrive GS.series_delete_max_ne_int_map_keys_shrink P.property_delete_max_ne_int_map_keys_shrink
runSmallCheck "DeleteMaxNeSetShrink" =
  scDrive GS.series_delete_max_ne_set_shrink P.property_delete_max_ne_set_shrink
runSmallCheck "DeleteMaxNeIntSetShrink" =
  scDrive GS.series_delete_max_ne_int_set_shrink P.property_delete_max_ne_int_set_shrink
runSmallCheck "IntersperseLengthInvariant" =
  scDrive GS.series_intersperse_length_invariant P.property_intersperse_length_invariant
runSmallCheck "SplitLeftPartitionAtUpperBound" =
  scDrive GS.series_split_left_partition_at_upper_bound P.property_split_left_partition_at_upper_bound
runSmallCheck "IsSubmapOfReflexiveAndKeyExists" =
  scDrive GS.series_is_submap_of_reflexive_and_key_exists P.property_is_submap_of_reflexive_and_key_exists
runSmallCheck "UpdateLookupReturnsOriginal" =
  scDrive GS.series_update_lookup_returns_original P.property_update_lookup_returns_original
runSmallCheck p = pure (Outcome "aborted" 0 Nothing (Just ("unknown property: " ++ p)))

scDrive
  :: (Show a)
  => SCS.Series IO a
  -> (a -> PropertyResult)
  -> IO Outcome
scDrive series f = do
  countRef <- newIORef (0 :: Int)
  let depth = 5
      check args = SC.monadic $ do
        modifyIORef' countRef (+1)
        pure $ case f args of
          Pass    -> True
          Discard -> True
          Fail _  -> False
      smTest = SC.over series check
  res <- try (SCD.smallCheckM depth smTest)
           :: IO (Either SomeException (Maybe SCD.PropertyFailure))
  n <- readIORef countRef
  case res of
    Left e          -> pure (Outcome "failed" n Nothing (Just (show e)))
    Right Nothing   -> pure (Outcome "passed" n Nothing Nothing)
    Right (Just pf) -> pure (Outcome "failed" n (Just (show pf)) Nothing)

------------------------------------------------------------------------------
-- Output (single JSON line, exit 0 except on argv error)
------------------------------------------------------------------------------

emit :: String -> String -> String -> Int -> Int -> Maybe String -> Maybe String -> IO ()
emit tool prop status tests us cex err = do
  let q = quoteJSON
      esc Nothing  = "null"
      esc (Just s) = q s
  printf "{\"status\":%s,\"tests\":%d,\"discards\":0,\"time\":\"%dus\",\"counterexample\":%s,\"error\":%s,\"tool\":%s,\"property\":%s}\n"
    (q status) tests us (esc cex) (esc err) (q tool) (q prop)
  hFlush stdout

quoteJSON :: String -> String
quoteJSON s = '"' : concatMap esc s ++ "\""
  where
    esc '"'  = "\\\""
    esc '\\' = "\\\\"
    esc '\n' = "\\n"
    esc '\r' = "\\r"
    esc '\t' = "\\t"
    esc c | fromEnum c < 0x20 = printf "\\u%04x" (fromEnum c)
          | otherwise = [c]
