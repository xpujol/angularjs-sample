/**
 - That's used to Filter and orderBy with objects in ngRepeat, as described here https://github.com/angular/angular.js/issues/8458
 - Defined as a module as in https://github.com/petebacondarwin/angular-toArrayFilter/blob/master/toArrayFilter.js
 - And tweaked following this gist to filter out the keys that AngularJS adds to the objects created through the factory (eg. $promise, $resolved)
   https://gist.github.com/rachelhigley/7966093
*/

angular.module('angular-toArrayFilter', [])

.filter('toArray', function () {
	return function (obj, addKey) {
		if ( addKey === false ) {
			return Object.keys(obj).map(function(key) {
				return obj[key];
			});
		} else {
			return Object.keys(obj).filter(function(key){if(key.charAt(0) !== "$") {return key;}}).map(function (key) {
				return Object.defineProperty(obj[key], '$key', { enumerable: false, value: key});
			});
		}
	};
});
