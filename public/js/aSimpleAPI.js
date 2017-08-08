var app = angular.module("aSimpleAPI", ["ngRoute"]);
app.config(function($routeProvider) {
    $routeProvider
    .when("/", {
        templateUrl : "/partials/signin.html"
    })
    .when("/signin", {
        templateUrl : "/partials/signin.html"
    })
    .when("/signout", {
        templateUrl : "/partials/signout.html"
    })
    .when("/posts", {
        templateUrl : "partials/posts/index.html"
    })
    .when("/users", {
        templateUrl : "partials/users/index.html"
    })
    .when("/posts/:id", {
        templateUrl : "partials/posts/show.html"
    });
});

