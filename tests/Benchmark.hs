{-# OPTIONS -fbang-patterns #-}
module Main where

import qualified Data.ByteString.Lazy as L
import Data.Binary
import Data.Binary.Put
import Text.Printf

import Control.Exception
import System.CPUTime


main :: IO ()
main = do
    word8
    word16
    word32
    word64

time :: String -> IO a -> IO a
time label f = do
    putStr (label ++ " ")
    start <- getCPUTime
    v     <- f
    end   <- getCPUTime
    let diff = (fromIntegral (end - start)) / (10^12)
    printf "%0.4f\n" (diff :: Double)
    return v

test label f n fs s = time label $ do
    let bs = runPut (doN (n :: Int) fs s f)
    evaluate (L.length bs)
    return ()

doN :: Int -> (t2 -> t2) -> t2 -> (t2 -> Put) -> Put
doN 0 _ _ _ = return ()
doN !n !f !s !body = do
    body s
    doN (n-1) f (f s) body

word8  = test "Word8  10MB" putWord8    10000000 (+1) 0
word16 = test "Word16 10MB" putWord16be  5000000 (+1) 0
word32 = test "Word32 10MB" putWord32be  2500000 (+1) 0
word64 = test "Word64 10MB" putWord64be  1250000 (+1) 0

