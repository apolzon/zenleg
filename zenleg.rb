require 'rubygems'
require 'rest-client'
require 'builder'
class Zenleg
	@@api_url = "http://applesonthetree.zendesk.com"
	# RestClient usage:
	# RestClient.get 'url'
	# RestClient.get 'url', {:params => {} }
	# RestClient.post 'url'
	# RestClient.delete 'url'
	
	def initialize(*args)
		defaults = {
			:email => "requester@applesonthetree.com",
			:name => "Request User",
			:roles => 4,
			:restriction_id => 1,
			:groups => [2,3]
		}
		params = defaults
		params = defaults.merge(args.first) unless args.empty?
		# Create the user
		# POST /users.xml
		url = "/users.xml"
		xml = ""
		builder = Builder::XmlMarkup.new(:target => xml)
		builder.instruct!
		builder.user do |u|
			u.email email
			u.name name
			u.roles roles
			u.tag! "restriction-id" restriction_id
			u.groups(:type => "array") do |g|
				groups.each do |g_num|
					g.group g_num
				end
			end
		end
		response = RestClient.post "#{@@api_url}#{url}", xml
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
			t.description description
			t.tag! "priority-id", priority_id
			t.tag! "requester-name", "Request User" # look this up in our created user
			t.tag! "requester-email", "requester@applesonthetree.com" # look this up in our created user
		end
		response = RestClient.post "#{@@api_url}#{url}", xml
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
			t.tag! "assignee-id", 1
			t.tag! "additional-tags", "tagname"
			t.tag! "ticket-field-entries", :type => "array" do |entry|
				entry.tag! "ticket-field-entry" do |field|
					field.tag! "ticket-field-id", 1
					field.value "value"
				end
			end
		end
		response = RestClient.put "#{@@api_url}#{url}", xml
	end
end
