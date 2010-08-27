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
		# Success returns xml with userid
		# No privs gives 507 (catch this?)
		# POST /users.xml
		# Sample xml:
		xml = ""
		builder = Builder::XmlMarkup.new(:target => xml)
		builder.instruct!
		builder.user do |u|
			u.email "requester@applesonthetree.com"
			u.name "Request User"
			u.roles 4
			u.tag! 'restriction-id' 1
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

	def create_ticket_as_requestor
		# POST /tickets.xml
		# Sample xml:
=begin
		<ticket>
			<description></description>
			<priority-id></priority-id>
			<requester-name></requester-name>
			<requester-email></requester-email>
		</ticket>
=end
	end

	def mark_ticket_resolved
		# PUT /tickets/#{id}.xml
		# Sample xml:
=begin
		<ticket>
			<assignee-id></assignee-id>
			<additional-tags></additional-tags>
			<ticket-field-entries type="array">
				<ticket-field-entry>
					<ticket-field-id></ticket-field-id>
					<value></value>
				</ticket-field-entry>
			</ticket-field-entries>
		</ticket>
=end
	end
end
