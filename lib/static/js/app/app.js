// main app
window.RUI = {
	model : {},
	collection : {},
	controller : {},
	view : {},
	template : {}
}

RUI.template.key = _.template(
	"<tr class='key'><td><%= type %></td><td><%= key %></td></tr>"
)

RUI.template.table = _.template(
	"<table><%= RUI.template.table.row %></table>"
)

RUI.template.table.rows = "<tr> <% _.each(, function(key, val) { %> <td><%= val %></td> <% }); %></tr>";


RUI.view.header = Backbone.View.extend({

	events : {
		'a.server click' : 'server'
	},
	
	initialize: function(){
		
	},
	
	render: function(){

	},
	
	server : function(){
		
	}
	
})


RUI.view.main = Backbone.View.extend({

	events : {
		'tr click' : 'show'
	},
	
	initialize: function(){
		this.collection.bind('refresh', _.bind(this.render, this)); 
	},
	
	render: function(){
		var table = $('<table>')
		
		_.each(this.collection.toJSON(), function(key){ 
			table.append(RUI.template.key(key))	
		})

		$('#main').html(table)
	},
	
	show : function(){
		
	}
	
})

