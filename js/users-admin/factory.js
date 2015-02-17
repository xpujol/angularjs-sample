AutoPanelUsersAdminApp

	.factory('UserFactory', function ($resource) {
		return $resource(
			'com/users.cfc.disabled',
			{
				returnFormat: 'json'
			},
			{
				retrieve: {
					url: 'com/sample/users.json', // Overwrite with sample data
					method: 'GET',
					params: {
						method: 'retrieve'
					}
				},
				create: {
					method: 'GET',
					params: {
						method: 'create'
					}
				},
				update: {
					method: 'GET',
					params: {
						method: 'update'
					}
				},
				delete: {
					method: 'GET',
					params: {
						method: 'delete'
					}
				}

			}
		);
	})

	.factory('ToolFactory', function ($resource) {
		return $resource(
			'com/tools.cfc.disabled', 
			{
				returnFormat: 'json'
			},
			{
				retrieve: {
					url: 'com/sample/tools.json', // Overwrite with sample data
					method: 'GET',
					params: {
						method: 'retrieve'
					}
				}
			}
		);
	})

	.factory('MakeFactory', function ($resource) {
		return $resource(
			'com/makes.cfc.disabled', 
			{
				returnFormat: 'json'
			},
			{
				retrieve: {
					url: 'com/sample/makes.json', // Overwrite with sample data
					method: 'GET',
					params: {
						method: 'retrieve'
					}
				}
			}
		);
	})

	.factory('ChannelFactory', function ($resource) {
		return $resource(
			'com/channels.cfc.disabled', 
			{
				returnFormat: 'json'
			},
			{
				retrieve: {
					url: 'com/sample/channels.json', // Overwrite with sample data
					method: 'GET',
					params: {
						method: 'retrieve'
					}
				}
			}
		);
	});
