AngularJS Sample App
====================

Sample AngularJS App made by Xavier Pujol (https://github.com/xpujol).


What is this?
-------------

This is a sample repository to show some of my coding skills.

The app provides a panel for adding, editing and deleting users from a certain website.
Users can also have some extra items attached to them (namely tools, makes and channels).

This is a real application built during my time at Carmen Data Ltd,
so some information has been obscured and some key technical details
have been removed.


Technologies used
-----------------

The front-end uses AngularJS, more specifically factories, controllers and directives.

The app uses ColdFusion as the back-end language.

Some sample data has been provided as JSON files,
as the full ColdFusion settings required for this example
are not being given.


What parts of this sample app will work for you? What will not work?
--------------------------------------------------------------------

You will be able to view a sample list of users and all their relevant properties.

You will be able to see and interact with the modals for
adding/updating/deleting users.

You will **NOT** be able to sucessfully add/update/delete users,
without the correct ColdFusion setup in the back-end.

However, you can see the ColdFusion code (CFC files), check
their structure, and check out the MySQL queries that they contain.


What makes me proud of this example?
------------------------------------

This is a responsive, light-weight, single-page app that
allows the administrator to quickly manage their list of users.

The JS code is very neat and modulated, with separate files for
each different part of the logic.

The back-end handles each objects separately (users, tools, makes and channels),
and neatly implements all the required CRUD operations.

The code is easy to maintain and expand:
adding new fields to a user is fairly simple as it only requires the
modification of line 5 on `users.cfc` (for the back-end),
and a few lines on `index.html` (for the front-end).

Both the JS and ColdFusion code are written very neatly,
keeping the lines short, the logical blocks clearly separated,
and with lots of comments.
They strictly follow the variable naming conventions that
were in place at Carmen Data Ltd at the time of writing
(prefixing the variables according to type, etc).


Known bugs
----------

- A bug was introduced when converting the original app into this sample:
it is possible to *re-attach* a tool/make/channel to a user
that is already attached to it. This action triggers a JS error that blocks
any further actions until that same tool/make/channel is removed from the user.
I haven't had time to debug it and sort it out


Possible improvements
---------------------

- Minify and concatenate the CSS (eg. with Grunt)

- Concatenate the JS (eg. with Grunt) and get the libraries from a CDN

- Modulate the HTML, by putting each part into separate files (eg header, list of users, modals, footer)

- The data model gets a bit messy because the IDs exist as both a structure key and as a value
(eg. `{"1":{"id":1,"name":"Guybrush"}}`). Some parts of the JS read the ID from the key, and some other parts
read it from the value. This duplicity should be eliminated.

- The UI needs pagination

- The error messages need to be shown more prominently when they come up


Last but not least
------------------

Check out my public repo with Sublime Text Handy User Settings
(https://github.com/xpujol/Sublime-Text-Handy-User-Settings)
to get a glimpse of how I like to use my favourite text editor
(Sublime Text!) along with some snippets to maximise my work efficiency.
