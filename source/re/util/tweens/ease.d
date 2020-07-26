module re.util.tweens.ease;

static import easings;

public alias EaseFunction = float function(float, float, float, float);

/// ease functions
struct Ease {
    pragma(inline, true) {

        // Linear Easing functions
        static float LinearNone(float t, float b, float c, float d) {
            return easings.EaseLinearNone(t, b, c, d);
        }

        static float LinearIn(float t, float b, float c, float d) {
            return easings.EaseLinearIn(t, b, c, d);
        }

        static float LinearOut(float t, float b, float c, float d) {
            return easings.EaseLinearOut(t, b, c, d);
        }

        static float LinearInOut(float t, float b, float c, float d) {
            return easings.EaseLinearInOut(t, b, c, d);
        }

        // Sine Easing functions
        static float SineIn(float t, float b, float c, float d) {
            return easings.EaseSineIn(t, b, c, d);
        }

        static float SineOut(float t, float b, float c, float d) {
            return easings.EaseSineOut(t, b, c, d);
        }

        static float SineInOut(float t, float b, float c, float d) {
            return easings.EaseSineInOut(t, b, c, d);
        }

        // Circular Easing functions
        static float CircIn(float t, float b, float c, float d) {
            return easings.EaseCircIn(t, b, c, d);
        }

        static float CircOut(float t, float b, float c, float d) {
            return easings.EaseCircOut(t, b, c, d);
        }

        static float CircInOut(float t, float b, float c, float d) {
            return easings.EaseCircInOut(t, b, c, d);
        }

        // Cubic Easing functions
        static float CubicIn(float t, float b, float c, float d) {
            return easings.EaseCubicIn(t, b, c, d);
        }

        static float CubicOut(float t, float b, float c, float d) {
            return easings.EaseCubicOut(t, b, c, d);
        }

        static float CubicInOut(float t, float b, float c, float d) {
            return easings.EaseCubicInOut(t, b, c, d);
        }

        // Quadratic Easing functions
        static float QuadIn(float t, float b, float c, float d) {
            return easings.EaseQuadIn(t, b, c, d);
        }

        static float QuadOut(float t, float b, float c, float d) {
            return easings.EaseQuadOut(t, b, c, d);
        }

        static float QuadInOut(float t, float b, float c, float d) {
            return easings.EaseQuadInOut(t, b, c, d);
        }

        // Exponential Easing functions
        static float ExpoIn(float t, float b, float c, float d) {
            return easings.EaseExpoIn(t, b, c, d);
        }

        static float ExpoOut(float t, float b, float c, float d) {
            return easings.EaseExpoOut(t, b, c, d);
        }

        static float ExpoInOut(float t, float b, float c, float d) {
            return easings.EaseExpoInOut(t, b, c, d);
        }

        // Back Easing functions
        static float BackIn(float t, float b, float c, float d) {
            return easings.EaseBackIn(t, b, c, d);
        }

        static float BackOut(float t, float b, float c, float d) {
            return easings.EaseBackOut(t, b, c, d);
        }

        static float BackInOut(float t, float b, float c, float d) {
            return easings.EaseBackInOut(t, b, c, d);
        }

        // Bounce Easing functions
        static float BounceOut(float t, float b, float c, float d) {
            return easings.EaseBounceOut(t, b, c, d);
        }

        static float BounceIn(float t, float b, float c, float d) {
            return easings.EaseBounceIn(t, b, c, d);
        }

        static float BounceInOut(float t, float b, float c, float d) {
            return easings.EaseBounceInOut(t, b, c, d);
        }

        // Elastic Easing functions
        static float ElasticIn(float t, float b, float c, float d) {
            return easings.EaseElasticIn(t, b, c, d);
        }

        static float ElasticOut(float t, float b, float c, float d) {
            return easings.EaseElasticOut(t, b, c, d);
        }

        static float ElasticInOut(float t, float b, float c, float d) {
            return easings.EaseElasticInOut(t, b, c, d);
        }
    }
}
