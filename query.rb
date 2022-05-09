require 'json'

class Query

    attr_reader :results
    attr_reader :query_id

    def initialize(org, queryid)
        @org = org
        @query_id = queryid
        @az_cmd = '/usr/local/bin/az'
        @datahash = JSON.parse(az_cmd_response)
        @results = get_results
    end

    def get_results

        query_list = @datahash
        results_array = Array.new

        query_list.each do |item|
            results_array.push item["fields"]["System.Id"]
        end

        results_array
    end

    private

    def az_cmd_response
        SafeShell.execute!("#{@az_cmd}", "boards", "query", "--id", "#{query_id}", "--org", "#{@org}") 
    end
end