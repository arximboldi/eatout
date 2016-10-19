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


var eob_directives = angular.module('eob.directives', []);

eob_directives
    
    .directive('eob-dropdown', function() {
	return function(scope, element, attr){
	    element.on('click', function(event) {
		if ( element.parent().hasClass('open') ) {
		    element.parent().removeClass('open');
		} else { element.parent().addClass('open'); }
	    });
	};
    })

    .directive('eob_markdown', function() {
	var converter = new Showdown.converter();
	return {
	    restrict: 'E',
	    link: function(scope, element, attrs) {
		var htmlText =  converter.makeHtml(element.text());
		element.html(htmlText);
	    }
	};
    });
