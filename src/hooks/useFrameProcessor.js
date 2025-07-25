import { useFrameProcessor } from 'react-native-vision-camera';
import { useResizePlugin } from 'vision-camera-resize-plugin';
import { useSharedValue } from 'react-native-reanimated';
import { useTensorFlowModel } from './useTensorFlowModel';

/**
 * Frame Processor Hook for Real-time Disease Detection
 * Based on official react-native-fast-tflite examples with real image processing
 */
export const useDiseaseFrameProcessor = () => {
	const tensorflowModel = useTensorFlowModel();
	const { resize } = useResizePlugin();
	const detectionResult = useSharedValue(null);

	const frameProcessor = useFrameProcessor(
		(frame) => {
			'worklet';

			// Only process if model is loaded
			if (!tensorflowModel.isLoaded || !tensorflowModel.model) {
				console.log('⚠️ Model not ready for frame processing');
				return;
			}

			try {
				console.log('🎥 Processing real camera frame');
				console.log('📊 Frame size:', frame.width + 'x' + frame.height);

				// STEP 1: Resize frame to match Python model input (128x128x3)
				// This is the KEY part - processing REAL image data!
				const resized = resize(frame, {
					scale: {
						width: 128, // Match Python model exactly
						height: 128, // Match Python model exactly
					},
					pixelFormat: 'rgb', // RGB format (3 channels)
					dataType: 'uint8', // UInt8 data type (0-255)
				});

				console.log('✅ Frame resized to 128x128x3');
				console.log('📊 Resized frame type:', typeof resized);
				console.log('📊 Resized frame length:', resized.length);

				// STEP 2: Run TensorFlow inference with REAL image data
				const result = tensorflowModel.analyzeImageFromFrame(resized);

				if (result.success) {
					console.log(
						'🎯 Real-time prediction:',
						result.data.prediction.className,
					);
					console.log(
						'📊 Confidence:',
						(result.data.prediction.confidence * 100).toFixed(1) + '%',
					);

					// Update shared value for UI
					detectionResult.value = result.data;
				} else {
					console.log('❌ Frame analysis failed:', result.error);
					detectionResult.value = null;
				}
			} catch (error) {
				console.error('❌ Frame processing error:', error);
				detectionResult.value = null;
			}
		},
		[tensorflowModel.isLoaded, tensorflowModel.model, resize], // Dependencies
	);

	return {
		frameProcessor,
		detectionResult,
		isModelLoaded: tensorflowModel.isLoaded,
		modelError: tensorflowModel.errorMessage,
		modelState: tensorflowModel.getModelInfo().state,
	};
};

export default useDiseaseFrameProcessor;
