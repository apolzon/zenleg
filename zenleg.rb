require 'rubygems'
require 'rest-client'
require 'builder'
require 'ostruct'
class Zenleg
	RestClient.log = $stdout
	@@resource = RestClient::Resource.new("http://applesonthetree.zendesk.com", :user => "apolzon@gmail.com", :password => "test123")
	def initialize(*args)
		defaults = {
			:email => "requester1@applesonthetree.com",
			:name => "Request User1",
			:roles => 0,
			:restriction_id => 4
		}
		params = defaults
		params = defaults.merge(args.first) unless args.empty?
		@user = OpenStruct.new
		@user.email = params[:email]
		@user.name = params[:name]
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
		xml = ""
		builder = Builder::XmlMarkup.new(:target => xml)
		builder.instruct!
		builder.ticket do |t|
			t.description params[:description]
			t.tag! "priority-id", params[:priority_id]
			t.tag! "requester-name", @user.name
			t.tag! "requester-email", @user.email 
		end
		response = @@resource["/tickets.xml"].post xml, :content_type => "xml"
	end

	def mark_ticket_resolved(*args)
		defaults = {
			:assignee_id => 16117939,
			:additional_tags => "",
			:ticket_field_entries => [],
			#:ticket_field_entries => [{:ticket_field_id => 312002, :value => 1}],
			:id => 2
		}
		params = defaults
		params = defaults.merge(args.first) unless args.empty?
		# PUT /tickets/#{id}.xml
		xml = ""
		builder = Builder::XmlMarkup.new(:target => xml)
		builder.instruct!
		builder.ticket do |t|
			t.status_id 3  
			t.tag! "assignee-id", params[:assignee_id]
			t.tag! "additional-tags", params[:additional_tags]
			unless params[:ticket_field_entries].empty?
				t.tag! "ticket-field-entries", :type => "array" do |entry|
					params[:ticket_field_entries].each do |param|
						entry.tag! "ticket-field-entry" do |field|
							field.tag! "ticket-field-id", param[:ticket_field_id]
							field.value param[:value]
						end
					end
				end
			end
		end
		response = @@resource["/tickets/#{params[:id]}.xml"].put xml, :content_type => "xml"
	end
end
