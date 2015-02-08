app = angular.module "opengathering", []
angular.module("opengathering").controller "WelcomeController", [
  "$scope"
  "$filter"
  "$http"
  "$log"
  ($scope, $filter, $http, $log) ->
    route = "http://mtgjson.com/json/AllCards.json"
    $log.debug "loading data"
    allCards = []
    matchedCards = []
    $http.get(route)
      .success (data) ->
        $log.debug "success!"
        parsedCards = []
        for cardName, card of data
          card.cardName = cardName
          parsedCards.push card
        allCards = parsedCards
        $scope.loaded = true
      .error (data) ->
        $log.error "an error occurred: ", data
    $scope.filter =
      rawText: ""
    $scope.filterCards = ->
      $scope.cards = []
      matchedCards = $filter("filter")(allCards, $scope.filter.rawText)
      $scope.cards = matchedCards.slice(0,10)
      $scope.matches = matchedCards.length
]
