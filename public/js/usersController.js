app.controller('usersController', function($scope, $rootScope, $http, $location, services) {
	$scope.services = services;
	$scope.hideform = true; 
	$scope.edit = false;
	$scope.incomplete = false;
	$scope.showUser=false;
	if(services.isAdmin){
		$scope.roles = ["admin", "user", "guest"];
	}else{
		$scope.roles = ["guest"];
	}
	
	$scope.showUserDetails = function(index){
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		$scope.showUser=true;
		$http.get("/users/"+$scope.users[index].id)
		.then(function mySuccess(response) {
			$scope.selectedUser = response.data;
		}, function myError(response) {
			$rootScope.errorMessage = response.data.error;
		});
	};
	
	$scope.toggleShowUser = function(){
		$scope.showUser = !$scope.showUser;
	};
	
	$scope.get = function(){
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		$http.get("/users")
		.then(function mySuccess(response) {
			$scope.users = response.data;
		}, function myError(response) {
			$rootScope.errorMessage = response.data.error;
		});
    };
	
	$scope.deleteUser = function(index){
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		$http.delete("/users/"+$scope.users[index].id)
		.then(function mySuccess(response) {
			if(services.isAdmin){
				$scope.users[index].disabled = true;
			}else{
				$scope.users.splice(index,1);
			}
			$rootScope.successMessage = "User deleted successfully"
		}, function myError(response) {
			$rootScope.errorMessage = response.data.error;
		});
    };
	
	$scope.editUser = function(index){
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		
		$scope.index = index;
		
		$scope.hideform = false;
		
		if (index == 'new') {
		    $scope.edit = false;
		    $scope.incomplete = true;
		    $scope.name = 'Name';
		    $scope.email = 'email@company.domain';
			if(services.isAdmin()){
				$scope.role = "guest"
				$scope.diabled = false;
			}
	    } else {
			$scope.edit = true;
		    $scope.name = $scope.users[index].name;
		    $scope.email = $scope.users[index].email;
			if(services.isAdmin()){
				$scope.role = $scope.users[index].role;
				$scope.disabled = $scope.users[index].disabled;
			}
	  	}
 	};
	
	$scope.submit = function(userForm){
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		
		if(userForm.name.$invalid || userForm.email.$invalid){
			return false;
		}
		if(!$scope.edit){
			if(userForm.password.$invalid){
				return false;
			}
		}
		var object = {name: $scope.name, email: $scope.email, password: $scope.password};
		if(services.isAdmin){
			object.role = $scope.role;
			object.disabled = $scope.disabled;
		}
		if($scope.edit){//update a user
			$http.put("/users/"+$scope.users[$scope.index].id, object)
			.then(function mySuccess(response) {
				$scope.users[$scope.index].name =  $scope.name;
				$scope.users[$scope.index].email =  $scope.email;
				if(services.isAdmin){
					$scope.users[$scope.index].role =  $scope.role;
					$scope.users[$scope.index].disabled =  $scope.disabled;
				}
				$scope.hideform = true; 
				$scope.edit = false;
				$scope.incomplete = false;
				$scope.index = null;
				$rootScope.successMessage = "User updated successfully"
			}, function myError(response) {
				$rootScope.errorMessage = response.data.error;
			});
			
		}
		else{//create new user
			$http.post("/users", object)
			.then(function mySuccess(response) {
				$scope.hideform = true; 
				$scope.edit = false;
				$scope.incomplete = false;
				$scope.index = null;
				$scope.users.push( response.data);
				$rootScope.successMessage = "User created successfully"
			}, function myError(response) {
				$rootScope.errorMessage = response.data.error;
			});
		}
    };
	
});