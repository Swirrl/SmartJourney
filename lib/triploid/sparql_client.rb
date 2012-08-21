# encoding: utf-8
module Triploid

  module SparqlClient

    # Runs a +sparql+ query against the endpoint. Returns a RestClient response object.
    #
    # @example Run a query
    #   Tripload::Sparql.query('SELECT * WHERE {?s ?p ?o}')
    #
    # @return [ RestClient::Response ]
    def self.query(sparql, format='json', headers = {})
      begin
        params = { :params => {:query => sparql, :output => format } } # TODO: allow different queries?
        hdrs = headers.merge(params)
        RestClient::Request.execute(
          :method => :get,
          :url => 'http://127.0.0.1:9874/dclg/sparql', # TODO: allow this to be configured
          :headers => hdrs,
          :timeout => 30 #TODO: allow this to be configured.
        )
      rescue RestClient::BadRequest => e
        body = e.http_body
        if body.start_with?('Error 400: Parse error:')
          # TODO: this is a SPARQL parsing exception. Do something different.
          raise e
        else
          raise e
        end
      end
    end

    # Runs a SELECT +query+ against the endpoint. Returns a hash of the results.
    # Specify +raw_format+ if you want the results raw, as returned from the SPARQL endpoint.
    #
    # @param [ String ] query The query to run
    # @param [ String ] raw_format valid formats are: 'json', 'text', 'csv', 'xml'
    #
    # @example Run a SELECT query
    #   Triploid::Sparql.select('SELECT * WHERE {?s ?p ?o}')
    #
    # @return [ Hash, String ]
    def self.select(query, raw_format=nil)
      query_response = PublishMyData::SparqlClient.query(query, (raw_format || 'json'))
      if raw_format
        query_response.body
      else
        JSON.parse(query_response.body)["results"]["bindings"]
      end
    end

    # Executes a DESCRIBE +query+ against the SPARQL endpoint.
    # Executes the +query+ and returns ntriples by default
    #
    # @example Run a DESCRIBE query
    #  Triploid::Sparql.select('DESCRIBE <http://foo>')
    #
    # @param [ String ] query The query to run
    # @param [ String ] accept_header The header to pass to the database.
    # 
    # @return [ String ] the raw response from the endpoint
    def self.describe(query, accept_header='application/n-triples')
      response = SparqlClient.query(query, nil, {:accept=>accept_header})
      return response.body
    end

  end
end