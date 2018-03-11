--app.ms
(

	-- Modolize
	local modo = Modolize()
	modo.refresh(getThisScriptFilename())
	break()
	
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
