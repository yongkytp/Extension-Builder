<cfoutput>	<div class="well sidebar-nav">
		<ul class="nav nav-list">
			<li class="nav-header">Extension</li>
			<li><a href="#buildURL("extension.edit?name=#rc.name#")#">Extension Info <i class="icon-question-sign" data-content="Allows you to edit the main information about this extension" title="Information"></i></a></li>
			<li class="nav-header">Add Items</li>
			<li><a href="#buildURL("extension.addApplication?name=#rc.name#")#">Applications <i class="icon-question-sign" data-content="Allows you to deploy a whole application to a web context" title="Applications"></i></a></li>
			<li><a href="#buildURL("extension.addTags?name=#rc.name#")#">Custom Tags <i class="icon-question-sign" data-content="Allows you to add custom tags and use them as you would the built in tags" title="Custom Tags"></i></a></li>
			<li><a href="#buildURL("extension.addFunctions?name=#rc.name#")#">Functions <i class="icon-question-sign" data-content="Allows you to add functions and use them as you would the built in functions" title="Functions"></i></a></li>
			<li><a href="#buildURL("extension.addJars?name=#rc.name#")#">Java Libraries <i class="icon-question-sign" data-content="Allows you to add any Java libraries you want to deploy with your extension" title="Java Libraries"></i></a></li>	
			<li class="nav-header">Screens</li>	
		</ul>
	</div>
</cfoutput>