# reopen sparqlclient to add caching

# this module is responsible for connecting to an http sparql endpoint
module Tripod::SparqlClient

  module Query

    # Runs a +sparql+ query against the endpoint. Returns a RestClient response object.
    #
    # @example Run a query
    #   Tripod::SparqlClient::Query.query('SELECT * WHERE {?s ?p ?o}')
    #
    # @return [ RestClient::Response ]
    def self.query(sparql, format='json', headers = {})

      begin
        params = { :params => {:query => sparql, :output => format } }
        hdrs = headers.merge(params)

        # CHANGE: wrap the request in a block which caches the results of a query in the rails cache.
        cache_sparql_results('SPARQL-query-' + Digest::SHA2.hexdigest([sparql, format, hdrs].join)) do

          Rails.logger.debug('actually executing query:')
          Rails.logger.debug(sparql)

          RestClient::Request.execute(
            :method => :get,
            :url => Tripod.query_endpoint,
            :headers => hdrs,
            :timeout => Tripod.timeout_seconds,
          )
        end
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

    def self.cache_sparql_results(cache_key, &block)
      if PublishMyData.cache_sparql_results
        Rails.logger.debug('caching sparql results')
        Rails.cache.fetch(cache_key) do
          yield
        end
      else
        Rails.logger.debug('not caching sparql results')
        yield
      end
    end

  end
end