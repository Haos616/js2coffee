require './setup'

{eachGroup} = require('../lib/support/specs_iterator')

eachGroup (group) ->
  nope = !! process.env.ALL

  run = if (not nope and group.pending) then xdescribe else describe

  run group.name, ->
    group.specs.forEach (spec) ->
      run = if (not nope and spec.meta?.pending) then xit else if spec.meta?.only then it.only else it
      run spec.name, do (spec) -> ->
        result = js2coffee.build(spec.input)
        try
          expect(result.code).eql(spec.output)
        catch e
          # this doesn't actually disable diffs, but rather it makes the diff
          # output look better. see: https://github.com/visionmedia/mocha/issues/1241
          e.showDiff = false
          e.stack = ''
          throw e

        if spec.meta.warnings
          descs = result.warnings.map((w) -> w.description).join(" ;; ")
          spec.meta.warnings.forEach (expected) ->
            if expected instanceof RegExp
              expect(descs).match expected
            else
              expect(descs).include expected
