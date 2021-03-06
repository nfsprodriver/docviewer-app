/*
 * Copyright (C) 2014-2016
 *                  Stefano Verzegnassi <verzegnassi.stefano@gmail.com>
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
import QtQuick.Layouts 1.1

Page {
    id: pdfContents
    objectName: "pdfcontents"

    // this property will have to be removed when bug #1341671 will be fixed.
    property string testProperty: "for page name issue"

    header: PageHeader {
        // TRANSLATORS: "Contents" refers to the "Table of Contents" of a PDF document.
        title: i18n.tr("Contents")
        flickable: view
    }

    onActiveChanged: {
        // Find out the current page position in the ToC index
        for (var i=0; i<poppler.tocModel.count; i++) {
            if (i+1 < poppler.tocModel.count) {
                if (pdfView.currentPageIndex >= poppler.tocModel.get(i).pageIndex &&
                        pdfView.currentPageIndex < poppler.tocModel.get(i+1).pageIndex) {
                    break;
                }
            }
        }

        // Set highlighted index
        view.currentIndex = i;

        // Position view at the highlighted index
        view.positionViewAtIndex(i, ListView.Center);
    }

    ScrollView {
        anchors.fill: parent

        ListView {
            id: view
            objectName: "view"
            anchors.fill: parent
            clip: true

            model: poppler.tocModel

            delegate: ListItem {
                id: delegate
                objectName: "delegate" + index

                property bool __isCurrentIndex: view.currentIndex == model.index

                onClicked: {
                    pdfView.positionAtIndex(model.pageIndex);
                    contentsBottomEdge.collapse();
                }

                // Highlighted property of ListItem is read-only. In order to
                // provide an highlight for the current page, we need to duplicate
                // the overlay.
                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(0, 0, 0, 0.05)
                    visible: __isCurrentIndex
                }

                /* UITK 1.3 spec: Three slot layout (A-B-C)   */
                //  ________________________________________
                // |                              |     |   |
                // |               A              |  B  | C |
                // |______________________________|__ __|___|
                //
                ListItemLayout {
                    id: listItemLayout
                    objectName: "listItemLayout" + index
                    anchors.fill: parent
                    anchors.leftMargin: model.level * units.gu(4)

                    /* UITK 1.3 specs: Slot A */
                    title.text: model.title
                    title.color: __isCurrentIndex ? theme.palette.selected.backgroundText
                                                  : theme.palette.normal.backgroundText

                    /* UITK 1.3 specs: Slot B */
                    Icon {
                        SlotsLayout.position: SlotsLayout.Trailing
                        width: units.gu(2); height: width
                        name: "tick"
                        color: UbuntuColors.green
                        visible: view.currentIndex == model.index
                    }

                    /* UITK 1.3 specs: Slot C */
                    Label {
                        objectName: "pageindex"
                        SlotsLayout.position: SlotsLayout.Last
                        text: model.pageIndex + 1
                        color: __isCurrentIndex ? theme.palette.selected.backgroundText
                                                : theme.palette.normal.backgroundText
                    }
                }
            }
        }
    }
}
