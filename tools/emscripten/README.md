# IOTA toolchains - emscripten

Transpile command:
```
bazel build --define=workspace=$(bazel info workspace)  --define=output_base=$(bazel info output_base) --crosstool_top=//tools/emscripten:emscripten --config='emscripten'  //tests:hi.js
```

##How to create a target
Add "emcc_binary" rule defined in "defs.bzl" to create a "js" and "wasm" file

##How to consume js files

One option at least is to create one js module that wrap and export the functions 
that was already exported via the emcc_binary (using linker flag "-s EXPORTED_FUNCTIONS=[]")
And another that calls them

###hi_wrapper.js
```
'use strict'

let Module = require('./hi.js')

var hi = Module.cwrap('hi', 'null', []);

module.exports = {
  hi: hi,
  Module: Module
}


```

###example.js 

```
'use strict'

let a = require('./hi_wrapper.js')

a.Module.onRuntimeInitialized = function() {
  a.hi()
}

```


Generally, it is better to follow  emscripten documentation:

[calling functions with emscripten](https://emscripten.org/docs/porting/connecting_cpp_and_javascript/Interacting-with-code.html#interacting-with-code-ccall-cwrap
)







