/*
  Copyright (C) 2013-2015 Stefano Verzegnassi

    This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License 3 as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

    This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
  along with this program. If not, see http://www.gnu.org/licenses/.
*/

import QtQuick 2.4
import Ubuntu.Components 1.2
import Ubuntu.Components.Popups 1.0
import QtQuick.Layouts 1.1

Dialog {
    id: deleteFileDialog

    property string path
    property var selectedIndices: viewLoader.item.ViewItems.selectedIndices;
    property int deleteCount: selectedIndices.length

    title: path ? i18n.tr("Delete file")
                : i18n.tr("Delete %1 file", "Delete %1 files", deleteCount).arg(deleteCount)
    text: path ? i18n.tr("Are you sure you want to permanently delete this file?")
               : i18n.tr("Are you sure you want to permanently delete this file?",
                         "Are you sure you want to permanently delete these files?",
                         deleteCount)


    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            margins: units.gu(-1)
        }

        Button {
            text: i18n.tr("Cancel")
            onClicked: PopupUtils.close(deleteFileDialog)
            Layout.fillWidth: true
        }

        Button {
            text: i18n.tr("Delete")
            color: UbuntuColors.red
            Layout.fillWidth: true

            onClicked: {
                if (deleteFileDialog.path) {
                    //deleteFileDialog.confirmed = true;
                    docModel.rm(deleteFileDialog.path);
                } else {
                    // This is called from selection mode
                    for (var i=0; i < deleteCount; i++) {
                        console.log("Removing:", folderModel.get(i).path);
                        docModel.rm(folderModel.get(i).path);
                    }

                    viewLoader.item.endSelection();
                }

                PopupUtils.close(deleteFileDialog)
            }
        }
    }
}

