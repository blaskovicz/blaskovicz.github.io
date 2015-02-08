(function() {
  var app;

  app = angular.module("opengathering", []);

  angular.module("opengathering").controller("WelcomeController", [
    "$scope", "$filter", "$http", "$log", function($scope, $filter, $http, $log) {
      var allCards, matchedCards, route;
      route = "http://mtgjson.com/json/AllCards.json";
      $log.debug("loading data");
      allCards = [];
      matchedCards = [];
      $http.get(route).success(function(data) {
        var card, cardName, parsedCards;
        $log.debug("success!");
        parsedCards = [];
        for (cardName in data) {
          card = data[cardName];
          card.cardName = cardName;
          parsedCards.push(card);
        }
        allCards = parsedCards;
        return $scope.loaded = true;
      }).error(function(data) {
        return $log.error("an error occurred: ", data);
      });
      $scope.filter = {
        rawText: ""
      };
      return $scope.filterCards = function() {
        $scope.cards = [];
        matchedCards = $filter("filter")(allCards, $scope.filter.rawText);
        $scope.cards = matchedCards.slice(0, 10);
        return $scope.matches = matchedCards.length;
      };
    }
  ]);

}).call(this);
