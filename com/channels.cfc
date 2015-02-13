component
	displayname = "Channels"
{
	// Objects
	VARIABLES.qry = new query();

	/**
	 Retrieve all channels
	*/
	remote struct function retrieve(){
		var skvReturn = {};
		skvReturn['success'] = false;
		skvReturn['msg'] = 'Failed to retrieve list of channels';

		if( !isUserAdmin() ){
			skvReturn['msg'] &= '. Authentication error';
			return skvReturn;
		}

		var strSql = '
			SELECT `id`, `titlePrepend`, `url`
			FROM `channel`
		';
		VARIABLES.qry.setSql( strSql );
		try{
			var rst = VARIABLES.qry.execute().getResult();
		}catch(Any e){
			skvReturn['msg'] &= '. #e.Message#';
			return skvReturn;
		}
		var cnt = rst.recordCount;

		// Loop over results and build structure
		var skvReturn['data'] = {};
		for( var row=1; row<=cnt; row++ ){
			var thisId = rst['id'][row];
			skvReturn['data'][thisId]['id'] = thisId;
			skvReturn['data'][thisId]['name'] = rst['titlePrepend'][row];
			// Loop over URLs
			var thisLstUrl = rst['url'][row];
			var thisArrUrl = listToArray( thisLstUrl );
			skvReturn['data'][thisId]['url'] = thisArrUrl;

		}

		// Return success and data
		skvReturn['success'] = true;
		skvReturn['msg'] = 'Successfully retrieved list of channels';
		return skvReturn;
	}

	/**
	 Check the user that's logged in is admin
	*/
	private boolean function isUserAdmin(){
		var objUser = new com.user();
		return objUser.isUserAdmin();
	}

}
