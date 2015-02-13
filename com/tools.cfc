component
	displayname = "AutoPanel tools"
{
	// Constants
	VARIABLES.arrColumn = ['name', 'href', 'description'];
	VARIABLES.lstColumn = listQualify( arrayToList( VARIABLES.arrColumn ), '`' );

	// Objects
	VARIABLES.qry = new query();

	/**
	 Retrieve all AutoPanel tools, or just one if you pass an ID
	 *@id      The ID of the tool
	*/
	remote struct function retrieve(
		numeric id = -1
	){
		var skvReturn = {};
		skvReturn['success'] = false;
		skvReturn['msg'] = 'Failed to retrieve list of tools';

		if( !isUserAdmin() ){
			skvReturn['msg'] &= '. Authentication error';
			return skvReturn;
		}

		var strSql = '
			SELECT `id`, #VARIABLES.lstColumn#
			FROM `tools`
		';
		if( ARGUMENTS.id != -1 ){
			strSql &= '
				WHERE `id` = #ARGUMENTS.id#
			';
		}
		VARIABLES.qry.setSql( strSql );
		try{
			var rstTool = VARIABLES.qry.execute().getResult();
		}catch(Any e){
			skvReturn['msg'] &= '. #e.Message#';
			return skvReturn;
		}
		var cntTool = rstTool.recordCount;

		// Loop over results and build structure
		var skvReturn['data'] = {};
		for( var row=1; row<=cntTool; row++ ){
			var thisId = rstTool['id'][row];
			skvReturn['data'][thisId]['id'] = thisId;
			for( var col in VARIABLES.arrColumn ){
				skvReturn['data'][thisId][col] = rstTool[col][row];
			}
		}

		// Return success and data
		skvReturn['success'] = true;
		skvReturn['msg'] = 'Successfully retrieved list of tools';
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
