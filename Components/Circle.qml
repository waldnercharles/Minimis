import QtQuick 2.3

Rectangle {
    height: radius * 2;
    width: radius * 2;

    radius: vpx(2);
    color: api.memory.get('settings.globalTheme.textColor')
}