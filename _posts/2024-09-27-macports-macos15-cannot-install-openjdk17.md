---
layout: page_with_comment
title: "Error when installing openjdk17 and openjdk20 after upgrading to macports 2.10 and macOS 15.0 Sequoia"
date: "2024-09-27"
tags:
  - "macports"
  - "openjdk"
  - "java"
  - "muniversal"
---

I was trying to install openjdk17 and openjdk20 after upgrading to macports 2.10 and macOS 15 Sequoia

```bash
 % sudo port install openjdk17 openjdk20
```

I encountered error `configure: error: Cannot find a type to use in place of socklen_t` when installing dependency diffutils-for-muniversal. 
I found this ticket https://trac.macports.org/ticket/64135 which described same error for grep and this fix https://github.com/macports/macports-ports/commit/97cf17c350a02266e5a52316c808088d6a1126ff to add `PortGroup       muniversal 1.1` to grep Portfile

I believe I need to patch `/opt/local/var/macports/sources/rsync.macports.org/macports/release/tarballs/ports/sysutils/diffutils-for-muniversal/Portfile` by adding `PortGroup          muniversal 1.1` to Portfile

```m4
PortSystem          1.0
PortGroup          muniversal 1.1

name                diffutils-for-muniversal
version             3.8
revision            0
platforms           {darwin >= 22}
```

then I can install diffutils-for-muniversal successfully

```bash
 % sudo port install diffutils-for-muniversal                                                                        
Portfile for diffutils-for-muniversal changed since last build; discarding previous state.
--->  Fetching archive for diffutils-for-muniversal
--->  Attempting to fetch diffutils-for-muniversal-3.8_0.darwin_24.arm64.tbz2 from https://packages.macports.org/diffutils-for-muniversal
--->  Attempting to fetch diffutils-for-muniversal-3.8_0.darwin_24.arm64.tbz2 from http://mirror.fcix.net/macports/packages/diffutils-for-muniversal
--->  Attempting to fetch diffutils-for-muniversal-3.8_0.darwin_24.arm64.tbz2 from https://ywg.ca.packages.macports.org/mirror/macports/packages/diffutils-for-muniversal
--->  Fetching distfiles for diffutils-for-muniversal
--->  Verifying checksums for diffutils-for-muniversal
--->  Extracting diffutils-for-muniversal
--->  Configuring diffutils-for-muniversal
Warning: Configuration logfiles contain indications of -Wimplicit-function-declaration; check that features were not accidentally disabled:
  MIN: found in diffutils-3.8/config.log
  re_set_syntax: found in diffutils-3.8/config.log
  re_compile_pattern: found in diffutils-3.8/config.log
  re_search: found in diffutils-3.8/config.log
--->  Building diffutils-for-muniversal
--->  Staging diffutils-for-muniversal into destroot     
--->  Installing diffutils-for-muniversal @3.8_0         
--->  Activating diffutils-for-muniversal @3.8_0
--->  Cleaning diffutils-for-muniversal
--->  Updating database of binaries
--->  Scanning binaries for linking errors
--->  No broken files found.                             
--->  No broken ports found.
```

then I need to install gmake

```bash
sudo port clean gmake && sudo port install gmake configure.cflags-append="-std=gnu89" build_arch=x86_64
```

and I can install openjdk but no matter

```bash
 % sudo port install openjdk17 openjdk20
```

or

```bash
 % sudo port install openjdk17 openjdk20 build_arch=x86_64
```

I see error logs

```bash
:info:build Optimizing the exploded image
:info:build #
:info:build # A fatal error has been detected by the Java Runtime Environment:
:info:build #
:info:build #  SIGSEGV (0xb) at pc=0x000000010a385934, pid=22039, tid=8963
:info:build #
:info:build # JRE version: OpenJDK Runtime Environment (17.0.12+7) (build 17.0.12+7)
:info:build # Java VM: OpenJDK 64-Bit Server VM (17.0.12+7, mixed mode, tiered, compressed oops, compressed class ptrs, g1 gc, bsd-amd64)
:info:build # Problematic frame:
:info:build # V  [libjvm.dylib+0x3e8934]  G1CollectedHeap::used_unlocked() const+0x4
:info:build #
:info:build # No core dump will be written. Core dumps have been disabled. To enable core dumping, try "ulimit -c unlimited" before starting Java again
:info:build #
:info:build # An error report file with more information is saved as:
:info:build # /opt/local/var/macports/build/_opt_local_var_macports_sources_rsync.macports.org_macports_release_tarballs_ports_java_openjdk17/openjdk17/work/jdk-17.0.12+7/make/hs_err_pid22039.log
:info:build #
:info:build # If you would like to submit a bug report, please visit:
:info:build #   https://trac.macports.org/newticket?port=openjdk17
:info:build #

```

then I find this ticket https://trac.macports.org/ticket/70918 which also says openjdk17 @17.0.12+7+release+server fails to build on macOS Sequoia 15

```bash
 % sudo port install openjdk17
 % sudo port install openjdk20
```

I still get errors such as below

```bash
:info:build Optimizing the exploded image
:info:build #
:info:build # A fatal error has been detected by the Java Runtime Environment:
:info:build #
:info:build #  SIGSEGV (0xb) at pc=0x000000010c7f0741, pid=29303, tid=21507
:info:build #
:info:build # JRE version: OpenJDK Runtime Environment (17.0.12+7) (build 17.0.12+7)
:info:build # Java VM: OpenJDK 64-Bit Server VM (17.0.12+7, mixed mode, tiered, compressed oops, compressed class ptrs, g1 gc, bsd-amd64)
:info:build # Problematic frame: 
:info:build # V  [libjvm.dylib+0x446741]  void G1ParCopyClosure<(G1Barrier)1, false>::do_oop_work<oopDesc*>(oopDesc**)+0x41
:info:build #
:info:build # No core dump will be written. Core dumps have been disabled. To enable core dumping, try "ulimit -c unlimited" before starting Java again
:info:build #
:info:build # An error report file with more information is saved as:
:info:build # /opt/local/var/macports/build/_opt_local_var_macports_sources_rsync.macports.org_macports_release_tarballs_ports_java_openjdk17/openjdk17/work/jdk-17.0.12+7/make/hs_err_pid29303.log
:info:build #
:info:build # If you would like to submit a bug report, please visit:
:info:build #   https://trac.macports.org/newticket?port=openjdk1
```

but I can use openjdk now, looks like failure in `Optimizing the exploded image` is not fatal?