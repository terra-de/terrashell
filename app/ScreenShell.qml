import QtQuick
import Quickshell

import "../features/bitwarden" as BitwardenFeature
import "../features/bitwarden/vm" as BitwardenVm
import "../services" as Services
import "../features/appdrawer" as AppDrawerFeature
import "../features/appdrawer/vm" as AppDrawerVm
import "../features/bar" as BarFeature
import "../features/clipboardhistory" as ClipboardHistoryFeature
import "../features/clipboardhistory/vm" as ClipboardHistoryVm
import "../features/controlcenter" as ControlCenterFeature
import "../features/controlcenter/vm" as ControlCenterVm
import "../features/emoji" as EmojiFeature
import "../features/notifications" as NotificationFeature
import "../features/notifications/vm" as NotificationPanelVm
import "../features/nerdfont" as NerdFontFeature
import "../features/pickerlauncher" as PickerLauncherFeature
import "../features/pickerlauncher/vm" as PickerLauncherVm
import "../features/symbolpicker/vm" as SymbolPickerVm
import "../features/mediaplayer" as MediaPlayerFeature
import "../features/mediaplayer/vm" as MediaPlayerVm
import "../features/whichkey" as WhichKeyFeature
import "../features/workspacerename" as WorkspaceRenameFeature

/*
  ScreenShell
  Composes all per-screen shell windows and shared state.
  Required properties: panelScreen.
*/
Item {
    id: root

    required property ShellScreen panelScreen

    ControlCenterVm.ControlCenterState {
        id: controlCenterState
    }

    NotificationPanelVm.NotificationPanelState {
        id: notificationPanelState
    }

    MediaPlayerVm.MediaPlayerState {
        id: mediaPlayerState
    }

    AppDrawerVm.AppDrawerState {
        id: appDrawerState
    }

    ClipboardHistoryVm.ClipboardHistoryState {
        id: clipboardHistoryState
    }

    BitwardenVm.BitwardenPickerState {
        id: bitwardenState
    }

    BitwardenVm.BitwardenSetupState {
        id: bitwardenSetupState
    }

    SymbolPickerVm.SymbolPickerState {
        id: emojiState
    }

    SymbolPickerVm.SymbolPickerState {
        id: nerdFontState
    }

    PickerLauncherVm.PickerLauncherState {
        id: pickerLauncherState
    }

    Component.onCompleted: {
        Services.MediaPlayerService.registerScreenState(root.panelScreen, mediaPlayerState);
        Services.ControlCenterService.registerScreenState(root.panelScreen, controlCenterState);
        Services.NotificationPanelService.registerScreenState(root.panelScreen, notificationPanelState);
        Services.AppDrawerService.registerScreenState(root.panelScreen, appDrawerState);
        Services.BitwardenService.registerScreenState(root.panelScreen, bitwardenState);
        Services.BitwardenService.registerSetupState(root.panelScreen, bitwardenSetupState);
        Services.ClipboardHistoryService.registerScreenState(root.panelScreen, clipboardHistoryState);
        Services.WorkspaceService.registerScreenState(root.panelScreen, workspaceRenamePanel);
        Services.SymbolPickerService.registerScreenState("emoji", root.panelScreen, emojiState);
        Services.SymbolPickerService.registerScreenState("nerdfont", root.panelScreen, nerdFontState);
        Services.PickerLauncherService.registerScreenState(root.panelScreen, pickerLauncherState);
    }

    Component.onDestruction: {
        Services.MediaPlayerService.unregisterScreenState(mediaPlayerState);
        Services.ControlCenterService.unregisterScreenState(controlCenterState);
        Services.NotificationPanelService.unregisterScreenState(notificationPanelState);
        Services.AppDrawerService.unregisterScreenState(appDrawerState);
        Services.BitwardenService.unregisterScreenState(bitwardenState);
        Services.BitwardenService.unregisterSetupState(bitwardenSetupState);
        Services.ClipboardHistoryService.unregisterScreenState(clipboardHistoryState);
        Services.WorkspaceService.unregisterScreenState(workspaceRenamePanel);
        Services.SymbolPickerService.unregisterScreenState("emoji", emojiState);
        Services.SymbolPickerService.unregisterScreenState("nerdfont", nerdFontState);
        Services.PickerLauncherService.unregisterScreenState(pickerLauncherState);
    }

    BarFeature.BarPanelFeature {
        panelScreen: root.panelScreen
        controlCenterState: controlCenterState
        notificationPanelState: notificationPanelState
        mediaPlayerState: mediaPlayerState
    }

    MediaPlayerFeature.MediaPlayerPanelFeature {
        panelScreen: root.panelScreen
        state: mediaPlayerState
    }

    NotificationFeature.NotificationPanelFeature {
        panelScreen: root.panelScreen
        state: notificationPanelState
    }

    ControlCenterFeature.ControlCenterPanelFeature {
        panelScreen: root.panelScreen
        state: controlCenterState
    }

    AppDrawerFeature.AppDrawerPanelFeature {
        panelScreen: root.panelScreen
        state: appDrawerState
    }

    ClipboardHistoryFeature.ClipboardHistoryPanelFeature {
        panelScreen: root.panelScreen
        state: clipboardHistoryState
    }

    BitwardenFeature.BitwardenPanelFeature {
        panelScreen: root.panelScreen
        state: bitwardenState
    }

    BitwardenFeature.BitwardenSetupPopupFeature {
        panelScreen: root.panelScreen
        state: bitwardenSetupState
    }

    EmojiFeature.EmojiPanelFeature {
        panelScreen: root.panelScreen
        state: emojiState
    }

    NerdFontFeature.NerdFontPanelFeature {
        panelScreen: root.panelScreen
        state: nerdFontState
    }

    PickerLauncherFeature.PickerLauncherPanelFeature {
        panelScreen: root.panelScreen
        state: pickerLauncherState
    }

    WhichKeyFeature.WhichKeyLayerFeature {
        panelScreen: root.panelScreen
    }

    WorkspaceRenameFeature.WorkspaceRenamePanelFeature {
        id: workspaceRenamePanel

        panelScreen: root.panelScreen
    }
}
