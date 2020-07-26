module re.util.tweens.ease;

static import easings;

public alias EaseFunction = float function(float, float, float, float);

/// ease functions
struct Ease {
    pragma(inline, true) {

        // Linear Easing functions
        static float EaseLinearNone(float t, float b, float c, float d) {
            return easings.EaseLinearNone(t, b, c, d);
        }

        static float EaseLinearIn(float t, float b, float c, float d) {
            return easings.EaseLinearIn(t, b, c, d);
        }

        static float EaseLinearOut(float t, float b, float c, float d) {
            return easings.EaseLinearOut(t, b, c, d);
        }

        static float EaseLinearInOut(float t, float b, float c, float d) {
            return easings.EaseLinearInOut(t, b, c, d);
        }

        // Sine Easing functions
        static float EaseSineIn(float t, float b, float c, float d) {
            return easings.EaseSineIn(t, b, c, d);
        }

        static float EaseSineOut(float t, float b, float c, float d) {
            return easings.EaseSineOut(t, b, c, d);
        }

        static float EaseSineInOut(float t, float b, float c, float d) {
            return easings.EaseSineInOut(t, b, c, d);
        }

        // Circular Easing functions
        static float EaseCircIn(float t, float b, float c, float d) {
            return easings.EaseCircIn(t, b, c, d);
        }

        static float EaseCircOut(float t, float b, float c, float d) {
            return easings.EaseCircOut(t, b, c, d);
        }

        static float EaseCircInOut(float t, float b, float c, float d) {
            return easings.EaseCircInOut(t, b, c, d);
        }

        // Cubic Easing functions
        static float EaseCubicIn(float t, float b, float c, float d) {
            return easings.EaseCubicIn(t, b, c, d);
        }

        static float EaseCubicOut(float t, float b, float c, float d) {
            return easings.EaseCubicOut(t, b, c, d);
        }

        static float EaseCubicInOut(float t, float b, float c, float d) {
            return easings.EaseCubicInOut(t, b, c, d);
        }

        // Quadratic Easing functions
        static float EaseQuadIn(float t, float b, float c, float d) {
            return easings.EaseQuadIn(t, b, c, d);
        }

        static float EaseQuadOut(float t, float b, float c, float d) {
            return easings.EaseQuadOut(t, b, c, d);
        }

        static float EaseQuadInOut(float t, float b, float c, float d) {
            return easings.EaseQuadInOut(t, b, c, d);
        }

        // Exponential Easing functions
        static float EaseExpoIn(float t, float b, float c, float d) {
            return easings.EaseExpoIn(t, b, c, d);
        }

        static float EaseExpoOut(float t, float b, float c, float d) {
            return easings.EaseExpoOut(t, b, c, d);
        }

        static float EaseExpoInOut(float t, float b, float c, float d) {
            return easings.EaseExpoInOut(t, b, c, d);
        }

        // Back Easing functions
        static float EaseBackIn(float t, float b, float c, float d) {
            return easings.EaseBackIn(t, b, c, d);
        }

        static float EaseBackOut(float t, float b, float c, float d) {
            return easings.EaseBackOut(t, b, c, d);
        }

        static float EaseBackInOut(float t, float b, float c, float d) {
            return easings.EaseBackInOut(t, b, c, d);
        }

        // Bounce Easing functions
        static float EaseBounceOut(float t, float b, float c, float d) {
            return easings.EaseBounceOut(t, b, c, d);
        }

        static float EaseBounceIn(float t, float b, float c, float d) {
            return easings.EaseBounceIn(t, b, c, d);
        }

        static float EaseBounceInOut(float t, float b, float c, float d) {
            return easings.EaseBounceInOut(t, b, c, d);
        }

        // Elastic Easing functions
        static float EaseElasticIn(float t, float b, float c, float d) {
            return easings.EaseElasticIn(t, b, c, d);
        }

        static float EaseElasticOut(float t, float b, float c, float d) {
            return easings.EaseElasticOut(t, b, c, d);
        }

        static float EaseElasticInOut(float t, float b, float c, float d) {
            return easings.EaseElasticInOut(t, b, c, d);
        }
    }
}
