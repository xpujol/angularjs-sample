AutoPanelUsersAdminApp

	.factory('UserFactory', function ($resource) {
		return $resource(
			'/com/users.cfc',
			{
				returnFormat: 'json'
			},
			{
				retrieve: {
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
			'/com/tools.cfc', 
			{
				returnFormat: 'json'
			},
			{
				retrieve: {
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
			'/com/makes.cfc', 
			{
				returnFormat: 'json'
			},
			{
				retrieve: {
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
			'/com/channels.cfc', 
			{
				returnFormat: 'json'
			},
			{
				retrieve: {
					method: 'GET',
					params: {
						method: 'retrieve'
					}
				}
			}
		);
	});
