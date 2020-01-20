# frozen_string_literal: true

module UserAgentParser
  class Version
    include Comparable

    # Private: Regex used to split string version string into major, minor,
    # patch, and patch_minor.
    SEGMENTS_REGEX = /\d+\-\d+|\d+[a-zA-Z]+$|\d+|[A-Za-z][0-9A-Za-z-]*$/.freeze

    attr_reader :version
    alias to_s version

    def initialize(*args)
      # If only one string argument is given, assume a complete version string
      # and attempt to parse it
      if args.length == 1 && args.first.is_a?(String)
        @version = args.first.to_s.strip
      else
        @segments = args.compact.map(&:to_s).map(&:strip)
        @version = segments.join('.')
      end
    end

    def major
      segments[0]
    end

    def minor
      segments[1]
    end

    def patch
      segments[2]
    end

    def patch_minor
      segments[3]
    end

    def inspect
      "#<#{self.class} #{self}>"
    end

    def eql?(other)
      self.class.eql?(other.class) &&
        version == other.version
    end

    def ==(other)
      other = normalize_version(other)

      self.<=>(other).zero?
    end

    def <=>(other)
      other = normalize_version(other)

      range = [segments.size, other.segments.size].min - 1

      (0..range).each do |i|
        return int_compare(segments[i], other.segments[i]) if segments[i] != other.segments[i]
      end

      0
    end

    def segments
      @segments ||= version.scan(SEGMENTS_REGEX)
    end

    def to_h
      {
        version: version,
        major: major,
        minor: minor,
        patch: patch,
        patch_minor: patch_minor
      }
    end

    private

    def normalize_version(version)
      version if version.is_a?(Version)
      Version.new(version.to_s)
    end

    def int_compare(s_segment, o_segment)
      Integer(s_segment).<=>Integer(o_segment)
    rescue ArgumentError, TypeError
      s_segment.<=>(o_segment)
    end
  end
end
