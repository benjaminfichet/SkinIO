-- Class: SkinIOBaseRequest
-- The base class for the Input/Output requests. Do not instantiate.
struct SkinIOBaseRequest (
	__child     = undefined,
	node        = undefined,
	skinmod     = undefined,
	__timestamp = undefined,
	__packed_extension = ".zip",

	fn validate = (
		local vnode     = (isValidNode node)
		local vskin     = ((classof skinmod) == Skin)

		local deps      = (refs.dependentNodes skinmod)
		local vsameNode = (if (deps != undefined) and (deps.count > 0) then (deps[1] == node) else (false))
			
		(vnode and vskin and vsameNode)
	),

	fn _loadSkinMod skin_name:undefined = (
		local ret = false
		if (isValidNode node) then (
			local sknName = if skin_name != undefined then (skin_name as name) else (#Skin)
			this.skinmod = (node.modifiers[sknName])
			ret = (classof(this.skinmod) == Skin)
		)
		ret
	),

	fn _makeFilenameFromThis = (
		local ret = false
		local fname = ""
		
		-- Object's name cut
		local splt_dash = filterString this.node.name "_"
		if splt_dash.count >= 2 then (
			fname = splt_dash[2]
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

	-- Variable: _super
    -- private - The baseclass, of type <<SkinIOBaseRequest>>, providing common methods for requests
	_super        = undefined, -- <<Super>> class

	-- Variable: export_path
    -- public - Where we will export our Skin
	export_path   = undefined,

	-- Variable: export_packed
    -- deprecated - Do we pack our export ?
	export_packed = undefined,


	/* Function: fn init node skin_name:undefined export_path:undefined = (..)

		Inits a request. The only required parameter is a node. You can also pass the <<skin_name:>> and <<export_path:>> parameters.

		Parameters:

			- node  The node to load a skinh modifier from
			- skin_name: If given we will select this skin modifier
			- export_path: If given this is the directory where we will export our skin to

		Return:
			True or False
	*/
	fn init node skin_name:undefined export_path:undefined = (
		local ret = SkinIOReturn ret:(isValidNode node)
		if ret.ret then (

			this._super.node = node
			
			ret = this._super._loadSkinMod skin_name:skin_name
			if ret then (
				ret = this._loadExportPath export_path
			)
		)else(ret.reason = @"The node in not valid!")
		ret
	),


	/* Function: fn validate = (..)

	   Validates this request by using the _super validator. Checks that : 

	   		- the node is valid
	   		- the skin is valid
	   		- the skin is holded by the same node 

	   	Return:

	   		True or False
	*/
	fn validate = (this._super.validate()),


	/* Function: fn getSkinMod = (..)

	   Returns the Skin modifier associated with this request.
	*/
	fn getSkinMod = (this._super.skinmod),

	/* Function: fn getNode = (..)

	   Returns the Node associated with this request.
	*/
	fn getNode    = (this._super.node),
	
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
		if ret then (ret = this._super._makeFilenameFromThis())
		ret
	),

	
	

	/* Function: fn _loadExportPath path = (..)

	   Sets export_path after validating it. 
	*/
	fn _loadExportPath path = (
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
	on create do (this._super = SkinIOBaseRequest __child:this)
)


-- Class: SkinIOImportRequest
-- The import request class
struct SkinIOImportRequest (
	on create do ()
)