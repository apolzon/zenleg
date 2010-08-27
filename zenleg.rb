require 'rubygems'
require 'rest-client'
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
=begin
		<user>
 		  <email>aljohson@yourcompany.dk</email>
		  <name>Al Johnson</name>
			<roles>4</roles>
		  <restriction-id>1</restriction-id>
 		  <groups type='array'>
		    <group>2</group>
 		    <group>3</group>
		  </groups>
		</user>
=end
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
