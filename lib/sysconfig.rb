class SysConfig
  @@dir, @@lsflags, @@ls = ''
  @@done = false
  def self.setup
    @@dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
    if RUBY_PLATFORM =~ /(win|w)32$/
      @@ls = "dir"
      @@lsflags = "/B"
    else
      @@ls = "ls"
      @@lsflags = "-1"
    end
    @@done = true
  end

  def self.dir
    @@dir
  end

  def self.lsflags
    @@lsflags
  end

  def self.ls
    @@ls
  end

  def self.done
    @@done
  end
end
