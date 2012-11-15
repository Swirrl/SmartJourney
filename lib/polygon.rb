module Polygon

  # x,y define a point
  # poly is an array of [x,y] points defining a closed loop - a 'linear ring'
  def self.point_in_ring(x,y,ring)

    # count number of times a horizontal ray from the test point crosses the polygon
    even = true
    (0...ring.length).each do |i|
      if ( ((ring[i][1] > y) != (ring[i-1][1] > y)) &&
              (x < (ring[i-1][0]-ring[i][0]) * (y-ring[i][1]) / (ring[i-1][1]-ring[i][1]) + ring[i][0]) )
        even = !even
      end
    end

    return !even # because if the number of crossings is even, then the point is not inside the polygon

  end

  # x,y define a point
  # poly is a 3 level array - the value of the "coordinates" key-value pair in a geoJSON Polygon (not a MultiPolygon)
  #  - comprising an outer ring and zero or more inner rings ('holes')
  def self.point_in_poly(x,y,poly)
    in_poly = false

    outer = poly.first
    if point_in_ring(x,y,outer)
      in_poly = true
      if poly.length > 1
        # inner rings - if inside an inner ring, then not in the overall poly
        poly[1...poly.length].each do |inner|
          in_poly = false if point_in_ring(x,y,inner)
        end
      end
    end

    return in_poly
  end

  # x,y define a point
  # zone should be a Ruby Hash representing a geoJSON polygon or multipolygon
  def self.point_in_zone(x,y, zone)

    in_zone = nil
    coords = zone["coordinates"]
    if zone["type"] == "Polygon"
      in_zone = point_in_poly(x,y,coords)

    elsif zone["type"] == "MultiPolygon"
      # loop over polygons - see if the point is inside any of them
      in_zone = false
      coords.each do |polygon|
        in_zone = true if point_in_poly(x,y,polygon)
      end

    else
      raise "point_in_zone: Unknown polygon type"
    end


  end


end