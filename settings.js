function createCollectionMetadata(category, parent = null, collectionType = false) {
    const metadata = {};

    if (parent) {
        metadata[parent.key] = { name: parent.name, defaultValue: false, type: 'header' };
    }

    const parentKey = parent && parent.key ? parent.key : undefined;

    const inset = parent ? 1 : 0;
    const prefix = parentKey ?? '';
    const fullPrefix = `settings.${category}.${prefix}`

    if (collectionType) {
        metadata[`${prefix}type`] = {
            name: 'Type',
            defaultValue: 0,
            values: [ 'None', 'Recently Played', 'Favorites', 'Bookmarks', 'Random Games' ],
            type: 'array',
            parent: parentKey, inset: inset
        };
    }

    metadata[`${prefix}preset`] = {
        name: 'Preset',
        defaultValue: 1,
        values: [ 'Box Art', 'Wide', 'Tall', 'Square', 'Custom' ],
        type: 'array',
        parent: parentKey, inset: inset,
        isEnabled: () => api.memory.get(`${fullPrefix}type`) !== 0,
        onChanged: (value) => {
            switch (value) {
                case 0: // Box Art
                    api.memory.set(`${fullPrefix}art`, 1);
                    api.memory.set(`${fullPrefix}aspectRatioNative`, true);
                    api.memory.set(`${fullPrefix}logoVisible`, false);
                    break;
                case 1: // Wide
                case 4: // Custom
                    api.memory.set(`${fullPrefix}art`, 0);
                    api.memory.set(`${fullPrefix}aspectRatioNative`, false);
                    api.memory.set(`${fullPrefix}aspectRatioWidth`, 9.2);
                    api.memory.set(`${fullPrefix}aspectRatioHeight`, 4.3);
                    api.memory.set(`${fullPrefix}logoVisible`, true);
                    break;
                case 2: // Tall
                    api.memory.set(`${fullPrefix}art`, 0);
                    api.memory.set(`${fullPrefix}aspectRatioNative`, false);
                    api.memory.set(`${fullPrefix}aspectRatioWidth`, 2);
                    api.memory.set(`${fullPrefix}aspectRatioHeight`, 3);
                    api.memory.set(`${fullPrefix}logoVisible`, true);
                    break;
                case 3: // Square
                    api.memory.set(`${fullPrefix}art`, 0);
                    api.memory.set(`${fullPrefix}aspectRatioNative`, false);
                    api.memory.set(`${fullPrefix}aspectRatioWidth`, 1);
                    api.memory.set(`${fullPrefix}aspectRatioHeight`, 1);
                    api.memory.set(`${fullPrefix}logoVisible`, true);
                    break;
            }
        }
    };

    metadata[`${prefix}art`] = {
        name: 'Art',
        defaultValue: 0,
        values: ['screenshot', 'boxFront', 'boxBack', 'boxSpine', 'boxFull', 'cartridge', 'marquee', 'bezel', 'panel', 'cabinetLeft', 'cabinetRight', 'tile', 'banner', 'steam', 'poster', 'background', 'titlescreen'],
        type: 'array',
        parent: parentKey, inset: inset,
        isEnabled: () => api.memory.get(`${fullPrefix}preset`) === 4
    };

    metadata[`${prefix}aspectRatioNative`] = {
        name: 'Art - Aspect Ratio - Use Native', defaultValue: false, type: 'bool',
        parent: parentKey, inset: inset,
        isEnabled: () => api.memory.get(`${fullPrefix}preset`) === 4
    };

    metadata[`${prefix}aspectRatioWidth`] = {
        name: 'Art - Aspect Ratio - Width', defaultValue: 9.2, delta: 0.1, min: 0.1, type: 'real',
        parent: parentKey, inset: inset,
        isEnabled: () => api.memory.get(`${fullPrefix}preset`) === 4 && !api.memory.get(`${fullPrefix}aspectRatioNative`)
    };

    metadata[`${prefix}aspectRatioHeight`] = {
        name: 'Art - Aspect Ratio - Height', defaultValue: 4.3, delta: 0.1, min: 0.1, type: 'real',
        parent: parentKey, inset: inset,
        isEnabled: () => api.memory.get(`${fullPrefix}preset`) === 4 && !api.memory.get(`${fullPrefix}aspectRatioNative`)
    };

    metadata[`${prefix}logoVisible`] = {
        name: 'Logo - Visible', defaultValue: true, type: 'bool',
        parent: parentKey, inset: inset,
        isEnabled: () => api.memory.get(`${fullPrefix}preset`) === 4
    };

    return metadata;
}

function createHeader(header, obj) {
    for (const property in obj) {
        obj[property].parent = header.key;
        obj[property].inset = (obj[property].inset ?? 0) + 1;
    }

    return Object.assign(
        { [`${header.key}`]: { name: header.name, defaultValue: false, type: 'header' } },
        obj
    );
}

function createMetadata() {
    const metadata = {
        global: Object.assign(
            createHeader(
                { key: 'videoPreview', name: 'Video Preview' },
                {
                    previewEnabled: { name: 'Enabled', defaultValue: true, type: 'bool' },
                    previewVolume: { name: 'Volume', defaultValue: 0.0, delta: 0.1, min: 0.0, max: 1.0, type: 'real', inset: 1, isEnabled: () => api.memory.get('settings.global.previewEnabled') },
                    videoPreviewDelay: { name: 'Delay', defaultValue: 1000, min: 0, delta: 50, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.global.previewEnabled') },
                    previewLogoVisible: { name: 'Logo - Visible', defaultValue: true, type: 'bool', inset: 1, isEnabled: () => api.memory.get('settings.global.previewEnabled') }
                }
            ),
            createHeader(
                { key: 'title', name: 'Card Title' },
                {
                    titleEnabled: { name: 'Enabled', defaultValue: true, type: 'bool', },
                    titleAlwaysVisible: { name: 'Always Visible', defaultValue: true, type: 'bool', inset: 1, isEnabled: () => api.memory.get('settings.global.titleEnabled') },
                    titleFontSize: { name: 'Font Size', defaultValue: 16, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.global.titleEnabled') },
                    titleBackgroundOpacity: { name: 'Background Opacity', defaultValue: 0.05, delta: 0.01, min: 0.0, max: 1.0, type: 'real', inset: 1, isEnabled: () => api.memory.get('settings.global.titleEnabled') },
                }
            ),
            createHeader(
                { key: 'scaling', name: 'Scaling' },
                {
                    scaleEnabled: { name: 'Card Scaling - Enabled', defaultValue: true, type: 'bool', },
                    scale: { name: 'Card Scaling - Default', defaultValue: 0.95, delta: 0.01, min: 0, max: 1.0, type: 'real', inset: 1, isEnabled: () => api.memory.get('settings.global.scaleEnabled') },
                    scaleSelected: { name: 'Card Scaling - Selected', defaultValue: 1.0, delta: 0.01, min: 0, type: 'real', inset: 1, isEnabled: () => api.memory.get('settings.global.scaleEnabled') },
                    logoScaleEnabled: { name: 'Logo Scaling - Enabled', defaultValue: true, type: 'bool', },
                    logoScale: { name: 'Logo Scaling - Default', defaultValue: 0.75, delta: 0.01, min: 0.01, type: 'real', inset: 1, isEnabled: () => api.memory.get('settings.global.logoScaleEnabled') },
                    logoScaleSelected: { name: 'Logo Scaling - Selected', defaultValue: 0.85, delta: 0.01, min: 0, type: 'real', inset: 1, isEnabled: () => api.memory.get('settings.global.logoScaleEnabled') },
                }
            ),
            createHeader(
                { key: 'animation', name: 'Animation' },
                {
                    animationEnabled: { name: 'Enabled', defaultValue: true, type: 'bool', },
                    animationArtScaleSpeed: { name: 'Card Scaling - Duration (Milliseconds)', defaultValue: 200, min: 0, delta: 50, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.global.animationEnabled') },
                    animationArtFadeSpeed: { name: 'Card Fading - Duration (Milliseconds)', defaultValue: 200, min: 0, delta: 50, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.global.animationEnabled') },
                    logoScaleSpeed: { name: 'Logo Scaling - Duration (Milliseconds)', defaultValue: 200, min: 0, delta: 50, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.global.animationEnabled'), },
                    logoFadeSpeed: { name: 'Logo Fading - Duration (Milliseconds)', defaultValue: 200, min: 0, delta: 50, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.global.animationEnabled') },
                }
            ),
            createHeader(
                { key: 'border', name: 'Border' },
                {
                    borderEnabled: { name: 'Enabled', defaultValue: true, type: 'bool', },
                    borderAnimated: { name: 'Animated', defaultValue: true, type: 'bool', inset: 1, isEnabled: () => api.memory.get('settings.global.borderEnabled') },
                    borderWidth: { name: 'Width', defaultValue: 3, min: 0, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.global.borderEnabled') },
                    cornerRadius: { name: 'Corner Radius', defaultValue: 5, min: 0, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.global.borderEnabled') },
                    // borderColor1: { name: 'Color 1', defaultValue: '#FFC85C', type: 'string', inset: 1, isEnabled: () => api.memory.get('settings.global.borderEnabled') },
                    // borderColor2: { name: 'Color 2', defaultValue: '#ECECEC', type: 'string', inset: 1, isEnabled: () => api.memory.get('settings.global.borderEnabled') },
                    borderColor1: { name: 'Color 1', defaultValue: '#FFC85C', type: 'string', inset: 1, isEnabled: () => api.memory.get('settings.global.borderEnabled') },
                    borderColor2: { name: 'Color 2', defaultValue: '#ECECEC', type: 'string', inset: 1, isEnabled: () => api.memory.get('settings.global.borderEnabled') },
                }
            ),
            createHeader(
                { key: 'overlay', name: 'Overlay' },
                { darkenAmount: { name: 'Darken', defaultValue: 0.15, delta: 0.01, min: 0.0, max: 1.0, type: 'real', } }
            ),
            createHeader(
                { key: 'logo', name: 'Logo' },
                { logoFontSize: { name: 'Font Size', defaultValue: 20, min: 1, type: 'int' } }
            ),
            createHeader(
                { key: 'navigation', name: 'Navigation' },
                {
                    navigationOpacity: { name: 'Background Opacity', defaultValue: 0.8, delta: 0.01, min: 0.0, max: 1.0, type: 'real', },
                    navigationSize: { name: 'Size', defaultValue: 160, type: 'int', },
                    navigationPauseDuration: { name: 'Pause Duration (Milliseconds)', defaultValue: 400, delta: 50, min: 0, type: 'int', },
                    navigationFadeDuration: { name: 'Fade Duration (Milliseconds)', defaultValue: 400, delta: 50, min: 0, type: 'int', },
                    navigationYearIncrement: { name: 'Year - Increment', defaultValue: 1, delta: 1, min: 1, type: 'int', },
                    navigationRatingIncrement: { name: 'Rating - Increment', defaultValue: 0.5, delta: 0.1, min: 0.1, max: 5.0, type: 'real', },
                }
            )
        ),
        home: Object.assign(
            createCollectionMetadata('home', { key: 'collection1', name: 'Collection 1' }, true),
            createCollectionMetadata('home', { key: 'collection2', name: 'Collection 2' }, true),
            createCollectionMetadata('home', { key: 'collection3', name: 'Collection 3' }, true),
            createCollectionMetadata('home', { key: 'collection4', name: 'Collection 4' }, true),
            createCollectionMetadata('home', { key: 'collection5', name: 'Collection 5' }, true),
        ),
        gameLibrary: Object.assign(
            { gameViewColumns: { name: 'Number of Columns', defaultValue: 4, type: 'int', min: 1 } },
            createCollectionMetadata('gameLibrary')
        ),
        gameDetails: {
            previewEnabled: { name: 'Video Preview - Enabled', defaultValue: true, type: 'bool' },
            previewVolume: { name: 'Video Preview - Volume', defaultValue: 0.0, delta: 0.1, min: 0.0, type: 'real' },
        },
        theme: {
            // backgroundColor: { name: 'Background Color', defaultValue: '#13161B', type: 'string' },
            // accentColor: { name: 'Accent Color', defaultValue: '#FFC85C', type: 'string' },
            // textColor: { name: 'Text Color', defaultValue: '#ECECEC', type: 'string' },

            backgroundColor: { name: 'Background Color', defaultValue: '#343434', type: 'string' },
            accentColor: { name: 'Accent Color', defaultValue: '#FFC85C', type: 'string' },
            textColor: { name: 'Text Color', defaultValue: '#ECECEC', type: 'string' },

            // backgroundColor: { name: 'Background Color', defaultValue: '#262A53', type: 'string' },
            // accentColor: { name: 'Accent Color', defaultValue: '#FFA0A0', type: 'string' },
            // textColor: { name: 'Text Color', defaultValue: '#FFE3E3', type: 'string' },

            leftMargin: { name: 'Screen Padding - Left', defaultValue: 60, min: 0, type: 'int' },
            rightMargin: { name: 'Screen Padding - Right', defaultValue: 60, min: 0, type: 'int' },
        },
        performance: {
            artImageResolution: { name: 'Art - Image Resolution', defaultValue: 0, values: ['Native', 'Scaled'], type: 'array' },
            artImageCaching: { name: 'Art - Image Caching', defaultValue: false, type: 'bool' },
            artImageSmoothing: { name: 'Art - Image Smoothing', defaultValue: false, type: 'bool' },
            artDropShadow: { name: 'Art - Drop Shadow', defaultValue: true, type: 'bool' },

            logoImageResolution: { name: 'Logo - Image Resolution', defaultValue: 0, values: ['Native', 'Scaled'], type: 'array' },
            logoImageCaching: { name: 'Logo - Image Caching', defaultValue: false, type: 'bool' },
            logoImageSmoothing: { name: 'Logo - Image Smoothing', defaultValue: true, type: 'bool' },
            logoDropShadow: { name: 'Logo - Drop Shadow', defaultValue: false, type: 'bool' }
        }
    };

    return metadata;
}

const metadata = createMetadata();