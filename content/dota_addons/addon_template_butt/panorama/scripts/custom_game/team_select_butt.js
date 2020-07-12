"use strict";

// line 103 requires game_info.xml -> Ctrl+F(InfoButtonLalala)

let IsHost = Game.GetLocalPlayerInfo().player_has_host_privileges;
let hostLocked = false;
let banning = false;
let allPick = false;
let currentEditor = "items";

// if (!IsHost) CustomNetTables.SubscribeNetTableListener("settings_butt_update", LoadSettingsButt);

if (!IsHost) {
	$("#SettingsBody").enabled=false;
}

function uniqueID() {
	var uniqueID_lalala = uniqueID_lalala || 1;
	let out;
	do {
		out = "autoID"+uniqueID_lalala++;
	} while($('#'+out));
	return out;
}

(function moveFrame() {
	let placeholder = $.GetContextPanel().GetParent().FindChildTraverse("TeamsSelectEmptySpace");
	if (placeholder) {
		$.Msg("moving Frame");
		$.GetContextPanel().SetParent(placeholder);
	} else {
		// happens
		$.Schedule( 0.1, moveFrame );
	}
})();

(function hostTitle() {
	if ($("#Host")) {
		for (let i of Game.GetAllPlayerIDs()) {
			if ( Game.GetPlayerInfo(i) && Game.GetPlayerInfo(i).player_has_host_privileges) {
				$("#Host").text = "HOST: " + Players.GetPlayerName( i );
			}
		}
	} else {
		$.Msg("failed hostTitle");
		$.Schedule( 0.1, hostTitle );
	}
})();

function loadButtings(kv,secondTime) {
	if (kv) {
		for (let i in kv) {
			updatePanel({setting: i, value: kv[i]});
		}
	} else {
		//didnt happen, lua loads before clients?
		if (!secondTime) { $.Msg("failed loadButtings");}
		$.Schedule( 0.1, ()=>{loadButtings(kv,true)});
	}
}
loadButtings(CustomNetTables.GetTableValue("butt_settings","default"));


const l1 = GameEvents.Subscribe( "game_rules_state_change", function(event) {
	if (Game.GameStateIs(DOTA_GameState.DOTA_GAMERULES_STATE_HERO_SELECTION)) {
		applySettingsPano();
		GameEvents.Unsubscribe(l1);
	}
});

function applySettingsPano() {
	let banPanel = findPanel("BanButton");
	let pickPanel = findPanel("HeroPickControls");
	if (!(banPanel && pickPanel)) {
		$.Schedule( 0.1, applySettingsPano );
		return;
	}
	if (!hostLocked) {
		banPanel.visible=false;
		pickPanel.visible=false;
		$.Schedule( 0.1, applySettingsPano );
		return;
	}
	banPanel.visible=(banning);
	pickPanel.visible=(allPick);
}

CustomNetTables.SubscribeNetTableListener("butt_settings", function(t,k,kv) {
	if("locked"===k) {
		$.Msg("butt_settings ",k);
		$("#SettingsBody").enabled=false;
		hostLocked = true;
		loadButtings(kv);

		findPanel("GameInfoButton").visible=true;

		banning = ($("#HERO_BANNING").checked);
		allPick = ("AP"===$("#GAME_MODE").GetSelected().id);

		for (let i = 0; i < $("#SettingsBody").GetChildCount(); i++) {
			$("#SettingsBody").GetChild(i).SetHasClass("SettingsGroupInsideSideBar", true);
		}
		let placeholder = findPanel("InfoButtonLalala");
		if (placeholder) {
			$("#SettingsBody").SetParent(placeholder);
		}
	}
});


////////////////////////////////////////////////////////////

function onPanelChange(name) {
	if (!IsHost) {
		return;
	}
	const panel = $("#"+name);
	if (!panel) {
		return;
	}
	const panelType = panel.paneltype;
	let val = undefined;

	if ("DropDown"===panelType) {
		val = panel.GetSelected().id;
	} else if ("ToggleButton"===panelType) {
		val = panel.checked;
	} else if ("TextEntry"===panelType) {
		val = parseFloat(panel.text);
		if (isNaN(val)){
			val = 0;
		}
	}
	if (undefined!==val) {
		GameEvents.SendCustomGameEventToAllClients( "butt_setting_changed", {setting: name , value: val });
		GameEvents.SendCustomGameEventToServer( "butt_setting_changed", {setting: name , value: val });
	}
	if ("Button"===panelType) {
		GameEvents.SendCustomGameEventToServer( "butt_on_clicked", {button: name});
	}
}

GameEvents.Subscribe( "butt_setting_changed", updatePanel );

function updatePanel(kv) {
	let name = kv.setting;
	let val = kv.value;
	let panel = $("#"+name);
	if (panel) {
		let panelType = panel.paneltype;
		// $.Msg(name,": ",val);
		switch(true) {
			case ("DropDown"===panelType):
				panel.SetSelected(val);
				break;
			case ("Label"===panelType):
				panel.text = val;
				break;
			case ("ToggleButton"===panelType):
				panel.checked = val;
				break;
			case ("TextEntry"===panelType):
				panel.text = val + panel.GetAttributeString("unit","");
				// $.Msg(panel.text);
				if (parseFloat(val)!==parseFloat(panel.text)) {
					panel.text = val;
				}
				break;
			default:
				break;
		}
	}
}

function onfocus(name) {
	if (!IsHost) {
		return;
	}
	let panel = $("#"+name);
	let panelType = panel.paneltype;
	if ("TextEntry"===panelType){
		panel.text = parseFloat(panel.text);
	}
	panel.SetAcceptsFocus(true);
}

////////////////////////////////////////////////////////////
//not working

(function fillBanList() {
	// let drop = findPanel("BanListDropDownMenu");
	// let herolist = ["npc_dota_hero_riki","npc_dota_hero_techies"]
	// for (let i = 0; i < herolist.length; i++) {
	// 	$.Msg(i,herolist[i]);
	// 	let iLabel = $.CreatePanel( "Label", drop, herolist[i] );
	// 	iLabel.text = herolist[i];
	// 	iLabel.AddClass("DropDownChild");
	// }
})();

///////////////////////////////////////////////////////////

function rootPanel() {
	let scrollup = $.GetContextPanel();
	while (scrollup.GetParent()) {
		scrollup = scrollup.GetParent();
	}
	return scrollup;
}

function findPanel(name) {
	if (typeof(name)!=="string") {
		$.Msg("findPanel argument fail");
		return null;
	}
	let scrollup = $.GetContextPanel();
	while (scrollup.GetParent()) {
		scrollup = scrollup.GetParent();
	}
	return scrollup.FindChildTraverse(name);
}


function openItemEditor(editor) {
	$('#CustomSettingsID').visible = false;
	$('#ItemEditor').visible = true;
	currentEditor = editor;
	Game.SetAutoLaunchEnabled( false );
	Game.SetRemainingSetupTime( -1 ); 
	// #itemlist
}

function closeItemEditor() {
	$('#CustomSettingsID').visible = true;
	$('#ItemEditor').visible = false;
	$('#itemlist').RemoveAndDeleteChildren();
}

function fancyTextField(parent, defaultText, overrideText, onSubmitFunc, onDelete){
	const fram = $.CreatePanel('Panel',parent,uniqueID());
	fram.AddClass('TextEntryFrame');

	const hasOverrideText = ("string"===typeof(overrideText) || "number"===typeof(overrideText));
	const tex = $.CreatePanel('TextEntry',fram,uniqueID());
	tex.text = (hasOverrideText) ? overrideText : defaultText;
 	if (hasOverrideText) tex.AddClass('goodTextEntry');

	tex.SetPanelEvent('ontextentrychange',function(id, p){
		tex.RemoveClass('goodTextEntry');
		tex.AddClass('waitTextEntry');
	});

	tex.SetPanelEvent('oninputsubmit',function(id, p){
		onSubmitFunc(tex.text);
	});

	if (undefined!==onDelete) {
		const xButt = $.CreatePanel('Button',fram,uniqueID());
		xButt.AddClass('XButton');
		xButt.SetPanelEvent('onactivate', onDelete);
	}

	return tex;
}

function createKvPanel(parent, kvs, overrideKV, parentChangeFunc) {
	const keyIsEditable = ("neutralItems"===currentEditor);


	const inOverrideTable = (overrideKV===true);
	const hasOverrideTable = (null!==overrideKV && "object"===typeof(overrideKV));

	let iOverflowStopper = 0;
	for (let k in kvs) {
		const overrideV = (hasOverrideTable && overrideKV[k]);
		const hasOverride = inOverrideTable || overrideV || (0===overrideV)|| ('0'===overrideV);
		// kv_change object is being built reverse
		const submitEntry = (obj,key) => parentChangeFunc({[key || k]: obj});

		const pan = $.CreatePanel('Panel',parent,uniqueID());pan.AddClass('SettingsGroup');
		if (hasOverride) pan.AddClass('GreenShadow');

		const keyElem = (keyIsEditable) ? fancyTextField(pan,k,(hasOverride && k),(text)=>{
				submitEntry(kvs[k], text)
			}) : ($.CreatePanel('Label',pan,"").text = k);


		if ('object'===typeof(kvs[k])) {
			createKvPanel(pan,kvs[k], (inOverrideTable || overrideV), submitEntry);
		} else {
			const valuElem = fancyTextField(pan,
				(kvs[k]),
				(inOverrideTable ? kvs[k] : overrideV),
				(text)=>{submitEntry(text)},
				()=>{submitEntry(null)});
		}
		overrideKV && delete overrideKV[k];
		if ((++iOverflowStopper>10) && (parent==$('#itemlist'))) break;
	}

	hasOverrideTable && createKvPanel(parent, overrideKV, true, parentChangeFunc);
}


function findKV() {
	const itemname = $('#itemssearch').text;
	// if (itemname.length>2) {
		GameEvents.SendCustomGameEventToServer( "kv_find", {type: currentEditor , name: itemname });
	// }
	// overflow handled by lua
}

GameEvents.Subscribe("kv_result", function(result) {
	result = fixParsedTable(result)
	$.Msg("result",result);

	let il = $('#itemlist');
	il.RemoveAndDeleteChildren();

	const itemname = $('#itemssearch').text;
	const changeSubmitFunc = (obj) => {
		if (obj) {
			GameEvents.SendCustomGameEventToServer( "kv_change", {filter:{type: currentEditor , name: itemname },value:{[currentEditor]:obj}});
			const blue = findPanel('LockAndStartButton');
			const red = findPanel('CancelAndUnlockButton');
			blue.visible = false;
			red.visible = true;
			red.enabled  = false;
			red.GetChild(0).text = 'You have to reload!';
		}
	}

	createKvPanel(il,result.default,result.custom,changeSubmitFunc);
});

(function unHideToolsModeButtons() {
	if ($("#toolsModeGroup")) {
		if (Game.IsInToolsMode()) {
			$("#toolsModeGroup").visible = true;
		}
	} else {
		$.Msg("toolsModeGroup not found")
		$.Schedule( 0.1, unHideToolsModeButtons );
	}
})();

function fixParsedTable(tabl) {
	if ("object"!==typeof(tabl)) return tabl;
	for (let k in tabl){
		tabl[k] = ("number"===typeof(tabl[k])) 
			? (0.001 * Math.floor(tabl[k]*1000+0.5)) 
			: fixParsedTable(tabl[k]);
	}
	return tabl
}