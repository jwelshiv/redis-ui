var RedisUI = {};
RedisUI.prefs = {
  "warn-on-del": true,
  "num-entries" : "25"
}

$(function() {
  

  RedisUI.keytable = $('table.keys').dataTable({
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


  // update prefs from cookie if available,
  // else set the cookie
  for(var key in RedisUI.prefs) {
    if (val = $.cookie(key)) {
      RedisUI.prefs[key] = val
    } else {
      $.cookie(key, RedisUI.prefs[key])
    }
  }
  
  // Todo: give them a type so we can loop through instead of this?
  // (if there are ever more than just checkboxes, anyway...)
  $('#warn-on-del').prop("checked", RedisUI.prefs['warn-on-del'] == "true");
  $('[name=DataTables_Table_0_length]').val(RedisUI.prefs['num-entries'])


  // update pref cookie when changing options
  $('input.pref-cb').click(function(e) {
    $.cookie('warn-on-del', $(this).prop('checked'));
  })
  
  $('[name=DataTables_Table_0_length]').change(function(e) {
    $.cookie('num-entries', $(this).val());
  })






  // ajax delete
  $('a.del').live('click', function(e) {
    e.preventDefault();

    var nodes = RedisUI.keytable.fnGetNodes();
    var row = $(this).closest('tr')[0]
    var key = $(this).data('key')

    if ($('#warn-on-del').prop('checked')){
      if(confirm("This will delete the key:\n\n\""+ key +"\"\n\n...from the DB. Are you sure?") ){
        doit(this)
      }
    } else {
      // just do it!
      doit(this)
    }
    
    function doit(element){
      $.post($(element).attr('href'), function(response) {
        RedisUI.keytable.fnDeleteRow(row);
      })
    }
  })





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