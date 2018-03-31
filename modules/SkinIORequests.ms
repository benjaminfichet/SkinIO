-- Class: SkinIOBaseRequest
-- The base class for the Input/Output requests. Do not instantiate.
struct SkinIOBaseRequest (

	-- Variable: node
    -- public - The node associated with the request
	node        = undefined,


	-- Variable: skinmod
    -- public - The skin modifier associated with the request
	skinmod     = undefined,

	-- Private stuff..
	__child     = undefined,
	__timestamp = undefined,
	__packed_extension = ".zip",


	/* Function: fn validate = (..)

	   Validates this request by using the super validator. Checks that : 

	   		- the node is valid
	   		- the skin is valid
	   		- the skin is holded by the same node 

	   	Return:

	   		True or False
	*/
	fn validate = (
		local vnode     = (isValidNode node)
		local vskin     = ((classof skinmod) == Skin)

		local deps      = (refs.dependentNodes skinmod)
		local vsameNode = (if (deps != undefined) and (deps.count > 0) then (deps[1] == node) else (false))
			
		(vnode and vskin and vsameNode)
	),


	/* Function: fn _loadSkinMod skin_name:undefined = (..)

	   Loads this.skinmod with node.modifiers[skin_name] if skin_name: is given else with node.modifiers[#Skin]


	   	Return:

	   		True or False
	*/
	fn _loadSkinMod skin_name:undefined = (
		local ret = false
		if (isValidNode node) then (
			local sknName = if skin_name != undefined then (skin_name as name) else (#Skin)
			this.skinmod = (node.modifiers[sknName])
			ret = (classof(this.skinmod) == Skin)
		)
		ret
	),

	/* Function: fn _makeFilenameFromThis = (..)

	   Makes a filename for the giver node, skin modifier, and registered timestamp.

	   	Return:

	   		False or Filename
	*/
	fn _makeFilenameFromThis = (
		local ret = false
		local fname = ""
		
		-- Object's name cut
		local splt_dash = filterString this.node.name "_"
		if splt_dash.count >= 2 then (
			fname = splt_dash[1] + "_" + splt_dash[2]
			for i=3 to splt_dash.count do (
				if i <= splt_dash.count do (fname=fname+"_")
				fname = fname + splt_dash[i]
			)

			-- Skin Name
			fname = fname + "_" + this.skinmod.name

			-- Timestamp
			if this.__timestamp == undefined then (this.__timestamp = timeStamp())
			fname = fname + "_" + (this.__timestamp as string)

			-- return
			ret = fname
		)
		ret
	),

	on create do ()
)


-- Class: SkinIOExportRequest
-- The export request class
struct SkinIOExportRequest (

	-- Variable: super
    -- private - The baseclass, of type <<SkinIOBaseRequest>>, providing common methods for requests
	super        = undefined, -- <<Super>> class



	private
	-- Variable: export_path
    -- public - Where we will export our Skin
	export_path   = undefined,


	-- Variable: ascii
    -- public - Do we export our skin in ascii format ?
	ascii         = false,


	-- Variable: export_packed
    -- deprecated - Do we pack our export ?
	export_packed = undefined,



	public
	/* Function: fn init node skin_name:undefined export_path:undefined = (..)

		Inits a request. The only required parameter is a node. You can also pass the <<skin_name:>> and <<export_path:>> parameters.

		Parameters:

			- node  The node to load a skinh modifier from
			- skin_name: If given we will select this skin modifier
			- export_path: If given this is the directory where we will export our skin to

		Return:
			True or False
	*/
	fn init node skin_name:undefined export_path:undefined ascii:false packed_extension:".zip" = (
		local ret = SkinIOReturn ret:(isValidNode node)
		if ret.ret then (

			this.super.node = node
			this.ascii = ascii
			this.super.__packed_extension = packed_extension
			
			ret = this.super._loadSkinMod skin_name:skin_name
			if ret then (
				ret = this.setExportPath export_path
			)
		)else(ret.reason = @"The node in not valid!")
		ret
	),

	/* Function: fn validate = (..)

	   Validates this request by using the super validator. Checks that : 

	   		- the node is valid
	   		- the skin is valid
	   		- the skin is holded by the same node 

	   	Return:

	   		True or False
	*/
	fn validate = (this.super.validate()),

	/* Function: fn getSkinMod = (..)

	   Returns the Skin modifier associated with this request.
	*/
	fn getSkinMod = (this.super.skinmod),

	/* Function: fn getNode = (..)

	   Returns the Node associated with this request.
	*/
	fn getNode    = (this.super.node),
	
	/* Function: fn getEnvPath = (..)

	   Returns the path for this's env file
	*/
	fn getEnvPath              = ((this.getPath()) + ".env"),
	
	/* Function: fn getIniPath = (..)

	   Returns the path for this's ini file
	*/
	fn getIniPath              = ((this.getPath()) + ".ini"),
	
	/* Function: fn getZipPath = (..)

	   Returns the path for this's zip file
	*/
	fn getZipPath              = ((this.getPath()) + ".zip"),

	/* Function: fn getPath = (..)

	   Returns the path for this's without any extension
	*/
	fn getPath = (this.export_path + (this.getFilename())),

	/* Function: fn getFilename = (..)

	   Returns the filename created for this request
	*/
	fn getFilename = (
		local ret = this.validate()
		if ret then (ret = this.super._makeFilenameFromThis())
		ret
	),

	/* Function: fn setExportPath path = (..)

	   Sets export_path after validating it. 
	*/
	fn setExportPath path = (
		local ret = (classof(path) == String) or path == undefined
		if ret then (
			local dp = path
			if dp == undefined then (dp = sysInfo.tempdir)
			local fexists = doesFileExist dp
			local isDir   = getFileAttribute dp #directory

			ret = (fexists and isDir)
			if ret then (this.export_path = dp)
		)
		ret
	),

	fn getExportPath = (this.export_path),


	on create do (this.super = SkinIOBaseRequest __child:this)
)


-- Class: SkinIOImportRequest
-- The import request class
struct SkinIOImportRequest (
	
	-- Variable: super
    -- private - The baseclass, of type <<SkinIOBaseRequest>>, providing common methods for requests
	super        = undefined,

	private
	-- Variable: import_path
    -- private - The importing archive path 
	import_path  = undefined,

	
	version      = undefined,
	filename     = undefined,
	skinName     = undefined,
	objectName   = undefined,

	public
	fn init import_path		 = (SkinIOReturn ret:(this.setImportPath import_path)),
	fn setImportPath ip = (
		local ret = (classof(ip) == String) or ip == undefined
		if ret then (
			local dp = ip
			if dp == undefined then (dp = sysInfo.tempdir)
			local fexists = doesFileExist dp
			local isDir   = not (getFileAttribute dp #directory)

			ret = (fexists and isDir)
			if ret then (
				this.import_path = dp
				ret = this.parseFilename()
			)else(
				this.import_path = false
			)
		)
		ret
	),
	fn validate = (
		true -- to implement!!!!
	),

	fn getImportPath    = (this.import_path),
	fn getImportPathDir = (getFilenamePath  (this.getImportPath())),
	fn getIniFilename   = (substituteString (this.getImportPath()) ".zip" ".ini" ),
	fn getEnvFilename   = (substituteString (this.getImportPath()) ".zip" ".env" ),


	private
	fn parseFilename = (
		local ret = import_path != undefined
		if ret then (
			local toks = filterString import_path @"\"
			ret = toks.count > 0 
			if ret then (
				toks = toks[toks.count]
				local ext = getFilenameType toks
				if ext == ".zip" then (
					this.filename = getFilenameFile(toks)
					local tokens = filterString (this.filename) "_"
					if tokens.count >=4 then (
						local oName = ""
						for i=1 to tokens.count-2 do (
							oName = oName + tokens[i]
							if i < (tokens.count-2) then (
								oName = oName + "_"
							)
						)

						if this.objectName == undefined then (this.objectName = oName)
						this.skinName   = tokens[tokens.count-1]
						this.version    = tokens[tokens.count]
						--format "ObjName:% SknName:% Version:%\n" this.objectName this.skinName this.version
						ret = true
					)
				)
			)
		)
		ret
	),

	public
	fn getVersion = (this.version),   
	fn getFilename = (this.filename),  

	fn getSkinName = (this.skinName),  
	fn getObjectName = (this.objectName),
	on create do (this.super = SkinIOBaseRequest __child:this)
)


--s = SkinIOImportRequest()
--s.init @"C:\Work\code\3ds\maxscript\tmp\GauvainF04A_Mdl_Hood_Skin_73015321.zip"--