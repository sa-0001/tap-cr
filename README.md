# tap

A test framework which outputs in TAP format.

If, like me, you already have a large set of tests in other languages, which are already using a TAP test api, and formatting / reporting tools which process the resulting TAP format, then you can use this to write tests for Crystal in the same way you are used to, and produce test results with the same output you are used to.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  tap:
    github: sa-0001/tap-cr
```

## Usage & Examples

```crystal
require "tap"

require "some-lib"

Tap.test "SomeLib" do |t|
	
	t.test "method a" do |t|
		
		t.eq SomeLib.a, "a"
		
	end
	
	t.test "method b" do |t|
		
		t.eq SomeLib.b, "b"
		
	end
end
```
