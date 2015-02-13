<div ng-controller="UserCtrl">

	<!--- Status --->
	<p
		class = "alert alert-{{status.class}} status-top"
		ng-bind-html = "status.msg"
	>
	</p>

	<div class="row">

		<div class="col-md-offset-1 col-md-10">

			<!--- Filter results / Add new user --->
			<div class="row userRow settingsRow">

				<div class="col-md-9">
					<input ng-model="search.$" class="form-control" placeholder="Type here to filter the entries">
				</div>

				<div class="col-md-offset-1 col-md-2 text-center">
					<span class="btn btn-primary" ng-click="createPrompt()">
						<i class="glyphicon glyphicon-plus"></i> Add user
					</span>
				</div>

			</div>


			<!--- The list of AutoPanel users --->
			<div class="row userRow" ng-repeat="(id, user) in skvUser | toArray | orderBy:'username' | filter:search:strict">

				<div class="col-md-2">
					<strong>{{user.username}}</strong>
					<span ng-if=" user.role=='admin' ">(Admin user)</span>
				</div>

				<div class="col-md-2">{{user.email}}</div>

				<div class="col-md-2">{{user.firstname}}</div>

				<div class="col-md-2">{{user.surname}}</div>

				<div class="col-md-2">{{user.company}}</div>

				<div class="col-md-2">{{user.jobtitle}}</div>

				<div class="col-md-12">
					<span class="field-header">List of tools:</span>
					<span ng-if=" user.arrTool.length==0 ">None</span>
					<span ng-repeat="(id, tool) in user.arrTool">
						{{tool['name']}}{{$last ? '' : ', '}}
					</span>
				</div>

				<div class="col-md-12">
					<span class="field-header">List of makes:</span>
					<span ng-if=" user.arrMakeId.length==0 ">None</span>
					<span ng-if=" user.arrMakeId[0]=='all' ">All makes</span>
					<span ng-if=" user.arrMakeId[0]!='all' " ng-repeat="(id, make) in user.arrMake">
						{{make['name']}}{{$last ? '' : ', '}}
					</span>
				</div>

				<div class="col-md-12">
					<span class="field-header">List of channels:</span>
					<span ng-if=" user.arrChannel.length==0 ">None</span>
					<!--- Loop over all the channels --->
					<span ng-repeat="(id, channel) in user.arrChannel">
						{{channel['id']}} - {{channel['name']}}
						<span ng-if=" channel['url'].length==0 ">
							(<a ng-href="http://comcar.co.uk?clk={{channel['id']}}">comcar.co.uk?clk={{channel['id']}}</a>){{$last ? '' : ', '}}
						</span>
						<span ng-if=" channel['url'].length!=0 ">
							<!--- Loop over all the URLs for this channel --->
							(<a ng-repeat="(id, url) in channel['url']" ng-href="http://{{url}}">{{url}}{{$last ? '' : ', '}}</a>){{$last ? '' : ', '}}
						</span>
					</span>
				</div>

				<div class="col-md-10"><span class="field-header">Last login (not including Comcar office IP):</span> {{ user.lastLoginDate.length ? user.lastLoginDate : 'Never' }}</div>

				<div class="col-md-2 text-center button-group">
					<span class="btn btn-primary" ng-click="updatePrompt(user.$key)">
						<i class="glyphicon glyphicon-pencil"></i>
					</span>
					<span class="btn btn-primary" ng-click="deletePrompt(user.$key)">
						<i class="glyphicon glyphicon-trash"> </i>
					</span>
				</div>

			</div>

		</div>

	</div>


	<!--- Modal to Create/Update/Delete a user --->
	<div class="modal fade" id="user-modal">
		<div class="modal-dialog">
			<div class="modal-content">

				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">&times;</span>
						<span class="sr-only">Close</span>
					</button>
					<h4 class="modal-title">
						<span ng-if=" activeAction=='create' ">Add user</span>
						<span ng-if=" activeAction=='update' ">Update user details</span>
						<span ng-if=" activeAction=='delete' ">Delete user</span>
					</h4>
				</div><!-- /.modal-header -->

				<div class="modal-body">

					<!--- Status. We only want to show it here in case of error --->
					<p
						ng-if = " status.class=='danger' "
						class = "alert alert-{{status.class}}"
						ng-bind-html = "status.msg"
					>
					</p>

					<div class="form-horizontal" role="form">

						<div modalformfield fieldname="username"  label="Username"></div>
						<div modalformfield fieldname="email"     label="Email"     placeholder="user@example.com" type="email"></div>
						<div modalformfield fieldname="firstname" label="First name"></div>
						<div modalformfield fieldname="surname"   label="Surname"></div>
						<div modalformfield fieldname="company"   label="Company"></div>
						<div modalformfield fieldname="jobtitle"  label="Job Title" placeholder="eg. Marketing Manager, Fleet Director"></div>
						<div modalformfield fieldname="role"      label="Role"      type="select"  arroption='[{"value":"normal","text":"Normal user"},{"value":"admin","text":"AutoPanel admin user"}]'></div>

						<!--- Password: different depending on active action --->
						<div modalformfield ng-if=" activeAction=='create' " fieldname="password"  label="Password" placeholder="Type the password"></div>
						<div modalformfield ng-if=" activeAction=='update' " fieldname="password"  label="Password" placeholder="Type new password if you wish to change it"></div>


						<div class="userAttachments" ng-hide=" activeAction=='delete' ">

							<hr />

							<!--- List of tools --->
							<div class="form-group">
								<label for="select-tool" class="col-md-2 control-label">Tools</label>
								<div class="col-md-10">
									<select ng-model="toolIdToAddToActiveUser" ng-change="addToolToActiveUser()" class="form-control" id="select-tool">
										<option value="">Select a tool to make it available for this user</option>
										<option ng-repeat="(id, tool) in skvTool | toArray | filter:filterOutUserTools" ng-value="tool.$key" >
											{{tool['name']}}
										</option>
									</select>
								</div>
							</div>
							<div class="form-group">
								<div class="col-md-offset-2 col-md-10">
									<div class="listOfUserAttachmentsHeader">List of tools available for this user:</div>
								</div>
								<ul class="col-md-offset-2 col-md-10 listOfUserAttachments list-unstyled">
									<li ng-if=" skvActiveUser.arrTool.length==0 ">None</li>
									<li ng-repeat="(id, tool) in skvActiveUser.arrTool" >
										<span>{{tool['name']}}</span>
										<i class="pull-right glyphicon glyphicon-trash" ng-click="removeToolFromActiveUser(tool['id'])"></i>
										<i class="pull-right glyphicon glyphicon-arrow-up" ng-click="promoteToolInActiveUser(tool['id'])" ng-if="!$first"></i>
									</li>
								</ul>
							</div>

							<hr />

							<!--- List of makes --->
							<div class="form-group">
								<label for="select-make" class="col-md-2 control-label">Makes</label>
								<div class="col-md-10">
									<select ng-model="makeIdToAddToActiveUser" ng-change="addMakeToActiveUser()" class="form-control" id="select-make" ng-disabled="allMakesForActiveUser==true">
										<option value="">Select a make to attach it to this user</option>
										<option ng-repeat="(id, make) in skvMake | toArray | orderBy:'name' | filter:filterOutUserMakes" ng-value="make.$key" >
											{{make['name']}}
										</option>
									</select>
								</div>
								<div class="checkbox col-md-offset-2 col-md-10">
									<label>
										<input type="checkbox" ng-model="allMakesForActiveUser" ng-change="addAllMakesToActiveUser()">
										Attach to all makes
									</label>
								</div>
							</div>
							<div class="form-group">
								<div class="col-md-offset-2 col-md-10">
									<div class="listOfUserAttachmentsHeader">List of makes attached to this user:</div>
								</div>
								<ul class="col-md-offset-2 col-md-10 listOfUserAttachments list-unstyled">
									<li ng-if=" skvActiveUser.arrMakeId.length==0 ">None</li>
									<li ng-if=" skvActiveUser.arrMakeId[0]=='all' ">All makes</li>
									<li ng-if=" skvActiveUser.arrMakeId[0]!='all' " ng-repeat="(id, make) in skvActiveUser.arrMake | orderBy:'name'" >
										<span>{{make['name']}}</span>
										<i class="pull-right glyphicon glyphicon-trash" ng-click="removeMakeFromActiveUser(make['id'])"></i>
									</li>
								</ul>
							</div>

							<hr />

							<!--- List of channels --->
							<div class="form-group">
								<label for="select-channel" class="col-md-2 control-label">Channels</label>
								<div class="col-md-10">
									<select ng-model="channelIdToAddToActiveUser" ng-change="addChannelToActiveUser()" class="form-control" id="select-channel">
										<option value="">Select a channel to attach it to this user</option>
										<option ng-repeat="(id, channel) in skvChannel | toArray | orderBy:'id' | filter:filterOutUserChannels" ng-value="channel.$key" >
											{{channel['id']}} - {{channel['name']}}
										</option>
									</select>
								</div>
							</div>
							<div class="form-group">
								<div class="col-md-offset-2 col-md-10">
									<div class="listOfUserAttachmentsHeader">List of channels attached to this user:</div>
								</div>
								<ul class="col-md-offset-2 col-md-10 listOfUserAttachments list-unstyled">
									<li ng-if=" skvActiveUser.arrChannel.length==0 ">None</li>
									<li ng-repeat="(id, channel) in skvActiveUser.arrChannel | orderBy:'id'" >
										<span>{{channel['id']}} - {{channel['name']}}</span>
										<i class="pull-right glyphicon glyphicon-trash" ng-click="removeChannelFromActiveUser(channel['id'])"></i>
									</li>
								</ul>
							</div>

						</div><!--- ./userAttachments --->

					</div><!--- ./form-horizontal --->

				</div><!-- /.modal-body -->

				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal" ng-click="cancel()">Cancel</button>
					<button ng-if=" activeAction=='create' " type="button" class="btn btn-primary" ng-click="create()">Add user</button>
					<button ng-if=" activeAction=='update' " type="button" class="btn btn-primary" ng-click="update()">Save changes</button>
					<button ng-if=" activeAction=='delete' " type="button" class="btn btn-danger"  ng-click="delete()">Delete user</button>
				</div><!-- /.modal-footer -->

			</div><!-- /.modal-content -->
		</div><!-- /.modal-dialog -->
	</div><!-- /.modal -->

</div>
