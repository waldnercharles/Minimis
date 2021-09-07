const metadata = {
    global: {
        videoPreview: { name: 'Video Preview', defaultValue: false, type: 'header' },
        previewEnabled: {
            name: 'Enabled', defaultValue: true, type: 'bool',
            parent: 'videoPreview', inset: 1,
        },
        previewVolume: {
            name: 'Volume', defaultValue: 0.5, delta: 0.1, min: 0.0, max: 1.0, type: 'real',
            parent: 'videoPreview', inset: 2,
            isEnabled: () => api.memory.get('settings.global.previewEnabled')
        },
        videoPreviewDelay: {
            name: 'Delay', defaultValue: 1000, min: 0, delta: 50, type: 'int',
            parent: 'videoPreview', inset: 2,
            isEnabled: () => api.memory.get('settings.global.previewEnabled')
        },
        previewLogoVisible: {
            name: 'Logo - Visible', defaultValue: true, type: 'bool',
            parent: 'videoPreview', inset: 2,
            isEnabled: () => api.memory.get('settings.global.previewEnabled')
        },

        title: { name: 'Title', defaultValue: false, type: 'header' },
        titleEnabled: {
            name: 'Enabled', defaultValue: true, type: 'bool',
            parent: 'title', inset: 1,
        },
        titleAlwaysVisible: {
            name: 'Always Visible', defaultValue: true, type: 'bool',
            parent: 'title', inset: 2,
            isEnabled: () => api.memory.get('settings.global.titleEnabled')
        },
        titleFontSize: {
            name: 'Font Size', defaultValue: 16, type: 'int',
            parent: 'title', inset: 2,
            isEnabled: () => api.memory.get('settings.global.titleEnabled')
        },
        titleBackgroundOpacity: {
            name: 'Background Opacity', defaultValue: 0.05, delta: 0.01, min: 0.0, max: 1.0, type: 'real',
            parent: 'title', inset: 2,
            isEnabled: () => api.memory.get('settings.global.titleEnabled')
        },

        scaling: { name: 'Scaling', defaultValue: false, type: 'header' },
        scaleEnabled: {
            name: 'Card Scaling - Enabled', defaultValue: true, type: 'bool',
            parent: 'scaling', inset: 1,
        },
        scale: {
            name: 'Card Scaling - Default', defaultValue: 0.95, delta: 0.01, min: 0, max: 1.0, type: 'real',
            parent: 'scaling', inset: 2,
            isEnabled: () => api.memory.get('settings.global.scaleEnabled')
        },
        scaleSelected: {
            name: 'Card Scaling - Selected', defaultValue: 1.0, delta: 0.01, min: 0, type: 'real',
            parent: 'scaling', inset: 2,
            isEnabled: () => api.memory.get('settings.global.scaleEnabled')
        },
        logoScaleEnabled: {
            name: 'Logo Scaling - Enabled', defaultValue: true, type: 'bool',
            parent: 'scaling', inset: 1,
        },
        logoScale: {
            name: 'Logo Scaling - Default', defaultValue: 0.75, delta: 0.01, min: 0.01, type: 'real',
            parent: 'scaling', inset: 2,
        },
        logoScaleSelected: {
            name: 'Logo Scaling - Selected', defaultValue: 0.75, delta: 0.01, min: 0, type: 'real',
            parent: 'scaling', inset: 2,
        },

        animation: { name: 'Animation', defaultValue: false, type: 'header' },
        animationEnabled: {
            name: 'Enabled', defaultValue: true, type: 'bool',
            parent: 'animation', inset: 1
        },
        animationArtScaleSpeed: {
            name: 'Scale Duration (Milliseconds)', defaultValue: 200, min: 0, delta: 50, type: 'int',
            parent: 'animation', inset: 2,
            isEnabled: () => api.memory.get('settings.global.animationEnabled')
        },
        animationArtFadeSpeed: {
            name: 'Fade Duration (Milliseconds)', defaultValue: 200, min: 0, delta: 50, type: 'int',
            parent: 'animation', inset: 2,
            isEnabled: () => api.memory.get('settings.global.animationEnabled')
        },
        logoScaleSpeed: {
            name: 'Scale Duration (Milliseconds)', defaultValue: 200, min: 0, delta: 50, type: 'int',
            parent: 'animation', inset: 2,
        },
        logoFadeSpeed: {
            name: 'Fade Duration (Milliseconds)', defaultValue: 200, min: 0, delta: 50, type: 'int',
            parent: 'animation', inset: 2,
        },

        border: { name: 'Border', defaultValue: false, type: 'header' },
        borderEnabled: {
            name: 'Enabled', defaultValue: true, type: 'bool',
            parent: 'border', inset: 1
        },
        borderAnimated: {
            name: 'Animated', defaultValue: true, type: 'bool',
            parent: 'border', inset: 2,
            isEnabled: () => api.memory.get('settings.global.borderEnabled')
        },
        borderWidth: {
            name: 'Width', defaultValue: 3, min: 0, type: 'int',
            parent: 'border', inset: 2,
            isEnabled: () => api.memory.get('settings.global.borderEnabled')
        },
        cornerRadius: {
            name: 'Corner Radius', defaultValue: 5, min: 0, type: 'int',
            parent: 'border', inset: 2,
            isEnabled: () => api.memory.get('settings.global.borderEnabled')
        },
        borderColor1: {
            name: 'Color 1', defaultValue: '#FFC85C', type: 'string',
            parent: 'border', inset: 2,
            isEnabled: () => api.memory.get('settings.global.borderEnabled')
        },
        borderColor2: {
            name: 'Color 2', defaultValue: '#ECECEC', type: 'string',
            parent: 'border', inset: 2,
            isEnabled: () => api.memory.get('settings.global.borderEnabled')
        },

        overlay: { name: 'Overlay', defaultValue: false, type: 'header' },
        darkenAmount: {
            name: 'Darken', defaultValue: 0.15, delta: 0.01, min: 0.0, max: 1.0, type: 'real',
            parent: 'overlay', inset: 1
        },

        logo: { name: 'Logo', defaultValue: false, type: 'header' },
        logoFontSize: {
            name: 'Font Size', defaultValue: 20, min: 1, type: 'int',
            parent: 'logo', inset: 1,
        },

        navigation: { name: 'Navigation', defaultValue: false, type: 'header' },
        navigationOpacity: {
            name: 'Background Opacity', defaultValue: 0.8, delta: 0.01, min: 0.0, max: 1.0, type: 'real',
            parent: 'navigation', inset: 1,
        },
        navigationSize: {
            name: 'Size', defaultValue: 160, type: 'int',
            parent: 'navigation', inset: 1,
        },
        navigationPauseDuration: {
            name: 'Pause Duration (Milliseconds)', defaultValue: 400, delta: 50, min: 0, type: 'int',
            parent: 'navigation', inset: 1,
        },
        navigationFadeDuration: {
            name: 'Fade Duration (Milliseconds)', defaultValue: 400, delta: 50, min: 0, type: 'int',
            parent: 'navigation', inset: 1,
        },
        navigationYearIncrement: {
            name: 'Year - Increment', defaultValue: 1, delta: 1, min: 1, type: 'int',
            parent: 'navigation', inset: 1,
        },
        navigationRatingIncrement: {
            name: 'Rating - Increment', defaultValue: 0.5, delta: 0.1, min: 0.1, max: 5.0, type: 'real',
            parent: 'navigation', inset: 1,
        },
    },
    gameLibrary: {
        gameViewColumns: { name: 'Number of Columns', defaultValue: 4, type: 'int', min: 1 },

        preset: {
            name: 'Preset',
            defaultValue: 1,
            values: [ 'Box Art', 'Wide', 'Tall', 'Square', 'Custom' ],
            type: 'array',
            onChanged: (value) => {
                switch (value) {
                    case 0: // Box Art
                        api.memory.set('settings.gameLibrary.art', 1);
                        api.memory.set('settings.gameLibrary.aspectRatioNative', true);
                        api.memory.set('settings.gameLibrary.logoVisible', false);
                        break;
                    case 1: // Wide
                    case 4: // Custom
                        api.memory.set('settings.gameLibrary.art', 0);
                        api.memory.set('settings.gameLibrary.aspectRatioNative', false);
                        api.memory.set('settings.gameLibrary.aspectRatioWidth', 9.2);
                        api.memory.set('settings.gameLibrary.aspectRatioHeight', 4.3);
                        api.memory.set('settings.gameLibrary.logoVisible', true);
                        break;
                    case 2: // Tall
                        api.memory.set('settings.gameLibrary.art', 0);
                        api.memory.set('settings.gameLibrary.aspectRatioNative', false);
                        api.memory.set('settings.gameLibrary.aspectRatioWidth', 2);
                        api.memory.set('settings.gameLibrary.aspectRatioHeight', 3);
                        api.memory.set('settings.gameLibrary.logoVisible', true);
                        break;
                    case 3: // Square
                        api.memory.set('settings.gameLibrary.art', 0);
                        api.memory.set('settings.gameLibrary.aspectRatioNative', false);
                        api.memory.set('settings.gameLibrary.aspectRatioWidth', 1);
                        api.memory.set('settings.gameLibrary.aspectRatioHeight', 1);
                        api.memory.set('settings.gameLibrary.logoVisible', true);
                        break;
                }
            },
        },
        art: {
            name: 'Art',
            defaultValue: 0,
            values: ['screenshot', 'boxFront', 'boxBack', 'boxSpine', 'boxFull', 'cartridge', 'marquee', 'bezel', 'panel', 'cabinetLeft', 'cabinetRight', 'tile', 'banner', 'steam', 'poster', 'background', 'titlescreen'],
            type: 'array',
            inset: 1,
            isEnabled: () => api.memory.get('settings.gameLibrary.preset') === 4
        },

        aspectRatioNative: {
            name: 'Art - Aspect Ratio - Use Native', defaultValue: false, type: 'bool',
            inset: 1,
            isEnabled: () => api.memory.get('settings.gameLibrary.preset') === 4
        },
        aspectRatioWidth: {
            name: 'Art - Aspect Ratio - Width', defaultValue: 9.2, delta: 0.1, min: 0.1, type: 'real',
            inset: 1,
            isEnabled: () => api.memory.get('settings.gameLibrary.preset') === 4
        },
        aspectRatioHeight: {
            name: 'Art - Aspect Ratio - Height', defaultValue: 4.3, delta: 0.1, min: 0.1, type: 'real',
            inset: 1,
            isEnabled: () => api.memory.get('settings.gameLibrary.preset') === 4
        },
        logoVisible: {
            name: 'Logo - Visible', defaultValue: true, type: 'bool',
            inset: 1,
            isEnabled: () => api.memory.get('settings.gameLibrary.preset') === 4
        },
    },
    gameDetails: {
        previewEnabled: { name: 'Video Preview - Enabled', defaultValue: true, type: 'bool' },
        previewVolume: { name: 'Video Preview - Volume', defaultValue: 0.0, delta: 0.1, min: 0.0, type: 'real' },
    },
    theme: {
        backgroundColor: { name: 'Background Color', defaultValue: '#13161B', type: 'string' },
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

        logoImageResolution: { name: 'Logo - Image Resolution', defaultValue: 1, values: ['Native', 'Scaled'], type: 'array' },
        logoImageCaching: { name: 'Logo - Image Caching', defaultValue: false, type: 'bool' },
        logoImageSmoothing: { name: 'Logo - Image Smoothing', defaultValue: true, type: 'bool' },
        logoDropShadow: { name: 'Logo - Drop Shadow', defaultValue: false, type: 'bool' }
    }
};