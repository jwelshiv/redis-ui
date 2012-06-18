$(function() {
  $('table.keys').dataTable();

  $('#namespace_tree').jstree({
    "plugins" : [ "themes", "html_data" ]
  });
})