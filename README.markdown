# IOM-CI MIMOSA Active Registry
Brandon Mathis  
Keyset Technical Solutions (for Assetricity)  
13 July 2010  

The most recent deployment of the Active Registry can be found [online](http://activeregistry.assetricity.com)

## How to start this app

	1. Install mongodb for your system and start it with mongod
	2. Unpack gems
	3. cd into directory containing app
	4. boot sinatra postback server			[$ ruby lib/postback_server.rb]
	5. start server							[$ script/server]
	
	> app will be at http://localhost:3000
	> events are published to events/

## Code Details

The following contains a rewrite of the mimosa active registry in order
    to support the inporting of 3.3 format CCOM XML. Most of these changes
    consist of adding an "xml_element => "New Name" to declared mongo 'documents.'
    Many of these changes may not be best practice but this is my first
    attempt at tackling ruby.
    
    The following things are important to note
        -This active registry supports installing assets onto a segment but will
         not uninstall those assets properly.
        -Sinatra is required to run the postback_server.rb which catches generated
		 events
        -Test do not pass in this commit. This is beta at best.
    
     Please enter the commit message for your changes. Lines starting

