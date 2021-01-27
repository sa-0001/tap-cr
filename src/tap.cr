require "json"

##======================================================================================================================

class Tap
	@@started = false
	
	@@start = Time.utc
	@@count = 0
	@@count_pass = 0
	@@count_fail = 0
	
	def self.test (title, &block)
		if !@@started
			@@started = true
			@@start = Time.utc
			
			puts "TAP version 13"
			
			at_exit do
				stop = Time.utc
				dura = stop - @@start
				puts %(1..#{@@count})
				if @@count_fail > 0
					puts %(# failed #{@@count_fail} of #{@@count} tests)
				end
				puts %(# time=#{dura.total_milliseconds.round(3)}ms)
			end
		end
		
		subtest = Tap.new title: title, indent_level: 0 { |t| yield t }
		
		@@count += 1
		if subtest.stats[:count_fail] == 0
			@@count_pass += 1
		else
			@@count_fail += 1
		end
	end
	
	@title : String
	@indent_level = 0
	
	@start = Time.utc
	@count = 0
	@count_pass = 0
	@count_fail = 0
	
	def initialize (@title = "TAP", @indent_level = 0, &block)
		
		# print title fo (sub)test
		log_indent "# Subtest: #{@title}"
		
		begin
			yield self
		rescue ex
			fail ex
		end
		
		stop = Time.utc
		dura = stop - @start
		
		# print number of asserts
		log_indent "    1..#{@count}"
		
		# print number of failed asserts (if there are any)
		if @count_fail > 0
			log_indent "    # failed #{@count_fail} of #{@count} tests"
		end
		
		# print status and duration of (sub)test
		if @count_fail > 0
			log_indent "not ok - #{@title} # time=#{dura.total_milliseconds.round(3)}ms"
		else
			log_indent "ok - #{@title} # time=#{dura.total_milliseconds.round(3)}ms"
		end
		
		# print empty line after each (sub)test
		log_indent ""
	end
	
	def stats
		{
			start: @start,
			count: @count,
			count_pass: @count_pass,
			count_fail: @count_fail,
		}
	end
	
	def test (title, &block)
		subtest = Tap.new title: title, indent_level: @indent_level + 1 { |t| yield t }
		
		@count += 1
		if subtest.stats[:count_fail] == 0
			@count_pass += 1
		else
			@count_fail += 1
		end
	end
	
	##--------------------------------------------------------------------------
	
	# reporting
	
	private def log_indent (message)
		str = ""
		@indent_level.times { str += "    " }
		str += message
		puts str
	end
	
	private def pass (message)
		@count += 1
		@count_pass += 1
		log_indent "    ok #{@count.to_s} - #{message}"
	end
	private def fail (message)
		@count += 1
		@count_fail += 1
		log_indent "    not ok #{@count.to_s} - #{message}"
	end
	private def fail (ex : Exception)
		fail ex.message
		log_indent "      ---"
		log_indent "      stack: >"
		ex.backtrace.each do |line|
			log_indent "        #{line}"
		end
		log_indent "      ..."
	end
	
	##--------------------------------------------------------------------------
	# asserts
	
	def ok (val)
		return pass("is truthy") if val
		fail %("#{val.to_s}" is not truthy)
	end
	
	def not_ok (val)
		return pass("is falsey") if !val
		fail %("#{val.to_s}" is not falsey)
	end
	
	def eq (val1, val2)
		return pass("are equal") if val1 == val2
		fail %("#{val1.to_s}" != "#{val2.to_s}")
	end
	
	def not_eq (val1, val2)
		return pass("are not equal") if val1 != val2
		fail %("#{val1.to_s}" == "#{val2.to_s}")
	end
	
	def is_nil (val)
		return pass("is nil") if val == nil
		fail %("#{val.to_s}" is not nil)
	end
	
	def not_nil (val)
		return pass("is not nil") if val != nil
		fail %("#{val.to_s}" is nil)
	end
	
	def is_true (val)
		return pass("is true") if val == true
		fail %("#{val.to_s}" is not true)
	end
	
	def is_false (val)
		return pass("is false") if val == false
		fail %("#{val.to_s}" is not false)
	end
	
	##--------------------------------------------------------------------------
	
	# asserts with blocks
	
	def ok (&block)
		val = yield
		ok val
	end
	
	def not_ok (&block)
		val = yield
		not_ok val
	end
	
	def eq (val1, &block)
		val2 = yield
		eq val1, val2
	end
	
	def not_eq (val1, &block)
		val2 = yield
		not_eq val1, val2
	end
	
	def is_nil (&block)
		val = yield
		is_nil val
	end
	
	def not_nil (&block)
		val = yield
		not_nil val
	end
	
	def is_true (&block)
		val = yield
		is_true val
	end
	
	def is_false (&block)
		val = yield
		is_false val
	end
	
	def raises (&block)
		assert = %(should raise an exception)
		begin
			yield
			fail assert
		rescue ex
			pass assert
		end
	end
	
	def raises (message : Regex | String, &block)
		assert = %(should raise an exception)
		begin
			yield
			fail assert
		rescue ex
			pass assert
			if message.is_a? Regex
				assert = %(should match regex #{message.to_s})
				message.match(ex.message.not_nil!) ? pass assert : fail assert
			elsif message.is_a? String
				assert = %(should match string "#{message.to_s}")
				ex.message.not_nil!.includes?(message) ? pass assert : fail assert
			end
		end
	end
	
	def not_raises (&block)
		assert = %(should not raise an exception)
		begin
			yield
			pass assert
		rescue ex
			fail assert
		end
	end
end
