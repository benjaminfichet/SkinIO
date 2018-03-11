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
			setCommandPanelTaskMode #modify
			modPanel.setCurrentObject skn
			ret = true
		)
		ret
	),

	fn prepareCommandPanelToNewSkin nd = (
		modPanel.setCurrentObject nd.baseObject node:nd ui:true
		if nd.modifiers[#Morpher] != undefined do modPanel.setCurrentObject nd.Morpher node:nd ui:true
	),

	fn isDir fp = ((doesFileExist fp) and (getFileAttribute fp #directory)),

	on create do ()
)
