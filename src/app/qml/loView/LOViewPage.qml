/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Layouts 1.0
import DocumentViewer 1.0
import DocumentViewer.LibreOffice 1.0 as LibreOffice

import "../common"
import "../common/utils.js" as Utils
import "../common"
import "KeybHelper.js" as KeybHelper

ViewerPage {
    id: loPage

    property bool isPresentation: loPage.contentItem && (loPage.contentItem.loDocument.documentType === LibreOffice.Document.PresentationDocument)
    property bool isTextDocument: loPage.contentItem && (loPage.contentItem.loDocument.documentType === LibreOffice.Document.TextDocument)
    property bool isSpreadsheet: loPage.contentItem && (loPage.contentItem.loDocument.documentType === LibreOffice.Document.SpreadsheetDocument)

    header: defaultHeader
    splashScreen: Splashscreen { }

    content: FocusScope {
        id: loPageContent
        anchors.fill: parent

        property alias loDocument: loView.document
        property alias loView: loView

        Layouts {
            id: layouts
            anchors.fill: parent

            layouts: [
                ConditionalLayout {
                    when: mainView.veryWideWindow
                    name: "wideWindowLayout"

                    Item {
                        anchors.fill: parent

                        ResizeableSidebar {
                            id: leftSidebar
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            visible: loPage.isPresentation

                            width: visible ? units.gu(40) : 0

                            PartsView {
                                id: partsView
                                anchors.fill: parent
                                model: loView.partsModel
                            }
                        }

                        ItemLayout {
                            item: "pinchArea"
                            anchors {
                                left: leftSidebar.right
                                right: parent.right
                                top: parent.top
                                bottom: sSelector.top
                            }
                        }

                        SpreadsheetSelector {
                            id: sSelector
                            anchors.bottom: parent.bottom
                            visible: loPage.isSpreadsheet
                            view: loView
                        }
                    }
                }
            ]

            ScalingPinchArea {
                id: pinchArea
                objectName: "pinchArea"
                Layouts.item: "pinchArea"
                clip: true

                targetFlickable: loView
                onTotalScaleChanged: targetFlickable.updateContentSize(totalScale)

                maximumZoom: loView.zoomSettings.maximumZoom
                minimumZoom: {
                    if (DocumentViewer.desktopMode || mainView.wideWindow)
                        return loView.zoomSettings.minimumZoom

                    switch(loView.document.documentType) {
                    case LibreOffice.Document.TextDocument:
                        return loView.zoomSettings.valueFitToWidthZoom
                    case LibreOffice.Document.PresentationDocument:
                        return loView.zoomSettings.valueAutomaticZoom
                    default:
                        return loView.zoomSettings.minimumZoom
                    }
                }

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: bottomBar.top
                }

                Binding {
                    when: !pinchArea.pinch.active
                    target: pinchArea
                    property: "zoomValue"
                    value: loView.zoomSettings.zoomFactor
                }

                Rectangle {
                    // Since UITK 1.3, the MainView background is white.
                    // We need to set a different color, otherwise pages
                    // boundaries are not visible.
                    anchors.fill: parent
                    color: "#f5f5f5"
                }

                ScrollView {
                    anchors.fill: parent

                    // We need to set some custom event handler.
                    // Forward the key events to the Viewer and
                    // fallback to the ScrollView handlers if the
                    // event hasn't been accepted.
                    Keys.forwardTo: loView
                    Keys.priority: Keys.AfterItem

                    LibreOffice.Viewer {
                        id: loView
                        objectName: "loView"
                        anchors.fill: parent

                        documentPath: file.path

                        Keys.onPressed: KeybHelper.parseEvent(event)

                        function updateContentSize(tgtScale) {
                            zoomSettings.zoomFactor = tgtScale
                        }

                        Component.onCompleted: {
                            // WORKAROUND: Fix for wrong grid unit size
                            flickDeceleration = 1500 * units.gridUnit / 8
                            maximumFlickVelocity = 2500 * units.gridUnit / 8
                            loPageContent.forceActiveFocus()
                        }

                        onErrorChanged: {
                            var errorString;

                            switch(error) {
                            case LibreOffice.Error.LibreOfficeNotFound:
                                errorString = i18n.tr("LibreOffice binaries not found.")
                                break;
                            case LibreOffice.Error.LibreOfficeNotInitialized:
                                errorString = i18n.tr("Error while loading LibreOffice.")
                                break;
                            case LibreOffice.Error.DocumentNotLoaded:
                                errorString = i18n.tr("Document not loaded.\nThe requested document may be corrupt or protected by a password.")
                                break;
                            }

                            if (errorString) {
                                loPage.pageStack.pop()

                                // We create the dialog in the MainView, so that it isn't
                                // initialized by 'loPage' and keep on working after the
                                // page is destroyed.
                                mainView.showErrorDialog(errorString);
                            }
                        }

                        ScalingMouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            targetFlickable: loView
                            onTotalScaleChanged: targetFlickable.updateContentSize(totalScale)

                            thresholdZoom: minimumZoom + (maximumZoom - minimumZoom) * 0.75
                            maximumZoom: {
                                if (DocumentViewer.desktopMode || mainView.wideWindow)
                                    return 3.0

                                return minimumZoom * 3
                            }
                            minimumZoom: {
                                if (DocumentViewer.desktopMode || mainView.wideWindow)
                                    return loView.zoomSettings.minimumZoom

                                switch(loView.document.documentType) {
                                case LibreOffice.Document.TextDocument:
                                    return loView.zoomSettings.valueFitToWidthZoom
                                case LibreOffice.Document.PresentationDocument:
                                    return loView.zoomSettings.valueAutomaticZoom
                                default:
                                    return loView.zoomSettings.minimumZoom
                                }
                            }

                            Binding {
                                target: mouseArea
                                property: "zoomValue"
                                value: loView.zoomSettings.zoomFactor
                            }
                        }

                        Label {
                            anchors.centerIn: parent
                            parent: loPage
                            textSize: Label.Large
                            text: i18n.tr("This sheet has no content.")
                            visible: loPage.isSpreadsheet && loView.contentWidth <= 0 && loView.contentHeight <= 0
                        }
                    }
                }
            }

            Item {
                id: bottomBar
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: childrenRect.height

                PartsView {
                    anchors { left: parent.left; right: parent.right }
                    height: visible ? units.gu(12) : 0
                    visible: loPage.isPresentation

                    model: loView.partsModel
                    orientation: ListView.Horizontal

                    HorizontalDivider {
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                        }
                    }
                }

                SpreadsheetSelector {
                    visible: loPage.isSpreadsheet
                    view: loView
                }
            }
        }
    }


    /*** Headers ***/

    LOViewDefaultHeader {
        id: defaultHeader
        visible: loPage.loaded
        title: DocumentViewer.getFileBaseNameFromPath(file.path);
        flickable: isTextDocument ? loPage.contentItem.loView : null
        targetPage: loPage
    }

    PageHeader {
        id: loadingHeader
        visible: !loPage.loaded
        // When we're still loading LibreOffice, show an empty header
    }
}
