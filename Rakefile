
desc "Commit src/version.rb and set git tag"
task :release, [:version] do |t, args|
  File.write(p("src/version.rb"), p(<<~EOF
    # generated with rake release[#{args[:version]}]
    module Edward
      VERSION = \"#{args[:version]}\"
    end
    EOF
  ))
  `gem build`
  `git add src/version.rb`
  `git commit -m "src/version.rb #{args[:version]}" --no-edit`
  `git tag #{args[:version]}`
  puts "please run \e[32mgem push mr-edward-#{args[:version]}.gem\e[0m"
end
