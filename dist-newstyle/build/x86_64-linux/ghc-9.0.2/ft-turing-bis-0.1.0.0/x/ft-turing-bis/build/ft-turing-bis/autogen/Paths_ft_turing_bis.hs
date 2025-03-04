{-# LANGUAGE CPP #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-import-lists #-}
{-# OPTIONS_GHC -Wno-missing-safe-haskell-mode #-}
module Paths_ft_turing_bis (
    version,
    getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir,
    getDataFileName, getSysconfDir
  ) where

import qualified Control.Exception as Exception
import Data.Version (Version(..))
import System.Environment (getEnv)
import Prelude

#if defined(VERSION_base)

#if MIN_VERSION_base(4,0,0)
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#else
catchIO :: IO a -> (Exception.Exception -> IO a) -> IO a
#endif

#else
catchIO :: IO a -> (Exception.IOException -> IO a) -> IO a
#endif
catchIO = Exception.catch

version :: Version
version = Version [0,1,0,0] []
bindir, libdir, dynlibdir, datadir, libexecdir, sysconfdir :: FilePath

bindir     = "/home/wmonachon/.cabal/bin"
libdir     = "/home/wmonachon/.cabal/lib/x86_64-linux-ghc-9.0.2/ft-turing-bis-0.1.0.0-inplace-ft-turing-bis"
dynlibdir  = "/home/wmonachon/.cabal/lib/x86_64-linux-ghc-9.0.2"
datadir    = "/home/wmonachon/.cabal/share/x86_64-linux-ghc-9.0.2/ft-turing-bis-0.1.0.0"
libexecdir = "/home/wmonachon/.cabal/libexec/x86_64-linux-ghc-9.0.2/ft-turing-bis-0.1.0.0"
sysconfdir = "/home/wmonachon/.cabal/etc"

getBinDir, getLibDir, getDynLibDir, getDataDir, getLibexecDir, getSysconfDir :: IO FilePath
getBinDir = catchIO (getEnv "ft_turing_bis_bindir") (\_ -> return bindir)
getLibDir = catchIO (getEnv "ft_turing_bis_libdir") (\_ -> return libdir)
getDynLibDir = catchIO (getEnv "ft_turing_bis_dynlibdir") (\_ -> return dynlibdir)
getDataDir = catchIO (getEnv "ft_turing_bis_datadir") (\_ -> return datadir)
getLibexecDir = catchIO (getEnv "ft_turing_bis_libexecdir") (\_ -> return libexecdir)
getSysconfDir = catchIO (getEnv "ft_turing_bis_sysconfdir") (\_ -> return sysconfdir)

getDataFileName :: FilePath -> IO FilePath
getDataFileName name = do
  dir <- getDataDir
  return (dir ++ "/" ++ name)
