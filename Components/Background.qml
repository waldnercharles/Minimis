import QtQuick 2.15
import QtGraphicalEffects 1.0

Item {
    property alias source: crossfade.source
    property bool showBackgroundImage: true

    ImageCrossfade {
        id: crossfade
        anchors.fill: parent

        opacity: showBackgroundImage ? api.memory.get('settings.global.backgroundOpacity') : 0
        Behavior on opacity { NumberAnimation { duration: 500 } }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: RadialGradient {
                width: crossfade.width
                height: crossfade.height

                gradient: Gradient {
                    GradientStop { position: 0; color: "#ffffffff" }
                    GradientStop { position: 1; color: "#00000000" }
                }
            }

            layer.enabled: api.memory.get('settings.global.backgroundBlurEnabled')
            layer.effect: FastBlur { radius: api.memory.get('settings.global.backgroundBlurAmount') }
        }
    }

    ShaderEffect {
        anchors.fill: parent

        fragmentShader: "
            #ifdef GL_ES
            precision highp float;
            #endif

            uniform float qt_Opacity;
            varying vec2 qt_TexCoord0;

            const float NOISE_GRANULARITY = 0.5 / 255.0;
            const float DARKEN = 2.5;

            float random(vec2 seed) {
                return fract(sin(dot(seed, vec2(12.9898, 78.233))) * 43758.5453);
            }

            void main() {
                vec2 uv = qt_TexCoord0;

                vec3 color1 = vec3(54, 66, 84);
                vec3 color2 = vec3(113, 135, 153);
                vec3 color3 = vec3(54, 66, 84);
                vec3 color4 = vec3(91, 114, 135);
                
                float opacity = distance(vec2(0.5), uv.xy) * 1.5;
                vec3 color = mix(mix(color2, color1, uv.y), mix(color3, color4, uv.y), uv.x) / (255.0 * DARKEN);
                float noise = mix(-NOISE_GRANULARITY, NOISE_GRANULARITY, random(uv));

                gl_FragColor = vec4(color + noise, opacity) * qt_Opacity;
            }
        "
    }
    
    Image {
        anchors.fill: parent

        source: '../assets/static.png'
        fillMode: Image.Tile

        smooth: false
        asynchronous: false

        opacity: 0.8
    }
}