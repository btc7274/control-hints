-- Light icon set for Xelu Free Controller & Key Prompts. Commonly used throughout most Roblox games.

-- IMPORTANT: This icon set does not support responsive highlighting
-- To add support, create a new table with a '_pressed' suffix for each platform, and fill it with pressed icons

local iconSet: {[string]: {[Enum.KeyCode]: string}} = {}

-- Keyboard / Mouse icons
iconSet.keyboard = {
	[Enum.KeyCode.A] = "rbxassetid://109936476736513",
	[Enum.KeyCode.B] = "rbxassetid://89428622623877",
	[Enum.KeyCode.C] = "rbxassetid://126818474512808",
	[Enum.KeyCode.D] = "rbxassetid://74197788343961",
	[Enum.KeyCode.E] = "rbxassetid://134323854592567",
	[Enum.KeyCode.F] = "rbxassetid://102395623732858",
	[Enum.KeyCode.G] = "rbxassetid://139742549530195",
	[Enum.KeyCode.H] = "rbxassetid://136658979995723",
	[Enum.KeyCode.I] = "rbxassetid://82558143986796",
	[Enum.KeyCode.J] = "rbxassetid://71304803931916",
	[Enum.KeyCode.K] = "rbxassetid://96775266334283",
	[Enum.KeyCode.L] = "rbxassetid://138252788760414",
	[Enum.KeyCode.M] = "rbxassetid://132119191852474",
	[Enum.KeyCode.N] = "rbxassetid://124153044629695",
	[Enum.KeyCode.O] = "rbxassetid://95710352912488",
	[Enum.KeyCode.P] = "rbxassetid://122503890474329",
	[Enum.KeyCode.Q] = "rbxassetid://131293229679922",
	[Enum.KeyCode.R] = "rbxassetid://109007545999678",
	[Enum.KeyCode.S] = "rbxassetid://106227857229630",
	[Enum.KeyCode.T] = "rbxassetid://140208904455191",
	[Enum.KeyCode.U] = "rbxassetid://116758503083622",
	[Enum.KeyCode.V] = "rbxassetid://100443963529345",
	[Enum.KeyCode.W] = "rbxassetid://71045906110905",
	[Enum.KeyCode.X] = "rbxassetid://96027149279239",
	[Enum.KeyCode.Y] = "rbxassetid://79774144208747",
	[Enum.KeyCode.Z] = "rbxassetid://111804673778509",
	[Enum.KeyCode.Zero] = "rbxassetid://134237192605359",
	[Enum.KeyCode.One] = "rbxassetid://121188844924219",
	[Enum.KeyCode.Two] = "rbxassetid://124840995495840",
	[Enum.KeyCode.Three] = "rbxassetid://130675512032173",
	[Enum.KeyCode.Four] = "rbxassetid://133037032205401",
	[Enum.KeyCode.Five] = "rbxassetid://119150511714534",
	[Enum.KeyCode.Six] = "rbxassetid://123356300054437",
	[Enum.KeyCode.Seven] = "rbxassetid://133140102358897",
	[Enum.KeyCode.Eight] = "rbxassetid://139647879395051",
	[Enum.KeyCode.Nine] = "rbxassetid://121424067594405",
	[Enum.KeyCode.Space] = "rbxassetid://82136866734909",
	[Enum.KeyCode.Return] = "rbxassetid://101934020096118", -- appears as enter
	[Enum.KeyCode.Tab] = "rbxassetid://133305674651646",
	[Enum.KeyCode.Backspace] = "rbxassetid://131507951077640",
	[Enum.KeyCode.Escape] = "rbxassetid://79782175647175",
	[Enum.KeyCode.Up] = "rbxassetid://98462907067382",
	[Enum.KeyCode.Down] = "rbxassetid://104308054416267",
	[Enum.KeyCode.Left] = "rbxassetid://132699835088525",
	[Enum.KeyCode.Right] = "rbxassetid://94456207049069",
	[Enum.KeyCode.LeftShift] = "rbxassetid://81749364987424",
	[Enum.KeyCode.RightShift] = "rbxassetid://81749364987424",
	[Enum.KeyCode.LeftControl] = "rbxassetid://118749047976629",
	[Enum.KeyCode.RightControl] = "rbxassetid://118749047976629",
	[Enum.KeyCode.LeftAlt] = "rbxassetid://104204541881622",
	[Enum.KeyCode.RightAlt] = "rbxassetid://104204541881622",
	[Enum.KeyCode.Slash] = "rbxassetid://97653203700700", -- appears as backslash
	[Enum.KeyCode.Semicolon] = "rbxassetid://124302598386270",
	[Enum.KeyCode.Quote] = "rbxassetid://106400222174667", -- appears as double quote
	[Enum.KeyCode.Minus] = "rbxassetid://120530904922045",
	[Enum.KeyCode.LeftBracket] = "rbxassetid://140708486919044",
	[Enum.KeyCode.RightBracket] = "rbxassetid://75378619289255",
	[Enum.KeyCode.BackSlash] = "rbxassetid://97653203700700",
	[Enum.KeyCode.MouseLeftButton] = "rbxassetid://86710830092772",
	[Enum.KeyCode.MouseRightButton] = "rbxassetid://118683001262054",
	[Enum.KeyCode.MouseMiddleButton] = "rbxassetid://114251641147797",
	-- Add more keyboard keys as needed.
}

-- Xbox controller icons (dark; no light version available)
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

-- PlayStation controller icons (dark; no light version available)
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