dartemis_transformer
====================
[![Build Status](https://drone.io/github.com/denniskaselow/dartemis_transformer/status.png)](https://drone.io/github.com/denniskaselow/dartemis_transformer/latest)
[![Coverage Status](https://coveralls.io/repos/denniskaselow/dartemis_transformer/badge.svg?branch=master&service=github)](https://coveralls.io/github/denniskaselow/dartemis_transformer?branch=master)
[![Pub](https://img.shields.io/pub/v/dartemis_transformer.svg)](https://pub.dartlang.org/packages/dartemis_transformer)

dartemis_transformer is a transformer for [dartemis](https://pub.dartlang.org/packages/dartemis).

The transformer converts your `Component`s into `PooledComponent`s and it creates the code
required to initialize `Mapper`s, `Manager`s and `EntitySystem`s in your `Manager`s and 
`EntitySystem`s `initialize()`-method.

If you are importing libraries from other packages with `Manager`s or `EntitySystem`s you
are using in your own code, you have to inform the transformer about them by passing
a list of those libraries to the transformer:

```yaml
transformers:
- dartemis_transformer
    additionalLibraries:
    - otherLib/otherLib.dart
    - moreLibs/moreLibs.dart
```

If those libraries need to be transformed as well, you have to add the transformer to 
their `pubspec.yaml`.

It's also possible to disable parts of the transformer:

```yaml
transformers:
- dartemis_transformer
    pooling: false
    initializeMethod: false
```

If you set `pooling` to `false` your `Component`s will not be converted into `PooledComponent`s.
If you set `initializeMethod` to `false` your `Mapper`s, `EntitySystem`s and `Manager`s will not contain
generated code for the initialization.
Setting both to false is the same as not including the transformer at all.

Caveats
-------
* If you have a component wth a constructor with a function body, use `this` to reference class variables and methods.
The transformer will not analyze whether a variable in the body is locally scoped or not and only turns `this` into
`pooledComponent`.

* The transformer is not tested with cases where a library is imported
using an alias. Please file a [new issue](https://github.com/denniskaselow/dartemis_transformer/issues/new)
if it doesn't work and you have to use an alias.

* Debugging a transformed file in the Dart Editor is not possible because lines don't match
but it works fine in Dartium.
