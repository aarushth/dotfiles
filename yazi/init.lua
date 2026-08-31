require("recycle-bin"):setup()
ps.sub("ind-app-title", function(body)
	-- body contains the current directory or app information
	local title = "Yazi"

	-- Send the escape sequence to update the terminal window title
	io.write("\27]2;" .. title .. "\7")
	io.flush()
end)
