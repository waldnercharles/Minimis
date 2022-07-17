import QtQuick 2.3

Rectangle {
    height: radius * 2 * uiScale;
    width: radius * 2 * uiScale;

    radius: vpx(2);
    color: api.memory.get('settings.general.textColor')
}