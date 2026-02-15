-- Dark icon set for Xelu Free Controller & Key Prompts. Commonly used throughout most Roblox games.

-- IMPORTANT: This icon set does not support responsive highlighting
-- To add support, create a new table with a '_pressed' suffix for each platform, and fill it with pressed icons

local iconSet: {[string]: {[Enum.KeyCode]: string}} = {}

-- Keyboard / Mouse icons
iconSet.keyboard = {
	[Enum.KeyCode.A] = "rbxassetid://106567914960693",
	[Enum.KeyCode.B] = "rbxassetid://93942557117561",
	[Enum.KeyCode.C] = "rbxassetid://73938035270751",
	[Enum.KeyCode.D] = "rbxassetid://132790717119288",
	[Enum.KeyCode.E] = "rbxassetid://136590271816477",
	[Enum.KeyCode.F] = "rbxassetid://102396597493191",
	[Enum.KeyCode.G] = "rbxassetid://111433199008675",
	[Enum.KeyCode.H] = "rbxassetid://127285084289020",
	[Enum.KeyCode.I] = "rbxassetid://119996050986381",
	[Enum.KeyCode.J] = "rbxassetid://105653294482350",
	[Enum.KeyCode.K] = "rbxassetid://75504871985204",
	[Enum.KeyCode.L] = "rbxassetid://133916917072027",
	[Enum.KeyCode.M] = "rbxassetid://95054444625827",
	[Enum.KeyCode.N] = "rbxassetid://94847088821931",
	[Enum.KeyCode.O] = "rbxassetid://94153119110032",
	[Enum.KeyCode.P] = "rbxassetid://84857838830427",
	[Enum.KeyCode.Q] = "rbxassetid://85368622180947",
	[Enum.KeyCode.R] = "rbxassetid://107331508406054",
	[Enum.KeyCode.S] = "rbxassetid://129469799241178",
	[Enum.KeyCode.T] = "rbxassetid://109217481144680",
	[Enum.KeyCode.U] = "rbxassetid://127594433018578",
	[Enum.KeyCode.V] = "rbxassetid://83541439256096",
	[Enum.KeyCode.W] = "rbxassetid://81597945257386",
	[Enum.KeyCode.X] = "rbxassetid://106860420712624",
	[Enum.KeyCode.Y] = "rbxassetid://84888804386263",
	[Enum.KeyCode.Z] = "rbxassetid://85981922194782",
	[Enum.KeyCode.Zero] = "rbxassetid://103060919530543",
	[Enum.KeyCode.One] = "rbxassetid://99320815768571",
	[Enum.KeyCode.Two] = "rbxassetid://90713115313249",
	[Enum.KeyCode.Three] = "rbxassetid://136236373663858",
	[Enum.KeyCode.Four] = "rbxassetid://88288258406940",
	[Enum.KeyCode.Five] = "rbxassetid://85826144381423",
	[Enum.KeyCode.Six] = "rbxassetid://102175868358774",
	[Enum.KeyCode.Seven] = "rbxassetid://120107879851574",
	[Enum.KeyCode.Eight] = "rbxassetid://132515780873117",
	[Enum.KeyCode.Nine] = "rbxassetid://77885589335149",
	[Enum.KeyCode.Space] = "rbxassetid://116330275913663",
	[Enum.KeyCode.Return] = "rbxassetid://126563602616414", -- appears as enter
	[Enum.KeyCode.Tab] = "rbxassetid://96989294242245",
	[Enum.KeyCode.Backspace] = "rbxassetid://104293586781939",
	[Enum.KeyCode.Escape] = "rbxassetid://104450053249683",
	[Enum.KeyCode.Up] = "rbxassetid://87238900992629",
	[Enum.KeyCode.Down] = "rbxassetid://133104334052392",
	[Enum.KeyCode.Left] = "rbxassetid://109748011270973",
	[Enum.KeyCode.Right] = "rbxassetid://135823944185304",
	[Enum.KeyCode.LeftShift] = "rbxassetid://90560288961887",
	[Enum.KeyCode.RightShift] = "rbxassetid://90560288961887",
	[Enum.KeyCode.LeftControl] = "rbxassetid://101475762269004",
	[Enum.KeyCode.RightControl] = "rbxassetid://101475762269004",
	[Enum.KeyCode.LeftAlt] = "rbxassetid://115928341989586",
	[Enum.KeyCode.RightAlt] = "rbxassetid://115928341989586",
	[Enum.KeyCode.Slash] = "rbxassetid://139246336579713", -- appears as backslash
	[Enum.KeyCode.Semicolon] = "rbxassetid://89284856298608",
	[Enum.KeyCode.Quote] = "rbxassetid://115432403988621", -- appears as double quote
	[Enum.KeyCode.Minus] = "rbxassetid://123122590911338",
	[Enum.KeyCode.LeftBracket] = "rbxassetid://111481567393699",
	[Enum.KeyCode.RightBracket] = "rbxassetid://97207123946239",
	[Enum.KeyCode.BackSlash] = "rbxassetid://139246336579713",
	[Enum.KeyCode.MouseLeftButton] = "rbxassetid://124503412360112",
	[Enum.KeyCode.MouseRightButton] = "rbxassetid://115799487501082",
	[Enum.KeyCode.MouseMiddleButton] = "rbxassetid://97120801583108",
	-- Add more keyboard keys as needed.
}

-- Xbox controller icons
iconSet.xbox = {
	[Enum.KeyCode.ButtonA] = "rbxassetid://121056661169708",
	[Enum.KeyCode.ButtonB] = "rbxassetid://74382587467013",
	[Enum.KeyCode.ButtonX] = "rbxassetid://100175429624309",
	[Enum.KeyCode.ButtonY] = "rbxassetid://86096454362572",
	[Enum.KeyCode.ButtonL1] = "rbxassetid://126218287657288",
	[Enum.KeyCode.ButtonR1] = "rbxassetid://95649500244183",
	[Enum.KeyCode.ButtonL2] = "rbxassetid://92789360182519",
	[Enum.KeyCode.ButtonR2] = "rbxassetid://98002716864197",
	[Enum.KeyCode.ButtonL3] = "rbxassetid://110802589523435",
	[Enum.KeyCode.ButtonR3] = "rbxassetid://114005394722262",
	[Enum.KeyCode.ButtonStart] = "rbxassetid://106385958705978",
	[Enum.KeyCode.ButtonSelect] = "rbxassetid://98742497173720",
	[Enum.KeyCode.DPadUp] = "rbxassetid://91339653952836",
	[Enum.KeyCode.DPadDown] = "rbxassetid://104669231341837",
	[Enum.KeyCode.DPadLeft] = "rbxassetid://70817433334175",
	[Enum.KeyCode.DPadRight] = "rbxassetid://100359799830093",
	-- Add more Xbox buttons as needed.
}

-- PlayStation controller icons
iconSet.ps = {
	[Enum.KeyCode.ButtonA] = "rbxassetid://83055964101519",
	[Enum.KeyCode.ButtonB] = "rbxassetid://103436293787842",
	[Enum.KeyCode.ButtonX] = "rbxassetid://119213726450334",
	[Enum.KeyCode.ButtonY] = "rbxassetid://105613821877337",
	[Enum.KeyCode.ButtonL1] = "rbxassetid://76595701899478",
	[Enum.KeyCode.ButtonR1] = "rbxassetid://103433116690568",
	[Enum.KeyCode.ButtonL2] = "rbxassetid://103003728115809",
	[Enum.KeyCode.ButtonR2] = "rbxassetid://98485031834725",
	[Enum.KeyCode.ButtonL3] = "rbxassetid://121661463374661",
	[Enum.KeyCode.ButtonR3] = "rbxassetid://82115243873064",
	[Enum.KeyCode.ButtonStart] = "rbxassetid://74783320689085",
	[Enum.KeyCode.ButtonSelect] = "rbxassetid://116587088401417",
	[Enum.KeyCode.DPadUp] = "rbxassetid://109098609680858",
	[Enum.KeyCode.DPadDown] = "rbxassetid://87887123801845",
	[Enum.KeyCode.DPadLeft] = "rbxassetid://79929158253781",
	[Enum.KeyCode.DPadRight] = "rbxassetid://70780762403440",
}

-- Mobile touch icon
iconSet.mobile = {
	[Enum.KeyCode.Touch] = "rbxassetid://104057783653073",
}

return iconSet