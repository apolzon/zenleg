require 'rubygems'
require 'rest-client'
require 'builder'
class Zenleg
	RestClient.log = $stdout
	@@resource = RestClient::Resource.new("http://applesonthetree.zendesk.com", :user => "apolzon@gmail.com", :password => "test123")
	# RestClient usage:
	# RestClient.get 'url'
	# RestClient.get 'url', {:params => {} }
	# RestClient.post 'url'
	# RestClient.delete 'url'
	
	def initialize(*args)
		defaults = {
			:email => "requester@applesonthetree.com",
			:name => "Request User",
			:roles => 0,
			:restriction_id => 4,
			:groups => [2,3]
		}
		params = defaults
		params = defaults.merge(args.first) unless args.empty?
		url = "/users.xml"
		xml = ""
		builder = Builder::XmlMarkup.new(:target => xml)
		builder.instruct!
		builder.user do |u|
			u.email params[:email]
			u.name params[:name]
			u.roles params[:roles]
			u.password "testuser"
			u.tag! "restriction-id", params[:restriction_id]
			u.tag! "is-verified", "true"
		end
		response = @@resource["/users.xml"].post xml, :content_type => "xml"
#		response = @resource["/users.xml"].post "<user><email>t@t.com</email><name>Test Test</name></user>", :content_type => "xml"
		if response.code == 507
			return "Account cannot create more users"
		end
		response
	end

	def create_ticket_as_requester(*args)
		defaults = {
			:description => "requester default description",
			:priority_id => 1
		}
		params = defaults
		params = defaults.merge(args.first) unless args.empty?
		# POST /tickets.xml
		url = "/tickets.xml"
		xml = ""
		builder = Builder::XmlMarkup.new(:target => xml)
		builder.instruct!
		builder.ticket do |t|
			t.description params[:description]
			t.tag! "priority-id", params[:priority_id]
			t.tag! "requester-name", "Request User" # look this up in our created user
			t.tag! "requester-email", "requester@applesonthetree.com" # look this up in our created user
		end
		response = @@resource.post "#{url}", xml, :content_type => "xml"
	end

	def mark_ticket_resolved(*args)
		defaults = {
			:assignee_id => 1,
			:additional_tags => "",
			:ticket_field_entries => []
		}
		params = defaults
		params = defaults.merge(args.first) unless args.empty?
		# PUT /tickets/#{id}.xml
		url = "/tickets/1.xml"
		xml = ""
		builder = Builder::XmlMarkup.new(:target => xml)
		builder.instruct!
		builder.ticket do |t|
			t.tag! "assignee-id", params[:assignee_id]
			t.tag! "additional-tags", params[:additional_tags]
			t.tag! "ticket-field-entries", :type => "array" do |entry|
				params[:ticket_field_entries].each do |param|
					entry.tag! "ticket-field-entry" do |field|
						field.tag! "ticket-field-id", param[:ticket_field_id]
						field.value param[:value]
					end
				end
			end
		end
		response = @@resource.put "#{url}", xml, :content_type => "xml"
	end
end
