/* Class: SkinIOReturn
	
	A class that is returned by most SkinIO* functions, it allows faster, more precise and concise control flow(s).

	The class is best used as the specific pattern:
	--- Code
	fn x = (..)
	fn y = (
		local ret = x() -- a SkinIOReturn
		if ret.ret then (
			-- use ret.data, set a ret, etc ..
		)
		ret -- Letting ret flow through the calls..
	)


	v = y()
	---
	if the code failed in x(), then 
	--- Code
		v.ret will be false
		v.reason will be x()'s one
		-- The SkinIOReturn in v is directly from x()
	---

	if the code failed in y(), then 
	--- Code
		v.ret will be false
		v.reason will be y()'s one
		-- The SkinIOReturn in v is from y()
	---




	Exemple  :

	--- Code
	fn aPatternFunc = (

		local ret = SkinIOReturn ret:(aCheckWhichRetABoolean()) -- Allocate a new return
		if ret.ret then (                       -- Checks for the boolean return code

			
			-- Another func ? No prob as it returns a SkinIOReturn we can directly set *ret* to it
			ret = anotherFunctionThatRet() -- And check if it returned well      
			if ret.ret then (

				-- If we are here then the data param could contain something..
				local myVar = ret.data          -- Data is in the data param if the ret code is true

				-- Now we can fill our own return code for the caller function to have a clean return
				ret.ret = ..domothing..
				ret.reason = "aReason"
				--...
			)
			else
			(
				-- If we are here then the reason parameter should contain a reson for the ret != true
				-- ..
			)

		)
		-- By using the same <<ret>> keyword, and the same pattern,
		-- we are able to transmit ret(s), data(s) and reason(s) from as deep as the calls go.


		ret -- Implicit return, does not use C++ exceptions! == fast
	)
	---

	By using the same <<ret>> keyword, and the same pattern through functions, we are able to transmit ret(s), data(s) and reason(s) from as deep as possible. == greater debug

	It also helps the use of implicit returns, which don't  use C++ exceptions, meaning faster code!

	You can allocate a SkinIOReturn using the keyword *SkiRet*
*/
struct SkinIOReturn (

	-- Variable: ret
    -- public - The main return code, usually a boolean. Can be something else for specific purposes.
	ret = undefined,
	

	-- Variable: data
    -- public - Let's say the return code is set as true, then maybe you want to return some data ? It is it here. 
	data = undefined,

	-- Variable: ret
    -- public - In case the ret code is set to false, then maybe the function did leave a reason for the fail ? It is it here. 
	reason = undefined
)
SkiRet = SkinIOReturn