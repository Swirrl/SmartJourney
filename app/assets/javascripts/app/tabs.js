/*!
 *  Progressive-enhancey simple tabs (Replaces the ones in Skeleton)
 *  Copyright 2012, Swirrl IT Limited
 *  All rights reserved
 */

(function ($) {

  function initTabs(){
    $('ul.tabs').show(); // show the tabs.
    $('ul.tabs a').bind('click', function(event) {
        event.preventDefault();
        showTab($(this));
    })
    showDefaultTab();
  }

  function showDefaultTab(){
    // if there's no hash in the URL, show the default tab
    var tabelem = $("#default_tab");

    // if there's a hash in the URL, navigate to the appropriate tab instead
    if (window.location.hash) {
      var hashTabElem = $("ul.tabs li a[href='" + window.location.hash + "']");
      if(hashTabElem.length > 0) {
        showTab($(hashTabElem[0]));
      } else {
        showTab(tabelem);
      }
    } else {
      showTab(tabelem);
    }
  }

  function showTab(tabelem){
     tabelem.addClass('active').parent().siblings().find('a').removeClass('active');
     var section = $(tabelem.attr("href"));
     section.siblings("section.tab-content").hide();
     section.show();
   }

  $(initTabs);

})(jQuery);