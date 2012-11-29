if (!window.SmartJourney) {
  window.SmartJourney = {};
}

(function() {

  //ctor
  var FeedMap = function(reports) {

    // private funcs

    var renderReports = function() {
      markers.clearLayers();

      for (var i = 0; i < reports.length; i++) {

        var report = reports[i];
        var marker = new L.Marker(new L.LatLng(report.latitude, report.longitude));

        var markerContent = report.description  + "<br/>";

        if( report.tags_string.length > 0 ) {
          markerContent +=  "<b>Tags:</b> " + report.tags_string + "<br/>";
        }

        markerContent += "<b>Status:</b> " + report.status + "<br/>";

        if (report.incident_begins_in_future) {
          markerContent += "<b>Begins:</b> " + report.incident_begins_at + "<br/>";
        }

        if (report.incident_ends_in_future) {
          markerContent += "<b>Ends:</b> " + report.incident_ends_at + "<br/>";
        }

        if (report.creator) {
          markerContent += "<b>Reporter:</b> " + report.creator + "<br/>";
        }
        markerContent += "<b>Reported:</b> " + report.created_at + "<br/>";
        markerContent += "<a href='/reports/" + report.guid + "'>details</a>";
        marker.bindPopup(markerContent);
        markers.addLayer(marker);
      }
    }

    // setup

    var map = L.map('feed-map').setView([57.15, -2.1], 10);

    var tileUrl = 'http://{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png',
    subDomains = ['otile1','otile2','otile3','otile4'],
    attrib = 'Map tiles: <a href="http://open.mapquest.co.uk" target="_blank">MapQuest</a>, <a href="http://www.openstreetmap.org/" target="_blank">OpenStreetMap</a> and contributors.';

    var tileLayer = new L.TileLayer(tileUrl, {maxZoom: 18, attribution: attrib, subdomains: subDomains});
    tileLayer.addTo(map);

    var markers = new L.MarkerClusterGroup();
    map.addLayer(markers);
    renderReports();

    // privileged funcs
    this.updateReports = function(newReports) {
      reports = newReports;
      renderReports();
    }

  }

  window.SmartJourney.FeedMap = FeedMap;
})();






