function createCollectionMetadata(category, parent, collectionType, defaults) {
    const metadata = {};

    if (parent) {
        metadata[parent.key] = { name: parent.name, defaultValue: false, type: 'header' };
    }

    const parentKey = parent && parent.key ? parent.key : undefined;

    const inset = parent ? 1 : 0;
    const prefix = parentKey ?? '';
    const fullPrefix = `settings.${category}.${prefix}`

    if (collectionType == 'collection') {
        metadata[`${prefix}.type`] = {
            name: 'Type',
            defaultValue: defaults[`type`] ?? 0,
            values: [ 'None', 'Recently Played', 'Favorites', /*'Bookmarks',*/ 'Random Games' ],
            type: 'array',
            parent: parentKey, inset: inset
        };
    } else if (collectionType == 'library') {
        metadata[`${prefix}.columns`] = {
            name: 'Number of Columns',
            defaultValue: defaults[`columns`] ?? 1,
            min: 1,
            type: 'int',
            parent: parentKey, inset: inset
        };
    }

    const boxArt = { art: 1, aspectRatioNative: true, aspectRatioWidth: 9.2, aspectRatioHeight: 4.3, logoVisible: false };
    const wide = { art: 0, aspectRatioNative: false, aspectRatioWidth: 9.2, aspectRatioHeight: 4.3, logoVisible: true };
    const tall = { art: 0, aspectRatioNative: false, aspectRatioWidth: 2, aspectRatioHeight: 3, logoVisible: true };
    const square = { art: 0, aspectRatioNative: false, aspectRatioWidth: 1, aspectRatioHeight: 1, logoVisible: true };
    const custom = wide;

    const presets = [ boxArt, wide, tall, square, custom ];

    metadata[`${prefix}.preset`] = {
        name: 'Preset',
        defaultValue: defaults[`preset`] ?? 1,
        values: [ 'Box Art', 'Wide', 'Tall', 'Square', 'Custom' ],
        type: 'array',
        parent: parentKey, inset: inset,
        isEnabled: () => api.memory.get(`${fullPrefix}.type`) !== 0,
        onChanged: (value) => {
            const preset = presets[value];

            api.memory.set(`${fullPrefix}.art`, preset.art);
            api.memory.set(`${fullPrefix}.aspectRatioNative`, preset.aspectRatioNative);
            api.memory.set(`${fullPrefix}.aspectRatioWidth`, preset.aspectRatioWidth);
            api.memory.set(`${fullPrefix}.aspectRatioHeight`, preset.aspectRatioHeight);
            api.memory.set(`${fullPrefix}.logoVisible`, preset.logoVisible);
        }
    };

    const defaultPreset = defaults['preset'] != null ? presets[defaults['preset']] : presets[0];

    metadata[`${prefix}.art`] = {
        name: 'Art',
        defaultValue: defaultPreset.art ?? 0,
        values: ['screenshot', 'boxFront', 'boxBack', 'boxSpine', 'boxFull', 'cartridge', 'marquee', 'bezel', 'panel', 'cabinetLeft', 'cabinetRight', 'tile', 'banner', 'steam', 'poster', 'background', 'titlescreen'],
        type: 'array',
        parent: parentKey, inset: inset,
        isEnabled: () => api.memory.get(`${fullPrefix}.preset`) === 4
    };

    metadata[`${prefix}.aspectRatioNative`] = {
        name: 'Art - Aspect Ratio - Use Native',
        defaultValue: defaultPreset.aspectRatioNative ?? false,
        type: 'bool',
        parent: parentKey, inset: inset,
        isEnabled: () => api.memory.get(`${fullPrefix}.preset`) === 4
    };

    metadata[`${prefix}.aspectRatioWidth`] = {
        name: 'Art - Aspect Ratio - Width',
        defaultValue: defaultPreset.aspectRatioWidth ?? 9.2,
        delta: 0.1, min: 0.1, type: 'real',
        parent: parentKey, inset: inset,
        isEnabled: () => api.memory.get(`${fullPrefix}.preset`) === 4 && !api.memory.get(`${fullPrefix}.aspectRatioNative`)
    };

    metadata[`${prefix}.aspectRatioHeight`] = {
        name: 'Art - Aspect Ratio - Height',
        defaultValue: defaultPreset.aspectRatioHeight ?? 4.3,
        delta: 0.1, min: 0.1, type: 'real',
        parent: parentKey, inset: inset,
        isEnabled: () => api.memory.get(`${fullPrefix}.preset`) === 4 && !api.memory.get(`${fullPrefix}.aspectRatioNative`)
    };

    metadata[`${prefix}.logoVisible`] = {
        name: 'Logo - Visible',
        defaultValue: defaultPreset.logoVisible ?? true,
        type: 'bool',
        parent: parentKey, inset: inset,
        isEnabled: () => api.memory.get(`${fullPrefix}.preset`) === 4
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
        layout: Object.assign(
            createCollectionMetadata('layout', { key: 'collection1', name: 'Collection 1' }, 'collection', { type: 1, preset: 3 }),
            createCollectionMetadata('layout', { key: 'collection2', name: 'Collection 2' }, 'collection', { type: 2, preset: 1 }),
            createCollectionMetadata('layout', { key: 'collection3', name: 'Collection 3' }, 'collection', { type: 3, preset: 0 }),
            createCollectionMetadata('layout', { key: 'collection4', name: 'Collection 4' }, 'collection', { type: 0, preset: 0 }),
            createCollectionMetadata('layout', { key: 'collection5', name: 'Collection 5' }, 'collection', { type: 0, preset: 0 }),
            createCollectionMetadata('layout', { key: 'library', name: 'Library' }, 'library', { columns: 8, preset: 2 }),
        ),
        cardTheme: Object.assign(
            createHeader(
                { key: 'animation', name: 'Animation' },
                {
                    animationEnabled: { name: 'Enabled', defaultValue: true, type: 'bool', },
                    animationArtScaleSpeed: { name: 'Card Scaling - Duration (Milliseconds)', defaultValue: 250, min: 0, delta: 50, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.animationEnabled') },
                    animationArtFadeSpeed: { name: 'Card Fading - Duration (Milliseconds)', defaultValue: 250, min: 0, delta: 50, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.animationEnabled') },
                    logoScaleSpeed: { name: 'Logo Scaling - Duration (Milliseconds)', defaultValue: 250, min: 0, delta: 50, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.animationEnabled'), },
                    logoFadeSpeed: { name: 'Logo Fading - Duration (Milliseconds)', defaultValue: 250, min: 0, delta: 50, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.animationEnabled') },
                }
            ),
            
            createHeader(
                { key: 'border', name: 'Border' },
                {
                    borderEnabled: { name: 'Enabled', defaultValue: true, type: 'bool', },
                    borderAnimated: { name: 'Animated', defaultValue: true, type: 'bool', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.borderEnabled') },
                    borderWidth: { name: 'Width', defaultValue: 3, min: 0, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.borderEnabled') },
                    cornerRadius: { name: 'Corner Radius', defaultValue: 5, min: 0, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.borderEnabled') },
                    borderColor1: { name: 'Color 1', defaultValue: '#FFC85C', type: 'string', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.borderEnabled') },
                    borderColor2: { name: 'Color 2', defaultValue: '#ECECEC', type: 'string', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.borderEnabled') },
                }
            ),
            createHeader(
                { key: 'title', name: 'Card Title' },
                {
                    titleEnabled: { name: 'Enabled', defaultValue: true, type: 'bool', },
                    titleAlwaysVisible: { name: 'Always Visible', defaultValue: true, type: 'bool', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.titleEnabled') },
                    titleFontSize: { name: 'Font Size', defaultValue: 20, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.titleEnabled') }
                }
            ),
            createHeader(
                { key: 'logo', name: 'Logo' },
                { logoFontSize: { name: 'Font Size', defaultValue: 20, min: 1, type: 'int' } }
            ),
            createHeader(
                { key: 'overlay', name: 'Overlay' },
                { darkenAmount: { name: 'Darken', defaultValue: 0.33, delta: 0.01, min: 0.0, max: 1.0, type: 'real', } }
            ),
            createHeader(
                { key: 'scaling', name: 'Scaling' },
                {
                    scaleEnabled: { name: 'Card Scaling - Enabled', defaultValue: true, type: 'bool', },
                    scale: { name: 'Card Scaling - Default', defaultValue: 0.95, delta: 0.01, min: 0, max: 1.0, type: 'real', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.scaleEnabled') },
                    scaleSelected: { name: 'Card Scaling - Selected', defaultValue: 1.0, delta: 0.01, min: 0, type: 'real', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.scaleEnabled') },
                    logoScaleEnabled: { name: 'Logo Scaling - Enabled', defaultValue: true, type: 'bool', },
                    logoScale: { name: 'Logo Scaling - Default', defaultValue: 0.75, delta: 0.01, min: 0.01, type: 'real', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.logoScaleEnabled') },
                    logoScaleSelected: { name: 'Logo Scaling - Selected', defaultValue: 0.85, delta: 0.01, min: 0, type: 'real', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.logoScaleEnabled') },
                }
            ),
            createHeader(
                { key: 'videoPreview', name: 'Video Preview' },
                {
                    previewEnabled: { name: 'Enabled', defaultValue: true, type: 'bool' },
                    previewVolume: { name: 'Volume', defaultValue: 0.0, delta: 0.1, min: 0.0, max: 1.0, type: 'real', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.previewEnabled') },
                    videoPreviewDelay: { name: 'Delay', defaultValue: 1000, min: 0, delta: 50, type: 'int', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.previewEnabled') },
                    previewLogoVisible: { name: 'Logo - Visible', defaultValue: false, type: 'bool', inset: 1, isEnabled: () => api.memory.get('settings.cardTheme.previewEnabled') }
                }
            ),
        ),
        globalTheme: Object.assign(
            createHeader(
                { key: 'background', name: 'Background' },
                {
                    backgroundOpacity: { name: 'Opacity', defaultValue: 0.8, type: 'real', min: 0, max: 1, delta: 0.01 },
                    backgroundBlurEnabled: { name: 'Blur', defaultValue: true, type: 'bool' },
                    backgroundBlurAmount: { name: 'Blur Amount', defaultValue: 64, min: 0, max: 64, inset: 1, type: 'int', isEnabled: () => api.memory.get('settings.globalTheme.backgroundBlurEnabled') },
                }
            ),
            {
                backgroundColor: { name: 'Background Color', defaultValue: '#343434', type: 'string' },
                accentColor: { name: 'Accent Color', defaultValue: '#FFC85C', type: 'string' },
                textColor: { name: 'Text Color', defaultValue: '#ECECEC', type: 'string' },

                leftMargin: { name: 'Screen Padding - Left', defaultValue: 60, min: 0, type: 'int' },
                rightMargin: { name: 'Screen Padding - Right', defaultValue: 60, min: 0, type: 'int' },
            }
        ),
        performance: Object.assign({
            assetDebounceDuration: { name: 'Asset Debounce Duration', defaultValue: 500, min: 0, delta: 50, type: 'real' },

            artImageResolution: { name: 'Art - Image Resolution', defaultValue: 0, values: ['Native', 'Scaled'], type: 'array' },
            artImageCaching: { name: 'Art - Image Caching', defaultValue: false, type: 'bool' },
            artImageSmoothing: { name: 'Art - Image Smoothing', defaultValue: false, type: 'bool' },
            // artDropShadow: { name: 'Art - Drop Shadow', defaultValue: true, type: 'bool' },

            logoImageResolution: { name: 'Logo - Image Resolution', defaultValue: 1, values: ['Native', 'Scaled'], type: 'array' },
            logoImageCaching: { name: 'Logo - Image Caching', defaultValue: false, type: 'bool' },
            logoImageSmoothing: { name: 'Logo - Image Smoothing', defaultValue: true, type: 'bool' },
            // logoDropShadow: { name: 'Logo - Drop Shadow', defaultValue: false, type: 'bool' }
        })
    };

    return metadata;
}

const metadata = createMetadata();