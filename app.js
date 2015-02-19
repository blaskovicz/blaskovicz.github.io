(function() {
  var app;

  app = angular.module("opengathering", ["firebase"]);

  angular.module("opengathering").controller("WelcomeController", [
    "$scope", "$filter", "$http", "$log", function($scope, $filter, $http, $log) {
      var allCards, firebase, matchedCards;
      firebase = new Firebase("https://blazing-torch-8857.firebaseio.com/");
      $log.debug("loading data");
      allCards = [];
      matchedCards = [];
      firebase.child("cards").on("value", function(data) {
        var card, cardName, parsedCards, _ref;
        $log.debug("success!");
        parsedCards = [];
        _ref = data.val();
        for (cardName in _ref) {
          card = _ref[cardName];
          card.cardName = cardName;
          parsedCards.push(card);
        }
        allCards = parsedCards;
        return $scope.loaded = true;
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
