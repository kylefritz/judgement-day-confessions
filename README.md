#Judgement Day Confessions

A tiny app for confessing one's sins. Doom or Forgive other users.

Features:

 * Record a confession
 * Listen to other confessions
 * Doom or forgive confessions
 * List "most Doomed", "most Forgiven"

Tech:

 * Sinatra - web app
 * Redis & Ohm - light-weight data model
 * Tropo - telephony api
 * AWS/S3 - confession storage/streaming
 * Capistrano - quick & awesome deploy

Obviously the world did not end on 21 May 2011 so this application is
mostly just a toy example--but it did work pretty well.

Gotchas Discovered:

 * nginx:
   * `client_body_temp` should go to real /tmp
   * `client_max_body_size` 20M;
 * passenger:
   * doesn't understand nginx `env` directive, use a wrapped ruby
     startup script


