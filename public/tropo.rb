require 'net/http'

say "judgement day confessions!"
wait 500
record("Please leave your confession at the beep. Press pound when finished.",{
    :beep=>true,
    :timeout=>5,
    :silenceTimeout=>7,
    :maxTime=>60,
    :terminator=>'#',
    :recordFormat=>"audio/mp3",
    :recordURI=>"http://judgementdayconfessions.com/confession/#{$currentCall.callerID}"
})
say "thanks. you might be forgiven, you might not."
wait 500
say "don't let that stop you from judging others."
wait 500
say "Here is your first chance. Listen closely. When the confession is done you can either doom or forgive them."

def judge
  http = Net::HTTP.new('judgementdayconfessions.com')

  resp,data=http.get "/judge/#{$currentCall.callerID}"
  confession_url,confession_id=data.split(',')
  say confession_url
  resp=ask "doom or forgive?",{
    :choices=>"doom, forgive",
    :onBadChoice => lambda { |event|
          say "It's simple: either doom or forgive."
      },
  }
  if resp.value=="doom"
    say "OK. To hell with them."
    http.post "/doom/#{confession_id}" , {}
  elsif resp.value=="forgive"
    say "We'll let them off the hook, but don't think you're going to heaven."
    http.post "/forgive/#{confession_id}", {}
  else
    hangup
  end
end

while true
  judge
  wait 500
  say "Here is another. Doom or forgive?"
end
