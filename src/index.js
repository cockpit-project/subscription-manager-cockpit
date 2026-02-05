/*
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Copyright (C) 2015 Red Hat, Inc.
 */

import "cockpit-dark-theme";
import cockpit from 'cockpit';
import React from 'react';
import { createRoot } from 'react-dom/client';

import 'patternfly/patternfly-6-cockpit.scss';

import subscriptionsClient from './subscriptions-client.js';
import SubscriptionsView from './subscriptions-view.jsx';

import './subscriptions.scss';

const dataStore = { };

function initStore(rootElement) {
    const root = createRoot(rootElement);

    dataStore.render = () => {
        root.render(<SubscriptionsView />);
    };
    subscriptionsClient.init();
}

document.addEventListener("DOMContentLoaded", function() {
    cockpit.translate();
    initStore(document.getElementById('app'));
    dataStore.render();
});
