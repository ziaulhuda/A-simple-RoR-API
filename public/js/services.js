//utility function to check if the user is admin or owner of the resource
app.factory('services', function($rootScope) {
	return {
		isOwner: function(uID) {
			if($rootScope.userRole == "admin" || $rootScope.userID == uID){
				return true;
			}
	        	return false;
		},
				
	    canCreate: function() {
			if($rootScope.userRole == "admin" || $rootScope.userRole == "user"){
				return true;
			}
	            return false;
		},
		
	    isAdmin: function() {
			if($rootScope.userRole == "admin"){
				return true;
			}
	            return false;
		}
	};
});

app.factory('httpRequestInterceptor', function ($rootScope) {
  return {
    request: function (config) {

      config.headers['Authorization'] = $rootScope.auth_token;

      return config;
    }
  };
});

app.config(function ($httpProvider) {
  $httpProvider.interceptors.push('httpRequestInterceptor');
});