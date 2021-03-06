// NOTE: BasedOn <X11/keysymdef.h>
// NOTE: Pulled XK_MISCELLANY and XK_LATIN1 only.
package X11

// Done in nvim via:
// TitleCase to Ada_Case substitution: s/\(_.*\)\(\w\)\([A-K]\)/\1\2_\3/ge
// #define macro to Odin constant macro: qavelxve[run substitution]elcw :: <esc>fxlvegU/#define<cr>q
// Later, after deciding to go the enum route: qadf_elct0 = <esc>A,<esc>/XK_<cr>q

Key_Code :: enum u16 {
	// #ifdef XK_MISCELLANY
	Back_Space         = 0xFF08,
	Tab                = 0xFF09,
	Linefeed           = 0xFF0A,
	Clear              = 0xFF0B,
	Return             = 0xFF0D,
	Pause              = 0xFF13,
	Scroll_Lock        = 0xFF14,
	Sys_Req            = 0xFF15,
	Escape             = 0xFF1B,
	Delete             = 0xFFFF,
	Multi_Key          = 0xFF20,
	Codeinput          = 0xFF37,
	Single_Candidate   = 0xFF3C,
	Multiple_Candidate = 0xFF3D,
	Previous_Candidate = 0xFF3E,
	Kanji              = 0xFF21,
	Muhenkan           = 0xFF22,
	Henkan_Mode        = 0xFF23,
	Henkan             = 0xFF23,
	Romaji             = 0xFF24,
	Hiragana           = 0xFF25,
	Katakana           = 0xFF26,
	Hiragana_Katakana  = 0xFF27,
	Zenkaku            = 0xFF28,
	Hankaku            = 0xFF29,
	Zenkaku_Hankaku    = 0xFF2A,
	Touroku            = 0xFF2B,
	Massyo             = 0xFF2C,
	Kana_Lock          = 0xFF2D,
	Kana_Shift         = 0xFF2E,
	Eisu_Shift         = 0xFF2F,
	Eisu_Toggle        = 0xFF30,
	Kanji_Bangou       = 0xFF37,
	Zen_Koho           = 0xFF3D,
	Mae_Koho           = 0xFF3E,
	Home               = 0xFF50,
	Left               = 0xFF51,
	Up                 = 0xFF52,
	Right              = 0xFF53,
	Down               = 0xFF54,
	Prior              = 0xFF55,
	Page_Up            = 0xFF55,
	Next               = 0xFF56,
	Page_Down          = 0xFF56,
	End                = 0xFF57,
	Begin              = 0xFF58,
	Select             = 0xFF60,
	Print              = 0xFF61,
	Execute            = 0xFF62,
	Insert             = 0xFF63,
	Undo               = 0xFF65,
	Redo               = 0xFF66,
	Menu               = 0xFF67,
	Find               = 0xFF68,
	Cancel             = 0xFF69,
	Help               = 0xFF6A,
	Break              = 0xFF6B,
	Mode_Switch        = 0xFF7E,
	Script_Switch      = 0xFF7E,
	Num_Lock           = 0xFF7F,
	KP_Space           = 0xFF80,
	KP_Tab             = 0xFF89,
	KP_Enter           = 0xFF8D,
	KP_F1              = 0xFF91,
	KP_F2              = 0xFF92,
	KP_F3              = 0xFF93,
	KP_F4              = 0xFF94,
	KP_Home            = 0xFF95,
	KP_Left            = 0xFF96,
	KP_Up              = 0xFF97,
	KP_Right           = 0xFF98,
	KP_Down            = 0xFF99,
	KP_Prior           = 0xFF9A,
	KP_Page_Up         = 0xFF9A,
	KP_Next            = 0xFF9B,
	KP_Page_Down       = 0xFF9B,
	KP_End             = 0xFF9C,
	KP_Begin           = 0xFF9D,
	KP_Insert          = 0xFF9E,
	KP_Delete          = 0xFF9F,
	KP_Equal           = 0xFFBD,
	KP_Multiply        = 0xFFAA,
	KP_Add             = 0xFFAB,
	KP_Separator       = 0xFFAC,
	KP_Subtract        = 0xFFAD,
	KP_Decimal         = 0xFFAE,
	KP_Divide          = 0xFFAF,
	KP_0               = 0xFFB0,
	KP_1               = 0xFFB1,
	KP_2               = 0xFFB2,
	KP_3               = 0xFFB3,
	KP_4               = 0xFFB4,
	KP_5               = 0xFFB5,
	KP_6               = 0xFFB6,
	KP_7               = 0xFFB7,
	KP_8               = 0xFFB8,
	KP_9               = 0xFFB9,
	F1                 = 0xFFBE,
	F2                 = 0xFFBF,
	F3                 = 0xFFC0,
	F4                 = 0xFFC1,
	F5                 = 0xFFC2,
	F6                 = 0xFFC3,
	F7                 = 0xFFC4,
	F8                 = 0xFFC5,
	F9                 = 0xFFC6,
	F10                = 0xFFC7,
	F11                = 0xFFC8,
	L1                 = 0xFFC8,
	F12                = 0xFFC9,
	L2                 = 0xFFC9,
	F13                = 0xFFCA,
	L3                 = 0xFFCA,
	F14                = 0xFFCB,
	L4                 = 0xFFCB,
	F15                = 0xFFCC,
	L5                 = 0xFFCC,
	F16                = 0xFFCD,
	L6                 = 0xFFCD,
	F17                = 0xFFCE,
	L7                 = 0xFFCE,
	F18                = 0xFFCF,
	L8                 = 0xFFCF,
	F19                = 0xFFD0,
	L9                 = 0xFFD0,
	F20                = 0xFFD1,
	L10                = 0xFFD1,
	F21                = 0xFFD2,
	R1                 = 0xFFD2,
	F22                = 0xFFD3,
	R2                 = 0xFFD3,
	F23                = 0xFFD4,
	R3                 = 0xFFD4,
	F24                = 0xFFD5,
	R4                 = 0xFFD5,
	F25                = 0xFFD6,
	R5                 = 0xFFD6,
	F26                = 0xFFD7,
	R6                 = 0xFFD7,
	F27                = 0xFFD8,
	R7                 = 0xFFD8,
	F28                = 0xFFD9,
	R8                 = 0xFFD9,
	F29                = 0xFFDA,
	R9                 = 0xFFDA,
	F30                = 0xFFDB,
	R10                = 0xFFDB,
	F31                = 0xFFDC,
	R11                = 0xFFDC,
	F32                = 0xFFDD,
	R12                = 0xFFDD,
	F33                = 0xFFDE,
	R13                = 0xFFDE,
	F34                = 0xFFDF,
	R14                = 0xFFDF,
	F35                = 0xFFE0,
	R15                = 0xFFE0,
	Shift_L            = 0xFFE1,
	Shift_R            = 0xFFE2,
	Control_L          = 0xFFE3,
	Control_R          = 0xFFE4,
	Caps_Lock          = 0xFFE5,
	Shift_Lock         = 0xFFE6,
	Meta_L             = 0xFFE7,
	Meta_R             = 0xFFE8,
	Alt_L              = 0xFFE9,
	Alt_R              = 0xFFEA,
	Super_L            = 0xFFEB,
	Super_R            = 0xFFEC,
	Hyper_L            = 0xFFED,
	Hyper_R            = 0xFFEE,
	// #endif MISCELLANY

	// #ifdef XK_LATIN1
	Space              = 0x0020,
	Exclam             = 0x0021,
	Quotedbl           = 0x0022,
	Numbersign         = 0x0023,
	Dollar             = 0x0024,
	Percent            = 0x0025,
	Ampersand          = 0x0026,
	Apostrophe         = 0x0027,
	Quoteright         = 0x0027,
	Parenleft          = 0x0028,
	Parenright         = 0x0029,
	Asterisk           = 0x002A,
	Plus               = 0x002B,
	Comma              = 0x002C,
	Minus              = 0x002D,
	Period             = 0x002E,
	Slash              = 0x002F,
	Num0               = 0x0030,
	Num1               = 0x0031,
	Num2               = 0x0032,
	Num3               = 0x0033,
	Num4               = 0x0034,
	Num5               = 0x0035,
	Num6               = 0x0036,
	Num7               = 0x0037,
	Num8               = 0x0038,
	Num9               = 0x0039,
	Colon              = 0x003A,
	Semicolon          = 0x003B,
	Less               = 0x003C,
	Equal              = 0x003D,
	Greater            = 0x003E,
	Question           = 0x003F,
	At                 = 0x0040,
	A                  = 0x0041,
	B                  = 0x0042,
	C                  = 0x0043,
	D                  = 0x0044,
	E                  = 0x0045,
	F                  = 0x0046,
	G                  = 0x0047,
	H                  = 0x0048,
	I                  = 0x0049,
	J                  = 0x004A,
	K                  = 0x004B,
	L                  = 0x004C,
	M                  = 0x004D,
	N                  = 0x004E,
	O                  = 0x004F,
	P                  = 0x0050,
	Q                  = 0x0051,
	R                  = 0x0052,
	S                  = 0x0053,
	T                  = 0x0054,
	U                  = 0x0055,
	V                  = 0x0056,
	W                  = 0x0057,
	X                  = 0x0058,
	Y                  = 0x0059,
	Z                  = 0x005A,
	Bracketleft        = 0x005B,
	Backslash          = 0x005C,
	Bracketright       = 0x005D,
	Asciicircum        = 0x005E,
	Underscore         = 0x005F,
	Grave              = 0x0060,
	Quoteleft          = 0x0060,
	a                  = 0x0061,
	b                  = 0x0062,
	c                  = 0x0063,
	d                  = 0x0064,
	e                  = 0x0065,
	f                  = 0x0066,
	g                  = 0x0067,
	h                  = 0x0068,
	i                  = 0x0069,
	j                  = 0x006A,
	k                  = 0x006B,
	l                  = 0x006C,
	m                  = 0x006D,
	n                  = 0x006E,
	o                  = 0x006F,
	p                  = 0x0070,
	q                  = 0x0071,
	r                  = 0x0072,
	s                  = 0x0073,
	t                  = 0x0074,
	u                  = 0x0075,
	v                  = 0x0076,
	w                  = 0x0077,
	x                  = 0x0078,
	y                  = 0x0079,
	z                  = 0x007A,
	Braceleft          = 0x007B,
	Bar                = 0x007C,
	Braceright         = 0x007D,
	Asciitilde         = 0x007E,
	Nobreakspace       = 0x00A0,
	Exclamdown         = 0x00A1,
	Cent               = 0x00A2,
	Sterling           = 0x00A3,
	Currency           = 0x00A4,
	Yen                = 0x00A5,
	Brokenbar          = 0x00A6,
	Section            = 0x00A7,
	Diaeresis          = 0x00A8,
	Copyright          = 0x00A9,
	Ordfeminine        = 0x00AA,
	Guillemotleft      = 0x00AB,
	Notsign            = 0x00AC,
	Hyphen             = 0x00AD,
	Registered         = 0x00AE,
	Macron             = 0x00AF,
	Degree             = 0x00B0,
	Plusminus          = 0x00B1,
	Twosuperior        = 0x00B2,
	Threesuperior      = 0x00B3,
	Acute              = 0x00B4,
	Mu                 = 0x00B5,
	Paragraph          = 0x00B6,
	Periodcentered     = 0x00B7,
	Cedilla            = 0x00B8,
	Onesuperior        = 0x00B9,
	Masculine          = 0x00BA,
	Guillemotright     = 0x00BB,
	Onequarter         = 0x00BC,
	Onehalf            = 0x00BD,
	Threequarters      = 0x00BE,
	Questiondown       = 0x00BF,
	Agrave             = 0x00C0,
	Aacute             = 0x00C1,
	Acircumflex        = 0x00C2,
	Atilde             = 0x00C3,
	Adiaeresis         = 0x00C4,
	Aring              = 0x00C5,
	A_E                = 0x00C6,
	Ccedilla           = 0x00C7,
	Egrave             = 0x00C8,
	Eacute             = 0x00C9,
	Ecircumflex        = 0x00CA,
	Ediaeresis         = 0x00CB,
	Igrave             = 0x00CC,
	Iacute             = 0x00CD,
	Icircumflex        = 0x00CE,
	Idiaeresis         = 0x00CF,
	Eth                = 0x00D0,
	Ntilde             = 0x00D1,
	Ograve             = 0x00D2,
	Oacute             = 0x00D3,
	Ocircumflex        = 0x00D4,
	Otilde             = 0x00D5,
	Odiaeresis         = 0x00D6,
	Multiply           = 0x00D7,
	Oslash             = 0x00D8,
	Ooblique           = 0x00D8,
	Ugrave             = 0x00D9,
	Uacute             = 0x00DA,
	Ucircumflex        = 0x00DB,
	Udiaeresis         = 0x00DC,
	Yacute             = 0x00DD,
	Thorn              = 0x00DE,
	ssharp             = 0x00DF,
	agrave             = 0x00E0,
	aacute             = 0x00E1,
	acircumflex        = 0x00E2,
	atilde             = 0x00E3,
	adiaeresis         = 0x00E4,
	aring              = 0x00E5,
	ae                 = 0x00E6,
	ccedilla           = 0x00E7,
	egrave             = 0x00E8,
	eacute             = 0x00E9,
	ecircumflex        = 0x00EA,
	ediaeresis         = 0x00EB,
	igrave             = 0x00EC,
	iacute             = 0x00ED,
	icircumflex        = 0x00EE,
	idiaeresis         = 0x00EF,
	eth                = 0x00F0,
	ntilde             = 0x00F1,
	ograve             = 0x00F2,
	oacute             = 0x00F3,
	ocircumflex        = 0x00F4,
	otilde             = 0x00F5,
	odiaeresis         = 0x00F6,
	division           = 0x00F7,
	oslash             = 0x00F8,
	ooblique           = 0x00F8,
	ugrave             = 0x00F9,
	uacute             = 0x00FA,
	ucircumflex        = 0x00FB,
	udiaeresis         = 0x00FC,
	yacute             = 0x00FD,
	thorn              = 0x00FE,
	ydiaeresis         = 0x00FF,
	// #endif LATIN1
}
