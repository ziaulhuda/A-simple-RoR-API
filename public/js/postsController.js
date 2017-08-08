app.controller('postsController', function($scope, $rootScope, $http, $location, services,$routeParams) {
	$scope.services = services;
	$scope.hideform = true; 
	$scope.edit = false;
	$scope.incomplete = false;
	
	$scope.show = function(){
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		$http.get("/posts/"+$routeParams.id)
		.then(function mySuccess(response) {
			$scope.selectedPost = response.data;
		}, function myError(response) {
			$rootScope.errorMessage = response.data.error;
		});
	};
	
	$scope.get = function(){
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		$http.get("/posts")
		.then(function mySuccess(response) {
			$scope.posts = response.data;
		}, function myError(response) {
			$rootScope.errorMessage = response.data.error;
		});
    };
	
	$scope.deletePost = function(index){
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		$http.delete("/posts/"+$scope.posts[index].id)
		.then(function mySuccess(response) {
			$scope.posts.splice(index,1);
			$rootScope.successMessage = "Post deleted successfully"
		}, function myError(response) {
			$rootScope.errorMessage = response.data.error;
		});
    };
	
	$scope.editPost = function(index){
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		
		$scope.index = index;
		
		$scope.hideform = false;
		
		if (index == 'new') {
		    $scope.edit = false;
		    $scope.incomplete = true;
		    $scope.title = 'Title';
		    $scope.body = 'body';
		    } else {
		    $scope.edit = true;
		    $scope.title = $scope.posts[index].title;
			$scope.body = $scope.posts[index].body; 
		  }
    };
	
	$scope.submit = function(postForm){
		$rootScope.errorMessage = "";
		$rootScope.successMessage = "";
		
		if(postForm.body.$invalid || postForm.title.$invalid){
			return false;
		}
		var params = {title: $scope.title, body: $scope.body};
		if($scope.edit){//update a post
			$http.put("/posts/"+$scope.posts[$scope.index].id, params)
			.then(function mySuccess(response) {
				$scope.posts[$scope.index].title =  $scope.title;
				$scope.posts[$scope.index].body =  $scope.body;
				$scope.hideform = true; 
				$scope.edit = false;
				$scope.incomplete = false;
				$scope.index = null;
				$rootScope.successMessage = "Post updated successfully"
			}, function myError(response) {
				$rootScope.errorMessage = response.data.error;
			});
			
		}
		else{//create new post
			$http.post("/posts", params)
			.then(function mySuccess(response) {
				$scope.hideform = true; 
				$scope.edit = false;
				$scope.incomplete = false;
				$scope.index = null;
				$scope.posts.push( response.data);
				$rootScope.successMessage = "Post created successfully"
			}, function myError(response) {
				$rootScope.errorMessage = response.data.error;
			});
		}
    };
	
});