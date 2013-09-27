# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Docviewer app autopilot tests."""

import os.path

from pprint import pprint

from autopilot.input import Mouse, Touch, Pointer
from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase

from ubuntuuitoolkit import emulators as toolkit_emulators
from ubuntu_docviewer_app import emulators

class DocviewerTestCase(AutopilotTestCase):

    """A common test case class that provides several useful methods for
    docviewer-app tests.

    """

    if model() == 'Desktop':
        scenarios = [('with mouse', dict(input_device_class=Mouse))]
    else:
        scenarios = [('with touch', dict(input_device_class=Touch))]

    local_location = "../../ubuntu-docviewer-app.qml"
    sample_dir = "/usr/lib/python2.7/dist-packages/"

    def setUp(self):
        self.pointing_device = Pointer(self.input_device_class.create())
        super(DocviewerTestCase, self).setUp()

    def launch_test_local(self, arg):
        self.app = self.launch_test_application(
            "qmlscene",
            "tests/autopilot/"+arg,
            self.local_location,
            app_type='qt')

    def launch_test_installed(self, arg):
        self.app = self.launch_test_application(
            "qmlscene",
            arg,
            "/usr/share/ubuntu-docviewer-app/ubuntu-docviewer-app.qml",
            "--desktop_file_hint=/usr/share/applications/ubuntu-docviewer-app.desktop",
            app_type='qt')

    @property
    def main_view(self):
        return self.app.select_single(emulators.MainView)
