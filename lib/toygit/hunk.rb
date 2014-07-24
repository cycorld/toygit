module ToyGit
  class Hunk
    attr_reader :path
    attr_reader :file
    attr_reader :header
    attr_reader :lines

    def initialize(rugged_hunk, rugged_commit)
      delta = rugged_hunk.delta.delta
      @path = delta.new_file[:path]
      @file = get_file(rugged_commit)
      @header = parse_header(rugged_hunk.header)
      @lines = get_lines(rugged_hunk)
    end

    private

    def get_file(rugged_commit)
      repo_path = rugged_commit.tree.repo.path
      current_directory = `pwd`
      blob = `cd '#{repo_path}' && git show '#{rugged_commit.oid}:#{@path}'`
      `cd #{current_directory}`
      blob
    end

    def parse_header(header_string)
      unless header_string =~ /@@ \-(\d+),(\d+) \+(\d+),(\d+) @@.*/
        raise "Invalid header string: #{header_string}"
      end
      { old_i: $1.to_i, old_n: $2.to_i, new_i: $3.to_i, new_n: $4.to_i }
    end

    def get_lines(rugged_hunk)
      lines = []
      rugged_hunk.each_line do |line|
        prefix = nil
        case line.line_origin
        when :addition
          prefix = '+'
        when :deletion
          prefix = '-'
        when :context
          prefix = ' '
        else
          next
        end
        lines << prefix + line.content.force_encoding('utf-8')
      end
      lines
    end
  end
end
