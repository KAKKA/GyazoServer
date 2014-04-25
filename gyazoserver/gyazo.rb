require 'rubygems'
require 'sinatra/base'
require 'digest/md5'
require 'sdbm'
require 'haml'

class MainApp < Sinatra::Base

	post '/upload' do
		id = params[:id]
		imagedata = params[:imagedata][:tempfile].read

		hash = Digest::MD5.hexdigest(imagedata)
		hash = hash[0..70]
		
		create_newid = false
		if not id or id == "" then
		    id = Digest::MD5.hexdigest(request.ip + Time.now.to_s)
		    create_newid = true
		end

#		dbm = SDBM.open('db/id',0644)
#		dbm[hash] = id
#		dbm.close
		
		File.open("/opt/gyazo/#{hash}.png","w") do |f|
			f.write(imagedata)
		end
		
		if create_newid then
		    headers['X-Gyazo-Id'] = id
		end
		
		"http://49.212.213.57/#{hash}.png"
	end

end
