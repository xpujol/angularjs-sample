component
	displayname = "Makes (Manufacturers)"
{
	// Objects
	VARIABLES.qry = new query();

	/**
	 Retrieve all makes
	*/
	remote struct function retrieve(){
		var skvReturn = {};
		skvReturn['success'] = false;
		skvReturn['msg'] = 'Failed to retrieve list of makes';

		if( !isUserAdmin() ){
			skvReturn['msg'] &= '. Authentication error';
			return skvReturn;
		}

		var strSql = '
			SELECT `id`, `name`
			FROM `makes`
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
			skvReturn['data'][thisId]['name'] = rst['name'][row];
		}

		// Return success and data
		skvReturn['success'] = true;
		skvReturn['msg'] = 'Successfully retrieved list of makes';
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
