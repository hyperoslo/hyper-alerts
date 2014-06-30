#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

window.HyperAlerts =
  Models: {
	  Facebook: {}
	  Twitter: {}
  }
  Collections: {
	  Facebook: {}
	  Twitter: {}
  }
  Routers: {}
  Views: {
  	Subscriptions: {
  	  Services: {
  	    Facebook: {}
  	    Twitter: {
  	      Search: {}
  	      Timeline: {}
  	    }
  	  }
  	}
  	Services: {
    	Facebook: {
  	  	Pages: {}
    	}
    	Twitter: {
    	  Timelines: {}
    	}
    }
  }
