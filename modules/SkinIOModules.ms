-- Class: SkinIOExport
-- The skin exporter
struct SkinIOExport (

	public
	fn export request = (
		local ret = (iskindof request SkinIOExportRequest) and (request.validate()) -- SkinIOExport works with a SkinIOExportRequest
		if ret then (
			--print ("Ready to export to : ("+request.getExportPath() + request.getFilename() +")")
			ret = this._outputBoneList request
			if ret then (
				ret = this._outputEnvelopes request
				if ret then (
					ret = this._packArchive request
				)
			)
		)
		ret
	),


	private
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
	fn _packArchive request = (
		local ret = false
		local tmp_folder_name = request.getPath()
		
		if (makeDir tmp_folder_name) then (
			local newenv = (tmp_folder_name + @"\" + request.getFilename() + ".env")
			local newini = (tmp_folder_name + @"\" + request.getFilename() + ".ini")

			local mv_1 = renameFile (request.getEnvPath()) newenv
			local mv_2 = renameFile (request.getIniPath()) newini
			if mv_1 and mv_2 then (

				local z = dotnetclass "System.IO.Compression.ZipFile"
				z.createFromDirectory tmp_folder_name (tmp_folder_name + request.super.__packed_extension)

				local sioDir = dotNetClass "System.IO.Directory"
				if (SIODir.Exists tmp_folder_name) do SIODir.Delete (tmp_folder_name) true

				ret = true
			)
		)
		ret
	)
)

-- Class: SkinIOImport
-- The skin importer 
struct SkinIOImport (

	private
	fn pre_import_backup = (
		true
	),
	fn _unpackArchive request = (
		local ret = false
		try(
			local z = dotnetclass "System.IO.Compression.ZipFile"
			z.extractToDirectory (request.getImportPath()) (request.getImportPathDir())
			ret = true
		)
		catch(ret = false)
		ret
	),
	fn _loadHostNode request = (
		local ret = false
		local nds = for i in objects where MatchPattern i.name pattern:("*_"+request.getObjectName()) collect i
		if nds.count > 0 then (ret = nds[1])
		ret
	),
	fn _importSkin host request = (

		local envFile = request.getEnvFilename()
		local iniFile = request.getIniFilename()
		local skinName = request.getSkinName()

		local ret = (doesFileExist envFile) and (doesFileExist iniFile) and (isValidNode host)
		if ret then (

			-- Prepare panels..
			(SkinIOHelpers()).prepareCommandPanelToNewSkin host

			-- Add new skin
			local skn = Skin name:skinName
			modPanel.addModToSelection (skn)
			(SkinIOHelpers()).selectSkinmod skn
			
			try
			(
				skinOps.closeWeightTool skn
				local nBones = skinOps.GetNumberBones skn
				for i=1 to nBones do skinOps.removebone skn 1
			
				local tempLog = ""
				F = openfile iniFile mode:#r
				while not eof F do
				(
					local nam = (readline F)
					local boneNode = getnodebyname nam
					if isValidNode boneNode then skinOps.addbone skn boneNode 0 else templog += nam+"\n"
				)
				close F
			)
			catch(messageBox "Error reading ini skin file!")
				
			fn skinMonitorOps = 
			(
				hwnd = dialogMonitorOps.getWindowHandle()
				dialogTitle = uiAccessor.getWindowText hwnd
				if dialogTitle != undefined and matchPattern dialogTitle pattern:"*Load Env*" then(uiAccessor.PressDefaultButton())
				true
			)
			
			modPanel.setCurrentObject skn node:host ui:true
			dialogMonitorOps.enabled = true
			dialogMonitorOps.interactive = false
			dialogMonitorOps.unregisterNotification id:#SkinIOLoader
			dialogMonitorOps.registerNotification skinMonitorOps id:#SkinIOLoader
			skinOps.LoadEnvelope skn envFile
			dialogMonitorOps.unregisterNotification id:#SkinIOLoader
			dialogMonitorOps.enabled = false

			-- Cleanup files
			this._deleteSkinFiles()
		)
		ret
	),
	fn _deleteSkinFiles = (
		try(
			deleteFile (request.getIniFilename())--print (request.getIniFilename())
			deleteFile (request.getEnvFilename())--print (request.getEnvFilename())
		)catch()
	),

	public
	fn import request no_bk:false = (
		local ret = (iskindof request SkinIOImportRequest) and (request.validate()) -- SkinIOExport works with a SkinIOExportRequest
		if ret then (
			if (pre_import_backup() == true) or (no_bk == true) then (
				local didExtract = this._unpackArchive(request) 
				if didExtract then (
					--print "extracted!"
					local hostNode = this._loadHostNode request
					if hostNode != false then (
						format "Loading skin on host: %\n" hostNode.name
						ret = this._importSkin hostNode request
					)
					this._deleteSkinFiles()
				)
			)
		)
		ret
	)
)