--fileins
(
	local thisdir = (getFilenamePath(getThisScriptFilename()))
	filein (thisdir + @"modules/SkinIOReturn.ms")
	filein (thisdir + @"modules/SkinIOHelpers.ms")
	filein (thisdir + @"modules/SkinIORequests.ms")
	filein (thisdir + @"modules/SkinIOModules.ms")
)


--m = Modulo()
--m.init (@"C:\Work\code\3ds\maxscript\SkinIO\SkinIO\")
--x = m.file_in "SkinIO"
--x = m.file_in "test"

-- Class: SkinIO
-- The main class to work with.
struct SkinIO (

	fn export_skin_archive host_node export_path:undefined skin_name:"Skin" = (
		local req = SkinIOExportRequest()
		req.init host_node export_path:export_path skin_name:skin_name

		local ret = (req.validate())
		if ret then (
			ret = (SkinIOExport()).export req
		)
		ret
	),

	fn load_skin_archive skin_archive = (
		local req = SkinIOImportRequest()
		req.init skin_archive

		(SkinIOImport()).import req
	),

	on create do ()
)

skinio = SkinIO()
--io.load_skin_archive @"C:\Work\code\3ds\maxscript\tmp\GauvainF04A_Mdl_Hood_Skin_78003013.zip"
--io.export_skin_archive $  export_path:@"C:\Work\code\3ds\maxscript\tmp\"
--0