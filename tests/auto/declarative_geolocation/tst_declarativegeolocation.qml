/****************************************************************************
**
** Copyright (C) 2021 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the test suite of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:GPL-EXCEPT$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 as published by the Free Software
** Foundation with exceptions as appearing in the file LICENSE.GPL3-EXCEPT
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.0
import QtTest 1.0
import QtPositioning 6.2

Item {
    id: testCase

    property var topLeft: QtPositioning.coordinate(1.0, 2.0)
    property var bottomRight: QtPositioning.coordinate(2.0, 1.0)
    property var centerPoint: QtPositioning.coordinate(1.5, 1.5)

    Location {
        id: defaultConstructed
    }

    Location {
        id: location
    }

    // Use property bindings insetead of signal spies
    property var addressObserver: location.address
    property int addressChangedCount: 0
    onAddressObserverChanged: {
        ++addressChangedCount
    }

    property var coordObserver: location.coordinate
    property int coordChangedCount: 0
    onCoordObserverChanged: {
        ++coordChangedCount
    }

    property var shapeObserver: location.boundingShape
    property int shapeChangedCount: 0
    onShapeObserverChanged: {
        ++shapeChangedCount
    }

    property var attrsObserver: location.extendedAttributes
    property int attrsChangedCount: 0
    onAttrsObserverChanged: {
        ++attrsChangedCount
    }

    Address {
        id: emptyAddress
    }

    Address {
        id: addr1
        country: "Germany"
        city: "Berlin"
        street: "Erich-Thilo-Str"
        streetNumber: "10"
        postalCode: "12489"
    }

    Location {
        id: completeLocation
        address: addr1
        coordinate: centerPoint
        boundingShape: QtPositioning.rectangle(topLeft, bottomRight)
    }

    Location {
        id: fromGeoLocation
    }

    TestCase {
        name: "DeclarativeGeoLocation"

        function test_default_construction() {
            compare(defaultConstructed.address.address, emptyAddress.address)
            compare(defaultConstructed.coordinate, QtPositioning.coordinate())
            compare(defaultConstructed.boundingShape, QtPositioning.shape())
        }

        function test_address_changed() {
            addressChangedCount = 0
            location.address = addr1
            compare(addressChangedCount, 1)
            compare(location.address.address, addr1.address)
        }

        function test_coordinate_changed() {
            var coord1 = QtPositioning.coordinate(1.0, 2.0)
            var emptyCoord = QtPositioning.coordinate()
            coordChangedCount = 0
            compare(location.coordinate, emptyCoord)
            location.coordinate = coord1
            compare(coordChangedCount, 1)
            compare(location.coordinate, coord1)
        }

        function test_bounding_box_changed() {
            var emptyShape = QtPositioning.shape()
            shapeChangedCount = 0
            compare(location.boundingShape, emptyShape)

            var box = QtPositioning.rectangle(topLeft, bottomRight)
            location.boundingShape = box
            compare(shapeChangedCount, 1)
            compare(QtPositioning.shapeToRectangle(location.boundingShape), box)
            // verify that shape's boundingGeoRectangle() matches the box.
            compare(location.boundingShape.boundingGeoRectangle(), box)

            var circle = QtPositioning.circle(centerPoint, 100)
            location.boundingShape = circle
            compare(shapeChangedCount, 2)
            compare(QtPositioning.shapeToCircle(location.boundingShape), circle)
        }

        function test_from_geolocation() {
            fromGeoLocation.location = completeLocation.location
            compare(fromGeoLocation.location, completeLocation.location)
            compare(fromGeoLocation.address.address, completeLocation.address.address)
            compare(fromGeoLocation.coordinate, completeLocation.coordinate)
            compare(fromGeoLocation.boundingShape, completeLocation.boundingShape)
        }

        function test_extended_attributes() {
            attrsChangedCount = 0

            var attributes = { "foo" : 42 }
            location.extendedAttributes = attributes;
            compare(location.extendedAttributes, attributes)
            compare(attrsChangedCount, 1)

            attributes["bar"] = 41
            verify(location.extendedAttributes !== attributes)
        }
    }
}
