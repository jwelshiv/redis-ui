$(function() {

  $('table.keys').dataTable({
    "bStateSave": true
  });
  
  $('#namespace_tree').bind("loaded.jstree", function (event, data) {
    $(this).jstree("open_all");
  }).jstree({
    "core" : {
      "animation": 20
    },
    "plugins" : [ "themes", "html_data" ]
  });


  function maybe_auto_refresh() {
    if($('#auto-refresh').prop('checked')) {
      $.ajax({
        type: 'get',
        dataType: 'html',
        accepts: 'html',
        url: window.location.href, 
        success: function(response) {
          $('#namespaces').replaceWith($('#namespaces', response))
          $('#data_table').replaceWith($('#data_table', response))
        }
      });
    }
    window.setTimeout(maybe_auto_refresh, 2000);
  }

  //window.setTimeout(maybe_auto_refresh, 2000);

})