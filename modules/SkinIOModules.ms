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
		local tmp_folder_name = request.getPath()
		
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
