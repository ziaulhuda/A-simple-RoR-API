app.controller('commentsController', function($scope, $rootScope, $http, $location, services,$routeParams) {
	$scope.services = services;
	$scope.hideform = true; 
	$scope.edit = false;
	$scope.incomplete = false;

	
	$scope.get = function(){
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		$scope.post_id = $routeParams.id;
		$http.get("/posts/"+$scope.post_id+"/comments/")
		.then(function mySuccess(response) {
			$scope.comments = response.data;
		}, function myError(response) {
			$rootScope.errorMessage = response.data.error;
		});
    };
	
	$scope.deleteComment = function(index){
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		$http.delete("/posts/"+$scope.post_id+"/comments/"+$scope.comments[index].id)
		.then(function mySuccess(response) {
			$scope.comments.splice(index,1);
			$rootScope.successMessage = "Comment deleted successfully"
		}, function myError(response) {
			$rootScope.errorMessage = response.data.error;
		});
    };
	
	$scope.editComment = function(index){
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		
		$scope.index = index;
		
		$scope.hideform = false;
		
		if (index == 'new') {
		    $scope.edit = false;
		    $scope.incomplete = true;
		    $scope.body = 'body';
		    } else {
		    $scope.edit = true;
		    $scope.body = $scope.comments[index].body; 
		  }
    };
	
	$scope.submit = function(commentForm){
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		
		if(commentForm.body.$invalid ){
			return false;
		}
		var params = {body: $scope.body};
		if($scope.edit){//update a comment
			$http.put("/posts/"+$scope.post_id+"/comments/"+$scope.comments[$scope.index].id, params)
			.then(function mySuccess(response) {
				$scope.comments[$scope.index].body =  $scope.body;
				$scope.hideform = true; 
				$scope.edit = false;
				$scope.incomplete = false;
				$scope.index = null;
				$rootScope.successMessage = "Comment updated successfully"
			}, function myError(response) {
				$rootScope.errorMessage = response.data.error;
			});
			
		}
		else{//create new comment
			$http.post("/posts/"+$scope.post_id+"/comments/", params)
			.then(function mySuccess(response) {
				$scope.hideform = true; 
				$scope.edit = false;
				$scope.incomplete = false;
				$scope.index = null;
				$scope.comments.push( response.data);
				$rootScope.successMessage = "Comment created successfully"
			}, function myError(response) {
				$rootScope.errorMessage = response.data.error;
			});
		}
    };
	
});