require 'sinatra'
require 'haml'
require 'aws/s3'
require 'ohm'

set :haml, :format => :html5

module JdayParams
  Bucket="jday-test"

  #TODO: set credentials in env
  AWS_KEY_ID=ENV["AWS_KEY_ID"]
  AWS_SECRET=ENV["AWS_SECRET"]
end

configure :production do
  require 'newrelic_rpm'
end

before do
  Ohm.connect :url => ENV['REDISTOGO_URL']
end

class Confession < Ohm::Model
  attribute :date
  attribute :phone_number
  counter :dooms
  counter :forgives

  index :phone_number

  def s3url
    "http://s3.amazonaws.com/#{JdayParams::Bucket}/confession-#{@id}.mp3"
  end
end

get "/" do
  haml :index, {},{:confessions=> Confession.all.sort(:order=>"DESC")}
end

get "/most-doomed" do
  haml :index, {},{:confessions=> Confession.all.sort_by(:dooms,:order=>"DESC")}
end

get "/most-saved" do
  haml :index, {},{:confessions=> Confession.all.sort_by(:forgives,:order=>"DESC")}
end

get "/judge/:phone_number" do
  choose_from=Confession.all.except(:phone_number=>params[:phone_number]).all
  choosen=choose_from[rand(choose_from.length)]
  "#{choosen.s3url},#{choosen.id}"
end

%w( doom forgive ).each do |make_it|
  post "/#{make_it}/:id" do
    confession=Confession[params[:id]]
    raise Sinatra::NotFound if confession.nil?
    confession.incr "#{make_it}s".to_sym, 1
    redirect request.referrer || "/"
  end
end

post "/confession/:phone_number" do
  AWS::S3::Base.establish_connection!(
    :access_key_id     => JdayParams::AWS_KEY_ID,
    :secret_access_key => JdayParams::AWS_SECRET
  )

  confession=Confession.create :date => Time.now, :phone_number=>params[:phone_number]

  AWS::S3::S3Object.store(
      "consfession-#{confession.id}.mp3",
      open(params[:filename][:tempfile]),
      JdayParams::Bucket,
      :access => :public_read
  )

  redirect "/"
end
