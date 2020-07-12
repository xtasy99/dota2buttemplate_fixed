function SelectionCourierUpdate(msg) {
    const needCourier = msg.newCourier;
    const selectedEntities = GetSelectedEntities();
    const selectionCounter = selectedEntities.length;
    const removeTatget = msg.removeCourier;

    const haveCourierInSelect = selectedEntities.some(function(e) { return Entities.IsCourier(e) });

    Selection_Remove({entities:removeTatget})

    if (haveCourierInSelect && selectionCounter < 2){
        Selection_New({ entities:needCourier });
    }else if(haveCourierInSelect){
        Selection_Add({ entities:needCourier });
    }
}

(function () {
    GameEvents.Subscribe( "selection_courier_update", SelectionCourierUpdate);
    const selectCourietButton = FindDotaHudElement('SelectCourierButton');
    const deliverItemsButton = FindDotaHudElement('DeliverItemsButton');

    selectCourietButton.SetPanelEvent("onactivate", function () {
        GameEvents.SendCustomGameEventToServer("courier_custom_select", {})
    });

    deliverItemsButton.SetPanelEvent("onactivate", function () {
        GameEvents.SendCustomGameEventToServer("courier_custom_select_deliever_items", {})
    });
})();