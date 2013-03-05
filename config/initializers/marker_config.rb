# Marker images in order of priority
#
# To add a new icon, place the map icon at app/assets/images/marker-#{img}.png
#                   and the big version at app/assets/images/marker-#{img}-big.png
#
# If using a new shape of icon (i.e. a new img_class)
#                   place the shadow at app/assets/images/marker-shadow-#{img_class}.png
#                      and the bevel at app/assets/images/marker-bevel-#{img_class}.png
#                      and add the relevant bevel styling to the layout CSS

MARKER_CONFIG = 
[
  {
    :tags => ['road closed'],
    :img => 'closed',
    :img_class => 'rectangle',
    :icon_size => [49, 30],
    :shadow_size => [90, 71]
  },
  
  {
    :tags => ['roadworks'],
    :img => 'roadworks',
    :img_class => 'triangle',
    :icon_size => [36, 32],
    :shadow_size => [46, 42]
  },

  {
    :tags => ['accident'],
    :img => 'accident',
    :img_class => 'oblong',
    :icon_size => [57, 20],
    :shadow_size => [93, 58]
  },

  {
    :tags => ['flood', 'surface water'],
    :img => 'flood',
    :img_class => 'triangle',
    :icon_size => [36, 32],
    :shadow_size => [46, 42]
  },

  {
    :tags => ['ice', 'snow'],
    :img => 'ice',
    :img_class => 'triangle',
    :icon_size => [36, 32],
    :shadow_size => [46, 42]
  },

  {
    :tags => ['traffic jam', 'slow'],
    :img => 'traffic',
    :img_class => 'triangle',
    :icon_size => [36, 32],
    :shadow_size => [46, 42]
  },

  {
    :tags => ['pothole', 'potholes'],
    :img => 'pothole',
    :img_class => 'triangle',
    :icon_size => [36, 32],
    :shadow_size => [46, 42]
  },

  {
    :tags => [],
    :img => 'default',
    :img_class => 'triangle',
    :icon_size => [36, 32],
    :shadow_size => [46, 42]
  }
]