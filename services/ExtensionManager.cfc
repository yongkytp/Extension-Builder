component output="false"{
<!--- This component provides some nice functions to be able to read from the extension zip files --->
	variables.validinfotags = "name,label,id,version,created,author,category,support,description,mailinglist,name,documentation,image,label,type,version,paypal";
	variables.cdata = "description"; //In case we add more
	
	function getConfig(String extensionName){
		var config = FileRead("zip://#expandPath("/ext/#extensionName#.zip")#!/config.xml")
		return XMLParse(config);
	}
	
	private function setConfig(String extensionName, XML xmlDocument){
		FileWrite("zip://#expandPath("/ext/#extensionName#.zip")#!/config.xml", toString(xmlDocument));
	}
	
	function getInfo(extensionName){
		//Read the config.xml/config/info xml from the /ext/#extensionName#.zip file

			var info = {};
			var config = FileRead("zip://#expandPath("/ext/#extensionName#.zip")#!/config.xml")
				config = XMLParse(config);
			var infoXML = XMLSearch(config, "//info");

				for(inf in infoXML[1].XmlChildren){
					info[inf.xmlName] = Trim(inf.xmlText);
				}
		return info;
	}
	
	function getCapability(String extensionName){
		var capability = {};
		var extPath = "zip://#expandPath("/ext/#extensionName#.zip")#!/";
			capability.tags = DirectoryExists(extPath & "tags") ? ArrayLen(DirectoryList(extPath & "tags",false,"name")) : 0;
			capability.functions = DirectoryExists(extPath & "functions") ? ArrayLen(DirectoryList(extPath & "functions",false,"name")) : 0;	
			capability.applications = DirectoryExists(extPath & "applications") ? ArrayLen(DirectoryList(extPath & "applications",false,"name")) : 0;	
			capability.jars = DirectoryExists(extPath & "jars") ? ArrayLen(DirectoryList(extPath & "jars",false,"name")) : 0;	
		return capability;
	}
	
	function saveInfo(String extensionName, Struct info){
		var extPath = "zip://#expandPath("/ext/#extensionName#.zip")#!/config.xml";
		var extXML = XMLParse(FileRead(extPath));
		
		// add uploaded image file info the extension zip file
		if (structKeyExists(info, "image") and info.image neq "" and not isValid("url", info.image) and fileExists(info.image))
		{
			var extImageName = rereplace(getFileFromPath(info.image), "[^a-zA-Z0-9\-_\.]", "_", "all");
			file action="copy" source="#info.image#" destination="zip://#expandPath("/ext/#extensionName#.zip")#!/#extImageName#";
			// keep a local copy as well, for display purposes
			file action="copy" source="#info.image#" destination="#expandPath("/ext/")##extImageName#";
			info.image = "/" & extImageName;
		}
		
		if(info['name'] EQ extensionName){
				StructDelete(info, "name");
		}
		var infoItem = extXML.config.info;
		
		
		loop collection="#info#" item="local.i"{
			var itemIndex = XMLChildPos(infoItem, i, 1);
			var item = infoItem.XMLChildren[itemIndex];
			if(itemIndex LT 0){
				addElementsToInfo(infoItem, i, info[i], ListFindNoCase(variables.cdata, i));
			}
			else if(ListFindNoCase(variables.cdata, i)){
				item.XMLText = ""; //clear it for upgraders, I would guess this wouldn't ever happen but it does in my tests so fix it.
				item.XmlCData = info[i];			
			}
			else {
				item.XMLText = info[i];
<<<<<<< HEAD
			}
		}	
=======
		}
				
>>>>>>> master
		FileWrite(extPath, toString(extXML));
		updateInstaller(extensionName);
		
		return getInfo(extensionName);
	}
	
	function updateInstaller(String extensionName){
		var installString = FileRead("/services/templates/Install.cfc");
		var extPath = "zip://#expandPath("/ext/#extensionName#.zip")#!";
		var lTags = "";
		var lFunc = "";
		var lJars = "";
		var lApps = "";
		var configXML = XMLParse(FileRead(extPath & "/config.xml"));
		if(DirectoryExists(extPath & "/tags/")){
		var qTAGS = DirectoryList(extPath & "/tags/",false,"query");
			lTags = ValueList(qTAGS.name);
		}
		if(DirectoryExists(extPath & "/functions/")){
		var qFUNC = DirectoryList(extPath & "/functions/",false,"query");
			lFunc = ValueList(qFUNC.name);
		}	
		
		if(DirectoryExists(extPath & "/jars/")){		
		var qJARS = DirectoryList(extPath & "/jars/",false,"query");
			lJars = ValueList(qJARS.name);
		}
		
		
		if(DirectoryExists(extPath & "/applications/")){
		var qApps = DirectoryList(extPath & "/applications/", false, "query");
			lApps = ValueList(qApps.name);
		}
		installString = Replace(installString, "__NAME__", extensionName, "all");
		installString = Replace(installString, "__LABEL__", configXML.config.info.label.XMLText, "all");
		installString = Replace(installString, "__TAGS__", lTags, "all");
		installString = Replace(installString, "__FUNCTIONS__", lFunc, "all");
		installString = Replace(installString, "__JARS__", lJars, "all");
		installString = Replace(installString, "__APPS__", lApps, "all");		
		
		
		FileWrite(extPath & "/Install.cfc", installString);
	}
	
	
	function createNewExtension(String extensionName, String extensionLabel){
		//Need to create the config.xml from the information provided
		var uuid = CreateUUID();
		var created = Now();
		//Create THE XMML config
		var validFields = ListToArray("author,category,support,description,mailinglist,documentation,image,paypal,packaged-by");
		var xmlConfig = XMLNew(true);
		xmlConfig.XMLRoot = XMLElemNew(xmlConfig, "config");
		var infoel = XMLElemNew(xmlConfig.XMLRoot, "info");
		
			//Add some default values
			addElementsToInfo(infoel, "name", extensionName);
			addElementsToInfo(infoel, "label", extensionLabel);
			addElementsToInfo(infoel, "id", CreateUUID());
			addElementsToInfo(infoel, "type", "server");
			addElementsToInfo(infoel, "version", "1.0.0");
			addElementsToInfo(infoel, "created", Now());
			//Now add the rest of the tags
			loop array="#validFields#" index="v"{
				addElementsToInfo(infoel, v, "");
			}
		ArrayAppend(xmlConfig.XMLRoot.XMLChildren, infoel);
		
		//Create a new file name after the name
		zip action="zip" file="#expandpath("/ext/#extensionName#.zip")#"{
			zipparam content=toString(xmlConfig) entrypath="config.xml";
		}
		
		return xmlConfig;
	}
	
	function listFolderContents(String extensionName, String folder){
		var items = [];
		
		var itemdir = "zip://#expandPath("/ext/#extensionName#.zip")#!/#folder#/";
		
		if(!DirectoryExists(itemdir)){
				return items;
		}
		
		var qItems = DirectoryList(itemdir,false,"query");
		
		loop query="qItems"{
				ArrayAppend(items, qItems.name);
		}
		
		return items;	
	}
	
	function addTextFile(String extensionName, String folder, String filename, String Content){
		var itemPath = "zip://#expandPath("/ext/#extensionName#.zip")#!/#folder#/";
		if(!DirectoryExists(itemPath)){
				Directorycreate(itemPath);
		}
		FileWrite(itemPath & "/" & filename, content);
		
		updateInstaller(extensionName);
	}
	
	function getFileContent(String extensionName, String folder, String filename){
		var ret = "";
		var itemPath = "zip://#expandPath("/ext/#extensionName#.zip")#!/#folder#/#filename#";
		if(!fileExists(itemPath)){
				return "";
		}
		return FileRead(itemPath);
	}
	
	function saveStep(String extensionName, Numeric step=0, String label, String description=""){
		var configXML = getConfig(extensionName);
		var steps = XMLSearch(configXML, "//step");
		
		
		if(step == 0){ // we are just adding this should be easier
			var item = XMLElemNew(configXML, "step");
				item.XMLAttributes["label"] = label;
				item.XMLAttributes["description"] = description;
			ArrayAppend(configXML.config.XMLChildren, item);
		}
		else {
			var item = configXML.config.step[step];
				item.XMLAttributes["label"] = label;
				item.XMLAttributes["description"] = description;
		}
		setConfig(extensionName, configXML)
		return getConfig(extensionName);		
	}
	
	
	function saveGroup(String extensionName, Numeric step=0, Numeric group=0, String label, String description=""){
		var configXML = getConfig(extensionName);
		var steps = XMLSearch(configXML, "//step");
		
		if(!Arrayisdefined(steps, step)){
				throw("No step found!");
		}
		var currstep = steps[step];
		
		if(group == 0){
			var groupItem  = XMLElemNew(configXML, "group") ;
				groupItem.XMLAttributes["label"] = label;
				groupItem.XMLAttributes["description"] = description;
				ArrayAppend(currstep.XMLChildren, groupItem);
		}
		else{ // the group should exist. 
			var groupItem	= configXML.config.step[step].group[group];
				groupItem.XMLAttributes["label"] = label;
				groupItem.XMLAttributes["description"] = description;
		}
		
		setConfig(extensionName, configXML);
	}

	
	function addBinaryFile(String extensionName, String source, String folder){
		var itemPath = "zip://#expandPath("/ext/#extensionName#.zip")#!/#folder#/";
		if(!DirectoryExists(itemPath)){
				Directorycreate(itemPath);
		}
		//Has to have the full name
			itemPath  = itemPath & ListLast(source, "/");
		
		FileMove(source, itemPath);
		updateInstaller(extensionName);
	}
	

	
	
	function addElementsToInfo(xmlItem, name, value="", isCDATA=false){
			var item = XMLElemNew(xmlItem, name);
			
				if(isCDATA){
					item.XmlCData = value;		
				}
				else{
					item.XMLText = value;
				}
			ArrayAppend(xmlItem.XMLChildren, item);
	}
	
	function removeTextFile(String extensionName, String folder, String filename){
		var itemPath = "zip://#expandPath("/ext/#extensionName#.zip")#!/#folder#/#filename#";
		if(FileExists(itemPath)){
			FileDelete(itemPath);
		}
	}
	
	
	
}