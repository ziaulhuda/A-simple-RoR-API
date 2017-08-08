app.controller('authorizeController', function($scope, $rootScope, $http, $location) {
	$scope.submit = function(signinForm){
		if(signinForm.password.$invalid || signinForm.email.$invalid){
			return false;
		}
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		var credentials = {email: $scope.email, password: $scope.password};
		$http.post("/signin", credentials)
		.then(function mySuccess(response) {
			$rootScope.userID = response.data.id;
			$rootScope.auth_token = response.data.auth_token;
			$rootScope.userRole = response.data.role;
			$rootScope.userName = response.data.name;
			$location.path("/posts");
		}, function myError(response) {
			$rootScope.errorMessage = response.data.error;
		});
    };
	
	$scope.signout = function(){
		if(!$rootScope.auth_token){
			return false
		}
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		var credentials = {id: $rootScope.userID}
		$http.delete("/signout/"+$rootScope.userID, credentials)
		.then(function mySuccess(response) {
			$rootScope.userID = null;
			$rootScope.auth_token = null;
			$rootScope.userRole = null;
			$rootScope.userName = null;
			$location.path("/");
			$rootScope.successMessage = "Signout Successfull";
		}, function myError(response) {
			$rootScope.errorMessage = response.data.error;
		});
	};
});