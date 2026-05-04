import QtQuick
import QtQuick.Controls

import org.qfield
import org.qgis
import Theme

import "qrc:/qml" as QFieldItems

Item {
  id: plugin

  property var mainWindow: iface.mainWindow()
  property var mapCanvas: iface.mapCanvas()
  property bool navMode: false

  QfToolButton {
    id: navButton
    bgcolor: navMode ? Theme.mainColor : Theme.darkGray
    iconSource: "icon.svg"
    iconColor: Theme.toolButtonColor
    round: true

    onClicked: {
      navMode = !navMode
      if (navMode) {
        mainWindow.displayToast(qsTr("Nav ON: tap on the map"))
      } else {
        mainWindow.displayToast(qsTr("Nav OFF"))
      }
    }
  }

  Component.onCompleted: {
    iface.addItemToPluginsToolbar(navButton)
  }

  Connections {
    target: mapCanvas

    // 1) încerci confirmedClicked; dacă nu merge, schimbăm pe clicked
    function onConfirmedClicked(point) {
      if (!navMode)
        return

      // 'point' este în coordonate ecran → îl convertim în coordonate hartă
      const mapPt = mapCanvas.mapSettings.screenToCoordinate(
                      Qt.point(point.x, point.y)
                    )

      // test: arată coordonatele în CRS proiect (3844)
      mainWindow.displayToast(
        "Map XY: " + mapPt.x.toFixed(2) + ", " + mapPt.y.toFixed(2)
      )

      // reproiectăm în WGS84
      const wgsPt = GeometryUtils.reprojectPointToWgs84(
                      mapPt,
                      qgisProject.crs
                    )

      const lon = wgsPt.x
      const lat = wgsPt.y

      mainWindow.displayToast(
        "WGS84: " + lat.toFixed(6) + ", " + lon.toFixed(6)
      )

      const url = "https://www.google.com/maps/dir/?api=1&destination="
                  + lat + "," + lon + "&travelmode=driving"

      Qt.openUrlExternally(url)

      navMode = false
      mainWindow.displayToast(qsTr("Opening Google Maps"))
    }

    // Dacă vezi că onConfirmedClicked NU se apelează deloc,
    // poți temporar să comentezi blocul de mai sus și să folosești:
    /*
    function onClicked(point, type) {
      if (!navMode)
        return

      const mapPt = mapCanvas.mapSettings.screenToCoordinate(
                      Qt.point(point.x, point.y)
                    )

      mainWindow.displayToast(
        "Map XY (clicked): " + mapPt.x.toFixed(2) + ", " + mapPt.y.toFixed(2)
      )
    }
    */
  }
}