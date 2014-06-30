module ToyGit
  class Commit
    attr_reader :toyid
    attr_reader :chapter
    attr_reader :step
    attr_reader :rugged_commit

    def initialize(toyid, chapter, step, rugged_commit)
      @toyid = toyid
      @chapter = chapter
      @step = step
      @rugged_commit = rugged_commit
    end
  end
end
