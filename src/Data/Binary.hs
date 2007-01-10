-----------------------------------------------------------------------------
-- |
-- Module      :
-- Copyright   :  (c)
-- License     :  BSD3-style (see LICENSE)
-- 
-- Maintainer  :
-- Stability   :  stable
-- Portability :  portable
--
-----------------------------------------------------------------------------

module Data.Binary (
      module Data.Binary.EncM
    , module Data.Binary.DecM
  ) where

import Data.Binary.EncM
import Data.Binary.DecM

import Control.Monad
import Foreign

class Binary t where
    put :: t -> EncM ()
    get :: DecM t

instance Binary () where
    put () = return ()
    get    = return ()

instance Binary Bool where
    put = putWord8 . fromIntegral . fromEnum
    get = liftM (toEnum . fromIntegral) getWord8

instance Binary Word8 where
    put = putWord8
    get = getWord8

instance Binary Word16 where
    put = putWord16be
    get = getWord16be

instance Binary Word32 where
    put = putWord32be
    get = getWord32be

instance Binary Word64 where
    put = putWord64be
    get = getWord64be

instance Binary Int8 where
    put i = put (fromIntegral i :: Word8)
    get = get >>= \(w::Word8) -> return $! fromIntegral w

instance Binary Int16 where
    put i = put (fromIntegral i :: Word16)
    get = get >>= \(w::Word16) -> return $! fromIntegral w

instance Binary Int32 where
    put i = put (fromIntegral i :: Word32)
    get = get >>= \(w::Word32) -> return $! fromIntegral w

instance Binary Int64 where
    put i = put (fromIntegral i :: Word64)
    get = get >>= \(w::Word64) -> return $! fromIntegral w

instance Binary Int where
    put i = put (fromIntegral i :: Int32)
    get = get >>= \(i::Int32) -> return $! fromIntegral i

instance Binary a => Binary [a] where
    put [] = putWord8 0
    put (x:xs) = putWord8 1 >> put x >> put xs
    get = do
        w <- getWord8
        case w of
            0 -> return []
            _ -> liftM2 (:) get get

instance Binary a => Binary (Maybe a) where
    put Nothing = putWord8 0
    put (Just x) = putWord8 1 >> put x
    get = do
        w <- getWord8
        case w of
            0 -> return Nothing
            _ -> liftM Just get

instance (Binary a, Binary b) => Binary (Either a b) where
    put (Left  a) = putWord8 0 >> put a
    put (Right b) = putWord8 1 >> put b
    get = do
        w <- getWord8
        case w of
            0 -> liftM Left  get
            _ -> liftM Right get
