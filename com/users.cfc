component
	displayname = "AutoPanel users"
{
	// Constants
	VARIABLES.arrEditableColumn = ['username', 'email', 'firstname', 'surname', 'company', 'jobtitle', 'role'];
	VARIABLES.lstEditableColumn = arrayToList( VARIABLES.arrEditableColumn );
	VARIABLES.lstEditableColumn = '`users`.`' & listChangeDelims( VARIABLES.lstEditableColumn, '`,`users`.`' ) & '`';

	// Objects
	VARIABLES.qry = new query();

	// Libraries
	VARIABLES.objHashing = new core.user.hashing();

	/**
	 Retrieve all AutoPanel users, or just one if you pass an ID
	 *@id      The ID of the user
	*/
	remote struct function retrieve(
		numeric id		
	){
		var skvReturn = {};
		skvReturn['success'] = false;
		skvReturn['msg'] = 'Failed to retrieve list of users';

		if( !isUserAdmin() ){
			skvReturn['msg'] &= '. Authentication error';
			return skvReturn;
		}

		var strSql = '
			SELECT
				`users`.`id`, #VARIABLES.lstEditableColumn#,
				DATE_FORMAT( `lastLoginDate`, :mask ) AS `lastLoginDate`,
				GROUP_CONCAT( DISTINCT `users_tools`.`tool_id` ORDER BY `users_tools`.`order` ASC ) AS `lstToolId`,
				IF( `users_makes`.`has_all_makes`=1, "all", GROUP_CONCAT( DISTINCT `users_makes`.`make_id` ) ) AS `lstMakeId`,
				GROUP_CONCAT( DISTINCT `users_channels`.`channel_id` ) AS `lstChannelId`
			FROM `users`
				LEFT JOIN `users_tools` ON `users_tools`.`user_id` = `users`.`id`
				LEFT JOIN `users_makes` ON `users_makes`.`user_id` = `users`.`id`
				LEFT JOIN `users_channels` ON `users_channels`.`user_id` = `users`.`id`
				LEFT JOIN (
					SELECT `user_id`, MAX(`login_date`) AS `lastLoginDate`
					FROM `users_login`
					WHERE `is_carmendata_ip` = 0
					GROUP BY `user_id`
				) AS `lastLogin`
				ON `lastLogin`.`user_id` = `users`.`id`
		';
		if( structKeyExists( ARGUMENTS, 'id' ) ){
			strSql &= '
				WHERE `users`.`id` = #ARGUMENTS.id#
			';
		}
		strSql &= '
			GROUP BY `users`.`id`
		';
		VARIABLES.qry.clearParams();
		VARIABLES.qry.addParam( name="mask", value='%e %b %Y, %H:%S', cfsqltype='cf_sql_varchar' );
		VARIABLES.qry.setSql( strSql );
		try{
			var rstUser = VARIABLES.qry.execute().getResult();
		}catch(Any e){
			skvReturn['msg'] &= '. #e.Message#';
			return skvReturn;
		}
		var cntUser = rstUser.recordCount;

		// Loop over results and build structure
		var skvReturn['data'] = {};
		for( var row=1; row<=cntUser; row++ ){
			var thisId = rstUser['id'][row];
			for( var col in VARIABLES.arrEditableColumn ){
				skvReturn['data'][thisId][col] = rstUser[col][row];
			}
			skvReturn['data'][thisId]['id'] = thisId;
			skvReturn['data'][thisId]['lastLoginDate'] = rstUser['lastLoginDate'][row];
			skvReturn['data'][thisId]['arrToolId']    = listToArray( rstUser['lstToolId'][row] );
			skvReturn['data'][thisId]['arrMakeId']    = listToArray( rstUser['lstMakeId'][row] );
			skvReturn['data'][thisId]['arrChannelId'] = listToArray( rstUser['lstChannelId'][row] );
		}

		// Return success and data
		skvReturn['success'] = true;
		skvReturn['msg'] = 'Successfully retrieved list of users';
		return skvReturn;
	}


	/**
	 Create an entry for an AutoPanel user
	 *@skvData Key-values
	*/
	remote struct function create(
		skvData = {}
	){
		var skvReturn = {};
		skvReturn['success'] = false;
		skvReturn['msg'] = 'Failed to create user';

		if( !isUserAdmin() ){
			skvReturn['msg'] &= '. Authentication error';
			return skvReturn;
		}

		// Check if skvData is a JSON object or a struct
		var skvTheData = handleStructOrJson( ARGUMENTS.skvData );

		// Build the SET clause of the query
		var skvBuildSETClause = buildSETClauseAndQueryParams( skvTheData );
		var strSETClause = skvBuildSETClause['strSETClause'];

		// Build query string and execute
		var strSql = '
			INSERT INTO `users` SET
			#strSETClause#
		';
		VARIABLES.qry.setSql( strSql );
		try{
			var rst = VARIABLES.qry.execute();
			var generatedUserId = rst.getPrefix().generatedKey;
		}catch(Any e){
			skvReturn['msg'] &= '. #e.Message#';
			return skvReturn;
		}

		// Create user-tool, user-make and user-channel joins
		try{
			if( structKeyExists( skvTheData, 'arrToolId' ) ){
				updateUserTool( generatedUserId, skvTheData['arrToolId'] );
			}
			if( structKeyExists( skvTheData, 'arrMakeId' ) ){
				updateUserMake( generatedUserId, skvTheData['arrMakeId'] );
			}
			if( structKeyExists( skvTheData, 'arrChannelId' ) ){
				updateUserChannel( generatedUserId, skvTheData['arrChannelId'] );
			}
		}catch(Any e){
			skvReturn['msg'] &= '. #e.message#';
			return skvReturn;
		}

		// Return success
		skvReturn['success'] = true;
		skvReturn['msg'] = 'Successfully created <strong>' & skvTheData['username'] & '</strong>';
		return skvReturn;
	}


	/**
	 Update an existing AutoPanel user
	 *@id         The ID of the user to be modified
	 *@skvChanges Key-values. Possible keys are all the ones in VARIABLES.arrEditableColumn, plus arrToolId, arrMakeId, arrChannelId
	*/
	remote struct function update(
		required numeric id,
		skvChanges = {}
	){
		var skvReturn = {};
		skvReturn['success'] = false;
		skvReturn['msg'] = 'Failed to update user';

		if( !isUserAdmin() ){
			skvReturn['msg'] &= '. Authentication error';
			return skvReturn;
		}

		// Check if skvData is a JSON object or a struct
		var skvData = handleStructOrJson( ARGUMENTS.skvChanges );

		// Start building query
		var strSql = ' UPDATE `users` SET ';

		// Build the SET clause of the query
		var skvBuildSETClause = buildSETClauseAndQueryParams( skvData );
		var isAtLeastOneKeyValid = skvBuildSETClause['isAtLeastOneKeyValid'];

		// Finish query string and execute
		if( isAtLeastOneKeyValid ){
			var strSETClause = skvBuildSETClause['strSETClause'];
			strSql &= '
				#strSETClause#
				WHERE `id` = #ARGUMENTS.id#
			';
			VARIABLES.qry.setSql( strSql );
			try{
				var rst = VARIABLES.qry.execute();
				if( rst.getPrefix().recordCount == 0 ){
					// Nothing was updated: this means the user with this ID doesn't exist
					skvReturn['msg'] &= '. Invalid ID provided';
					return skvReturn;
				}
			}catch(Any e){
				skvReturn['msg'] &= '. #e.Message#';
				return skvReturn;
			}
		}else{
			// None of the keys provided was valid: just ignore and return success
		}

		// Update user-tool, user-make and user-channel joins
		try{
			if( structKeyExists( skvData, 'arrToolId' ) ){
				updateUserTool( ARGUMENTS.id, skvData['arrToolId'] );
			}
			if( structKeyExists( skvData, 'arrMakeId' ) ){
				updateUserMake( ARGUMENTS.id, skvData['arrMakeId'] );
			}
			if( structKeyExists( skvData, 'arrChannelId' ) ){
				updateUserChannel( ARGUMENTS.id, skvData['arrChannelId'] );
			}
		}catch(Any e){
			skvReturn['msg'] &= '. #e.message#';
			return skvReturn;
		}

		// Get the username of the user that has just been updated, for a nice feedback message
		var username = '';
		if( structKeyExists(skvData, 'username') ){
			username = skvData.username;
		}else{
			var skvRetrieveUser = retrieve( ARGUMENTS.id );
			username = skvRetrieveUser['data'][ARGUMENTS.id]['username'];
		}

		// Return success
		skvReturn['success'] = true;
		skvReturn['msg'] = 'Successfully updated <strong>' & username & '</strong>';
		return skvReturn;
	}


	/**
	 Delete the AutoPanel user with the given ID
	 *@id      The ID of the user to be deleted
	*/
	remote struct function delete(
		required numeric id
	){
		var skvReturn = {};
		skvReturn['success'] = false;
		skvReturn['msg'] = 'Failed to delete user';

		if( !isUserAdmin() ){
			skvReturn['msg'] &= '. Authentication error';
			return skvReturn;
		}

		// Get the username of the user about to be deleted, for a nice feedback message
		var skvRetrieveUser = retrieve( ARGUMENTS.id );
		var username = '';
		if( structCount( skvRetrieveUser.data ) == 0 ){
			// This user ID doesn't exist
			skvReturn['msg'] &= '. Invalid ID provided';
			return skvReturn;
		}else{
			// Found a user with this ID. Get their username
			username = skvRetrieveUser['data'][ARGUMENTS.id]['username'];
		}

		// Build query string
		var strSql = '
			DELETE FROM `users`
			WHERE `id` = #ARGUMENTS.id#
		';

		// Execute
		VARIABLES.qry.setSql( strSql );
		try{
			VARIABLES.qry.execute();
		}catch(Any e){
			skvReturn['msg'] &= '. #e.Message#';
			return skvReturn;
		}

		// Return success
		skvReturn['success'] = true;
		skvReturn['msg'] = 'Successfully deleted <strong>' & username & '</strong>';
		return skvReturn;
	}


	/**
	 Check the user that's logged in is admin
	*/
	private boolean function isUserAdmin(){
		var objUser = new com.user();
		return objUser.isUserAdmin();
	}


	/**
	 Takes either a struct and returns it unmodified, or a JSON variable and returns it deserialized as a struct
	 *@someVariable   The variable, either a struct or a JSON string
	*/
	private struct function handleStructOrJson(
		required someVariable
	){
		var skvReturn = {};

		if( isStruct( ARGUMENTS.someVariable ) ){
			// Argument is already a struct: OK!
			skvReturn = duplicate( ARGUMENTS.someVariable );
		}else{
			try{
				var someVariableDeserialized = deserializeJSON( ARGUMENTS.someVariable );
				if( isStruct( someVariableDeserialized ) ){
					// Argument is JSON and we've managed to desierialize it as a struct: OK!
					skvReturn = someVariableDeserialized;
				}else{
					// Argument is JSON but it doesn't desierialize as a struct
					skvReturn = {};
				}
			}catch(Any e){
				// Argument is not JSON
				skvReturn = {};
			}
		}

		return skvReturn;
	}


	/**
	 Loop over all the key-value pairs, check if they are valid and append to the SET clause of the query string, using query params
	 *@skvData    Key-values
	*/
	private struct function buildSETClauseAndQueryParams(
		required struct skvData
	){
		VARIABLES.qry.clearParams();

		var strSETClause = '';

		// Loop over all the key-value pairs, check if they are valid and append to the query string
		var isAtLeastOneKeyValid = false;
		for( var key in ARGUMENTS.skvData ){

			if( arrayFind( VARIABLES.arrEditableColumn, key ) || key=='password' ){

				if( key=='password' ){
					// Hash the password, ready for insertion into the DB
					var thisKey = 'hash';
					var value = VARIABLES.objHashing.createNewHash({ 'password' = ARGUMENTS.skvData[key] });
				}else{
					// Non-password fields: insert plain text value
					var thisKey = key;
					var value = ARGUMENTS.skvData[key];
				}

				if( !isAtLeastOneKeyValid ){
					// First valid key
					isAtLeastOneKeyValid = true;
				}else{
					// Successive valid keys
					strSETClause &= ' , ';
				}

				// For any of the valid keys
				strSETClause &= ' `#thisKey#` = :#thisKey# ';
				VARIABLES.qry.addParam( name=thisKey, value=value, cfsqltype='cf_sql_varchar' );
			}

		}

		return {
			'strSETClause' = strSETClause,
			'isAtLeastOneKeyValid' = isAtLeastOneKeyValid
		};
	}


	/**
	 Update the list of user-tool joins
	 *@userId     The ID of the user
	 *@arrToolId  The updated array of tool IDs. Any new IDs will be added, existing IDs will be kept, and IDs not anymore in this array will be deleted from the join table
	*/
	private void function updateUserTool( required numeric userId, required array arrToolId ){
		return common_updateUserToolMakeChannel( 'tool', ARGUMENTS.userId, ARGUMENTS.arrToolId );
	}


	/**
	 Update the list of user-make joins
	 *@userId     The ID of the user
	 *@arrMakeId  The updated array of make IDs. Any new IDs will be added, existing IDs will be kept, and IDs not anymore in this array will be deleted from the join table
	*/
	private void function updateUserMake( required numeric userId, required array arrMakeId ){

		// users_makes is different to the other join tables because it has the option "has all makes"

		if( arrayLen(ARGUMENTS.arrMakeId)==1 && ARGUMENTS.arrMakeId[1]=='all' ){
			// Assign this user to "has all makes"
			// by deleting all their existing entries, and inserting a new row with has_all_makes=1
			var strSql = '
				DELETE FROM `users_makes`
				WHERE `user_id` = #ARGUMENTS.userId#
			';
			VARIABLES.qry.setSql( strSql );
			VARIABLES.qry.execute();
			var strSql = '
				INSERT INTO `users_makes` ( `user_id`, `make_id`, `has_all_makes` )
				VALUES ( #ARGUMENTS.userId#, NULL, 1 )
			';
			VARIABLES.qry.setSql( strSql );
			VARIABLES.qry.execute();

			return;

		}else{
			// Delete a possible existing entry with has_all_makes=1,
			// and then call the common function to insert the new make IDs
			var strSql = '
				DELETE FROM `users_makes`
				WHERE `user_id` = #ARGUMENTS.userId#
					AND `has_all_makes` = 1
			';
			VARIABLES.qry.setSql( strSql );
			VARIABLES.qry.execute();

			return common_updateUserToolMakeChannel( 'make', ARGUMENTS.userId, ARGUMENTS.arrMakeId );
		}
	}


	/**
	 Update the list of user-channel joins
	 *@userId        The ID of the user
	 *@arrChannelId  The updated array of channel IDs. Any new IDs will be added, existing IDs will be kept, and IDs not anymore in this array will be deleted from the join table
	*/
	private void function updateUserChannel( required numeric userId, required array arrChannelId ){
		return common_updateUserToolMakeChannel( 'channel', ARGUMENTS.userId, ARGUMENTS.arrChannelId );
	}


	/**
	 Common code to update the list of user-tool, user-make and user-channel joins
	 *@elementType   'tool', 'make' or 'channel'
	 *@userId        The ID of the user
	 *@arrElementId  The updated array of tool/make/channel IDs. Any new IDs will be added, existing IDs will be kept, and IDs not anymore in this array will be deleted from the join table
	*/
	private void function common_updateUserToolMakeChannel( required string elementType, required numeric userId, required array arrElementId ){
		var lstElementId = arrayToList( ARGUMENTS.arrElementId );
		var cntElementId = listLen( lstElementId );

		// Check validity of element IDs
		for( var elementId in ARGUMENTS.arrElementId ){
			if( !isNumeric(elementId) ){
				// Throw error: the calls to this function are wrapped in a try/catch, so it will be picked up
				throw( type="500", message="Non-numeric #ARGUMENTS.elementType# IDs provided" );
			}
		}

		// Delete join entries that might have been there but are not found anymore in arrElementId
		var strSql = '
			DELETE FROM `user_#ARGUMENTS.elementType#`
			WHERE `user_id` = #ARGUMENTS.userId#
		';
		if( cntElementId>0 ){
			strSql &= ' AND `#ARGUMENTS.elementType#_id` NOT IN (#lstElementId#) ';
		}
		VARIABLES.qry.setSql( strSql );
		VARIABLES.qry.execute();

		// Insert new values, and ignore the ones that are already there
		if( cntElementId>0 ){

			// For tools, we want to store an `order`, but we don't need it for makes and channels
			var doesOrderMatter = ( ARGUMENTS.elementType=='tool' ? true : false );

			if( doesOrderMatter ){
				// INSERT INTO ... ON DUPLICATE KEY UPDATE
				var strSql = '
					INSERT INTO `user_#ARGUMENTS.elementType#`
						(`user_id`, `#ARGUMENTS.elementType#_id`, `order`)
					VALUES
				';
			}else{
				// INSERT IGNORE INTO
				var strSql = '
					INSERT IGNORE INTO `user_#ARGUMENTS.elementType#`
						(`user_id`, `#ARGUMENTS.elementType#_id`)
					VALUES
				';
			}
			for( var i=1; i<=cntElementId; i++ ){
				if( doesOrderMatter ){
					// user_id, element_id, order
					strSql &= ' ( #ARGUMENTS.userId#, #listGetAt(lstElementId,i)#, #i# ) ';
				}else{
					// user_id, element_id
					strSql &= ' ( #ARGUMENTS.userId#, #listGetAt(lstElementId,i)# ) ';
				}
				if( i<cntElementId ){
					strSql &= ',';
				}
			}
			if( doesOrderMatter ){
				strSql &= ' ON DUPLICATE KEY UPDATE `order` = VALUES(`order`) ';
			}
			VARIABLES.qry.setSql( strSql );
			VARIABLES.qry.execute();

		}

		return;
	}

}
