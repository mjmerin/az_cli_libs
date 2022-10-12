require 'json'
require 'safe_shell'

class WorkItem 

    attr_reader :title
    attr_reader :createdBy
    attr_reader :resolvedBy
    attr_reader :children
    attr_reader :parent
    attr_reader :tags
    attr_reader :item_id
    attr_reader :createdDate
    attr_reader :state
    attr_reader :type
    attr_reader :url
    attr_reader :project

    def initialize(org, itemid)
        @org = org
        @item_id = itemid
        @az_cmd = '/usr/local/bin/az'
        @datahash = JSON.parse(az_cmd_response)
        @createdDate = get_createdDate
        @title = get_title
        @createdBy = get_createdby
        @resolvedBy = get_resolvedby
        @children = get_relations("Child")
        @parent = get_relations("Parent")
        @tags = get_tags
        @state = get_state
        @type = get_type
        @url = build_url
        @project = get_project
    end

    def get_title
        @datahash["fields"]["System.Title"]
    end

    def get_type
        @datahash["fields"]["System.WorkItemType"]
    end

    def get_tags
        @datahash["fields"]["System.Tags"].nil? ? "" : @datahash["fields"]["System.Tags"]
    end

    def get_state
        @datahash["fields"]["System.State"]
    end

    def get_project
        @datahash["fields"]["System.TeamProject"]
    end

    def get_createdby
        [@datahash["fields"]["System.CreatedBy"]["displayName"], @datahash["fields"]["System.CreatedBy"]["uniqueName"]]
    end

    def get_resolvedby
        @datahash["fields"]["Microsoft.VSTS.Common.ResolvedBy"]["uniqueName"]
    end

    def get_createdDate
        @datahash["fields"]["System.CreatedDate"]
    end

    def get_relations(relationship)
        relations = @datahash["relations"]
        if relations.nil?
            return ''
        end

        relationship_array = Array.new
        relations.each do |relation|    
            if relation["attributes"]["name"].eql? relationship
                ticket_url = relation["url"]
                ticket_id_regex = ticket_url.match /workItems\/(.*)/
                ticket_id = ticket_id_regex[1]
                relationship_array.push ticket_id
            end
        end
        relationship_array
    end 

    def build_url
        File.join @org, get_project, '_workitems', 'edit', @item_id.to_s
    end

    private

    def az_cmd_response
        SafeShell.execute!("#{@az_cmd}", "boards", "work-item", "show", "--id", "#{@item_id}", "--org", "#{@org}") 
    end

end
