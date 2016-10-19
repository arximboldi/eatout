/*
 * eatout - yummy places in the hood
 * Copyright (C) 2014-2016 Maria Carrasco Rodriguez
 *
 * This file is part of eatout.
 *
 * eatout is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * eatout is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with eatout.  If not, see <http://www.gnu.org/licenses/>.
 */

'use strict';

/* jasmine specs for controllers go here */
describe('EOB controllers', function() {

    beforeEach(function(){
	this.addMatchers({
	    toEqualData: function(expected) {
		return angular.equals(this.actual, expected);
	    }
	});
    });

    describe('eob_MapCtrl', function(){
	var scope, ctrl, $httpBackend;

	beforeEach(module('eob.app'));
	beforeEach(module('eob.services'));

	beforeEach(inject(function(_$httpBackend_, $rootScope, $controller) {
	    $httpBackend = _$httpBackend_;
	    $httpBackend.expectGET('data/places.json').
		respond([{"name": "Sala Da Mangiare",
			  "url": "http://www.saladamangiare.de/",
			  "address" : "Mainzer Straße 23",
			  "date" : "2014-09-20",
			  "foodtype": "italian",
			  "lat": 52.480655,
			  "lng": 13.427778,
			  "title": "Homemade Pasta in Neukolln",
			  "description": "We liked the wine, and the homemade licorice liqueur was a surprise.",
			  "rating": 4.6,
			  "recommended": true,
			  "images": ["images/places/SalaDaMangiare/cover.JPG"]
			 }]);

	    scope = $rootScope.$new();
	    ctrl = $controller('eob_MapCtrl', {$scope: scope});
	}));

	it('should create "phones" model with sala da mangiare', inject(function($controller) {
	    console.log("hallo");
	    expect(scope.places[0].name).toBe("Sala Da Mangiare");
	}));
    });
});
