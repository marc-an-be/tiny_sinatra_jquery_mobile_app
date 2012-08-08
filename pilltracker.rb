#!/usr/bin/env ruby
%w(sinatra sqlite3 dm-sqlite-adapter data_mapper haml time).each{|g| require g}

########## MODELS
class Event
  include DataMapper::Resource
  property :id, Serial
  property :time, DateTime
  property :type, String
  property :description, String
end

########## PERSISTENCE
DataMapper::setup(:default,"sqlite3:pilltracker.db")
DataMapper.finalize.auto_upgrade!

########## CONTROLLERS / ROUTES
get '/' do
  @events = Event.all(:order => :time.desc)
  haml :index
end

get '/new/?' do
  haml :new
end

post '/new/?' do
  begin
    Event.create(
      :time        => Time.parse(params['time']),
      :type        => params['type'],
      :description => params['description']
    )
    redirect '/'
  rescue
    haml :new
  end
end

########## VIEWS
__END__

@@ layout
!!! 5
%html{:lang => 'en'}
  %head
    %meta{:charset => 'utf-8'}
    %meta{:name => 'viewport', :content => 'width=device-width, initial-scale=1'}
    %meta{:name => 'format-detection', :content => 'telephone=no'}
    %title PillTracker
    %link{:href => '//code.jquery.com/mobile/1.0.1/jquery.mobile-1.0.1.css', :rel => 'stylesheet'}
    %link{:href => '//dev.jtsage.com/cdn/datebox/latest/jquery.mobile.datebox.min.css', :rel => 'stylesheet'}
    %script{:src => '//code.jquery.com/jquery-1.7.1.min.js'}
    %script{:src => '//code.jquery.com/mobile/1.0.1/jquery.mobile-1.0.1.min.js'}
    %script{:src => '//dev.jtsage.com/cdn/datebox/latest/jquery.mobile.datebox.min.js'}
  %body
    %div{'data-role' => 'page'}
      %div{'data-role' => 'header'}
        %h2 PillTracker
      = yield(:layout)

@@ index
%ul.ui-listview{:data => {:role => 'listview', :theme => 'b'}}
  %li{:data => {:theme => 'a'}}
    %a{href:'/new/'} New
  - @events.each do |event|
    %li
      %img{:style => 'float:left;margin:1em;',
           :src => event.type == 'took' ? 'pills.png' : 'stethoscope.png'}
        %div&= event.time.strftime("%Y-%m-%d %H:%M")
        %div&= "#{event.type}: #{event.description}"

@@ new
%form{:action => '/new/', :method => 'post'}
  %p
    %label{:for => 'event'} Event
  %p
    %fieldset{:data => {:role => 'controlgroup', :type => 'horizontal'}}
      %input{:type => 'radio', :name => 'type', :id => 'took', :value => 'took', :checked => 'checked'}
      %label{:for => 'took'} took
      %input{:type => 'radio', :name => 'type', :id => 'feel', :value => 'feel'}
      %label{:for => 'feel'} feel
  %p
    %label{:for => 'time'} Time
  %p
    %input{:name => 'time', :id => 'time', :type => 'date', 'data-role' => 'datebox',
           :value => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
           'data-options' => '{"mode": "slidebox", "dateFormat":"YYYY-MM-DD GG:ii", "timeFormat":24, "fieldsOrderOverride":["y","m","d","h","i"]}'}
  %p
    %label{ :for => 'description'} Description
  %p
    %textarea{:name => 'description', :id => 'description'}
  %p
    %a{:href => '/', :data => {:role => 'button', :data => 'true'}} Cancel
    %button.ui-btn-hidden{:type => 'submit', 'data-theme'=>'a', 'aria-disabled'=>'false'} Save
