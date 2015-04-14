# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2013, 2014 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

"""docviewer app autopilot helpers."""

import logging
from autopilot import logging as autopilot_logging
logger = logging.getLogger(__name__)

import ubuntuuitoolkit


class DocviewerException(ubuntuuitoolkit.ToolkitException):

    """Exception raised when there are problems with the docviewer."""


class DocviewerApp(object):

    """Autopilot helper object for the docviewer application."""

    def __init__(self, app_proxy):
        self.app = app_proxy
        self.main_view = self.app.select_single(MainView)

    @property
    def pointing_device(self):
        return self.app.pointing_device


class MainView(ubuntuuitoolkit.MainView):

    """A helper that makes it easy to interact with the docviewer-app."""

    def __init__(self, *args):
        super(MainView, self).__init__(*args)
        self.visible.wait_for(True)

    def open_PdfView(self):
        """Open the PdfView Page.

        :return the PdfView Page

        """
        return self.wait_select_single(PdfView)

    @autopilot_logging.log_action(logger.info)
    def get_PdfViewGotoDialog(self):
        """Return a dialog emulator"""
        return self.wait_select_single(objectName="PdfViewGotoDialog")

    def go_to_page_from_dialog(self, page_no):
        """ Go to page from get_PfdViewGotoDialog """
        textfield = self.wait_select_single(
            "TextField", objectName="goToPageTextField")
        textfield.write(page_no)
        go_button = self.wait_select_single("Button", objectName="GOButton")
        self.pointing_device.click_object(go_button)


class Page(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot helper for Pages."""

    def __init__(self, *args):
        super(Page, self).__init__(*args)
        # XXX we need a better way to keep reference to the main view.
        # --elopio - 2014-01-31
        self.main_view = self.get_root_instance().select_single(MainView)


class PdfView(Page):
    """Autopilot helper for PdfView page."""

    @autopilot_logging.log_action(logger.info)
    def toggle_header_visibility(self):
        """Show/hide page header by clicking on the center of main view"""
        self.pointing_device.click_object(self.main_view)

    def click_go_to_page_button(self):
        """Click the go_to_page header button."""
        header = self.main_view.get_header()
        header.click_action_button('gotopage')
