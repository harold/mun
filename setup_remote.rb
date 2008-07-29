#!/usr/bin/env ruby
map = {
  "Phrogz" => "harold",
  "harold" => "Phrogz"
}
config = IO.read( ".git/config" )
user = config[ /remote "origin".+?(Phrogz|harold)/m , 1]
proj = config[ /([^\/]+\.git)/m , 1]

other_user = map[user]
`git remote add #{other_user} git://github.com/#{other_user}/#{proj}`
`git fetch #{other_user}`
puts "Next: 'git merge #{other_user}/master' (since I already did 'git fetch #{other_user}')"