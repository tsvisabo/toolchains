#!/bin/bash

set -euo pipefail

clang_path="$PWD/external/emscripten_clang"
#We choose a WORKSPACE because it's a file that must be present
#and we take it's containing directory path
clang_path=`readlink -f $clang_path/WORKSPACE`
clang_path=${clang_path%"/WORKSPACE"}
external_path=${clang_path%"/emscripten_clang"}

EM_CONFIG="LLVM_ROOT='$clang_path';"

EM_CONFIG+="EMSCRIPTEN_NATIVE_OPTIMIZER='$clang_path/optimizer';"
EM_CONFIG+="BINARYEN_ROOT='$clang_path/binaryen';"
EM_CONFIG+="NODE_JS='$external_path/nodejs/bin/nodejs/bin/node';"
EM_CONFIG+="SPIDERMONKEY_ENGINE='';"
EM_CONFIG+="V8_ENGINE='';"
EM_CONFIG+="TEMP_DIR='tmp';"
EM_CONFIG+="COMPILER_ENGINE=NODE_JS;"
EM_CONFIG+="JS_ENGINES=[NODE_JS];"
export EM_CONFIG

export EM_EXCLUSIVE_CACHE_ACCESS=1
export EMCC_SKIP_SANITY_CHECK=1
export EMCC_WASM_BACKEND=0


mkdir -p "tmp/emscripten_cache"

export EM_CACHE="tmp/emscripten_cache"
export TEMP_DIR="tmp"

# Prepare the cache content so emscripten doesn't try to rebuild it all the time

(
  cd tmp/emscripten_cache;
  for n in "../../tools/emscripten/emscripten_cache"/*;do
    ln -s "$n"
  done
)

argv=("$@")

tarfile=
# Find the -o option, and strip the .tar from it.
for (( i=0; i<$#; i++ )); do
  if [[ "x${argv[i]}" == x-o ]]; then
    arg=${argv[$((i+1))]}
    if [[ "x$arg" == x*.tar ]];then
        tarfile=$(basename "$arg")
        emfile="$(dirname "$arg")/$(basename $arg .tar)"
        basearg="$(basename "$(basename "$(basename "$emfile" .js)" .html)" .wasm)"
        baseout="$(dirname "$arg")/$basearg"
        argv[$((i+1))]="$emfile"
    fi
  fi
done


python external/emscripten_toolchain/emcc.py "${argv[@]}"


# Now create the tarfile
shopt -s extglob
if [ "x$tarfile" != x ]; then
  outdir="$(dirname "$baseout")"
  outbase="$(basename "$baseout")"
  (
      cd "$outdir";
      sources="$outbase."?(html|js|wasm|mem|data|worker.js)
      tar cvf $tarfile $sources
  )
fi
