app = angular.module "opengathering", ["firebase"]
angular.module("opengathering").controller "WelcomeController", [
  "$scope"
  "$filter"
  "$http"
  "$log"
  ($scope, $filter, $http, $log) ->
#    route = "http://mtgjson.com/json/AllCards.json"
    firebase = new Firebase "https://blazing-torch-8857.firebaseio.com/"
    $log.debug "loading data"
    allCards = []
    matchedCards = []
    firebase.child("cards").on("value",
      (data) ->
        $log.debug "success!"
        parsedCards = []
        for cardName, card of data.val()
          card.cardName = cardName
          parsedCards.push card
        allCards = parsedCards
        $scope.loaded = true
    )
    $scope.filter =
      rawText: ""
    $scope.filterCards = ->
      $scope.cards = []
      matchedCards = $filter("filter")(allCards, $scope.filter.rawText)
      $scope.cards = matchedCards.slice(0,10)
      $scope.matches = matchedCards.length
]
