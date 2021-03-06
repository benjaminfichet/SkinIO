(
	local thisdir = (getFilenamePath(getThisScriptFilename()))
	filein (thisdir + @"modules/SkinIOReturn.ms")
	filein (thisdir + @"modules/SkinIOHelpers.ms")
	filein (thisdir + @"modules/SkinIORequests.ms")
	filein (thisdir + @"modules/SkinIOModules.ms")
)

-- Class: SkinIO
-- The main class to work with.
struct SkinIO (

	fn export_skin_archive host_node export_path:undefined skin_name:"Skin" ascii:false = (
		local req = SkinIOExportRequest()
		req.init host_node export_path:export_path skin_name:skin_name ascii:ascii

		local ret = (req.validate())
		if ret then (
			ret = (SkinIOExport()).export req
		)
		ret
	),

	fn import_skin_archive skin_archive node:undefined = (
		local req = SkinIOImportRequest()
		req.init skin_archive node:node

		(SkinIOImport()).import req
	),

	fn reload_skin host_node skin_name:"Skin" = (
		local xpt_req = SkinIOExportRequest()
		xpt_req.init host_node skin_name:skin_name

		if (xpt_req.validate()) then (
			if ((SkinIOExport()).export xpt_req) then (

				-- We did export successfully, now import
				local imp_req = SkinIOImportRequest()
				imp_req.init (xpt_req.getZipPath())

				-- Delete old skin


				return ((SkinIOImport()).import imp_req)
			)
		)
	),

	on create do ()
)

-- Instantiate a SkinIO object
-- sio = SkinIO()
-- sio.export_skin_archive $Ch_XXXX_Mdl_XXXX export_path:@"C:\Work\code\3ds\maxscript\UMS\datastore\" -- ascii:true
-- sio.import_skin_archive @"C:\Work\code\3ds\maxscript\tmp\Ch_XXXX_Mdl_XXXX_Skin_78003013.zip"
-- sio.reload_skin $Ch_XXXX_Mdl_XXXX skin_name:"Skin"