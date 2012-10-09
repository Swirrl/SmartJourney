namespace :fuseki do
  desc 'seed the database'
  task :seed => 'environment' do

    if Rails.env.to_sym == :test
      silent_or_verbose = "s"
      fuseki_data_endpoint = 'http://localhost:3030/winter-test/data'
    elsif Rails.env.to_sym == :development
      silent_or_verbose = "v"
      fuseki_data_endpoint = 'http://localhost:3030/winter/data'
    else
      return #quit. not designed for production.
    end

    #zones
    sh "curl -#{silent_or_verbose} -H 'Content-Type: text/turtle' --upload-file #{Rails.root.join('seed_data/zones.ttl')} #{fuseki_data_endpoint}?graph=#{Zone.graph_uri}"

  end
end