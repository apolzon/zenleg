require 'rubygems'
require 'rest-client'
require 'builder'
class Zenleg
	# RestClient usage:
	# RestClient.get 'url'
	# RestClient.get 'url', {:params => {} }
	# RestClient.post 'url'
	# RestClient.delete 'url'
	
	def initialize
		# Create the user
		# POST /users.xml
		xml = ""
		builder = Builder::XmlMarkup.new(:target => xml)
		builder.instruct!
		builder.user do |u|
			u.email "requester@applesonthetree.com"
			u.name "Request User"
			u.roles 4
			u.tag! "restriction-id" 1
			u.groups(:type => "array") do |g|
				g.group 2
				g.group 3
			end
		end
		response = RestClient.post "http://applesonthetree.zendesk.com/users.xml" xml
		if response.code == 507
			return "Account cannot create more users"
		end
		response
	end

	def create_ticket_as_requester
		# POST /tickets.xml
		xml = ""
		builder = Builder::XmlMarkup.new(:target => xml)
		builder.instruct!
		builder.ticket do |t|
			t.description "this is my requester ticket"
			t.tag! "priority-id" 1
			t.tag! "requester-name" "Request User"
			t.tag! "requester-email" "requester@applesonthetree.com"
		end
		response = RestClient.post "http://applesonthetree.zendesk.com/tickets.xml" xml
	end

	def mark_ticket_resolved
		# PUT /tickets/#{id}.xml
		xml = ""
		builder = Builder::XmlMarkup.new(:target => xml)
		builder.instruct!
		builder.ticket do |t|
			t.tag! "assignee-id" 1
			t.tag! "additional-tags" "tagname"
			t.tag(:type => "array")! "ticket-field-entries" do |entry|
				entry.tag! "ticket-field-entry" do |field|
					field.tag! "ticket-field-id" 1
					field.value "value"
				end
			end
		end
		response = RestClient.put "http://applesonthetree.zendesk.com/tickets/1.xml"
	end
end
