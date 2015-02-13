<cfscript>
	skvPage.title = 'AutoPanel Users Admin';

	skvPage.content = 'users.inc.cfm';

	skvPage.js = '
		<script src="js/users.js.cfm"></script>
	';

	skvPage.css = '
		<link rel="stylesheet" href="css/users.css">
	';

	skvPage.isAngularApp = true;
	skvPage.arrAngularAdditionalModule = [ 'sanitize', 'resource', 'toArrayFilter' ];

	include '/template.cfm';
</cfscript>
