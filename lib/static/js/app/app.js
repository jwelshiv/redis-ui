// main app
window.RUI = {
	model : {},
	collection : {},
	controller : {},
	view : {},
	template : {}
}

RUI.template.key = _.template("<li class='key'><%= id %><em><%= type %></em></li>")

RUI.view.main = Backbone.View.extend({
	initialize: function(){
		RUI.data.keys.bind("refresh", this.render)
	},
	
	events : {
		'click' : 'show'
	},
	
	render: function(){
		console.log(RUI.data.keys.toJSON())
		var keys = RUI.data.keys.toJSON()
		_.each(keys, function(key){
			$('#main').append(RUI.template.key(key))
		})
	},
	
	show : function(){
		
	}
	
})