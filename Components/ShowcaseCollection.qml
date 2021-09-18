import QtQuick 2.3
import SortFilterProxyModel 0.2

HorizontalListView { 
    id: listView

    title: settingsMetadata.home[`${collectionKey}type`].values[collectionType]

    aspectRatioNative: api.memory.get(`settings.home.${collectionKey}aspectRatioNative`)

    aspectRatioWidth: api.memory.get(`settings.home.${collectionKey}aspectRatioWidth`)
    aspectRatioHeight: api.memory.get(`settings.home.${collectionKey}aspectRatioHeight`)

    assetKey: settingsMetadata.home[`${collectionKey}art`].values[api.memory.get(`settings.home.${collectionKey}art`)]
    logoVisible: api.memory.get(`settings.home.${collectionKey}logoVisible`)
}