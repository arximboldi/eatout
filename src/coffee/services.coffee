eob_services = angular.module 'eob.services', []

# https://gist.github.com/bentruyman/1211400
toSlug = (value) ->
  # 1) convert to lowercase
  # 2) remove dashes and pluses
  # 3) replace spaces with dashes
  # 4) remove everything but alphanumeric characters and dashes
    value
      .toLowerCase()
      .replace /-+/g, ''
      .replace /\s+/g, '-'
      .replace /[^a-z0-9-]/g, ''


eob_services.factory 'eob_imgCache', ($q) ->
  loadImg = (url) ->
    promise = $q.defer()
    img = new Image()
    img.src = url
    img.onload  = -> promise.resolve(img)
    img.onerror = -> promise.reject(img)
    promise
    

  cache = {};

  load: (images) ->
    promises = {};
    for key of images
      promise = cache[key];
      if promise == null
        promise = cache[key] = loadImg(images[key]);
      promises[key] = promise
            
    $q.all promises
        


eob_services.factory 'eob_geolocation', ->
  service = {
    getCurrentPosition: (success) ->
      # Try HTML5 geolocation
      if navigator.geolocation
        navigator.geolocation.getCurrentPosition success, ->
          alert "Geolocation failed!"
          return
      else alert "Geolocation not supported by your browser!"
      return
  }
  service


eob_services.factory 'eob_data', ($http, $q) ->
  service = {};

  service.placesPromise = $http.get 'data/places.json'
    .success (data) ->
	    # Order the array by descending vertical position on the map
	    data.sort (a, b) ->
        (b.lat - a.lat)
	    
      # Compute slug information
      data.forEach (place) ->
        place.slug = toSlug place.name
            
	    service.places = data
        

  service.districtsPromise = $http.get 'data/districts.json'
        .success (data) ->
    	    service.districts = data
        

  service.promise = $q.all [service.placesPromise, service.districtsPromise]
    
  service;


eob_services.factory 'eob_weather', ['$http',
  ($http) ->
    FORECAST_ENDPOINT = "http://query.yahooapis.com/v1/public/yql?q="
    FORECAST_YQL_OPEN 	= "select * from weather.forecast where location='"
    FORECAST_YQL_CLOSE 	= "'and u='c'&format=json"
    YQL_BERLIN = "GMXX0007"

    {
      getWeather: (scope) ->
        url = FORECAST_ENDPOINT + FORECAST_YQL_OPEN + YQL_BERLIN + FORECAST_YQL_CLOSE
        $http.get(url).success( (data) ->
          scope.weather = data
          scope.temp = data.query.results.channel.item.condition.temp
          scope.wcode = data.query.results.channel.item.condition.code
        )
    }
  ]