namespace :fuseki do
  desc 'seed the database'
  task :seed => 'environment' do

    WebMock.allow_net_connect!

    if Rails.env.to_sym == :test
      fuseki_data_endpoint = 'http://localhost:3030/winter-test/data'
    elsif Rails.env.to_sym == :development
      fuseki_data_endpoint = 'http://localhost:3030/winter/data'
    else
      return #quit. not designed for production.
    end

    fuseki_graph_uri = "#{fuseki_data_endpoint}?graph=#{Zone.graph_uri.to_s}"
    filename = "#{Rails.root.join('seed_data/zones.ttl')}"

    response = RestClient::Request.execute(
      :method => :put,
      :url => fuseki_graph_uri,
      :payload =>  File.read(filename),
      :headers => {content_type: 'text/turtle'},
      :timeout => 300
    )

  end
end