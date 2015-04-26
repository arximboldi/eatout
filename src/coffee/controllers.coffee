
eob_controllers = angular.module 'eob.controllers', []

DROP_DELAY = 200

BERLIN_POS = new google.maps.LatLng 52.5170423, 13.4018519

ASCII_ART = "Made with ❤ by\n"+
"\t\t\t   /\\/\\   __ _ _ __(_) __ _ \n"+
"\t\t\t  /    \\ / _` | '__| |/ _` |\n"+
"\t\t\t / /\\/\\ \\ (_| | |  | | (_| |\n"+
"\t\t\t \\/    \\/\\__,_|_|  |_|\\__,_|"

MARKER_ICONS =
    #bakery: 'images/icons/SVG/muffin.svg'
    #beer: 'images/icons/SVG/beer.svg'
    breakfast: 'images/icons/SVG/coffee.svg'
    brunch: 'images/icons/SVG/brunch.svg'
    burger: 'images/icons/SVG/burger.svg'
    cocktails: 'images/icons/SVG/cocktails.svg'
    #croissant: 'images/icons/croissant.png'
    #cheese: 'images/icons/cheese.png'
    french: 'images/icons/SVG/french.svg'
    german: 'images/icons/SVG/german.svg'
    icecream: 'images/icons/SVG/icecream.svg'
    japanese: 'images/icons/SVG/sushi.svg'
    mexican: 'images/icons/SVG/mexican.svg'
    italian: 'images/icons/SVG/pizza.svg'
    portuguese: 'images/icons/SVG/sardine.svg'
    spanish: 'images/icons/SVG/spanish.svg'
    sandwich: 'images/icons/SVG/sandwich.svg'
    viet: 'images/icons/SVG/ramen.svg'
    foodtruck: 'images/icons/SVG/food-truck.svg'


MAP_STYLES = [
  {
      stylers: [
        { hue: "#5ebf64" },
        { saturation: -20 }
      ]
  },{
      featureType: "road",
      elementType: "geometry",
      stylers: [
        { lightness: 100 },
        { visibility: "simplified" }
      ]
  },{
      featureType: "road",
      elementType: "labels",
      stylers: [
        { visibility: "on" }
      ]
  },{
      featureType: "road.highway",
      elementType: "labels",
      stylers: [
        { visibility: "off" }
      ]
  },{
      featureType: "administrative.locality",
      elementType: "all",
      stylers: [
        { color: "#ff1526" },
        { weight: 0.4 }
      ]
  },{
      featureType: "water",
      elementType: "geometry",
      stylers: [
        { color: "#05C7F2" }
      ]
  },{
      featureType: "landscape",
      stylers: [
        { hue: "#FFB20E" },
        { saturation: 20 }
      ]
  },{
      featureType: "transit.line",
      stylers:  [
        { visibility: "off" }
      ]
  },{
      featureType: "poi",
      elementType: "labels",
      stylers:  [
        { visibility: "off" }
      ]
  },{
      featureType: "poi.school",
      elementType: "all",
      stylers:  [
        { visibility: "off" }
      ]
  },{
      featureType: "poi.business",
      elementType: "label",
      stylers:  [
        { visibility: "off" }
      ]
  },{
      featureType: "poi.sports_complex",
      elementType: "all",
      stylers:  [
        { visibility: "off" }
      ]
  },{
      featureType: "poi.medical",
      elementType: "all",
      stylers:  [
        { visibility: "off" }
      ]
  },{
      featureType: "landscape",
      elementType: "geometry",
      stylers:  [
        { visibility: "off" }
      ]
  }
]


eob_controllers.controller 'eob_WeatherCtrl', ($scope, eob_weather) ->
    eob_weather.getWeather $scope
    return

eob_controllers.controller 'eob_MenuCtrl', ($scope, $location, eob_data) ->

    eob_data.districtsPromise.success (data) ->
        $scope.districts = data

        $scope.foodTypes = Object.keys MARKER_ICONS
        $scope.allChecked = true
        $scope.foodTypeChecked = {}

    $scope.menuFindMe = ->
        $location.path "/"
        $scope.findMe true

    $scope.openSuggestion = ->
        $location.path '/suggestion'

    $scope.menuSelectAll = ->
        $scope.allChecked = true
        $scope.foodTypeChecked = {}
        $scope.filterMarkers $scope.foodTypes

    $scope.menuSelectFoodType = (food) ->
        $scope.allChecked = false
        $scope.foodTypeChecked[food] = !$scope.foodTypeChecked[food]
        checkedTypes = _.filter $scope.foodTypes, (foodtype) ->
            $scope.foodTypeChecked[foodtype]

        if _.isEmpty checkedTypes then $scope.menuSelectAll()
        else $scope.filterMarkers checkedTypes

    $scope.menuSelectDistrict = (district) ->
        $scope.active = ''
        $scope.centerPosition district.lat, district.lng, district.zoom

    $scope.toggleItem = (item) ->
        $scope.active = (if $scope.active is item then '' else item)

    $scope.isActive = (item) ->
        $scope.active is item

    return


eob_controllers.controller 'eob_MapCtrl', ($scope, $http, $location,
             eob_data, eob_geolocation, eob_imgCache) ->

    eob_imgCache.load MARKER_ICONS

    # display my name one time on the console!
    console.log ASCII_ART
    $scope.seemenu = true
    $scope.seepanel = false
    $scope.expandpanel = 50
    $scope.place = null
    $scope.panel = true
    $scope.suggestions = true
    findMeMarker = null

    $scope.hidePanel = ->
        $scope.seepanel = false
        $scope.expandpanel = 50

    $scope.showPanel = ->
        $scope.seepanel = true
        if window.innerWidth < 760
            do $scope.hideMenu

    $scope.hideMenu = ->
        $scope.seemenu = false

    $scope.showMenu = ->
        $scope.seemenu = true

    $scope.expandPanel = ->
        $scope.hideMenu()
        $scope.expandpanel = if $scope.expandpanel is 100 then 50 else 100

    $scope.toggleMenu = ->
        $scope.seemenu = !$scope.seemenu

    $scope.setPlace = (place) -> $scope.place = place
    $scope.setSuggestions = (place) -> $scope.suggestions = place
    $scope.setPanel = (panel) -> $scope.panel = panel

    $scope.openPlace = (placeSlug) ->
        $location.path '/place/' + placeSlug
        do $scope.$apply

    $scope.centerPosition = (lat, lng, zoom) ->
        center = new google.maps.LatLng(lat, lng)
        # The panel might be changing right now, in which case
        # 'offsetWidth' returns 0, so let's deffer this
        if $scope.seepanel or $scope.seemenu
            setTimeout (->
                mapWidth = document.getElementById("map-canvas").offsetWidth
                panelWidth = if not $scope.seepanel \
                             then 0 else document.getElementById("main-panel").offsetWidth
                menuWidth  = if not $scope.seemenu \
                             then 0 else document.getElementById("main-menu").offsetWidth
                panelWidth = 0  if panelWidth >= mapWidth
                adjust = panelWidth / 2 - menuWidth / 2
                map.panTo center
                map.setZoom zoom  if zoom
                map.panBy adjust, 0
              ), 0
        else
            map.panTo center
            if zoom then map.setZoom zoom

    $scope.getLocation = ->
        eob_geolocation.getCurrentPosition (position) ->
            eob_imgCache.load(_.pick MARKER_ICONS, 'findme').then ->
                pos = new google.maps.LatLng position.coords.latitude,
                                             position.coords.longitude

    $scope.findMe = (center) ->
      eob_geolocation.getCurrentPosition (position) ->
        eob_imgCache.load( _.pick MARKER_ICONS, 'findme').then ->
          pos = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
          if findMeMarker isnt null
              markers.splice markers.indexOf(findMeMarker), 1
              findMeMarker.setMap null

          findMeMarker = new google.maps.Marker
              map: map
              position: pos
              icon: "images/SVG/iamhere.svg"
              animation: google.maps.Animation.DROP
              zIndex: 9999999

          markers.push findMeMarker

          $scope.centerPosition position.coords.latitude, position.coords.longitude  if center

          getSuggestedPlaces pos, $scope.places

    eob_data.placesPromise.success (data) ->
        $scope.places = data

    mapData =
        center: BERLIN_POS
        zoom: 13
        disableDefaultUI: true
        mapTypeId: google.maps.MapTypeId.ROADMAP
        styles: MAP_STYLES

    map = new google.maps.Map(document.getElementById('map-canvas'), mapData)
    markers = []

    addMarkersFrom = (index) ->
        index = 0 if index is null

        if index >= 0 and index < $scope.places.length
            place = $scope.places[index]
            eob_imgCache.load(_.pick(MARKER_ICONS, place.foodtype)).then ->
                image =
                    url: MARKER_ICONS[place.foodtype]
                    size: new google.maps.Size(70, 85)
                    scaledSize: new google.maps.Size(70, 85)

                marker = new google.maps.Marker
                    position: new google.maps.LatLng place.lat, place.lng
                    map: map
                    title: place.name
                    icon: image
                    animation: google.maps.Animation.DROP

                markers.push marker
                google.maps.event.addListener marker, "click", ->
                    $scope.openPlace place.slug
                    return

                setTimeout _.partial(addMarkersFrom, index + 1), DROP_DELAY
                return
        else if index is $scope.places.length
            $scope.findMe false

    $scope.filterMarkers = (types) ->
        _.map markers, (marker) ->
            visible = undefined != _.find types, (type) ->
                marker.getIcon().url is MARKER_ICONS[type]
            marker.setVisible visible

    getSuggestedPlaces = (pos, places) ->
        suggestions = {}
        i = 0
        min = 999

        for place, i in places
            placePos = new google.maps.LatLng(place.lat, place.lng)
            distance = (google.maps.geometry.spherical.computeDistanceBetween( pos, placePos ) / 1000).toFixed(2)
            place.distance = distance
            if min > distance then min = distance

        if min >= 999 then suggestions = null
        # Get the closest places
        newPlaces = places.slice 0
        newPlaces.sort compareDistances
        suggestions = newPlaces.slice 0,5
        return suggestions

    compareDistances = (a,b) ->
        if a.distance < b.distance then return -1
        if a.distance > b.distanc then return 1
        return 0

    fitBounds = (markers) ->
        bounds = new google.maps.LatLngBounds()
        for marker, i in markers
            if marker.getVisible() is true
                bounds.extend marker.getPosition()
        map.fitBounds bounds

    # do something only the first time the map is loaded
    google.maps.event.addListenerOnce map, 'tilesloaded', ->
        eob_data.placesPromise.then _.partial(addMarkersFrom, 0)

    return

eob_controllers.controller 'eob_PlaceCtrl', ($scope, $location, $window) ->
    shareMsg = (place) ->
         'I found delicious ' + place.foodtype + ' at '+ place.name + ' via #EatOutBerlin'

    twitterShareUrl = ->
        event = event or window.event
        if event.stoppPropagation then event.stopPropagation()
        else (event.cancelBubble = true)

        place = $scope.place
        if place
            msg = shareMsg place
            return 'http://twitter.com/share?' +
                'text=' + $window.encodeURIComponent(msg) +
                '&url=' + $location.absUrl()

        return ''

    externalize = (url) ->
        $location.protocol() +
            '://' + $location.host() +
            '/' + url

    $scope.twitterShare = ->
        $window.open(
            twitterShareUrl(),
            'height=450, width=550' +
                ', top='    + ($window.innerHeight/2 - 225) +
                ', left=' + ($window.innerWidth/2 - 275) +
                ', toolbar=0, location=0, menubar=0, directories=0, scrollbars=0')

    $scope.facebookShare = ->
        event = event || window.event
        if event.stoppPropagation then event.stopPropagation()
        else (event.cancelBubble = true)
        place = $scope.place
        if place
            msg = shareMsg(place)
            FB.ui({
                method: 'feed'
                link: $location.absUrl()
                picture: externalize(place.images[0])
                name: "Eat Out Berlin: " + place.name
                description: place.description
            }, -> )

    return


eob_controllers.controller 'eob_PlaceUrlCtrl', ($scope, $routeParams, eob_data) ->
    eob_data.placesPromise.success (places) ->
        place = _.findWhere(places,
            slug: $routeParams.placeSlug
        )
        if place isnt undefined
            $scope.setPanel "place"
            $scope.setPlace place
            $scope.showPanel()
            $scope.centerPosition place.lat, place.lng, 16
        else
            alert "Place not found: " + $routeParams.placeSlug
    return

eob_controllers.controller 'eob_SuggestionUrlCtrl', ($scope, eob_data) ->
    eob_data.placesPromise.success (places) ->
        $scope.setPanel 'suggestion'
        $scope.setSuggestions places
        $scope.showPanel()
        return

eob_controllers.controller 'eob_NoPlaceUrlCtrl', ($scope) ->
    do $scope.hidePanel
    return
