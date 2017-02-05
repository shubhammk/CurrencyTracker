 # *milliseconds*: Timer for measuring short intervals
 # Return elapsed time of operation in milliseconds (rounded up)
 # ===Usages:
 #   et = Milliseconds.new
 #   et.start
 #   << Operations_to_perform >>
 #   et.stop
  
 class Milliseconds
   # A Ruby Time object with the start time for this object
   attr_reader :start_time
   # A Ruby Time object with the most recent end time for this object
   attr_reader :stop_time

   # Initialize an Milliseconds object and optionally time the enclosed operation.
   def initialize
     start
     if block_given?
       yield
       stop
     end
   end

   # Reset the timers and begin timing a new operation
   def start
     @start_time, @stop_time = Time.now, nil
   end

   # Stop timer and calculate elapsed time in milliseconds
   def stop
     [ @start_time, (@stop_time = @stop_time.nil? ? Time.now : @stop_time) ]
   end

   # Return either final or current duration depending if stop has 
   # been called
   def duration
     (@stop_time.nil? ? Time.now : @stop_time) - @start_time
   end

   # Return current elapsed time in long format (i.e., d, h, m, s, ms)
   # ===Usage
   #   et = ElapsedTime.new
   #   days,hours,minutes,seconds,milli = et.elapsed
   def elapsed
     ms  = duration
     s   = ms.to_i
     ms  = ((ms - s) * 1000).to_i
     h   = s / 3600
     s   = s % 3600
     d   = h / 24
     h   = h % 24
     m   = s / 60
     s   = s % 60
     return d, h, m, s, ms
   end

   # Return current elapsed time as rounded number of milliseconds
   def ms
     ((duration * 1000.0) + 0.4999).to_i
   end

   # Return rounded number of seconds (use to_f for unrounded)
   def seconds
     (duration + 0.4999).to_i
   end

   # Return the current elapsed time in a string in a 'pretty' format
   # ===Format
   #   "D HH:MM:SS.MS"   # The "D " is only included when non-zero
   def to_s(pretty=true)
     d, h, m, s, ms = elapsed
     e_t  = (d > 0) ? "#{d.to_s}d " : ''
     if pretty
       e_t += ('%02u:' % [h]) if (d + h) > 0
       e_t += ('%02u:' % [m]) if (d + h + m) > 0
       e_t += '%02u.%03u' % [s, ms]
     else
       e_t << '%02u:%02u:%02u.%03u' % [h,m,s, ms]
     end
   end
 end