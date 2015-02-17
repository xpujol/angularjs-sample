AutoPanelUsersAdminApp

	.controller( 'UserCtrl', [ '$scope', 'UserFactory', 'ToolFactory', 'MakeFactory', 'ChannelFactory', function ($scope, UserFactory, ToolFactory, MakeFactory, ChannelFactory){

		/**
		 List of factories that have already been retrieved.
		 It should eventually contain ['user','tool','make','channel']
		*/
		var arrFactoryRetrieved = [];

		/**
		 After certain pairs of factories have been retrieved, we need to do some extra processing.
		 We keep track of this processes in this array.
		 It should eventually contain ['usertool','usermake','userchannel']
		*/
		var arrFactoryPairsProcessed = [];


		/**
		 Handle an error in the ajax call for a factory retrieve function
		 *@factoryType  'user', 'tool', 'make' or 'channel'
		 *@err          The error structure returned from the ajax call
		*/
		var handleRetrieveAjaxError = function( factoryType, err ){
			$scope.status.msg = 'Failed to retrieve list of AutoPanel ' + factoryType + 's';
			if( typeof err === 'object' && err.statusText !== undefined ){
				$scope.status.msg += '. <strong>' + err.statusText + '</strong>';
			}
			$scope.status.class = 'danger';
		}

		/**
		 Handle a successful ajax call for a factory retrieve function
		 *@factoryType  'user', 'tool', 'make' or 'channel'
		 *@skvReturn    The structure returned from the ajax call
		 *@forceProcessFactoryType    Whether or not to force the factory pairs to be processed
		*/
		var handleRetrieveAjaxSuccess = function( factoryType, skvReturn, forceProcessFactoryType ){
			// Capitalise factoryType. Ie. 'User', 'Tool', 'Make' or 'Channel'
			var factoryTypeCapital = factoryType.charAt(0).toUpperCase() + factoryType.slice(1);

			if( skvReturn.success ){
				// Load list of tools
				$scope['skv'+factoryTypeCapital] = skvReturn.data;
			}else{
				// The ajax call was successful, but returned an error message
				$scope.status.msg = skvReturn.msg;
				$scope.status.class = 'danger';
			}

			// Add to the list of factories retrieved
			arrFactoryRetrieved.push( factoryType );

			// Calculate skvUser.arrToolName, skvUser.arrMakeName, skvUser.arrChannelName
			tryToProcessFactoryPair( 'tool', forceProcessFactoryType );
			tryToProcessFactoryPair( 'make', forceProcessFactoryType );
			tryToProcessFactoryPair( 'channel', forceProcessFactoryType );
		}

		/**
		 'user' only comes back with an array of tool IDs, make IDs and channel IDs.
		 Let's use the information retrieved by the tool, make and channel factories to populated those IDs with data.
		 *@factoryType    'tool', 'make' or 'channel'
		 *@forceProcessFactoryType    Whether or not to force this factory pair to be processed
		*/
		var tryToProcessFactoryPair = function( factoryType, forceProcessFactoryType ){

			// If all relevant data has been retrieved AND the pair hasn't been processed yet...
			// or if the argument forces the processing to occur
			if(
				( arrFactoryRetrieved.indexOf('user')>-1 && arrFactoryRetrieved.indexOf(factoryType)>-1 && arrFactoryPairsProcessed.indexOf('user'+factoryType)==-1 )
				||
				forceProcessFactoryType
			){
				// Capitalise factoryType. Ie. 'User', 'Tool', 'Make' or 'Channel'
				var factoryTypeCapital = capitalise( factoryType );

				// Loop over users
				for( var userId in $scope['skvUser'] ){

					// This array will contain all the information about the relevant tool/make/channels
					$scope['skvUser'][userId]['arr'+factoryTypeCapital] = [];

					// Loop over tool IDs, make IDs or channel IDs
					for( var i in $scope['skvUser'][userId]['arr'+factoryTypeCapital+'Id'] ){
						// Get tool/make/channel ID
						var thisFactoryProductId = $scope['skvUser'][userId]['arr'+factoryTypeCapital+'Id'][i];
						// Special case: arrMakeId=['all']
						if( thisFactoryProductId=='all' ){
							$scope['skvUser'][userId]['arr'+factoryTypeCapital] = ['all'];
							break;
						}
						// Get tool/make/channel object
						var thisFactoryProduct = $scope['skv'+factoryTypeCapital][thisFactoryProductId];
						// Append it to the users structure
						$scope['skvUser'][userId]['arr'+factoryTypeCapital].push( thisFactoryProduct );
					}

					// Order makes by name; order channels by ID (for tools, do not reorder them)
					if( factoryType=='make' ){
						$scope['skvUser'][userId]['arr'+factoryTypeCapital].sort(sortByObjectProperty('name'));
					}else if( factoryType=='channel' ){
						$scope['skvUser'][userId]['arr'+factoryTypeCapital].sort(sortByObjectProperty('id'));
					}
				}

				// Yeehaa! This pair has been processed
				arrFactoryPairsProcessed.push( 'user'+factoryType );
			}
		}

		/**
		 Handle a successful ajax call for a user creation/update/deletion
		 *@skvReturn    The structure returned from the ajax call
		*/
		var handleCreateUpdateDeleteAjaxSuccess = function( skvReturn ){

			if( !skvReturn.success ){
				// The ajax call was successful, but returned an error message
				$scope.status.msg = skvReturn.msg;
				$scope.status.class = 'danger';

			}else{
				// Hide modal
				$('#user-modal').modal('hide');
				// Reset active action and active user
				$scope.activeAction = '';
				resetSkvActiveUser();
				// Reload list of users and show success message
				retrieveUsers();
				$scope.status.msg = skvReturn.msg;
				$scope.status.class = 'success';
			}

		}

		/**
		 Handle an error in the ajax call for a user creation/update/deletion
		 *@err          The error structure returned from the ajax call
		*/
		var handleCreateUpdateDeleteAjaxError = function( err ){

			if( typeof err !== 'object' ){ err={}; }

			$scope.status.msg = 'Failed to perform the operation';
			if( err.statusText !== undefined ){
				$scope.status.msg += '. <strong>' + err.statusText + '</strong>';
			}
			$scope.status.class = 'danger';

		}

		/**
		 Sort an array of objects by the value of one of its properties
		*/
		var sortByObjectProperty = function( property ) { 
			return function( obj1, obj2 ){
				if (typeof obj1[property] == "number") {
					return (obj1[property] - obj2[property]);
				} else {
					return ((obj1[property] < obj2[property]) ? -1 : ((obj1[property] > obj2[property]) ? 1 : 0));
				}
			};
		}

		/**
		 Capitalise the first letter of a string. Eg. 'foo bar' --> 'Foo bar'
		*/
		var capitalise = function( str ){
			return str.charAt(0).toUpperCase() + str.slice(1);
		}

		/**
		 Retrieve tools, makes and channels
		*/
		$scope.skvTool = {};
		$scope.skvMake = {};
		$scope.skvChannel = {};
		ToolFactory.retrieve(
			{ /* no arguments */ },
			function( skvReturn ) {
				handleRetrieveAjaxSuccess( 'tool', skvReturn, false );
			},
			function( err ) {
				handleRetrieveAjaxError( 'tool', err );
			}
		);
		MakeFactory.retrieve(
			{ /* no arguments */ },
			function( skvReturn ) {
				handleRetrieveAjaxSuccess( 'make', skvReturn, false );
			},
			function( err ) {
				handleRetrieveAjaxError( 'make', err );
			}
		);
		ChannelFactory.retrieve(
			{ /* no arguments */ },
			function( skvReturn ) {
				handleRetrieveAjaxSuccess( 'channel', skvReturn, false );
			},
			function( err ) {
				handleRetrieveAjaxError( 'channel', err );
			}
		);

		/**
		 Retrieve list of users for the first one (we will reuse this function on every data change)
		*/
		$scope.skvUser = {};
		var usersAlreadyRetrievedOnce = false;
		var retrieveUsers = function(){
			UserFactory.retrieve(
				{ /* no arguments */ },
				function( skvReturn ) {
					handleRetrieveAjaxSuccess( 'user', skvReturn, usersAlreadyRetrievedOnce );
					usersAlreadyRetrievedOnce = true;
				},
				function( err ) {
					handleRetrieveAjaxError( 'user', err );
				}
			);
		}
		retrieveUsers();

		/**
		 Default status
		*/
		var setDefaultStatus = function(){
			$scope.status = {
				msg : 'Use this page to add, edit or delete users. You can make tools available to users on an individual basis, and you can attach users to certain makes and channels',
				class : 'info'
			};
		}
		setDefaultStatus();

		/**
		 If we're currently creating/updating/deleting a user, store its information here
		*/
		$scope.activeAction = ''; // create, update or delete
		$scope.activeId = '';
		$scope.skvActiveUser = {};
		$scope.allMakesForActiveUser = false;

		/**
		 Default skvActiveUser
		*/
		var resetSkvActiveUser = function(){
			$scope.skvActiveUser = {
				'role' : 'normal',
				'arrTool' : [],
				'arrToolId' : [],
				'arrMake' : [],
				'arrMakeId' : [],
				'arrChannel' : [],
				'arrChannelId' : []
			};
			$scope.allMakesForActiveUser = false;
		}
		resetSkvActiveUser();

		/**
		 Prompt the 'Create' modal
		*/
		$scope.createPrompt = function(){
			// Reset status
			setDefaultStatus();

			if( $scope.activeAction=='create' ){
				// Carrying on with an unsaved user creation: do not reset data
			}else{
				// Set active action
				$scope.activeAction = 'create';

				// Reset active user data
				resetSkvActiveUser();
			}

			// Display modal
			$('#user-modal').modal();
		}

		/**
		 Prompt the 'Update' modal
		*/
		$scope.updatePrompt = function( id ){
			// Reset status
			setDefaultStatus();

			if( $scope.activeAction=='update' && $scope.activeId==id ){
				// Carrying on with an unsaved user update: do not reset data
			}else{
				// Set active action and user Id
				$scope.activeAction = 'update';
				$scope.activeId = id;

				// Set active user data (deep clone from the original skvUser)
				$scope.skvActiveUser = jQuery.extend( true, {}, $scope.skvUser[id]);

				// Set the variable that flags whether this user is attached to all makes
				$scope.allMakesForActiveUser = ( $scope.skvActiveUser.arrMakeId[0]=='all' );
			}

			// Display modal
			$('#user-modal').modal();
		}

		/**
		 Prompt the 'Delete' modal
		*/
		$scope.deletePrompt = function( id ){
			// Reset status
			setDefaultStatus();

			// Set active action and user Id
			$scope.activeAction = 'delete';
			$scope.activeId = id;

			// Set active user data (deep clone from the original skvUser)
			$scope.skvActiveUser = jQuery.extend( true, {}, $scope.skvUser[id]);

			// Display modal
			$('#user-modal').modal();
		}

		/**
		 Cancel the modal edition and reset all values for active user
		*/
		$scope.cancel = function(){
			// Reset status
			setDefaultStatus();

			// Reset active action
			$scope.activeAction = '';

			// Reset active user data
			resetSkvActiveUser();
		}

		/**
		 Call the factory to create a user
		*/
		$scope.create = function(){

			UserFactory.create(
				{
					'skvData': $scope.skvActiveUser
				},
				function( skvReturn ) {
					handleCreateUpdateDeleteAjaxSuccess( skvReturn );
				},
				function( err ) {
					handleCreateUpdateDeleteAjaxError( err );
				}
			);

		}

		/**
		 Call the factory to update a user
		*/
		$scope.update = function(){

			// Loop over the available data to see what's actually changed
			var skvChanges = {};
			for( var key in $scope.skvActiveUser ){

				if( key=='arrTool' || key=='arrMake' || key=='arrChannel' ){
					// We're not looking for changes in these keys, but we do want  arrToolId, arrMakeId, arrChannelId
					break;
				}

				var newValue = $scope.skvActiveUser[key];

				if( key != 'password' ){
					var oldValue = $scope.skvUser[$scope.activeId][key];

					// Compare JSONified values (so that strings, numbers and arrays can be compared)
					if( JSON.stringify(newValue) != JSON.stringify(oldValue) ){
						skvChanges[key] = newValue;
					}

				}else{
					// Password is never available in oldValue. Only pass it to the 'update' function if it's not empty
					if( newValue.length > 0 ){
						skvChanges['password'] = newValue;
					}
				}

			}

			UserFactory.update(
				{
					'id': $scope.activeId,
					'skvChanges': skvChanges
				},
				function( skvReturn ) {
					handleCreateUpdateDeleteAjaxSuccess( skvReturn );
				},
				function( err ) {
					handleCreateUpdateDeleteAjaxError( err );
				}
			);
		}

		/**
		 Call the factory to delete a user
		*/
		$scope.delete = function(){

			UserFactory.delete(
				{
					'id': $scope.activeId
				},
				function( skvReturn ) {
					handleCreateUpdateDeleteAjaxSuccess( skvReturn );
				},
				function( err ) {
					handleCreateUpdateDeleteAjaxError( err );
				}
			);
		}

		/**
		 In a dropdown with all the tools/makes/channels,
		 filter out the ones that are already attached to the active user
		 *@factoryType     'tool', 'make' or 'channel'
		 *@factoryElement  The tool, make or channel object
		*/
		var filterOutUserElement = function( factoryType, factoryElement ){
			var factoryTypeCapital = capitalise( factoryType );    // Capitalise factoryType. Ie. 'User', 'Tool', 'Make' or 'Channel'
			return ( $scope.skvActiveUser['arr'+factoryTypeCapital+'Id'].indexOf( parseInt(factoryElement.id, 10) ) == -1 );
		}
		$scope.filterOutUserTools = function( tool ){
			return filterOutUserElement( 'tool', tool );
		}
		$scope.filterOutUserMakes = function( make ){
			return filterOutUserElement( 'make', make );
		}
		$scope.filterOutUserChannels = function( channel ){
			return filterOutUserElement( 'channel', channel );
		}

		/**
		 Add a tool/make/channel to the active user
		 *@factoryType       'tool', 'make' or 'channel'
		 *@factoryElementId  The ID of the tool/make/channel to add to the user
		*/
		var addFactoryElementToActiveUser = function( factoryType, factoryElementId ){
			var factoryTypeCapital = capitalise( factoryType );    // Capitalise factoryType. Ie. 'User', 'Tool', 'Make' or 'Channel'

			if( factoryElementId=='all' ){
				// Special case: arrMakeId=['all']
				$scope.skvActiveUser['arr'+factoryTypeCapital+'Id'] = ['all'];
				$scope.skvActiveUser['arr'+factoryTypeCapital] = ['all'];

			}else if( factoryElementId!='' ){
				// Normal case: toolId, makeId or channelId is an integer
				var numFactoryElementId = parseInt( factoryElementId, 10 );

				// Add ID to arrToolId, arrMakeId or arrChannelId
				$scope.skvActiveUser['arr'+factoryTypeCapital+'Id'].push( numFactoryElementId );

				// Add object to arrTool, arrMake or arrChannel
				$scope.skvActiveUser['arr'+factoryTypeCapital].push( $scope['skv'+factoryTypeCapital][numFactoryElementId] );
			}
		}
		$scope.toolIdToAddToActiveUser = '';
		$scope.makeIdToAddToActiveUser = '';
		$scope.channelIdToAddToActiveUser = '';
		$scope.addToolToActiveUser = function(){
			addFactoryElementToActiveUser( 'tool', $scope.toolIdToAddToActiveUser );
		}
		$scope.addMakeToActiveUser = function(){
			addFactoryElementToActiveUser( 'make', $scope.makeIdToAddToActiveUser );
		}
		$scope.addChannelToActiveUser = function(){
			addFactoryElementToActiveUser( 'channel', $scope.channelIdToAddToActiveUser );
		}
		$scope.addAllMakesToActiveUser = function(){
			// Tick or untick the "Attach to all makes" checkbox
			if( $scope.allMakesForActiveUser ){
				addFactoryElementToActiveUser( 'make', 'all' );
			}else{
				removeFactoryElementFromActiveUser( 'make', 'all' );
			}
		}


		/**
		 Remove a tool/make/channel from the active user
		 *@factoryType       'tool', 'make' or 'channel'
		 *@factoryElementId  The ID of the tool/make/channel to remove from the user
		*/
		var removeFactoryElementFromActiveUser = function( factoryType, factoryElementId ){
			var factoryTypeCapital = capitalise( factoryType );    // Capitalise factoryType. Ie. 'User', 'Tool', 'Make' or 'Channel'

			// Special case remove arrMakeId=['all'], arrMake=['all'] and quit function
			if( factoryElementId=='all' ){
				$scope.skvActiveUser['arr'+factoryTypeCapital+'Id'] = [];
				$scope.skvActiveUser['arr'+factoryTypeCapital] = [];
				return;
			}

			// Remove ID from arrToolId, arrMakeId or arrChannelId
			var indexToRemove = $scope.skvActiveUser['arr'+factoryTypeCapital+'Id'].indexOf( factoryElementId );
			$scope.skvActiveUser['arr'+factoryTypeCapital+'Id'].splice( indexToRemove, 1 );

			// Remove object from arrTool, arrMake or arrChannel
			indexToRemove = -1;
			$.each( $scope.skvActiveUser['arr'+factoryTypeCapital], function( index, value ){
				if( value['id']==factoryElementId ){
					indexToRemove = index;
				}
			});
			$scope.skvActiveUser['arr'+factoryTypeCapital].splice( indexToRemove, 1 );
		}
		$scope.removeToolFromActiveUser = function( toolId ){
			removeFactoryElementFromActiveUser( 'tool', toolId );
		}
		$scope.removeMakeFromActiveUser = function( makeId ){
			removeFactoryElementFromActiveUser( 'make', makeId );
		}
		$scope.removeChannelFromActiveUser = function( channelId ){
			removeFactoryElementFromActiveUser( 'channel', channelId );
		}

		/**
		 Promote (move up) a tool for the active user
		 *@toolId  The ID of the tool to promote (move up)
		*/
		$scope.promoteToolInActiveUser = function( toolId ){
			// Get the index of the element that needs to be promoted
			var i = $scope.skvActiveUser['arrToolId'].indexOf( toolId );
			if( i >= 1 ){
				// Delete element 'i', grab it, and insert it into the position 'i-1':  arr.splice( i-1, 0, arr.splice(i,1)[0] );
				$scope.skvActiveUser['arrToolId'].splice( i-1, 0, $scope.skvActiveUser['arrToolId'].splice( i, 1 )[0] );
				$scope.skvActiveUser['arrTool'].splice( i-1, 0, $scope.skvActiveUser['arrTool'].splice( i, 1 )[0] );
			}else{
				// This element is already at the top: nothing to do
			}
		}


	}]);
