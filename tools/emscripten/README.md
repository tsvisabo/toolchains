# IOTA toolchains - emscripten

Transpile command:
```
bazel build --define=workspace=$(bazel info workspace)  --define=output_base=$(bazel info output_base)  --config='emscripten'  //tests:hi.js
```

##How to create a target
Add "emcc_binary" rule defined in "defs.bzl" to create a ".js" and ".wasm" file

##How to consume js files

One option at least is to create one js module that wrap and export the functions 
that was already exported via the emcc_binary
And another that calls them

In emcc_binary, make sure to set `linkopts = ["-s LINKABLE=1 -s EXPORT_ALL=1"]`
to export to the .js file all functions in compiled module or `linkopts = ["-s EXPORTED_FUNCTIONS='[\"_func_name\"]'"]`

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







