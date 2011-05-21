RUI.model.key = Backbone.Model.extend({
	url : function(){
		if( this.id ) return '/keys/' + this.id
		return '/keys'
	},
	
	initialize: function() {
		
	},
	
});

RUI.collection.keys = Backbone.Collection.extend({
	model : RUI.model.key,
	url : "/keys",
	parse : function(response){
		return response.keys
	}
}); 

RUI.data = {}
RUI.data.keys = new RUI.collection.keys;
