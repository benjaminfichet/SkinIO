-- SkinIO.ms


-- Class: SkinIOHelpers
-- A class that encapsulate various commons methods to work with 3dsmax skins
struct SkinIOHelpers (

	/* Function: selectSkinmod

	   Selects the given skin modifier in the modify panel.

	   Parameters:

	    	skn - The skin modifier to select.
	    	node_index:1 - In canse there is multiple nodes referencing the skin, set which index to select

	   Returns:

	    	True or False if the skin was selectionned or not
	*/
	fn selectSkinmod skn node_index:1 = (
		local ret = false
		local nd = refs.dependentNodes skn
		if nd!=undefined and nd.count > 0 then (
			nd = nd[node_index]
			max modify mode
			clearSelection()
			select nd
			modPanel.setCurrentObject skn
			ret = true
		)
		ret
	),

	on create do ()
)



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

	fn _findSkinMod skin_name:undefined = (
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
	_super      = undefined, -- <<Super>> class

	export_path   = undefined,
	export_packed = undefined,

	fn getSkinMod = (this._super.skinmod),
	fn getNode    = (this._super.node),
	
	fn getEnvPath              = ((this.getPathWithoutExtension()) + ".env"),
	fn getIniPath              = ((this.getPathWithoutExtension()) + ".ini"),
	fn getZipPath              = ((this.getPathWithoutExtension()) + ".zip"),
	fn getPathWithoutExtension = (this.export_path + (this.getFilename())),

	fn getFilename = (
		local ret = this.validate()
		if ret then (ret = this._super._makeFilenameFromThis())
		ret
	),

	fn validate = (this._super.validate()),
	fn init node skin_name:undefined export_path:undefined = (
		local ret = false
		if (isValidNode node) then (
			this._super.node = node
			ret = this._super._findSkinMod skin_name:skin_name

			if ret then (
				ret = this._findExportPath export_path
			)
		)
		ret
	),

	fn _findExportPath path = (
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

-- Class: SkinIOExport
-- The skin exporter
struct SkinIOExport (
	fn export request = (
		local ret = (iskindof request SkinIOExportRequest) and (request.validate()) -- SkinIOExport works with a SkinIOExportRequest
		if ret then (
			print ("Ready to export to : ("+request.export_path + request.getFilename() +")")
			ret = this._outputBoneList request
			if ret then (
				ret = this._outputEnvelopes request
				if ret then (
					ret = this._zipExport request
				)
			)
		)
		ret
	),

	fn _outputBoneList request = (
		local ret = false -- ReturnCode ret:false reason:("Unable to output bone list! (" + (request.getFilename()) + ")")	
		local sknMod = (request.getSkinMod())
		ret = (SkinIOHelpers()).selectSkinmod sknMod
		if ret then (
			local boneListFilename = request.getIniPath()
			local f = createfile (boneListFilename)
			close f


			local numbone = skinOps.GetNumberBones sknMod
			local f = openfile boneListFilename mode:#a
			for i=1 to numbone do
			(
				TempName = skinOps.GetBoneName sknMod i 1
				TempName= TempName+"\n"
				format TempName to:f
			)
			close f
			ret = true
		)
		ret
	),

	fn _outputEnvelopes request ascii:false = (
		local ret = false -- ReturnCode ret:false reason:("Unable to output envelopes! (" + (pub.getEnvelopesFilepath()) + ")")	
		
		-- select skin..
		ret =  true -- (SkinIOHelpers()).selectSkinmod sknMod
		if ret then (
			local envpath = request.getEnvPath() --request.export_path + (request.getFilename()) + ".env"
			local sknMod = (request.getSkinMod())
			if ascii == true then (skinOps.SaveEnvelopeAsASCII sknMod (envpath + "ASCII"))
			else                  (skinOps.SaveEnvelope sknMod (envpath))

			ret = true
		)
		ret
	),

	fn _zipExport request = (
		local ret = false
		local tmp_folder_name = request.getPathWithoutExtension()
		
		if (makeDir tmp_folder_name) then (
			local newenv = (tmp_folder_name + @"\" + request.getFilename() + ".env")
			local newini = (tmp_folder_name + @"\" + request.getFilename() + ".ini")

			local mv_1 = renameFile (request.getEnvPath()) newenv
			local mv_2 = renameFile (request.getIniPath()) newini
			if mv_1 and mv_2 then (

				local z = dotnetclass "System.IO.Compression.ZipFile"
				z.createFromDirectory tmp_folder_name (tmp_folder_name + request._super.__packed_extension)

				local sioDir = dotNetClass "System.IO.Directory"
				if (SIODir.Exists tmp_folder_name) do SIODir.Delete (tmp_folder_name) true

				ret = true
			)
		)
		ret
	),

	on create do ()
)

-- Class: SkinIOImport
-- The skin importer 
struct SkinIOImport (
	on create do ()
)


-- Class: SkinIO
-- The main class to work with.
struct SkinIO (
	on create do ()
)




export_request = SkinIOExportRequest()-- export_packed:true
export_request.init $ export_path:@"C:\Work\code\3ds\maxscript\tmp\"--skin_name:"Skina" -- export_path:"MySuperPath"
if not (export_request.validate()) then (throw "Request is not valid.")

-- export_request is a valid request, we can work with it.
exporter = SkinIOExport()
exporter.export export_request
