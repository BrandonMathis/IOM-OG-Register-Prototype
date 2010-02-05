module Tags
  RUBY_FILES = FileList['**/*.rb'].exclude("pkg")
end

namespace "tags" do
  desc "build the TAGS file using exuberant ctags for emacs"
  task :emacs do
    puts "Making Emacs TAGS file"
    `xctags -e #{Tags::RUBY_FILES}`
  end
end

task :tags => ["tags:emacs"]
