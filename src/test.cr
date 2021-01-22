#!/usr/bin/env crystal

require "./tap"

##======================================================================================================================

Tap.test "tap" do |t|
	
	t.test "asserts" do |t|
		
		t.ok true
		t.ok { true }
		t.not_ok false
		t.not_ok { false }
		
		t.eq 1, 1
		t.not_eq 1, 2
		
		t.is_nil nil
		t.is_nil { nil }
		t.not_nil ""
		t.not_nil { "" }
		
		t.is_true true
		t.is_true { true }
		t.is_false false
		t.is_false { false }
		
		t.raises { raise "OH NO" }
		t.raises /OH NO/ { raise "OH NO" }
		t.raises "OH NO" { raise "OH NO" }
		
		t.not_raises { true }
		
	end
end
