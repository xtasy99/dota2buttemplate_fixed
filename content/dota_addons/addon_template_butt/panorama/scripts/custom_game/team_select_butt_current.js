"use strict";

let IsHost = false; //Game.GetLocalPlayerInfo().player_has_host_privileges;
let hostLocked = false;
let banning = false;
let allPick = false;
var BCategories = $.GetContextPanel().FindChildInLayoutFile("BCategories");
var BSettingsMain = $.GetContextPanel().FindChildInLayoutFile("BSettings");
var BSettings = [$.GetContextPanel().FindChildInLayoutFile("BSettingsColumn1"),$.GetContextPanel().FindChildInLayoutFile("BSettingsColumn2")];
var path_links = {};
var clean = false;
var current_block = undefined;
var lcol = 0;
var setting_slots = {};

function loadSettings(kv,secondTime) {
	if (!clean) {
		let children = BCategories.Children()
		for (let i in children) {
			children[i].DeleteAsync(0.1);
		}
		children = BSettings[0].Children();
		for (let i in children) {
			children[i].DeleteAsync(0.1);
		}
		children = BSettings[1].Children();
		for (let i in children) {
			children[i].DeleteAsync(0.1);
		}
		clean = true;
	}
	if (kv) {
		kv = sort_array(kv);
		for (let i in kv) {
			generateCategory(kv[i],kv[i].CATEGORY);
		}
		let children = BCategories.Children();
		SortElements(children);
		children = BSettings[0].Children();
		SortElements(children);
		children = BSettings[1].Children();
		SortElements(children);
	} else {
		if (!secondTime) { $.Msg("failed loadSettings");}
		$.Schedule( 0.1, ()=>{loadSettings(kv,true)});
	}
}
loadSettings(CustomNetTables.GetTableValue("butt_settings","updated"));


function generateCategory(odata,category_id) {
	var data = odata.OBJ;
	if (undefined==data || typeof data != "object" || data.length == 0) return;
	let no_objects = true;
	for (let i in data) {
		if (typeof data[i] == "object") {
			no_objects = false;
		}
	}
	if (no_objects) return;
    var category = $.CreatePanel('Panel', BCategories, '');
    category.BLoadLayoutSnippet("SettingCategory");
	if (undefined==data.NAME) {
		category.FindChildTraverse( "SettingCategoryText" ).text = $.Localize("#Butting_" + category_id);
		if ($.Localize("#Butting_" + category_id + "_Description") != "#Butting_" + category_id + "_Description") {
			category.FindChildTraverse( "SettingCategoryText" ).SetPanelEvent( 'onmouseover', function () {
				$.DispatchEvent("DOTAShowTextTooltip", category.FindChildTraverse( "SettingCategoryText" ), $.Localize("#Butting_" + category_id + "_Description"));
			} ); 
			category.FindChildTraverse( "SettingCategoryText" ).SetPanelEvent( 'onmouseout', function () {
				$.DispatchEvent("DOTAHideTextTooltip", category.FindChildTraverse( "SettingCategoryText" ));
			} );
		}
	} else {
		category.FindChildTraverse( "SettingCategoryText" ).text = data.NAME;
	}
    var category_block = $.CreatePanel('Panel', BSettings[lcol], '');
	lcol = (lcol + 1)%2;
    category_block.BLoadLayoutSnippet("SettingCategoryBlock");
	if (!IsHost) {
		category_block.enabled=false;
	}
	category_block.FindChildTraverse( "SettingCategoryBlock_Tittle" ).SetAttributeInt("order",-1000);
	if (undefined==data.NAME) {
		category_block.FindChildTraverse( "SettingCategoryBlock_TittleText" ).text = $.Localize("#Butting_" + category_id);
	} else {
		category_block.FindChildTraverse( "SettingCategoryBlock_TittleText" ).text = data.NAME;
	}
	if (undefined==data.ORDER) {
		category_block.SetAttributeInt("order",1000);
		category.SetAttributeInt("order",1000);
	} else {
		category_block.SetAttributeInt("order",data.ORDER);
		category.SetAttributeInt("order",data.ORDER);
	}
	/*
	category_block.visible = false;
	category.SetPanelEvent( 'onactivate', function () {
		if (undefined!==current_block) current_block.visible = false;
		current_block = category_block;
		current_block.visible = true;
	} );
	*/

	category.SetPanelEvent( 'onactivate', function () {
		category_block.ScrollParentToMakePanelFit(2,false);
	} ); 
	if (undefined!==data.TYPE && data.TYPE == "OPTIONAL") {
		var path = [category_id,"ENABLED"];
		var setting = $.CreatePanel('Panel', category_block, '');
		setting.BLoadLayoutSnippet("SettingBoolean");
		setting.SetAttributeInt("order",-1000);
		setting.FindChildTraverse( "SettingValue" ).text = $.Localize("#Butting_ENABLED");
		setting.FindChildTraverse( "SettingValue" ).checked = data.ENABLED;
		setting.SetHasClass("SettingGroupEnable",true);
		linkPanel(path,setting,1);
	}
	for (let i in data) {
		if (typeof data[i] == "object") {
			generateSetting(data[i],category_block,category_id,i);
		}
	}
	let children = category_block.Children();
	SortElements(children);
}

function generateSetting(data,category_block,category_id,setting_id) {
	if (undefined!==data.TYPE) {
		if (data.TYPE == "BOOLEAN") {
			generateSetting_boolean(data,category_block,category_id,setting_id)
		} else if (data.TYPE == "OPTIONS") {
			generateSetting_options(data,category_block,category_id,setting_id);
		} else if (data.TYPE == "NUMBER") {
			generateSetting_number(data,category_block,category_id,setting_id);
		}
	} else {
		generateSetting_number(data,category_block,category_id,setting_id);
	}
}

function generateSetting_options(data,category_block,category_id,setting_id) {
    var setting = $.CreatePanel('Panel', category_block, '');
	if (undefined==data.ORDER)
		setting.SetAttributeInt("order",1000);
	else
		setting.SetAttributeInt("order",data.ORDER);
    setting.BLoadLayoutSnippet("SettingOptions");

	if ($.Localize("#Butting_" + category_id + "_Option_" + setting_id + "_Description") != "#Butting_" + category_id + "_Option_" + setting_id + "_Description") {
		setting.SetPanelEvent( 'onmouseover', function () {
			$.DispatchEvent("DOTAShowTextTooltip", setting, $.Localize("#Butting_" + category_id + "_Option_" + setting_id + "_Description"));
		} ); 
		setting.SetPanelEvent( 'onmouseout', function () {
			$.DispatchEvent("DOTAHideTextTooltip", setting);
		} );
	}

	let dropdown = setting.FindChildTraverse( "SettingValue" );

	for (let i in data.OPTIONS) {
		let id = data.OPTIONS[i];
		let txt = i;
		let opt = $.CreatePanel('Label', dropdown, id);
		if ($.Localize("#Butting_" + category_id + "_Option_" + setting_id + "_Option_" + txt) == "#Butting_" + category_id + "_Option_" + setting_id + "_Option_" + txt) {
			opt.text = txt;
		} else {
			opt.text = $.Localize("#Butting_" + category_id + "_Option_" + setting_id + "_Option_" + txt);
		}
		dropdown.AddOption(opt);
		if (undefined!==data.VALUE && data.VALUE == id) {
			dropdown.SetSelected(id);
		}
	}

	var path = [category_id,setting_id,"VALUE"];
	linkPanel(path,setting,0);
	
}
function generateSetting_number(data,category_block,category_id,setting_id) {
	if (undefined==data.DECIMAL) {
		data.DECIMAL = 0;
	}
    var setting = $.CreatePanel('Panel', category_block, '');
	if (undefined==data.ORDER)
		setting.SetAttributeInt("order",1000);
	else
		setting.SetAttributeInt("order",data.ORDER);
    setting.BLoadLayoutSnippet("SettingNumber");
	if ($.Localize("#Butting_" + category_id + "_Option_" + setting_id + "_Description") != "#Butting_" + category_id + "_Option_" + setting_id + "_Description") {
		setting.SetPanelEvent( 'onmouseover', function () {
			$.DispatchEvent("DOTAShowTextTooltip", setting, $.Localize("#Butting_" + category_id + "_Option_" + setting_id + "_Description"));
		} ); 
		setting.SetPanelEvent( 'onmouseout', function () {
			$.DispatchEvent("DOTAHideTextTooltip", setting);
		} );
	}
	if (undefined==data.NAME) {
		setting.FindChildTraverse( "SettingNumberText" ).text = $.Localize("#Butting_" + category_id + "_Option_" + setting_id);
	} else {
		setting.FindChildTraverse( "SettingNumberText" ).text = data.NAME;
	}
	setting.FindChildTraverse( "SettingValue" ).SetAttributeInt("decimal",data.DECIMAL);
	if (undefined!==data.UNIT) {
		setting.FindChildTraverse( "SettingValue" ).SetAttributeString("unit",data.UNIT);
		setting.FindChildTraverse( "SettingValue" ).text = data.VALUE.toFixed(data.DECIMAL) + data.UNIT;
	} else {
		setting.FindChildTraverse( "SettingValue" ).text = data.VALUE.toFixed(data.DECIMAL);
	}
	setting.FindChildTraverse( "SettingValue" ).SetPanelEvent( 'onfocus', function () {
		if (!IsHost) {
			return;
		}
		let panel = setting.FindChildTraverse( "SettingValue" );
		panel.text = parseFloat(panel.text).toFixed(data.DECIMAL);
		panel.SetAcceptsFocus(true);
	});
	setting.FindChildTraverse( "SettingValue" ).SetAttributeInt("max",data.MAX);
	setting.FindChildTraverse( "SettingValue" ).SetAttributeInt("min",data.MIN);
	var path = [category_id,setting_id,"VALUE"];
	linkPanel(path,setting,2);
	
}
function generateSetting_boolean(data,category_block,category_id,setting_id) {
    var setting = $.CreatePanel('Panel', category_block, '');
	if (undefined==data.ORDER)
		setting.SetAttributeInt("order",1000);
	else
		setting.SetAttributeInt("order",data.ORDER);
    setting.BLoadLayoutSnippet("SettingBoolean");
	if ($.Localize("#Butting_" + category_id + "_Option_" + setting_id + "_Description") != "#Butting_" + category_id + "_Option_" + setting_id + "_Description") {
		setting.SetPanelEvent( 'onmouseover', function () {
			$.DispatchEvent("DOTAShowTextTooltip", setting, $.Localize("#Butting_" + category_id + "_Option_" + setting_id + "_Description"));
		} ); 
		setting.SetPanelEvent( 'onmouseout', function () {
			$.DispatchEvent("DOTAHideTextTooltip", setting);
		} );
	}
	if (undefined==data.NAME) {
		setting.FindChildTraverse( "SettingValue" ).text = $.Localize("#Butting_" + category_id + "_Option_" + setting_id);
	} else {
		setting.FindChildTraverse( "SettingValue" ).text = data.NAME;
	}
	setting.FindChildTraverse( "SettingValue" ).checked = data.VALUE;
	var path = [category_id,setting_id,"VALUE"];
	linkPanel(path,setting,1);
}

function linkPanel(path,panel,optype) {
	var path_str = path[0];
	for (var i = 1; i < path.length; i++) {
		path_str = path_str + "&" + path[i];
	}
	path_links[path_str] = panel;
	if (optype == 0) {
		panel.FindChildTraverse( "SettingValue" ).SetPanelEvent( 'oninputsubmit', function () {
			if (!IsHost) return;
			let val = undefined;
			val = panel.FindChildTraverse( "SettingValue" ).GetSelected().id;
			if (undefined!==val) {
				GameEvents.SendCustomGameEventToAllClients( "butt_setting_changed", {setting: path_str , value: val });
				GameEvents.SendCustomGameEventToServer( "butt_setting_changed", {setting: path_str , value: val });
			}
		} ); 
	} else if (optype == 1) {
		panel.FindChildTraverse( "SettingValue" ).SetPanelEvent( 'onactivate', function () {
			if (!IsHost) return;
			let val = undefined;
			val = panel.FindChildTraverse( "SettingValue" ).checked;
			if (undefined!==val) {
				GameEvents.SendCustomGameEventToAllClients( "butt_setting_changed", {setting: path_str , value: val });
				GameEvents.SendCustomGameEventToServer( "butt_setting_changed", {setting: path_str , value: val });
			}
		} ); 
	} else if (optype == 2) {
		panel.FindChildTraverse( "SettingValue" ).SetPanelEvent( 'oninputsubmit', function () {
			if (!IsHost) return;
			let val = undefined;
			val = parseFloat(panel.FindChildTraverse( "SettingValue" ).text);
			if (isNaN(val)){
				val = 0;
			}
			let unit = panel.FindChildTraverse( "SettingValue" ).GetAttributeString("unit","");
			let min = panel.FindChildTraverse( "SettingValue" ).GetAttributeInt("min",-99999);
			let max = panel.FindChildTraverse( "SettingValue" ).GetAttributeInt("max",99999);
			if (val < min) {
				val = min;
			}
			if (val > max) {
				val = max;
			}
			if (undefined!==val) {
				GameEvents.SendCustomGameEventToAllClients( "butt_setting_changed", {setting: path_str , value: val });
				GameEvents.SendCustomGameEventToServer( "butt_setting_changed", {setting: path_str , value: val });
			}
			panel.FindChildTraverse( "SettingValue" ).text = val + unit;
		} ); 
		panel.FindChildTraverse( "SettingValue" ).SetPanelEvent( 'onblur', function () {
			if (!IsHost) return;
			let val = undefined;
			val = parseFloat(panel.FindChildTraverse( "SettingValue" ).text);
			if (isNaN(val)){
				val = 0;
			}
			let unit = panel.FindChildTraverse( "SettingValue" ).GetAttributeString("unit","");
			let min = panel.FindChildTraverse( "SettingValue" ).GetAttributeInt("min",-99999);
			let max = panel.FindChildTraverse( "SettingValue" ).GetAttributeInt("max",99999);
			if (val < min) {
				val = min;
			}
			if (val > max) {
				val = max;
			}
			if (undefined!==val) {
				GameEvents.SendCustomGameEventToAllClients( "butt_setting_changed", {setting: path_str , value: val });
				GameEvents.SendCustomGameEventToServer( "butt_setting_changed", {setting: path_str , value: val });
			}
			panel.FindChildTraverse( "SettingValue" ).text = val.toFixed(panel.FindChildTraverse( "SettingValue" ).GetAttributeInt("decinal",0)) + unit;
		} );
	}
}

function getLinkedPanel(path) {
	path_str = path[0];
	for (var i = 1; i < path.length; i++) {
		path_str = path_str + "&" + path[i];
	}
	if (path_links[path_str]) {
		return path_links[path_str];
	}
}

function editLinkedValue(path,value) {
	
}

function SortElements(elements,changes) {
	if (elements.length < 1) {
		return;
	}
	let parent = elements[0].GetParent();
	for (var i = 0; i < elements.length; i++) {
		if (i + 1 < elements.length) {
			let a = elements[i].GetAttributeInt("order",1000);
			let b = elements[i+1].GetAttributeInt("order",1000);
			if (a > b) {
				parent.MoveChildBefore(elements[i+1],elements[i]);
				changes = true;
			}
		}
	}
	if (changes) {
		$.Schedule( 0.01, function() {SortElements(parent.Children(),changes)} );
	}
}


function updatePanel(kv) {
	let name = kv.setting;
	let val = kv.value;
	let panel = path_links[name];
	if (panel!=undefined) {
		let valuePanel = panel.FindChildTraverse( "SettingValue" );
		if (valuePanel) {
			let panelType = valuePanel.paneltype;
			switch(true) {
				case ("DropDown"===panelType):
					valuePanel.SetSelected(val);
					break;
				case ("Label"===panelType):
					valuePanel.text = val;
					break;
				case ("ToggleButton"===panelType):
					valuePanel.checked = (val=="1");
					break;
				case ("TextEntry"===panelType):
					valuePanel.text = Number(val).toFixed(valuePanel.GetAttributeInt("decimal",0)) + valuePanel.GetAttributeString("unit","");
					break;
				default:
					$.Msg("Well... something is f**ked.",panelType);
					break;
			}
		}
	}
}

function sort_array(okv) {
	var kv = okv;
	if (typeof(okv) == "object") {
		kv = [];
		var o = 0;
		for (let i in okv) {
			kv[o] = {CATEGORY: i, OBJ: okv[i]};
			o++;
		}
	}
	var result = kv.sort(function(a,b) {
		if (a.ORDER==undefined) {
			if (b.ORDER==undefined) {
				return 0;
			} else {
				return 1;
			}
		} else {
			if (b.ORDER==undefined) {
				return -1;
			} else {
				return a.ORDER - b.ORDER;
			}
		}
	})
	return result;
}

GameEvents.Subscribe( "butt_setting_changed", updatePanel );

function LoadSlot(slot) {
	if (!IsHost) {
		return;
	}
	$.Msg("loadslot",slot);
	GameEvents.SendCustomGameEventToServer( "slot_load", {slot: slot });

}


function SaveSlot(slot) {
	if (!IsHost) {
		return;
	}
	$.Msg("saveslot",slot);
	GameEvents.SendCustomGameEventToServer( "slot_save", {slot: slot });
}


function CreateToggleButton() {
    var button_bar = FindDotaHudElement("ButtonBar");
    var existing_button = button_bar.FindChildTraverse("SettingsOpenButton");
    if (existing_button) {
        existing_button.DeleteAsync(0);
    }
	if (button_bar == undefined) {
		$.Msg("ButtonBar not found")
		return;
	}
    var panel = $.CreatePanel('Button', $.GetContextPanel(), "SettingsOpenButton" );
    panel.BLoadLayoutSnippet("SettingsOpenButton");
    panel.SetPanelEvent( 'onactivate', function () {
		$.GetContextPanel().ToggleClass("hidden");
    });
	panel.SetParent(button_bar);
}

(function init() {
    CreateToggleButton();
})();


function GetDotaHud() {
    var panel = $.GetContextPanel();
    while (panel && panel.id !== 'Hud') {
        panel = panel.GetParent();
	}

    if (!panel) {
        throw new Error('Could not find Hud root from panel with id: ' + $.GetContextPanel().id);
	}
	return panel;
}
function FindDotaHudElement(id) {
	return GetDotaHud().FindChildTraverse(id);
}
