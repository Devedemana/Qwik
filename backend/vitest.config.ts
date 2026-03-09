import { defineConfig } from 'vitest/config'


export default defineConfig({
    test: {
        globals: true,
        testTimeout: 10_000,// after 10 seconds
        globalSetup: ['./tests/setup/globalSetup.ts'],
        // Automatically clean up after each test to ensure isolation
        clearMocks: true,
        restoreMocks: true,
        // Ensure tests run sequentially to avoid database conflicts
        pool: 'threads',
        coverage: {
            provider: "v8",
            enabled:true
        }
    },
    plugins: [],

});