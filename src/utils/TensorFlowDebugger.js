/**
 * TensorFlow Lite Debugging Utility
 * Helps identify and debug model output formats
 */

class TensorFlowDebugger {
	/**
	 * Analyze and log detailed information about model output
	 * @param {any} output - Raw model output to analyze
	 * @param {string} label - Label for this analysis
	 */
	static analyzeOutput(output, label = 'Model Output') {
		console.log(`\n=== ${label.toUpperCase()} ANALYSIS ===`);
		
		// Basic type information
		console.log('Type:', typeof output);
		console.log('Constructor:', output?.constructor?.name);
		console.log('Is Array:', Array.isArray(output));
		console.log('Is null/undefined:', output == null);
		
		if (output == null) {
			console.log('Output is null or undefined');
			return;
		}
		
		// For objects, analyze structure
		if (typeof output === 'object') {
			console.log('Object keys:', Object.keys(output));
			console.log('Object values types:', Object.values(output).map(v => typeof v));
			
			// Check for common properties
			const commonProps = ['data', 'output', 'result', 'predictions', 'values', 'length'];
			commonProps.forEach(prop => {
				if (prop in output) {
					console.log(`Has ${prop}:`, typeof output[prop], Array.isArray(output[prop]));
				}
			});
			
			// Try to stringify
			try {
				const jsonStr = JSON.stringify(output, null, 2);
				if (jsonStr.length < 1000) {
					console.log('JSON representation:', jsonStr);
				} else {
					console.log('JSON representation (truncated):', jsonStr.substring(0, 1000) + '...');
				}
			} catch (error) {
				console.log('Cannot stringify:', error.message);
			}
			
			// Check if it's a typed array
			if (output.constructor && output.constructor.name.includes('Array')) {
				console.log('Typed array detected:', output.constructor.name);
				console.log('Length:', output.length);
				if (output.length <= 10) {
					console.log('Values:', Array.from(output));
				} else {
					console.log('First 10 values:', Array.from(output.slice(0, 10)));
				}
			}
		}
		
		// For arrays, analyze content
		if (Array.isArray(output)) {
			console.log('Array length:', output.length);
			console.log('Element types:', output.map(v => typeof v));
			if (output.length <= 10) {
				console.log('All values:', output);
			} else {
				console.log('First 10 values:', output.slice(0, 10));
			}
		}
		
		// For primitives
		if (typeof output === 'number' || typeof output === 'string' || typeof output === 'boolean') {
			console.log('Value:', output);
		}
		
		console.log(`=== END ${label.toUpperCase()} ANALYSIS ===\n`);
	}
	
	/**
	 * Try different extraction methods and report which ones work
	 * @param {any} output - Raw model output
	 * @returns {Array} Array of successful extraction results
	 */
	static tryExtractionMethods(output) {
		console.log('\n=== TRYING EXTRACTION METHODS ===');
		const results = [];
		
		const methods = [
			{ name: 'Direct use', fn: (o) => o },
			{ name: 'output property', fn: (o) => o.output },
			{ name: 'data property', fn: (o) => o.data },
			{ name: 'result property', fn: (o) => o.result },
			{ name: 'predictions property', fn: (o) => o.predictions },
			{ name: 'values property', fn: (o) => o.values },
			{ name: 'First key', fn: (o) => o[Object.keys(o)[0]] },
			{ name: 'Index 0', fn: (o) => o[0] },
			{ name: 'Object.values', fn: (o) => Object.values(o) },
			{ name: 'Array.from', fn: (o) => Array.from(o) },
			{ name: 'output.data', fn: (o) => o.output?.data },
			{ name: 'data.values', fn: (o) => o.data?.values },
		];
		
		methods.forEach(method => {
			try {
				const result = method.fn(output);
				if (result != null) {
					console.log(`✓ ${method.name}:`, typeof result, Array.isArray(result));
					if (Array.isArray(result) && result.every(v => typeof v === 'number')) {
						console.log(`  → Valid numeric array with ${result.length} elements:`, result);
						results.push({ method: method.name, result });
					}
				}
			} catch (error) {
				console.log(`✗ ${method.name}: ${error.message}`);
			}
		});
		
		console.log('=== END EXTRACTION METHODS ===\n');
		return results;
	}
	
	/**
	 * Test the postprocessResults method with mock data
	 * @param {any} mockOutput - Mock model output to test
	 */
	static testPostprocessing(mockOutput) {
		console.log('\n=== TESTING POSTPROCESSING ===');
		
		try {
			// Import TensorFlowService dynamically to avoid circular imports
			const TensorFlowService = require('../services/TensorFlowService').default;
			const result = TensorFlowService.postprocessResults(mockOutput);
			console.log('✓ Postprocessing successful');
			console.log('Result:', result);
			return result;
		} catch (error) {
			console.log('✗ Postprocessing failed:', error.message);
			console.log('Error stack:', error.stack);
			return null;
		}
	}
	
	/**
	 * Generate test cases for different output formats
	 */
	static generateTestCases() {
		return [
			// Direct array
			[0.8, 0.1, 0.05, 0.05],
			
			// Object with output property
			{ output: [0.8, 0.1, 0.05, 0.05] },
			
			// Object with data property
			{ data: [0.8, 0.1, 0.05, 0.05] },
			
			// Nested structure
			{ output: { data: [0.8, 0.1, 0.05, 0.05] } },
			
			// Float32Array simulation
			{ 0: 0.8, 1: 0.1, 2: 0.05, 3: 0.05, length: 4 },
			
			// Multiple outputs
			{ output_0: [0.8, 0.1, 0.05, 0.05], output_1: [0.2, 0.3, 0.4, 0.1] },
		];
	}
	
	/**
	 * Run comprehensive debugging on all test cases
	 */
	static runFullDebug() {
		console.log('\n🔍 STARTING COMPREHENSIVE TENSORFLOW DEBUG SESSION\n');
		
		const testCases = this.generateTestCases();
		
		testCases.forEach((testCase, index) => {
			console.log(`\n--- TEST CASE ${index + 1} ---`);
			this.analyzeOutput(testCase, `Test Case ${index + 1}`);
			this.tryExtractionMethods(testCase);
			this.testPostprocessing(testCase);
		});
		
		console.log('\n🏁 DEBUG SESSION COMPLETE\n');
	}
}

export default TensorFlowDebugger;
