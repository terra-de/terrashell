function activateCopy(panel, doCopy) {
    doCopy();
    panel.state.close();
}

function activateType(panel, doCopy, doType) {
    doCopy();
    panel.state.close();
    var handler = function() {
        doType();
        panel.closeCompleted.disconnect(handler);
    };
    panel.closeCompleted.connect(handler);
}
